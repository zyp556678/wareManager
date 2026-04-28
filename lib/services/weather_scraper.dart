import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocoding;
import '../models/weather_data.dart';

class WeatherScraper {
  static const _baseUrl = 'https://api.open-meteo.com/v1';

  static const _weatherCodeMap = {
    0: '晴',
    1: '大部晴朗',
    2: '多云',
    3: '阴',
    45: '雾',
    48: '结冰雾',
    51: '小毛毛雨',
    53: '中毛毛雨',
    55: '大毛毛雨',
    56: '小冻毛毛雨',
    57: '大冻毛毛雨',
    61: '小雨',
    63: '中雨',
    65: '大雨',
    66: '小冻雨',
    67: '大冻雨',
    71: '小雪',
    73: '中雪',
    75: '大雪',
    77: '雪粒',
    80: '小阵雨',
    81: '中阵雨',
    82: '大阵雨',
    85: '小阵雪',
    86: '大阵雪',
    95: '雷暴',
    96: '雷暴伴小冰雹',
    99: '雷暴伴大冰雹',
  };

  static String _getCondition(int code) {
    return _weatherCodeMap[code] ?? '未知';
  }

  static Future<WeatherData> fetchWeatherByCoords(
      double lat, double lon) async {
    final cityName = await _getCityName(lat, lon);

    final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,wind_direction_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max'
        '&timezone=auto&forecast_days=7');

    final response =
        await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('请求失败: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseResponse(data, cityName ?? '未知城市');
  }

  static Future<WeatherData> fetchWeather(String cityName) async {
    final coords = await _geocodeCity(cityName);
    if (coords == null) {
      throw Exception('未找到城市: $cityName');
    }
    return fetchWeatherByCoords(coords['lat']!, coords['lon']!);
  }

  static Future<Map<String, double>?> _geocodeCity(String cityName) async {
    try {
      final locations = await geocoding.locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        return {
          'lat': locations.first.latitude,
          'lon': locations.first.longitude,
        };
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> _getCityName(double lat, double lon) async {
    try {
      final placemarks =
          await geocoding.placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            placemarks.first.administrativeArea;
      }
    } catch (_) {}
    return null;
  }

  static WeatherData _parseResponse(
      Map<String, dynamic> data, String cityName) {
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    final currentTemp =
        (current['temperature_2m'] as num).round();
    final condition =
        _getCondition((current['weather_code'] as num).toInt());
    final humidity =
        (current['relative_humidity_2m'] as num).round();
    final windSpeed =
        (current['wind_speed_10m'] as num).round();

    final forecasts = <DailyForecast>[];
    final dailyLength =
        (daily['time'] as List).length;

    for (int i = 0; i < dailyLength && i < 7; i++) {
      final day = daily['time'][i] as String;
      final tempMax =
          (daily['temperature_2m_max'][i] as num).round();
      final tempMin =
          (daily['temperature_2m_min'][i] as num).round();
      final weatherCode =
          (daily['weather_code'][i] as num).toInt();
      final windMax =
          (daily['wind_speed_10m_max'][i] as num).round();

      final date = DateTime.parse(day);
      final dayName = _getDayName(date);

      forecasts.add(DailyForecast(
        day: dayName,
        condition: _getCondition(weatherCode),
        tempLow: tempMin,
        tempHigh: tempMax,
        wind: '${windMax}km/h',
      ));
    }

    return WeatherData(
      cityName: cityName,
      currentTemp: currentTemp,
      condition: condition,
      humidity: humidity,
      windDirection: '',
      windLevel: '${windSpeed}km/h',
      aqi: 0,
      aqiLevel: '',
      forecasts: forecasts,
      updatedAt: DateTime.now(),
    );
  }

  static String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == 2) return '后天';
    const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekDays[date.weekday - 1];
  }
}
