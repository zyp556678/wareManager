import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import '../models/operation_log.dart';
import '../providers/clothing_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_card.dart';
import '../utils/image_utils.dart';

class EditClothingPage extends StatefulWidget {
  final ClothingItem item;

  const EditClothingPage({super.key, required this.item});

  @override
  State<EditClothingPage> createState() => _EditClothingPageState();
}

class _EditClothingPageState extends State<EditClothingPage> {
  late TextEditingController _categoryController;
  late TextEditingController _colorController;
  late TextEditingController _materialController;
  late TextEditingController _styleController;
  String? _imagePath;

  final List<String> _categories = ['上衣', '裤子', '裙装', '外套', '鞋子', '配饰'];
  final List<String> _styles = ['休闲', '商务', '运动', '约会', '派对'];
  final List<String> _materials = ['棉', '麻', '丝', '羊毛', '涤纶', '牛仔', '皮革'];
  final List<String> _seasons = ['四季', '春季', '夏季', '秋季', '冬季', '春秋', '春秋冬'];
  late String _season;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.item.category);
    _colorController = TextEditingController(text: widget.item.color);
    _materialController = TextEditingController(text: widget.item.material);
    _styleController = TextEditingController(text: widget.item.style);
    _season = widget.item.season.isNotEmpty ? widget.item.season : '四季';
    _imagePath = widget.item.imagePath;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) setState(() => _imagePath = pickedFile.path);
  }

  Future<void> _saveChanges() async {
    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入品类')));
      return;
    }

    String? finalImagePath = _imagePath;
    if (_imagePath != null && _imagePath!.isNotEmpty && _imagePath != widget.item.imagePath) {
      finalImagePath = await saveImageToAppDir(_imagePath!);
    }

    final updatedItem = widget.item.copyWith(
      imagePath: finalImagePath ?? '',
      category: _categoryController.text.trim(),
      color: _colorController.text.trim(),
      material: _materialController.text.trim(),
      style: _styleController.text.trim(),
      season: _season,
    );

    await context.read<ClothingProvider>().updateClothingItem(updatedItem);
    await context.read<ClothingProvider>().addOperationLog(
      OperationLog(
        type: 'edit',
        clothingId: updatedItem.id,
        clothingName: '${updatedItem.category} · ${updatedItem.color}',
        content: '编辑衣物',
        createdAt: DateTime.now(),
      ),
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑衣物'),
        actions: [
          TextButton(onPressed: _saveChanges, child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _imagePath != null && _imagePath!.isNotEmpty
                        ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                        : Container(
                            color: cs.secondary.withValues(alpha: 0.3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 48, color: cs.primary),
                                const SizedBox(height: 8),
                                Text('点击更换图片', style: TextStyle(color: cs.primary, fontSize: 13)),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDropdownField(label: '品类', value: _categoryController.text, items: _categories, onChanged: (v) => setState(() => _categoryController.text = v!)),
                  const SizedBox(height: 16),
                  _buildTextField(label: '颜色', controller: _colorController, hint: '例如：白色、黑色'),
                  const SizedBox(height: 16),
                  _buildDropdownField(label: '材质', value: _materialController.text, items: _materials, onChanged: (v) => setState(() => _materialController.text = v!)),
                  const SizedBox(height: 16),
                  _buildDropdownField(label: '风格', value: _styleController.text, items: _styles, onChanged: (v) => setState(() => _styleController.text = v!)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('季节', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.7))),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _seasons.map((season) {
                      return ChoiceChip(
                        label: Text(season),
                        selected: _season == season,
                        onSelected: (selected) {
                          if (selected) setState(() => _season = season);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('删除衣物', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _showDeleteConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, String? hint}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: Text('请选择$label'),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除衣物'),
        content: const Text('确定要删除这件衣物吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('删除')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ClothingProvider>().deleteClothingItem(widget.item.id!);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已删除')));
      }
    }
  }
}
