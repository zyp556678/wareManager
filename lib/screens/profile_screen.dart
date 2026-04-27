import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../providers/clothing_provider.dart';
import 'location_management_page.dart';
import 'settings_page.dart';
import 'profile_edit_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '用户昵称';
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    
    // 加载衣物数据和用户资料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClothingProvider>().loadClothingItems();
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _username = prefs.getString('username') ?? '用户昵称';
          _avatarPath = prefs.getString('avatar_path');
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // 使用默认值
      if (mounted) {
        setState(() {
          _username = '用户昵称';
          _avatarPath = null;
        });
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileEditPage(),
      ),
    );

    if (result == true && mounted) {
      _loadUserProfile();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 现代化用户概览卡片
            GestureDetector(
              onTap: _navigateToEditProfile,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                child: _avatarPath != null && _avatarPath!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.file(
                                          File(_avatarPath!),
                                          fit: BoxFit.cover,
                                          width: 64,
                                          height: 64,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 36,
                                        color: colorScheme.primary,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '欢迎回来',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _username,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildModernStatItem(
                            context.watch<ClothingProvider>().activeClothing.length.toString(),
                            '衣橱总数',
                            Icons.checkroom_outlined,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildModernStatItem(
                            context.watch<ClothingProvider>().idleClothing.length.toString(),
                            '闲置件数',
                            Icons.archive_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 设置菜单列表
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildModernMenuItem(
                      icon: Icons.location_on_outlined,
                      title: '我的地点管理',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LocationManagementPage(),
                          ),
                        );
                      },
                      colorScheme: colorScheme,
                    ),
                    _buildModernMenuItem(
                      icon: Icons.event_outlined,
                      title: '场合管理',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('场合管理功能开发中...')),
                        );
                      },
                      colorScheme: colorScheme,
                    ),
                    _buildModernMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'App设置',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                      colorScheme: colorScheme,
                    ),
                    _buildModernMenuItem(
                      icon: Icons.backup_outlined,
                      title: '数据导出与备份',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('数据备份功能开发中...')),
                        );
                      },
                      colorScheme: colorScheme,
                    ),
                    _buildModernMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: '隐私设置',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('隐私设置功能开发中...')),
                        );
                      },
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: colorScheme.onPrimaryContainer,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface.withValues(alpha: 0.4),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
