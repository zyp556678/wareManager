import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../models/city_coords.dart';

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
      double lat, double lon, {String? cityName}) async {
    debugPrint('WeatherScraper: Fetching weather for lat=$lat, lon=$lon');
    String finalCityName = cityName ?? '未知城市';
    if (cityName == null) {
      try {
        finalCityName = await _getCityName(lat, lon) ?? '当前位置';
      } catch (e) {
        debugPrint('WeatherScraper: Failed to get city name: $e');
      }
    }

    final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,wind_direction_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max'
        '&timezone=auto&forecast_days=7');

    debugPrint('WeatherScraper: Requesting $url');

    try {
      final response =
          await http.get(url).timeout(const Duration(seconds: 15));

      debugPrint('WeatherScraper: Response status ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('请求失败: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseResponse(data, finalCityName);
    } catch (e) {
      debugPrint('WeatherScraper: API request failed: $e');
      rethrow;
    }
  }

  static Future<WeatherData> fetchWeather(String cityName) async {
    debugPrint('WeatherScraper: Fetching weather for city: $cityName');
    final coords = await _geocodeCity(cityName);
    if (coords == null) {
      debugPrint('WeatherScraper: Failed to geocode city: $cityName');
      throw Exception('未找到城市: $cityName');
    }
    debugPrint('WeatherScraper: Geocoded to lat=${coords['lat']}, lon=${coords['lon']}');
    return fetchWeatherByCoords(coords['lat']!, coords['lon']!);
  }

  static Future<Map<String, double>?> _geocodeCity(String cityName) async {
    debugPrint('WeatherScraper: Geocoding city: $cityName');

    // 优先从静态映射表查找
    final mapped = cityCoordinates[cityName];
    if (mapped != null) {
      debugPrint('WeatherScraper: Found in mapping table: $cityName');
      return mapped;
    }

    // 映射表未命中，尝试 geocoding API
    try {
      final coords = await _queryGeocodingApi(cityName);
      if (coords != null) return coords;

      // 原始名称查询失败，去掉"市"后缀重试
      if (cityName.endsWith('市')) {
        final withoutSuffix = cityName.substring(0, cityName.length - 1);
        debugPrint('WeatherScraper: Retrying without suffix: $withoutSuffix');
        return await _queryGeocodingApi(withoutSuffix);
      }
    } catch (e) {
      debugPrint('WeatherScraper: Geocoding failed: $e');
    }
    return null;
  }

  static Future<Map<String, double>?> _queryGeocodingApi(String name) async {
    final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$name&count=1&language=zh&format=json');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        final first = results[0] as Map<String, dynamic>;
        debugPrint('WeatherScraper: API found lat=${first['latitude']}, lon=${first['longitude']}');
        return {
          'lat': first['latitude'] as double,
          'lon': first['longitude'] as double,
        };
      }
    }
    return null;
  }

  static Future<String?> _getCityName(double lat, double lon) async {
    // 城市名称由 AMapLocationService 提供，这里直接返回 null 使用默认值
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
