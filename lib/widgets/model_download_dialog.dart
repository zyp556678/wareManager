import 'package:flutter/material.dart';
import '../services/model_downloader.dart';
import '../services/ai_service.dart';

class ModelDownloadDialog extends StatefulWidget {
  final VoidCallback? onDownloadComplete;
  final ModelConfig? modelConfig;

  const ModelDownloadDialog({super.key, this.onDownloadComplete, this.modelConfig});

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onDownloadComplete,
    ModelConfig? modelConfig,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModelDownloadDialog(
        onDownloadComplete: onDownloadComplete,
        modelConfig: modelConfig,
      ),
    );
  }

  @override
  State<ModelDownloadDialog> createState() => _ModelDownloadDialogState();
}

class _ModelDownloadDialogState extends State<ModelDownloadDialog> {
  @override
  void initState() {
    super.initState();
    ModelDownloader.downloadingNotifier.addListener(_onStateChange);
    ModelDownloader.progressNotifier.addListener(_onProgressChange);
    ModelDownloader.speedNotifier.addListener(_onStateChange);
    ModelDownloader.errorNotifier.addListener(_onStateChange);
  }

  @override
  void dispose() {
    ModelDownloader.downloadingNotifier.removeListener(_onStateChange);
    ModelDownloader.progressNotifier.removeListener(_onProgressChange);
    ModelDownloader.speedNotifier.removeListener(_onStateChange);
    ModelDownloader.errorNotifier.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _onProgressChange() {
    if (mounted) setState(() {});
  }

  Future<void> _startDownload() async {
    final config = widget.modelConfig ?? ModelDownloader.availableModels.first;
    await ModelDownloader.downloadModel(config);
    if (mounted && ModelDownloader.errorNotifier.value == null) {
      Navigator.pop(context);
      await AIService.instance.loadModel();
      widget.onDownloadComplete?.call();
    }
  }

  void _cancelDownload() {
    ModelDownloader.cancelDownload();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDownloading = ModelDownloader.downloadingNotifier.value;
    final progress = ModelDownloader.progressNotifier.value;
    final error = ModelDownloader.errorNotifier.value;
    final config = widget.modelConfig ?? ModelDownloader.availableModels.first;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.smart_toy, color: cs.primary),
          const SizedBox(width: 8),
          Text('下载 ${config.name}'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(config.description),
          const SizedBox(height: 8),
          Text(
            '模型大小：约 ${config.sizeGB} GB',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          Text(
            '下载后可离线使用',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (isDownloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress > 0 ? progress / 100 : null,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progress > 0 ? '下载中 ${progress.toStringAsFixed(0)}%' : '准备下载...',
                  style: TextStyle(fontSize: 13, color: cs.primary),
                ),
                if (ModelDownloader.speedNotifier.value.isNotEmpty)
                  Text(
                    ModelDownloader.speedNotifier.value,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18, color: cs.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '下载失败，请检查网络后重试',
                      style: TextStyle(fontSize: 13, color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (isDownloading)
          TextButton(
            onPressed: _cancelDownload,
            child: Text('取消下载', style: TextStyle(color: cs.error)),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.download),
            label: const Text('开始下载'),
          ),
        ],
      ],
    );
  }
}
