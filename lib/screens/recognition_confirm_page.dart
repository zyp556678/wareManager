import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';

class RecognitionConfirmPage extends StatefulWidget {
  final String imagePath;

  const RecognitionConfirmPage({super.key, required this.imagePath});

  @override
  State<RecognitionConfirmPage> createState() => _RecognitionConfirmPageState();
}

class _RecognitionConfirmPageState extends State<RecognitionConfirmPage> {
  String _category = '上衣';
  String _material = '棉';
  String _style = '休闲';
  String _season = '四季';
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  final List<String> _categories = ['上衣', '裤子', '裙装', '外套', '鞋子', '配饰'];
  final List<String> _materials = ['棉', '麻', '丝', '羊毛', '涤纶', '牛仔'];
  final List<String> _styles = ['休闲', '商务', '运动', '复古', '简约', '时尚'];
  final List<String> _seasons = ['四季', '春季', '夏季', '秋季', '冬季', '春秋', '春秋冬'];

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _showIdleSettings() {
    DateTime? selectedDate;
    String selectedLocation = '主卧衣柜';
    final List<String> locations = ['主卧衣柜', '次卧衣柜', '收纳箱A', '收纳箱B'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '闲置设置',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 日期选择
              const Text('预计闲置至'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('zh', 'CN'),
                    helpText: '选择闲置开始日期',
                    confirmText: '确认',
                    cancelText: '取消',
                  );
                  if (date != null) {
                    setModalState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                        : '选择日期',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 放置地点
              const Text('放置地点'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...locations.map((location) => ChoiceChip(
                        label: Text(location),
                        selected: selectedLocation == location,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedLocation = location;
                          });
                        },
                      )),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('新建'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('新建地点'),
                          content: TextField(
                            decoration: const InputDecoration(
                              hintText: '输入地点名称',
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                setModalState(() {
                                  locations.add(value);
                                  selectedLocation = value;
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 确认按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDate != null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已进入闲置')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请选择闲置日期')),
                      );
                    }
                  },
                  child: const Text('确认闲置'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveToWardrobe() async {
    final clothingItem = ClothingItem(
      imagePath: widget.imagePath,
      category: _category,
      color: '默认',
      material: _material,
      style: _style,
      season: _season,
      customTags: _tags,
      createdDate: DateTime.now(),
    );

    if (mounted) {
      await context.read<ClothingProvider>().addClothingItem(clothingItem);
    }
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已收入衣橱')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别确认'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片展示区域
            Stack(
              children: [
                Image.file(
                  File(widget.imagePath),
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // 识别标签
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '上衣 · 米白色 · 纯色',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // 表单区域
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 品类选择
                  const Text('品类', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: _categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 材质选择
                  const Text('材质', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _materials.map((material) {
                      return ChoiceChip(
                        label: Text(material),
                        selected: _material == material,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _material = material;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 风格选择
                  const Text('风格', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _styles.map((style) {
                      return ChoiceChip(
                        label: Text(style),
                        selected: _style == style,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _style = style;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 季节选择
                  const Text('季节', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _seasons.map((season) {
                      return ChoiceChip(
                        label: Text(season),
                        selected: _season == season,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _season = season;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 个人标签
                  const Text('个人标签', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: '添加标签',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addTag,
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 底部按钮
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveToWardrobe,
                child: const Text('直接收入衣橱'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _showIdleSettings,
                child: const Text('进入闲置设置'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

