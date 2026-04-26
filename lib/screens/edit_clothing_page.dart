import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';
import 'package:provider/provider.dart';

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
  late TextEditingController _seasonController;
  String? _imagePath;

  final List<String> _categories = ['上衣', '裤子', '裙装', '外套', '鞋子', '配饰'];
  final List<String> _styles = ['休闲', '商务', '运动', '约会', '派对'];
  final List<String> _materials = ['棉', '麻', '丝', '羊毛', '涤纶', '牛仔', '皮革'];
  final List<String> _seasons = ['春', '夏', '秋', '冬', '四季'];

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.item.category);
    _colorController = TextEditingController(text: widget.item.color);
    _materialController = TextEditingController(text: widget.item.material);
    _styleController = TextEditingController(text: widget.item.style);
    _seasonController = TextEditingController(text: widget.item.season);
    _imagePath = widget.item.imagePath;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    _styleController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入品类')),
      );
      return;
    }

    final updatedItem = widget.item.copyWith(
      imagePath: _imagePath ?? '',
      category: _categoryController.text.trim(),
      color: _colorController.text.trim(),
      material: _materialController.text.trim(),
      style: _styleController.text.trim(),
      season: _seasonController.text.trim(),
    );

    await context.read<ClothingProvider>().updateClothingItem(updatedItem);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑衣物'),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _imagePath != null && _imagePath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 50,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击更换图片',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 表单字段
            _buildDropdownField(
              label: '品类',
              value: _categoryController.text,
              items: _categories,
              onChanged: (value) {
                setState(() {
                  _categoryController.text = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: '颜色',
              controller: _colorController,
              hint: '例如：白色、黑色',
            ),
            const SizedBox(height: 16),

            _buildDropdownField(
              label: '材质',
              value: _materialController.text,
              items: _materials,
              onChanged: (value) {
                setState(() {
                  _materialController.text = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildDropdownField(
              label: '风格',
              value: _styleController.text,
              items: _styles,
              onChanged: (value) {
                setState(() {
                  _styleController.text = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildDropdownField(
              label: '季节',
              value: _seasonController.text,
              items: _seasons,
              onChanged: (value) {
                setState(() {
                  _seasonController.text = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // 删除按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('删除衣物', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _showDeleteConfirm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: Text('请选择$label'),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ClothingProvider>().deleteClothingItem(widget.item.id!);
      Navigator.pop(context);
      Navigator.pop(context); // 返回到列表页
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      }
    }
  }
}
