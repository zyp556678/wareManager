import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _idleNotification = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: 从 SharedPreferences 加载设置
    setState(() {
      _themeMode = ThemeMode.system;
      _idleNotification = true;
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    // TODO: 保存到 SharedPreferences
    // 通知应用更新主题
  }

  Future<void> _saveIdleNotification(bool value) async {
    setState(() {
      _idleNotification = value;
    });
    // TODO: 保存到 SharedPreferences
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理应用缓存吗？这将删除所有临时文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清理'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('缓存清理成功')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('清理失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _exportData() async {
    try {
      // TODO: 实现数据导出功能
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据导出功能开发中...')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'taitanyunluo4@yeah.net',
      query: 'subject=${Uri.encodeComponent('穿戴管家反馈')}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开邮件客户端')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App设置'),
      ),
      body: ListView(
        children: [
          // 外观设置
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '外观设置',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('主题模式'),
                  trailing: DropdownButton<ThemeMode>(
                    value: _themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('浅色'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('深色'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('跟随系统'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _saveThemeMode(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 通知设置
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '通知设置',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('闲置提醒'),
                  subtitle: const Text('衣物闲置到期前发送提醒'),
                  value: _idleNotification,
                  onChanged: (value) {
                    _saveIdleNotification(value);
                  },
                ),
              ],
            ),
          ),

          // 数据管理
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '数据管理',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('清理缓存'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _clearCache,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('导出数据'),
                  subtitle: const Text('导出为 CSV 格式'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportData,
                ),
              ],
            ),
          ),

          // 关于应用
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '关于应用',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('版本'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('意见反馈'),
                  subtitle: const Text('taitanyunluo4@yeah.net'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _sendFeedback,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
