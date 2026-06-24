import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clothing_provider.dart';
import '../widgets/glass_card.dart';

class OutfitLogTab extends StatefulWidget {
  const OutfitLogTab({super.key});

  @override
  State<OutfitLogTab> createState() => _OutfitLogTabState();
}

class _OutfitLogTabState extends State<OutfitLogTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<ClothingProvider>(
      builder: (context, provider, child) {
        final logs = provider.operationLogs;

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history, size: 56, color: cs.primary.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无操作记录',
                  style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 8),
                Text(
                  '您的操作历史将显示在这里',
                  style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.4)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          itemCount: logs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogItem(log, cs);
          },
        );
      },
    );
  }

  Widget _buildLogItem(dynamic log, ColorScheme cs) {
    final iconData = _getOperationIcon(log.type);
    final color = _getOperationColor(log.type);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        log.operationText,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(log.createdAt),
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.clothingName ?? '',
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
                if (log.extra != null && log.extra!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.extra!,
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getOperationIcon(String type) {
    switch (type) {
      case 'add':
        return Icons.add_circle_outline;
      case 'idle':
        return Icons.pause_circle_outline;
      case 'wakeup':
        return Icons.play_circle_outline;
      case 'delete':
        return Icons.delete_outline;
      case 'edit':
        return Icons.edit_outlined;
      default:
        return Icons.history;
    }
  }

  Color _getOperationColor(String type) {
    switch (type) {
      case 'add':
        return Colors.green;
      case 'idle':
        return Colors.orange;
      case 'wakeup':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'edit':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
