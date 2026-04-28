import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_card.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _searchController = TextEditingController();
  List<String> _recentCities = [];
  String? _error;

  static const _allCities = [
    '北京市', '上海市', '天津市', '重庆市',
    '广州市', '深圳市', '杭州市', '南京市', '苏州市',
    '成都市', '武汉市', '西安市', '长沙市', '郑州市',
    '青岛市', '大连市', '沈阳市', '哈尔滨市', '长春市',
    '济南市', '福州市', '厦门市', '昆明市', '贵阳市',
    '南昌市', '合肥市', '太原市', '石家庄市', '兰州市',
    '南宁市', '海口市', '银川市', '西宁市', '拉萨市',
    '乌鲁木齐市', '呼和浩特市',
    '珠海市', '佛山市', '东莞市', '无锡市', '常州市',
    '宁波市', '温州市', '嘉兴市', '烟台市', '潍坊市',
    '洛阳市', '三亚市', '桂林市',
  ];

  List<String> get _filteredCities {
    final query = _searchController.text.trim();
    if (query.isEmpty) return _allCities;
    return _allCities
        .where((c) => c.contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadRecentCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cities = prefs.getStringList('recent_weather_cities') ?? [];
      if (mounted) {
        setState(() => _recentCities = cities.take(5).toList());
      }
    } catch (e) {
      debugPrint('CitySearchScreen: Failed to load recent cities: $e');
    }
  }

  Future<void> _saveRecentCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cities = prefs.getStringList('recent_weather_cities') ?? [];
      cities.remove(cityName);
      cities.insert(0, cityName);
      await prefs.setStringList('recent_weather_cities', cities.take(10).toList());
    } catch (e) {
      debugPrint('CitySearchScreen: Failed to save recent city: $e');
    }
  }

  Future<void> _selectCity(String cityName) async {
    final weatherProvider = context.read<WeatherProvider>();
    await _saveRecentCity(cityName);

    if (mounted) {
      await weatherProvider.switchToCityWeather(cityName);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('选择城市')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索城市名称...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surface,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          if (_error != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
            ),
          ],

          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildCityList(context, _filteredCities)
                : _recentCities.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              '最近使用',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildCityList(context, _recentCities),
                          ),
                        ],
                      )
                    : _buildCityList(context, _allCities),
          ),
        ],
      ),
    );
  }

  Widget _buildCityList(BuildContext context, List<String> cities) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cities.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cityName = cities[index];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          onTap: () => _selectCity(cityName),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_city, color: cs.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        );
      },
    );
  }
}
