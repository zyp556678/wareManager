import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class OutfitLogTab extends StatefulWidget {
  const OutfitLogTab({super.key});

  @override
  State<OutfitLogTab> createState() => _OutfitLogTabState();
}

class _OutfitLogTabState extends State<OutfitLogTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _outfitLogs = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMockData();
  }

  void _loadMockData() {
    // 模拟数据
    final today = DateTime.now();
    _outfitLogs[today] = [
      {
        'weather': '晴',
        'occasion': '工作',
        'image': null,
      },
    ];
    
    final yesterday = today.subtract(const Duration(days: 1));
    _outfitLogs[yesterday] = [
      {
        'weather': '多云',
        'occasion': '约会',
        'image': null,
      },
    ];
  }

  List<Map<String, dynamic>> _getLogsForDay(DateTime day) {
    return _outfitLogs[DateTime(day.year, day.month, day.day)] ?? [];
  }

  bool _hasEvents(DateTime day) {
    return _outfitLogs.containsKey(DateTime(day.year, day.month, day.day));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 日历（限制高度）
        SizedBox(
          height: 420,
          child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            eventLoader: _getLogsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_hasEvents(date)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),

        const Divider(height: 1),

        // 穿搭记录列表
        Expanded(
          child: _selectedDay == null
              ? const Center(child: Text('请选择日期'))
              : _buildLogsList(_selectedDay!),
        ),
      ],
    );
  }

  Widget _buildLogsList(DateTime day) {
    final logs = _getLogsForDay(day);

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '该日期暂无穿搭记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.checkroom, size: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            avatar: const Icon(Icons.wb_sunny, size: 16),
                            label: Text(log['weather']),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            avatar: const Icon(Icons.event, size: 16),
                            label: Text(log['occasion']),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
