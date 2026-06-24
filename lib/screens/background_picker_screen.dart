import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/image_utils.dart';
import '../widgets/glass_card.dart';

class BackgroundPickerScreen extends StatefulWidget {
  const BackgroundPickerScreen({super.key});

  @override
  State<BackgroundPickerScreen> createState() => _BackgroundPickerScreenState();
}

class _BackgroundPickerScreenState extends State<BackgroundPickerScreen> {
  String? _tempPath;
  bool _isLoading = false;
  late TextEditingController _opacityController;

  @override
  void initState() {
    super.initState();
    _opacityController = TextEditingController();
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _tempPath = pickedFile.path);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_tempPath == null) return;

    setState(() => _isLoading = true);
    try {
      final savedPath = await saveImageToAppDir(_tempPath!);
      final themeProvider = context.read<ThemeProvider>();
      themeProvider.setBackground(savedPath);
      themeProvider.toggleBackground(true);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('背景已保存')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  void _restoreDefault() {
    final themeProvider = context.read<ThemeProvider>();
    themeProvider.toggleBackground(false);
    themeProvider.setBackground(null);
    setState(() => _tempPath = null);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已恢复默认背景')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final currentPath = _tempPath ?? themeProvider.backgroundPath;
    final hasBackground = currentPath != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义背景'),
        actions: [
          if (_tempPath != null)
            TextButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('保存', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 预览区
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: hasBackground
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(currentPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: cs.surface,
                            child: Center(child: Icon(Icons.broken_image, size: 48, color: cs.onSurface.withValues(alpha: 0.3))),
                          ),
                        ),
                        // 模拟毛玻璃卡片效果
                        Positioned.fill(
                          child: Container(
                            color: cs.surface.withValues(alpha: themeProvider.backgroundOpacity),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Text('预览效果', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: cs.surface,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined, size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text('暂无自定义背景', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // 操作按钮
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: cs.primary),
                  title: const Text('从相册选择'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: _showImageSourceDialog,
                ),
                const Divider(height: 1, indent: 16),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: cs.primary),
                  title: const Text('拍照'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                if (hasBackground) ...[
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('恢复默认', style: TextStyle(color: Colors.red)),
                    onTap: _restoreDefault,
                  ),
                ],
              ],
            ),
          ),

          // 启用开关
          if (themeProvider.backgroundPath != null) ...[
            const SizedBox(height: 16),
            GlassCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                secondary: Icon(Icons.toggle_on_outlined, color: cs.primary),
                title: const Text('启用自定义背景'),
                subtitle: Text(
                  themeProvider.backgroundEnabled ? '当前使用自定义背景' : '当前使用默认背景',
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)),
                ),
                value: themeProvider.backgroundEnabled,
                onChanged: (value) => themeProvider.toggleBackground(value),
              ),
            ),
          ],

          // 背景透明度
          if (themeProvider.backgroundEnabled) ...[
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.opacity, color: cs.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('背景透明度', style: TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      SizedBox(
                        width: 56,
                        height: 32,
                        child: TextField(
                          controller: _opacityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            hintText: '${(themeProvider.backgroundOpacity * 100).round()}',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              themeProvider.setBackgroundOpacity(parsed / 100);
                            }
                            _opacityController.clear();
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('%', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('透明', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                      Expanded(
                        child: Slider(
                          value: themeProvider.backgroundOpacity,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          label: '${(themeProvider.backgroundOpacity * 100).round()}%',
                          onChanged: (value) => themeProvider.setBackgroundOpacity(value),
                        ),
                      ),
                      Text('不透明', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          // 提示
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '自定义背景将显示在所有主页面下方，毛玻璃组件会自然透出背景效果',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
