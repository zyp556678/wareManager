import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';
import '../services/weather_scraper.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;
  String? _cityName;

  static const _cacheKey = 'weather_cache';
  static const _cacheTimeKey = 'weather_cache_time';
  static const _cityKey = 'weather_city';
  static const _cacheDuration = Duration(minutes: 30);

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get cityName => _cityName;
  bool get hasData => _weather != null;

  Future<void> loadWeather(String cityName) async {
    _cityName = cityName;

    final cached = await _loadCache(cityName);
    if (cached != null) {
      _weather = cached;
      notifyListeners();
      return;
    }

    await _fetchAndCache(cityName);
  }

  Future<void> refreshWeather() async {
    if (_cityName == null) return;
    await _fetchAndCache(_cityName!);
  }

  Future<void> changeCity(String cityName) async {
    _cityName = cityName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, cityName);
    await _fetchAndCache(cityName);
  }

  Future<void> loadWeatherByCoords(double lat, double lon) async {
    _cityName = '当前位置';

    final cached = await _loadCache('current_location');
    if (cached != null) {
      _weather = cached;
      notifyListeners();
      return;
    }

    await _fetchAndCacheByCoords(lat, lon, 'current_location');
  }

  Future<void> _fetchAndCacheByCoords(
      double lat, double lon, String cacheKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await WeatherScraper.fetchWeatherByCoords(lat, lon);
      await _saveCache(cacheKey);
    } catch (e) {
      _error = e.toString();
      debugPrint('WeatherProvider Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _fetchAndCache(String cityName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await WeatherScraper.fetchWeather(cityName);
      await _saveCache(cityName);
    } catch (e) {
      _error = e.toString();
      debugPrint('WeatherProvider Error: $_error');
      debugPrint('WeatherProvider City: $cityName');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WeatherData?> _loadCache(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('${_cacheKey}_$cityName');
      final cacheTime = prefs.getInt('${_cacheTimeKey}_$cityName');

      if (cachedJson != null && cacheTime != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
        if (DateTime.now().difference(cacheDate) <= _cacheDuration) {
          final json = jsonDecode(cachedJson) as Map<String, dynamic>;
          return WeatherData.fromJson(json);
        }
      }
    } catch (e) {
      debugPrint('WeatherProvider: Failed to load cache: $e');
    }
    return null;
  }

  Future<void> _saveCache(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_weather != null) {
        await prefs.setString(
            '${_cacheKey}_$cityName', jsonEncode(_weather!.toJson()));
        await prefs.setInt('${_cacheTimeKey}_$cityName',
            _weather!.updatedAt.millisecondsSinceEpoch);
      }
    } catch (e) {
      debugPrint('WeatherProvider: Failed to save cache: $e');
    }
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cityName = prefs.getString(_cityKey);

      final useLocation = prefs.getBool('weather_use_location') ?? true;

      if (useLocation) {
        await loadWeatherByLocation();
      } else if (_cityName != null) {
        await loadWeather(_cityName!);
      }
    } catch (e) {
      debugPrint('WeatherProvider: Failed to load prefs: $e');
    }
  }

  Future<void> loadWeatherByLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        _error = '桌面端不支持定位，请使用移动设备或手动选择城市';
        _isLoading = false;
        notifyListeners();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error = '定位权限被拒绝，请在设置中开启';
        _isLoading = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getLastKnownPosition()
          ?? await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.medium,
              ).timeout(const Duration(seconds: 15));

      final cached = await _loadCache('current_location');
      if (cached != null) {
        _weather = cached;
        _cityName = '当前位置';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _weather = await WeatherScraper.fetchWeatherByCoords(
        position.latitude,
        position.longitude,
      );
      _cityName = '当前位置';
      await _saveCache('current_location');
    } catch (e) {
      _error = '定位失败: ${e.toString().replaceAll('Exception: ', '')}';
      debugPrint('WeatherProvider location error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchToLocationWeather() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weather_use_location', true);
    await loadWeatherByLocation();
  }

  Future<void> switchToCityWeather(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weather_use_location', false);
    await changeCity(cityName);
  }
}
