import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/location.dart' as model;
import '../screens/location_management_page.dart';
import '../services/amap_location_service.dart';

Future<String?> showLocationPicker(BuildContext context) async {
  final locations = await DatabaseHelper.instance.getAllLocations();

  if (!context.mounted) return null;

  if (locations.isEmpty) {
    final goToAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('暂无地点'),
        content: const Text('请先添加存放地点'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('去添加'),
          ),
        ],
      ),
    );

    if (goToAdd == true && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LocationManagementPage()),
      );
      if (context.mounted) {
        return showLocationPicker(context);
      }
    }
    return null;
  }

  if (!context.mounted) return null;

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择存放地点',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final newLocation = await showAddLocationDialog(context);
                      if (newLocation != null && context.mounted) {
                        Navigator.pop(context, newLocation);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新建'),
                  ),
                ],
              ),
            ),
            ...locations.map((loc) => ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(loc.type).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(loc.type),
                      color: _getTypeColor(loc.type),
                      size: 20,
                    ),
                  ),
                  title: Text(loc.name),
                  subtitle: loc.description != null && loc.description!.isNotEmpty
                      ? Text(loc.description!)
                      : null,
                  onTap: () => Navigator.pop(context, loc.name),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

Future<String?> showAddLocationDialog(BuildContext context) async {
  final nameController = TextEditingController();
  String selectedType = 'home';
  final descriptionController = TextEditingController();
  String? address;
  bool isLoadingLocation = false;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        Future<void> getCurrentLocation() async {
          setDialogState(() => isLoadingLocation = true);
          try {
            final locationResult =
                await AMapLocationService().getCurrentLocation();

            if (!locationResult.isSuccess) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                        '定位失败: ${locationResult.errorInfo ?? '未知错误'}'),
                  ),
                );
              }
              setDialogState(() => isLoadingLocation = false);
              return;
            }

            final addressStr = locationResult.address ?? '未知地址';
            setDialogState(() {
              address = addressStr;
              isLoadingLocation = false;
            });
          } catch (e) {
            if (dialogContext.mounted) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('定位失败: $e')),
              );
            }
            setDialogState(() => isLoadingLocation = false);
          }
        }

        return AlertDialog(
          title: const Text('添加地点'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '地点名称',
                    hintText: '例如：主卧衣柜',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: '地点类型'),
                  items: const [
                    DropdownMenuItem(value: 'home', child: Text('家')),
                    DropdownMenuItem(value: 'office', child: Text('办公室')),
                    DropdownMenuItem(value: 'gym', child: Text('健身房')),
                    DropdownMenuItem(value: 'travel', child: Text('旅行')),
                    DropdownMenuItem(value: 'other', child: Text('其他')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration:
                      const InputDecoration(labelText: '描述（可选）'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            isLoadingLocation ? null : getCurrentLocation,
                        icon: isLoadingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.location_on),
                        label: Text(address != null ? '已定位' : '获取位置'),
                      ),
                    ),
                    if (address != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setDialogState(() => address = null),
                      ),
                    ],
                  ],
                ),
                if (address != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    address!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('请输入地点名称')),
                  );
                  return;
                }
                final location = model.Location(
                  name: nameController.text.trim(),
                  type: selectedType,
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  address: address,
                  createdAt: DateTime.now(),
                );
                await DatabaseHelper.instance.createLocation(location);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, location.name);
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    ),
  );
}

IconData _getTypeIcon(String type) {
  switch (type) {
    case 'home':
      return Icons.home;
    case 'office':
      return Icons.business;
    case 'gym':
      return Icons.fitness_center;
    case 'travel':
      return Icons.flight;
    default:
      return Icons.location_on;
  }
}

Color _getTypeColor(String type) {
  switch (type) {
    case 'home':
      return Colors.blue;
    case 'office':
      return Colors.purple;
    case 'gym':
      return Colors.orange;
    case 'travel':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
