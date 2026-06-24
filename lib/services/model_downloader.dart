import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// 可用模型配置
class ModelConfig {
  final String id;
  final String name;
  final String description;
  final String url;
  final ModelFileType fileType;
  final double sizeGB;

  const ModelConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.fileType,
    required this.sizeGB,
  });
}

class ModelDownloader {
  static const _prefActiveModelId = 'ai_active_model_id';

  /// 可用模型列表（可扩展）
  static const List<ModelConfig> availableModels = [
    ModelConfig(
      id: 'gemma-4-E2B-it.litertlm',
      name: 'Gemma 4 E2B',
      description: '2B 参数，LiteRT 引擎，支持文字推理',
      url: 'https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm?download=true',
      fileType: ModelFileType.litertlm,
      sizeGB: 2.5,
    ),
  ];

  // 下载状态管理
  static final ValueNotifier<double> progressNotifier = ValueNotifier(0);
  static final ValueNotifier<bool> downloadingNotifier = ValueNotifier(false);
  static final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  static final ValueNotifier<String> speedNotifier = ValueNotifier('');

  static CancelToken? _cancelToken;
  static DateTime? _downloadStartTime;
  static DateTime? _lastProgressTime;

  /// 获取当前激活的模型 ID
  static Future<String?> getActiveModelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefActiveModelId);
  }

  /// 设置激活的模型
  static Future<void> setActiveModel(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefActiveModelId, modelId);
  }

  /// 检查指定模型是否已安装
  static Future<bool> isModelInstalled(String modelId) async {
    try {
      final installedIds = await FlutterGemma.listInstalledModels();
      debugPrint('ModelDownloader: 已安装模型列表: $installedIds');
      return installedIds.contains(modelId);
    } catch (e) {
      debugPrint('ModelDownloader: 检查模型失败: $e');
      return false;
    }
  }

  /// 检查是否有任何模型已安装
  static Future<bool> hasAnyModel() async {
    try {
      final installedIds = await FlutterGemma.listInstalledModels();
      return installedIds.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 获取已安装的模型列表
  static Future<List<ModelConfig>> getInstalledModels() async {
    try {
      final installedIds = await FlutterGemma.listInstalledModels();
      debugPrint('ModelDownloader: 已安装模型ID: $installedIds');
      return availableModels
          .where((m) => installedIds.contains(m.id))
          .toList();
    } catch (e) {
      debugPrint('ModelDownloader: 获取已安装列表失败: $e');
      return [];
    }
  }

  /// 下载指定模型
  static Future<void> downloadModel(ModelConfig config) async {
    if (downloadingNotifier.value) return;

    downloadingNotifier.value = true;
    errorNotifier.value = null;
    progressNotifier.value = 0;
    speedNotifier.value = '';
    _cancelToken = CancelToken();
    _downloadStartTime = DateTime.now();
    _lastProgressTime = _downloadStartTime;

    try {
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: config.fileType,
      )
          .fromNetwork(config.url)
          .withCancelToken(_cancelToken!)
          .withProgress((progress) {
            final now = DateTime.now();
            final currentProgress = progress.toDouble();
            progressNotifier.value = currentProgress;

            // 计算速度和剩余时间
            if (_lastProgressTime != null) {
              final elapsed = now.difference(_lastProgressTime!).inMilliseconds / 1000;
              if (elapsed > 0.5) {
                final totalElapsed = now.difference(_downloadStartTime!).inMilliseconds / 1000;
                final avgSpeed = currentProgress / totalElapsed; // %/秒
                final remaining = (100 - currentProgress) / avgSpeed;

                speedNotifier.value = _formatSpeed(avgSpeed, config.sizeGB, remaining);
                _lastProgressTime = now;
              }
            }
          })
          .install();

      // 设置为激活模型
      await setActiveModel(config.id);

      debugPrint('ModelDownloader: 模型 ${config.name} 安装完成');
    } catch (e) {
      debugPrint('ModelDownloader: 模型安装失败: $e');
      errorNotifier.value = e.toString();
    } finally {
      downloadingNotifier.value = false;
      _cancelToken = null;
    }
  }

  /// 删除指定模型
  static Future<void> deleteModel(String modelId) async {
    try {
      await FlutterGemma.uninstallModel(modelId);
      debugPrint('ModelDownloader: 已删除模型 $modelId');
    } catch (e) {
      debugPrint('ModelDownloader: 删除模型失败: $e');
    }
    // 如果删除的是当前激活模型，清除激活状态
    final activeId = await getActiveModelId();
    if (activeId == modelId) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefActiveModelId);
    }
  }

  /// 取消下载
  static void cancelDownload() {
    _cancelToken?.cancel('用户取消下载');
    _cancelToken = null;
    downloadingNotifier.value = false;
    errorNotifier.value = null;
    speedNotifier.value = '';
  }

  /// 格式化下载速度和剩余时间
  static String _formatSpeed(double percentPerSec, double sizeGB, double remainingSec) {
    if (percentPerSec <= 0) return '';

    // 计算实际下载速度 (MB/s)
    final totalMB = sizeGB * 1024;
    final mbPerSec = totalMB * percentPerSec / 100;

    // 格式化速度
    String speedText;
    if (mbPerSec >= 1) {
      speedText = '${mbPerSec.toStringAsFixed(1)} MB/s';
    } else {
      speedText = '${(mbPerSec * 1024).toStringAsFixed(0)} KB/s';
    }

    // 格式化剩余时间
    if (remainingSec.isFinite && remainingSec > 0) {
      String timeText;
      if (remainingSec < 60) {
        timeText = '${remainingSec.ceil()}秒';
      } else if (remainingSec < 3600) {
        timeText = '${(remainingSec / 60).ceil()}分钟';
      } else {
        final hours = (remainingSec / 3600).floor();
        final mins = ((remainingSec % 3600) / 60).ceil();
        timeText = '$hours小时$mins分钟';
      }
      return '$speedText · 剩余 $timeText';
    }

    return speedText;
  }

  /// 清除所有模型记录
  static Future<void> clearAllRecords() async {
    for (final model in availableModels) {
      await deleteModel(model.id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefActiveModelId);
  }

  /// 清理废模型文件（下载失败/中断的残留文件）
  static Future<int> cleanOrphanFiles() async {
    int cleaned = 0;
    try {
      final appDir = await getApplicationSupportDirectory();
      final installedIds = await FlutterGemma.listInstalledModels();

      // 扫描模型目录下的文件
      final modelDir = Directory('${appDir.path}/models');
      if (await modelDir.exists()) {
        await for (final entity in modelDir.list()) {
          if (entity is File) {
            final filename = entity.path.split('/').last.split('\\').last;
            // 检查是否是模型文件且不在已安装列表中
            if (_isModelFile(filename) && !_isInstalledFile(filename, installedIds)) {
              try {
                await entity.delete();
                cleaned++;
                debugPrint('ModelDownloader: 清理废文件: $filename');
              } catch (e) {
                debugPrint('ModelDownloader: 删除失败 $filename: $e');
              }
            }
          }
        }
      }

      // 扫描缓存目录
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          if (entity is File) {
            final filename = entity.path.split('/').last.split('\\').last;
            if (_isModelFile(filename) || filename.endsWith('.part') || filename.endsWith('.tmp')) {
              try {
                await entity.delete();
                cleaned++;
                debugPrint('ModelDownloader: 清理缓存: $filename');
              } catch (_) {}
            }
          }
        }
      }

      debugPrint('ModelDownloader: 共清理 $cleaned 个废文件');
    } catch (e) {
      debugPrint('ModelDownloader: 清理失败: $e');
    }
    return cleaned;
  }

  /// 判断是否是模型文件
  static bool _isModelFile(String filename) {
    return filename.endsWith('.litertlm') ||
        filename.endsWith('.task') ||
        filename.endsWith('.bin') ||
        filename.endsWith('.tflite');
  }

  /// 判断是否在已安装列表中
  static bool _isInstalledFile(String filename, List<String> installedIds) {
    return installedIds.any((id) => filename.contains(id) || id.contains(filename));
  }
}
