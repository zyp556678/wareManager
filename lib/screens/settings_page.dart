import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';
import 'theme_color_screen.dart';
import 'version_info_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _idleNotification = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _idleNotification = true);
  }

  Future<void> _saveIdleNotification(bool value) async {
    setState(() => _idleNotification = value);
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理应用缓存吗？这将删除临时文件，不会影响衣物图片和数据。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('清理')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缓存清理成功')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('清理失败: $e')));
      }
    }
  }

  Future<void> _exportData() async {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('数据导出功能开发中...')));
  }

  Future<void> _sendFeedback() async {
    await Clipboard.setData(const ClipboardData(text: 'taitanyunluo4@yeah.net'));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('邮箱已复制，感谢您的每一次pull request！')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('App设置')),
      body: ListView(
        children: [
          _buildSectionHeader('外观设置', cs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return ListTile(
                        leading: Icon(Icons.palette_outlined, color: cs.primary),
                        title: const Text('主题配色'),
                        subtitle: Text(ThemeProvider.colorNames[themeProvider.colorIndex], style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeColorScreen())),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return ListTile(
                        leading: Icon(Icons.brightness_6_outlined, color: cs.primary),
                        title: const Text('深色模式'),
                        subtitle: Text(_themeModeLabel(themeProvider.themeMode), style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => _showThemeModePicker(context, themeProvider),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildSectionHeader('通知设置', cs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('闲置提醒'),
                subtitle: const Text('衣物闲置到期前发送提醒'),
                value: _idleNotification,
                onChanged: _saveIdleNotification,
              ),
            ),
          ),
          _buildSectionHeader('数据管理', cs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.cleaning_services_outlined), title: const Text('清理缓存'), trailing: const Icon(Icons.chevron_right, size: 18), onTap: _clearCache),
                  const Divider(height: 1, indent: 16),
                  ListTile(leading: const Icon(Icons.download_outlined), title: const Text('导出数据'), subtitle: const Text('导出为 CSV 格式'), trailing: const Icon(Icons.chevron_right, size: 18), onTap: _exportData),
                ],
              ),
            ),
          ),
          _buildSectionHeader('关于应用', cs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('版本'),
                    trailing: const Row(mainAxisSize: MainAxisSize.min, children: [Text('2.0.0'), SizedBox(width: 4), Icon(Icons.chevron_right, size: 18)]),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VersionInfoScreen())),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: const Text('意见反馈'),
                    subtitle: const Text('taitanyunluo4@yeah.net'),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: _sendFeedback,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showThemeModePicker(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(title: const Text('浅色模式'), value: ThemeMode.light, groupValue: themeProvider.themeMode, onChanged: (v) { if (v != null) { themeProvider.setThemeMode(v); Navigator.pop(context); } }),
            const Divider(height: 1),
            RadioListTile<ThemeMode>(title: const Text('深色模式'), value: ThemeMode.dark, groupValue: themeProvider.themeMode, onChanged: (v) { if (v != null) { themeProvider.setThemeMode(v); Navigator.pop(context); } }),
            const Divider(height: 1),
            RadioListTile<ThemeMode>(title: const Text('跟随系统'), value: ThemeMode.system, groupValue: themeProvider.themeMode, onChanged: (v) { if (v != null) { themeProvider.setThemeMode(v); Navigator.pop(context); } }),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return '浅色模式';
      case ThemeMode.dark: return '深色模式';
      case ThemeMode.system: return '跟随系统';
    }
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary, letterSpacing: 0.5)),
    );
  }
}
