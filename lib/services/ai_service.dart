import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/clothing_item.dart';
import 'database_helper.dart';
import 'model_downloader.dart';

class AIService {
  static final AIService instance = AIService._init();
  AIService._init();

  dynamic _model; // Model instance
  dynamic _chat; // Chat session
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isModelLoaded = false;
  bool _isFirstMessage = true; // 是否是当前会话的第一条消息
  bool _shouldStop = false; // 是否应该停止生成
  int _maxTokens = 4096; // 默认上下文窗口
  bool _contextInjected = false; // 上下文是否已注入
  final List<ChatMessage> _messageHistory = [];

  bool get isLoading => _isLoading;
  bool get isModelLoaded => _isModelLoaded;
  int get maxTokens => _maxTokens;

  /// 设置上下文窗口大小
  void setMaxTokens(int value) {
    _maxTokens = value;
    _chat = null; // 需要重建 chat
    debugPrint('AIService: maxTokens 设为 $value');
  }

  /// 停止当前生成
  void stopGeneration() {
    _shouldStop = true;
    debugPrint('AIService: 用户请求停止生成');
  }
  String? get currentSessionId => _currentSessionId;

  /// 初始化并加载模型
  Future<bool> loadModel() async {
    try {
      debugPrint('AIService: 开始检查模型...');
      final activeId = await ModelDownloader.getActiveModelId();
      if (activeId == null) {
        debugPrint('AIService: 没有激活的模型');
        return false;
      }
      final installed = await ModelDownloader.isModelInstalled(activeId);
      debugPrint('AIService: 模型安装状态: $installed');
      if (!installed) {
        debugPrint('AIService: 模型未安装');
        return false;
      }

      debugPrint('AIService: 正在加载模型...');
      _model = await FlutterGemma.getActiveModel(
        maxTokens: _maxTokens,
        preferredBackend: PreferredBackend.gpu,
        supportImage: true,
      );
      _isModelLoaded = true;
      debugPrint('AIService: 模型加载成功');
      return true;
    } catch (e, stackTrace) {
      debugPrint('AIService: 模型加载失败: $e');
      debugPrint('AIService: 堆栈: $stackTrace');
      _isModelLoaded = false;
      return false;
    }
  }

  /// 创建新会话
  Future<String> createSession({String title = '新对话'}) async {
    final id = const Uuid().v4();
    await DatabaseHelper.instance.createChatSession(id, title);
    _currentSessionId = id;
    _chat = null;
    _contextInjected = false;
    _isFirstMessage = true;
    _messageHistory.clear();
    return id;
  }

