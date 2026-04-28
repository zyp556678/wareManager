import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_card.dart';
import 'city_search_screen.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (!provider.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('天气详情')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final weather = provider.weather!;

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CitySearchScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(weather.cityName),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
            actions: [
              if (weather.cityName != '当前位置')
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () => provider.switchToLocationWeather(),
                  tooltip: '定位获取',
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.refreshWeather(),
                tooltip: '刷新',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.refreshWeather(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentWeather(context, weather),
                  const SizedBox(height: 16),
                  _buildDetailGrid(context, weather),
                  const SizedBox(height: 16),
                  if (weather.forecasts.isNotEmpty) ...[
                    _buildDailyForecast(context, weather),
                    const SizedBox(height: 16),
                  ],
                  _buildOutfitSuggestion(context, weather),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentWeather(BuildContext context, dynamic weather) {
    final cs = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _weatherIcon(weather.condition, size: 64),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    '${weather.currentTemp}°',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                      height: 1,
                    ),
                  ),
                  Text(
                    weather.condition,
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${weather.windDirection} ${weather.windLevel}  |  湿度 ${weather.humidity}%',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGrid(BuildContext context, dynamic weather) {
    final cs = Theme.of(context).colorScheme;

    final items = [
      _DetailItem(
        icon: Icons.water_drop,
        label: '湿度',
        value: '${weather.humidity}%',
        color: Colors.blue,
      ),
      _DetailItem(
        icon: Icons.air,
        label: '风力',
        value: '${weather.windDirection}${weather.windLevel}',
        color: Colors.teal,
      ),
      _DetailItem(
        icon: Icons.eco,
        label: '空气质量',
        value: '${weather.aqi} ${weather.aqiLevel}',
        color: _aqiColor(weather.aqi),
      ),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 24, color: item.color),
                  const SizedBox(height: 8),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyForecast(BuildContext context, dynamic weather) {
    final cs = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '天气预报',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...weather.forecasts.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      day.day,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: _weatherIcon(day.condition, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      day.condition,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${day.tempHigh}°',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${day.tempLow}°',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitSuggestion(BuildContext context, dynamic weather) {
    final cs = Theme.of(context).colorScheme;
    final temp = weather.currentTemp;
    final condition = weather.condition as String;

    final suggestions = <String>[];

    if (temp > 30) {
      suggestions.add('天气炎热，建议穿短袖、短裤或裙子，注意补水防晒');
    } else if (temp >= 25) {
      suggestions.add('温暖舒适，适合轻薄长袖或短袖');
    } else if (temp >= 15) {
      suggestions.add('温度适宜，建议穿长袖 + 薄外套，方便增减');
    } else if (temp >= 5) {
      suggestions.add('天气偏凉，建议穿厚外套或毛衣');
    } else {
      suggestions.add('寒冷，请穿羽绒服或厚棉衣，注意保暖');
    }

    if (condition.contains('雨')) {
      suggestions.add('今日有雨，记得带伞');
    } else if (condition.contains('雪')) {
      suggestions.add('今日降雪，注意防滑保暖');
    }

    if (weather.windLevel.contains('4') ||
        weather.windLevel.contains('5') ||
        weather.windLevel.contains('6')) {
      suggestions.add('风力较大，注意防风');
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                '穿搭建议',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: cs.primary)),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }

  Widget _weatherIcon(String condition, {double size = 24}) {
    IconData icon;
    Color color;

    if (condition.contains('雨')) {
      icon = Icons.water_drop;
      color = Colors.blue;
    } else if (condition.contains('雪')) {
      icon = Icons.ac_unit;
      color = Colors.lightBlue;
    } else if (condition.contains('雷')) {
      icon = Icons.thunderstorm;
      color = Colors.deepPurple;
    } else if (condition.contains('云') || condition.contains('阴')) {
      icon = Icons.cloud;
      color = Colors.blueGrey;
    } else if (condition.contains('雾') || condition.contains('霾')) {
      icon = Icons.foggy;
      color = Colors.grey;
    } else if (condition.contains('晴')) {
      icon = Icons.wb_sunny;
      color = Colors.orange;
    } else {
      icon = Icons.cloud_outlined;
      color = Colors.grey;
    }

    return Icon(icon, size: size, color: color);
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
