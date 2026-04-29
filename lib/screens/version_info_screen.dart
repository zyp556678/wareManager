import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class VersionInfoScreen extends StatelessWidget {
  const VersionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final versions = [
      {
        'version': '2.0.0',
        'date': '2026-04-29',
        'content': [
          '天气模块重构：改用 Open-Meteo API（免费、无需 Key）',
          '天气默认基于定位获取，支持手动切换城市',
          '天气预报扩展至 7 天',
          '天气详情页新增"立即定位"按钮',
          '天气定位显示详细地址（城市 + 区 + 街道）',
          '定位模块重构：切换至高德定位 SDK，国内定位更稳定快速',
          '室内定位优化：融合 GPS + WiFi + 基站，定位速度 2-5 秒',
          '逆地理编码：高德自带，不再依赖 Google Play 服务',
          '启动时主动请求定位权限',
          '相机界面新增放大功能（双指捏合/双击切换/预设档位/滑动条）',
          '相机界面支持调用系统相机拍照',
          '地点管理支持地址显示与编辑',
          '修复缓存清理逻辑，确保数据正确清除',
          '主题模式默认跟随系统',
          '全新液态玻璃 UI 设计',
          'Bento Grid 首页布局',
          '悬浮玻璃导航栏',
          '全新5套主题配色（冰川蓝/翡翠绿/玫瑰金/星空紫/月光银）',
        ],
      },
      {
        'version': '1.0.1+4',
        'date': '2026-04-27',
        'content': [
          '新增五组主题配色',
          '新增深色模式支持',
          '新增操作日志功能',
          '新增毛玻璃 UI 组件',
          '导航栏升级为 Material 3',
          '地点管理支持 GPS 定位',
        ],
      },
      {
        'version': '1.0',
        'date': '2026-04-27',
        'content': [
          '项目基础架构',
          '底部导航与四个主页面',
          '相机拍照与相册选择',
          '数据模型与数据库',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('版本说明')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: versions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = versions[index];
          final isLatest = index == 0;

          return GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('v${item['version']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLatest ? cs.primary : cs.onSurface)),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(6)),
                        child: const Text('最新', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    const Spacer(),
                    Text(item['date'] as String, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 12),
                ...(item['content'] as List<String>).map(
                  (content) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(fontSize: 14, color: cs.primary)),
                        Expanded(child: Text(content, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
