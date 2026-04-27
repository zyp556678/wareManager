import 'package:flutter/material.dart';

class VersionInfoScreen extends StatelessWidget {
  const VersionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final versions = [
      {
        'version': '1.0.1',
        'date': '2026-04-27',
        'content': [
          '新增五组主题配色切换',
          '新增深色模式支持',
          '重构现代化拍照界面（V2.0）',
          '新增毛玻璃 UI 组件',
          '全局毛玻璃底部导航',
          '修复代码问题',
        ],
      },
      {
        'version': '1.0',
        'date': '2026-04-27',
        'content': [
          '项目基础架构',
          '底部导航与四个主页面',
          '相机拍照与相册选择',
          '识别确认页表单',
          '数据模型与数据库',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('版本说明'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: versions.length,
        itemBuilder: (context, index) {
          final item = versions[index];
          final isLatest = index == 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'v${item['version']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLatest
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (isLatest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '最新',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        item['date'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(item['content'] as List<String>).map(
                    (content) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              content,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}