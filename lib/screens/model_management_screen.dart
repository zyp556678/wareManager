import 'package:flutter/material.dart';
import '../services/model_downloader.dart';
import '../services/ai_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/model_download_dialog.dart';

class ModelManagementScreen extends StatefulWidget {
  const ModelManagementScreen({super.key});

  @override
  State<ModelManagementScreen> createState() => _ModelManagementScreenState();
}

class _ModelManagementScreenState extends State<ModelManagementScreen> {
  List<ModelConfig> _installedModels = [];
  String? _activeModelId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModelInfo();
  }

  Future<void> _loadModelInfo() async {
    final installed = await ModelDownloader.getInstalledModels();
    final activeId = await ModelDownloader.getActiveModelId();
    if (mounted) {
      setState(() {
        _installedModels = installed;
        _activeModelId = activeId;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadModel(ModelConfig config) async {
    await ModelDownloadDialog.show(
      context,
      modelConfig: config,
      onDownloadComplete: () => _loadModelInfo(),
    );
  }

  Future<void> _deleteModel(ModelConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除模型'),
        content: Text('确定要删除 "${config.name}" 吗？删除后需要重新下载。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ModelDownloader.deleteModel(config.id);
      await _loadModelInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除 ${config.name}')),
        );
      }
    }
  }

  Future<void> _switchModel(ModelConfig config) async {
    await ModelDownloader.setActiveModel(config.id);
    // 重新加载模型
    final loaded = await AIService.instance.loadModel();
    if (mounted) {
      setState(() => _activeModelId = config.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loaded ? '已切换到 ${config.name}' : '切换失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('模型管理')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 当前模型
                if (_activeModelId != null) ...[
                  _buildSectionHeader('当前模型', cs),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.smart_toy, color: cs.primary, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ModelDownloader.availableModels
                                    .firstWhere((m) => m.id == _activeModelId,
                                        orElse: () => ModelDownloader.availableModels.first)
                                    .name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text('使用中', style: TextStyle(fontSize: 13, color: cs.primary)),
                            ],
                          ),
                        ),
                        Icon(Icons.check_circle, color: cs.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 已安装模型
                _buildSectionHeader('已安装', cs),
                if (_installedModels.isEmpty)
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('暂无已安装的模型', style: TextStyle(color: cs.onSurfaceVariant)),
                    ),
                  )
                else
                  ..._installedModels.map((model) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildModelCard(model, cs, installed: true),
                  )),

                const SizedBox(height: 20),

                // 可下载模型
                _buildSectionHeader('可下载', cs),
                ...ModelDownloader.availableModels
                    .where((m) => !_installedModels.any((i) => i.id == m.id))
                    .map((model) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildModelCard(model, cs, installed: false),
                    )),

                const SizedBox(height: 20),

                // 上下文窗口设置
                _buildSectionHeader('推理设置', cs),
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.memory, color: cs.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('上下文窗口', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '当前: ${AIService.instance.maxTokens} tokens（约${(AIService.instance.maxTokens / 300).floor()}轮对话）',
                        style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      _buildTokenSlider(cs),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 清理全部
                if (_installedModels.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('清理全部模型'),
                          content: const Text('确定要删除所有已安装的模型吗？'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('全部删除'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && mounted) {
                        await ModelDownloader.clearAllRecords();
                        await _loadModelInfo();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已清理全部模型')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    label: const Text('清理全部模型', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 12),
                // 清理废文件
                OutlinedButton.icon(
                  onPressed: () async {
                    final cleaned = await ModelDownloader.cleanOrphanFiles();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(cleaned > 0 ? '已清理 $cleaned 个废文件' : '没有需要清理的废文件')),
                      );
                    }
                  },
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('清理废文件（下载失败/中断）'),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
      ),
    );
  }

  Widget _buildTokenSlider(ColorScheme cs) {
    final currentTokens = AIService.instance.maxTokens;
    // 对应索引: 0=2048, 1=4096, 2=8192, 3=16384
    final options = [2048, 4096, 8192, 16384];
    final labels = ['2K', '4K', '8K', '16K'];
    final currentIndex = options.indexOf(currentTokens).clamp(0, 3);

    return Column(
      children: [
        Slider(
          value: currentIndex.toDouble(),
          min: 0,
          max: 3,
          divisions: 3,
          label: labels[currentIndex],
          onChanged: (value) {
            final newIndex = value.round();
            AIService.instance.setMaxTokens(options[newIndex]);
            setState(() {});
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.asMap().entries.map((entry) {
            final isSelected = entry.key == currentIndex;
            return Text(
              entry.value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModelCard(ModelConfig model, ColorScheme cs, {required bool installed}) {
    final isActive = _activeModelId == model.id;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                installed ? Icons.storage : Icons.cloud_download_outlined,
                color: isActive ? cs.primary : cs.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${model.name} (${model.url.split('.').last.split('?').first})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(model.description, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('${model.sizeGB} GB', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (installed && !isActive)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _switchModel(model),
                    child: const Text('切换'),
                  ),
                ),
              if (installed && isActive)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('当前使用中', style: TextStyle(fontSize: 13, color: cs.primary)),
                    ),
                  ),
                ),
              if (!installed) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadModel(model),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('下载'),
                  ),
                ),
              ],
              if (installed) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteModel(model),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
