import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_message.dart';
import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';
import '../providers/theme_provider.dart';
import '../services/ai_service.dart';
import '../services/ai_context_builder.dart';
import '../services/model_downloader.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/glass_card.dart';
import '../widgets/model_download_dialog.dart';
import 'clothing_detail_page.dart';
import 'model_management_screen.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService.instance;

  bool _isLoading = false;
  bool _isModelReady = false;
  bool _isCheckingModel = true;
  String? _sessionId;
  String? _pendingImagePath;
  ClothingItem? _referencedClothing;

  @override
  void initState() {
    super.initState();
    _checkModel();
  }

  Future<void> _checkModel() async {
    // 检查是否有已安装的模型
    final installed = await ModelDownloader.getInstalledModels();
    debugPrint('AiChatScreen: 已安装模型: ${installed.map((m) => m.id).toList()}');

    if (installed.isNotEmpty) {
      // 有已安装的模型，确保激活
      final activeId = await ModelDownloader.getActiveModelId();
      if (activeId == null || !installed.any((m) => m.id == activeId)) {
        await ModelDownloader.setActiveModel(installed.first.id);
      }
      final loaded = await _aiService.loadModel();
      if (!loaded && mounted) {
        // 加载失败，可能是文件损坏，自动删除
        debugPrint('AiChatScreen: 模型加载失败，删除损坏文件');
        final currentActive = await ModelDownloader.getActiveModelId();
        if (currentActive != null) {
          await ModelDownloader.deleteModel(currentActive);
        }
      }
      if (mounted) {
        setState(() {
          _isModelReady = loaded;
          _isCheckingModel = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isCheckingModel = false);
      }
    }
  }

  Future<void> _showDownloadDialog() async {
    await ModelDownloadDialog.show(
      context,
      modelConfig: ModelDownloader.availableModels.first,
      onDownloadComplete: () {
        if (mounted) setState(() => _isModelReady = true);
      },
    );
  }

  Future<void> _ensureSession() async {
    _sessionId ??= await _aiService.createSession();
  }

  void _stopGeneration() {
    _aiService.stopGeneration();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty && _pendingImagePath == null) return;
    if (!_isModelReady) {
      await _showDownloadDialog();
      return;
    }

    await _ensureSession();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      text: text.isNotEmpty ? text : null,
      imagePath: _pendingImagePath,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _inputController.clear();
      _pendingImagePath = null;
    });
    _scrollToBottom();

    try {
      final contextBuilder = AIContextBuilder(context.read<ClothingProvider>());
      final contextMessages = contextBuilder.buildContext(
        history: _messages.length > 1
            ? _messages
                .sublist(0, _messages.length - 1)
                .map((m) => {'role': m.role, 'content': m.text ?? ''})
                .toList()
            : null,
      );

      // 插入空的 AI 消息占位
      final aiMsgId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _messages.add(ChatMessage(
          id: aiMsgId,
          role: 'assistant',
          text: '',
          timestamp: DateTime.now(),
        ));
      });

      // 流式接收 token
      final buffer = StringBuffer();
      final stream = _aiService.sendMessageStream(
        text: text,
        imagePath: userMsg.imagePath,
        referencedClothing: _referencedClothing,
        contextMessages: contextMessages,
      );

      await for (final token in stream) {
        buffer.write(token);
        if (mounted) {
          setState(() {
            // 更新最后一条 AI 消息的文本
            _messages.last = ChatMessage(
              id: aiMsgId,
              role: 'assistant',
              text: buffer.toString(),
              timestamp: _messages.last.timestamp,
            );
          });
          _scrollToBottom();
        }
      }

      // 流结束，保存完整消息到数据库
      await _aiService.saveAssistantMessage(buffer.toString());
      if (mounted) {
        setState(() => _referencedClothing = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: 'assistant',
            text: '抱歉，发生了错误：$e',
            timestamp: DateTime.now(),
          ));
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showSessionHistory() async {
    final sessions = await _aiService.loadSessions();
    if (!mounted || sessions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('暂无历史对话')),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        builder: (ctx, scrollController) => GlassCard(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text('历史对话', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: sessions.length,
                  itemBuilder: (ctx, index) {
                    final session = sessions[index];
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        _formatDate(session.lastMessageDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          final isCurrentSession = _sessionId == session.id;
                          await _aiService.deleteSession(session.id);
                          if (isCurrentSession && mounted) {
                            setState(() {
                              _messages.clear();
                              _sessionId = null;
                            });
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已删除')),
                            );
                          }
                        },
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _loadSession(session.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return '今天 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.month}/${date.day}';
  }

  Future<void> _loadSession(String sessionId) async {
    final messages = await _aiService.loadMessages(sessionId);
    setState(() {
      _sessionId = sessionId;
      _messages.clear();
      _messages.addAll(messages);
    });
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null && mounted) {
      setState(() => _pendingImagePath = picked.path);
    }
  }

  void _showClothingPicker() {
    final clothingProvider = context.read<ClothingProvider>();
    final allItems = [
      ...clothingProvider.activeClothing,
      ...clothingProvider.idleClothing,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        builder: (ctx, scrollController) => GlassCard(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text('选择引用衣物', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: allItems.isEmpty
                    ? const Center(child: Text('衣橱为空'))
                    : GridView.builder(
                        controller: scrollController,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: allItems.length,
                        itemBuilder: (ctx, index) {
                          final item = allItems[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() => _referencedClothing = item);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(item.imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.checkroom),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tp = context.watch<ThemeProvider>();
    final bgColor = tp.backgroundEnabled
        ? cs.surface.withValues(alpha: tp.backgroundOpacity)
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('AI 搭配助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: '模型管理',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModelManagementScreen()),
              );
              // 返回后重新检测模型
              _checkModel();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '历史对话',
            onPressed: _showSessionHistory,
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: '新对话',
            onPressed: () {
              setState(() {
                _messages.clear();
                _sessionId = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: _isCheckingModel
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text('正在检测模型...', style: TextStyle(color: cs.onSurfaceVariant)),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 64, color: cs.primary.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text(
                                _isModelReady ? '开始和 AI 聊聊穿搭吧' : '开始和 AI 聊聊穿搭吧',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                              if (!_isModelReady) ...[
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _showDownloadDialog,
                                  icon: const Icon(Icons.download),
                                  label: const Text('下载 AI 模型'),
                                ),
                              ],
                            ],
                          ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        // 加载动画
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                                ),
                                const SizedBox(width: 8),
                                Text('思考中...', style: TextStyle(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        );
                      }
                      return ChatBubble(
                        message: _messages[index],
                        onClothingTap: (clothing) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ClothingDetailPage(item: clothing),
                          ));
                        },
                      );
                    },
                  ),
          ),
          // 引用衣物预览
          if (_referencedClothing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: cs.surfaceContainerLow,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(_referencedClothing!.imagePath),
                      width: 36, height: 36, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(Icons.checkroom, size: 20, color: cs.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_referencedClothing!.category} · ${_referencedClothing!.color}',
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                    onPressed: () => setState(() => _referencedClothing = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          // 图片预览
          if (_pendingImagePath != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: cs.surfaceContainerLow,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(_pendingImagePath!),
                      width: 36, height: 36, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('已选择图片', style: TextStyle(fontSize: 13))),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                    onPressed: () => setState(() => _pendingImagePath = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          // 输入区域
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 90),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt_outlined, color: cs.onSurfaceVariant),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon: Icon(Icons.photo_outlined, color: cs.onSurfaceVariant),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                IconButton(
                  icon: Icon(Icons.checkroom_outlined, color: cs.onSurfaceVariant),
                  onPressed: _showClothingPicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: '聊聊穿搭...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _isLoading
                      ? const Icon(Icons.stop, color: Colors.white)
                      : const Icon(Icons.send),
                  onPressed: _isLoading ? _stopGeneration : _sendMessage,
                  style: _isLoading
                      ? IconButton.styleFrom(backgroundColor: Colors.red)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
