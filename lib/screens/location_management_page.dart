import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location.dart' as model;
import '../services/database_helper.dart';

class LocationManagementPage extends StatefulWidget {
  const LocationManagementPage({super.key});

  @override
  State<LocationManagementPage> createState() => _LocationManagementPageState();
}

class _LocationManagementPageState extends State<LocationManagementPage> {
  List<model.Location> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    try {
      final locations = await DatabaseHelper.instance.getAllLocations();
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading locations: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddLocationDialog() async {
    final nameController = TextEditingController();
    String selectedType = 'home';
    final descriptionController = TextEditingController();
    String? address;
    bool isLoadingLocation = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> getCurrentLocation() async {
            setDialogState(() => isLoadingLocation = true);
            try {
              final permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                final requested = await Geolocator.requestPermission();
                if (requested == LocationPermission.denied ||
                    requested == LocationPermission.deniedForever) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('定位权限被拒绝')),
                    );
                  }
                  setDialogState(() => isLoadingLocation = false);
                  return;
                }
              }

              final position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              final placemarks = await placemarkFromCoordinates(
                position.latitude,
                position.longitude,
              );

              if (placemarks.isNotEmpty) {
                final place = placemarks.first;
                final parts = <String>[];
                if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
                  parts.add(place.administrativeArea!);
                }
                if (place.subLocality != null && place.subLocality!.isNotEmpty) {
                  parts.add(place.subLocality!);
                }
                if (place.street != null && place.street!.isNotEmpty) {
                  parts.add(place.street!);
                }
                final addressStr = parts.join('');
                setDialogState(() {
                  address = addressStr.isNotEmpty ? addressStr : '未知地址';
                  isLoadingLocation = false;
                });
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('已获取位置: $address')),
                  );
                }
              } else {
                setDialogState(() => isLoadingLocation = false);
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('无法解析地址')),
                  );
                }
              }
            } catch (e) {
              setDialogState(() => isLoadingLocation = false);
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('获取位置失败: $e')),
                );
              }
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
                      hintText: '例如：主卧衣柜、办公室',
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
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '描述（可选）',
                      hintText: '例如：二楼左侧衣柜',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoadingLocation ? null : getCurrentLocation,
                          icon: isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.location_on),
                          label: Text(address != null ? '已定位' : '获取位置'),
                        ),
                      ),
                      if (address != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setDialogState(() {
                              address = null;
                            });
                          },
                          tooltip: '清除位置',
                        ),
                      ],
                    ],
                  ),
                  if (address != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      address!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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
                  if (mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (mounted) {
                    _loadLocations();
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('地点添加成功')),
                    );
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

  Future<void> _showEditLocationDialog(model.Location location) async {
    final nameController = TextEditingController(text: location.name);
    String selectedType = location.type;
    final descriptionController =
        TextEditingController(text: location.description ?? '');
    String? address = location.address;
    bool isLoadingLocation = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> getCurrentLocation() async {
            setDialogState(() => isLoadingLocation = true);
            try {
              final permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                final requested = await Geolocator.requestPermission();
                if (requested == LocationPermission.denied ||
                    requested == LocationPermission.deniedForever) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('定位权限被拒绝')),
                    );
                  }
                  setDialogState(() => isLoadingLocation = false);
                  return;
                }
              }

              final position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              final placemarks = await placemarkFromCoordinates(
                position.latitude,
                position.longitude,
              );

              if (placemarks.isNotEmpty) {
                final place = placemarks.first;
                final parts = <String>[];
                if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
                  parts.add(place.administrativeArea!);
                }
                if (place.subLocality != null && place.subLocality!.isNotEmpty) {
                  parts.add(place.subLocality!);
                }
                if (place.street != null && place.street!.isNotEmpty) {
                  parts.add(place.street!);
                }
                final addressStr = parts.join('');
                setDialogState(() {
                  address = addressStr.isNotEmpty ? addressStr : '未知地址';
                  isLoadingLocation = false;
                });
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('已更新位置: $address')),
                  );
                }
              } else {
                setDialogState(() => isLoadingLocation = false);
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('无法解析地址')),
                  );
                }
              }
            } catch (e) {
              setDialogState(() => isLoadingLocation = false);
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('获取位置失败: $e')),
                );
              }
            }
          }

          return AlertDialog(
            title: const Text('编辑地点'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '地点名称'),
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
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '描述（可选）'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoadingLocation ? null : getCurrentLocation,
                          icon: isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.location_on),
                          label: Text(address != null ? '重新定位' : '获取位置'),
                        ),
                      ),
                      if (address != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setDialogState(() {
                              address = null;
                            });
                          },
                          tooltip: '清除位置',
                        ),
                      ],
                    ],
                  ),
if (address != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      address!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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

final updatedLocation = location.copyWith(
                  name: nameController.text.trim(),
                  type: selectedType,
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  address: address,
                );

                await DatabaseHelper.instance.updateLocation(updatedLocation);
                if (mounted) {
                  Navigator.pop(dialogContext);
                }
                if (mounted) {
                  _loadLocations();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('地点更新成功')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
        },
      ),
    );
  }

  Future<void> _deleteLocation(model.Location location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除地点'),
        content: Text('确定要删除"${location.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseHelper.instance.deleteLocation(location.id!);
      _loadLocations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('地点已删除')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的地点管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无地点',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击下方按钮添加您的衣物存放地点',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getTypeColor(location.type).withValues(alpha: 0.2),
                          child: Icon(
                            _getTypeIcon(location.type),
                            color: _getTypeColor(location.type),
                          ),
                        ),
                        title: Text(
                          location.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(location.typeLabel),
                            if (location.description != null &&
                                location.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                location.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            if (location.address != null && location.address!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    location.address!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () =>
                                  _showEditLocationDialog(location),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () => _deleteLocation(location),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