  /// 加载已有会话
  Future<void> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    _chat = null;
    _contextInjected = false;
    _isFirstMessage = false; // 历史会话不需要重命名
    // 加载历史消息
    _messageHistory.clear();
    _messageHistory.addAll(await loadMessages(sessionId));
  }

  /// 发送消息并获取回复
  Future<ChatMessage?> sendMessage({
    required String text,
    String? imagePath,
    ClothingItem? referencedClothing,
    List<Map<String, String>>? contextMessages,
  }) async {
    if (!_isModelLoaded || _model == null) {
      throw Exception('模型未加载');
    }
    if (_currentSessionId == null) {
      throw Exception('未创建会话');
    }

    _isLoading = true;

    try {
      // 保存用户消息
      final userMsg = ChatMessage(
        id: const Uuid().v4(),
        role: 'user',
        text: text,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      );
      await _saveMessage(userMsg);

      // 创建或重建 chat
      _chat ??= await _model.createChat();

      // 构建上下文
      if (contextMessages != null) {
        for (final msg in contextMessages) {
          final isUser = msg['role'] == 'user';
          await _chat.addQueryChunk(Message.text(
            text: msg['content'] ?? '',
            isUser: isUser,
          ));
        }
      }

      // 构建用户消息
      var userContent = text;
      if (referencedClothing != null) {
        userContent += '\n\n[引用衣物] 类别：${referencedClothing.category}，'
            '颜色：${referencedClothing.color}，'
            '材质：${referencedClothing.material}，'
            '风格：${referencedClothing.style}';
        if (referencedClothing.season.isNotEmpty) {
          userContent += '，季节：${referencedClothing.season}';
        }
      }

      // 如果有图片，发送多模态消息
      if (imagePath != null && await File(imagePath).exists()) {
        await _chat.addQueryChunk(Message.withImage(
          text: userContent,
          imageBytes: await File(imagePath).readAsBytes(),
          isUser: true,
        ));
      } else {
        await _chat.addQueryChunk(Message.text(
          text: userContent,
          isUser: true,
        ));
      }

      // 获取回复
      final response = await _chat.generateChatResponse();
      final responseText = response.toString();

      // 保存 AI 回复
      final aiMsg = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        text: responseText,
        timestamp: DateTime.now(),
      );
      await _saveMessage(aiMsg);

      // 更新会话最后消息时间
      await DatabaseHelper.instance.updateSessionLastMessage(_currentSessionId!);

      _isLoading = false;
      return aiMsg;
    } catch (e) {
      debugPrint('AIService: 发送消息失败: $e');
      _isLoading = false;
      rethrow;
    }
  }

  /// 流式发送消息，返回 token 流
  Stream<String> sendMessageStream({
    required String text,
    String? imagePath,
    ClothingItem? referencedClothing,
    List<Map<String, String>>? contextMessages,
  }) async* {
    if (!_isModelLoaded || _model == null) {
      throw Exception('模型未加载');
    }
    if (_currentSessionId == null) {
      throw Exception('未创建会话');
    }

    _isLoading = true;

    try {
      // 保存用户消息
      final userMsg = ChatMessage(
        id: const Uuid().v4(),
        role: 'user',
        text: text,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      );
      await _saveMessage(userMsg);

      // 第一条消息自动命名会话
      if (_isFirstMessage && text.isNotEmpty) {
        _isFirstMessage = false;
        final title = text.length > 15 ? '${text.substring(0, 15)}...' : text;
        await DatabaseHelper.instance.updateSessionTitle(_currentSessionId!, title);
      }

      // 创建或重建 chat
      if (_chat == null) {
        debugPrint('AIService: 创建新 chat...');
        try {
          _chat = await _model.createChat();
          _contextInjected = false;
          debugPrint('AIService: chat 创建成功');
        } catch (e) {
          debugPrint('AIService: chat 创建失败: $e');
          rethrow;
        }
      }

      // 只在第一次注入上下文（系统提示 + 衣物摘要 + 历史消息）
      if (!_contextInjected) {
        _contextInjected = true;

        // 注入系统提示 + 衣物摘要
        if (contextMessages != null) {
          for (final msg in contextMessages) {
            await _chat.addQueryChunk(Message.text(
              text: msg['content'] ?? '',
              isUser: msg['role'] == 'user',
            ));
          }
        }

        // 注入历史消息
        if (_messageHistory.isNotEmpty) {
          for (final msg in _messageHistory) {
            if (msg.text != null && msg.text!.isNotEmpty) {
              await _chat.addQueryChunk(Message.text(
                text: msg.text!,
                isUser: msg.role == 'user',
              ));
            }
          }
          _messageHistory.clear();
        }

        debugPrint('AIService: 上下文已注入');
      }

      // 构建用户消息
      var userContent = text;
      if (referencedClothing != null) {
        userContent += '\n\n[引用衣物] 类别：${referencedClothing.category}，'
            '颜色：${referencedClothing.color}，'
            '材质：${referencedClothing.material}，'
            '风格：${referencedClothing.style}';
        if (referencedClothing.season.isNotEmpty) {
          userContent += '，季节：${referencedClothing.season}';
        }
      }

      // 确定要发送的图片
      Uint8List? imageBytes;
      if (imagePath != null && await File(imagePath).exists()) {
        // 用户上传的图片优先
        imageBytes = await File(imagePath).readAsBytes();
      } else if (referencedClothing != null &&
          await File(referencedClothing.imagePath).exists()) {
        // 引用衣物时，自动发送衣物照片
        imageBytes = await File(referencedClothing.imagePath).readAsBytes();
      }

      // 发送消息（文字 + 可选图片）
      debugPrint('AIService: 添加用户消息，含图片: ${imageBytes != null}');
      if (imageBytes != null) {
        await _chat.addQueryChunk(Message.withImage(
          text: userContent,
          imageBytes: imageBytes,
          isUser: true,
        ));
      } else {
        await _chat.addQueryChunk(Message.text(
          text: userContent,
          isUser: true,
        ));
      }
      debugPrint('AIService: 用户消息添加成功，开始流式生成...');
      _shouldStop = false;

      // 流式获取回复
      final stream = _chat.generateChatResponseAsync();
      await for (final response in stream) {
        // 检查是否需要停止
        if (_shouldStop) {
          debugPrint('AIService: 用户停止生成');
          break;
        }
        if (response is TextResponse) {
          final tokenText = response.token;
          if (tokenText.isNotEmpty) {
            yield tokenText;
          }
        }
      }

      _isLoading = false;
    } catch (e) {
      debugPrint('AIService: 流式发送失败: $e');
      _isLoading = false;
      rethrow;
    }
  }

  /// 保存完整 AI 回复到数据库
  Future<void> saveAssistantMessage(String fullText) async {
    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      text: fullText,
      timestamp: DateTime.now(),
    );
    await _saveMessage(aiMsg);
    _messageHistory.add(aiMsg); // 追加到历史记录
    if (_currentSessionId != null) {
      await DatabaseHelper.instance.updateSessionLastMessage(_currentSessionId!);
    }
  }

  /// 保存消息到数据库
  Future<void> _saveMessage(ChatMessage message) async {
    await DatabaseHelper.instance.insertChatMessage({
      ...message.toMap(),
      'sessionId': _currentSessionId,
    });
  }

  /// 加载会话历史消息
  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    final maps = await DatabaseHelper.instance.getChatMessages(sessionId);
    return maps.map((m) => ChatMessage.fromMap(m)).toList();
  }

  /// 加载所有会话
  Future<List<ChatSession>> loadSessions() async {
    final maps = await DatabaseHelper.instance.getChatSessions();
    return maps.map((m) => ChatSession.fromMap(m)).toList();
  }

  /// 删除会话
  Future<void> deleteSession(String sessionId) async {
    await DatabaseHelper.instance.deleteChatSession(sessionId);
    if (_currentSessionId == sessionId) {
      _currentSessionId = null;
      _chat = null;
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      await _model?.close();
    } catch (_) {}
    _model = null;
    _chat = null;
    _isModelLoaded = false;
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdDate;
  final DateTime lastMessageDate;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdDate,
    required this.lastMessageDate,
  });

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'],
      title: map['title'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
      lastMessageDate: DateTime.fromMillisecondsSinceEpoch(map['lastMessageDate']),
    );
  }
}
