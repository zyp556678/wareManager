import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../screens/weather_detail_screen.dart';
import '../screens/city_search_screen.dart';
import 'glass_card.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasData) {
          return _buildLoadingCard(context);
        }

        if (provider.error != null && !provider.hasData) {
          return _buildErrorCard(context, provider);
        }

        if (!provider.hasData) {
          return _buildEmptyCard(context, provider);
        }

        return _buildWeatherCard(context, provider);
      },
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wb_sunny, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '正在获取天气...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '请稍候',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WeatherProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off, color: cs.error, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '获取天气失败',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.error!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.clearError();
                    provider.switchToLocationWeather();
                  },
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('定位获取'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.clearError();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CitySearchScreen()),
                    );
                  },
                  icon: const Icon(Icons.location_city, size: 18),
                  label: const Text('选择城市'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, WeatherProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.wb_sunny, color: cs.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '获取天气信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '选择定位或手动选择城市',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.switchToLocationWeather();
                  },
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('定位获取'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CitySearchScreen()),
                    );
                  },
                  icon: const Icon(Icons.location_city, size: 18),
                  label: const Text('选择城市'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final weather = provider.weather!;
    final isLocationWeather = weather.cityName == '当前位置';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WeatherDetailScreen()),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      weather.cityName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: cs.primary,
                      ),
                    ),
                    if (!isLocationWeather) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          provider.switchToLocationWeather();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 12,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '定位',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                _weatherIcon(weather.condition, size: 36),
                const SizedBox(width: 8),
                Text(
                  '${weather.currentTemp}°',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  weather.condition,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDetailItem(
                  context,
                  icon: Icons.water_drop,
                  label: '${weather.humidity}%',
                ),
                const SizedBox(width: 16),
                _buildDetailItem(
                  context,
                  icon: Icons.air,
                  label: weather.windLevel,
                ),
                if (weather.aqi > 0) ...[
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    context,
                    icon: Icons.eco,
                    label: '${weather.aqi} ${weather.aqiLevel}',
                    color: _aqiColor(weather.aqi),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? cs.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
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
