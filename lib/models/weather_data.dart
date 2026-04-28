class WeatherData {
  final String cityName;
  final int currentTemp;
  final String condition;
  final int humidity;
  final String windDirection;
  final String windLevel;
  final int aqi;
  final String aqiLevel;
  final List<DailyForecast> forecasts;
  final DateTime updatedAt;

  WeatherData({
    required this.cityName,
    required this.currentTemp,
    required this.condition,
    required this.humidity,
    required this.windDirection,
    required this.windLevel,
    required this.aqi,
    required this.aqiLevel,
    required this.forecasts,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'currentTemp': currentTemp,
        'condition': condition,
        'humidity': humidity,
        'windDirection': windDirection,
        'windLevel': windLevel,
        'aqi': aqi,
        'aqiLevel': aqiLevel,
        'forecasts': forecasts.map((f) => f.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        cityName: json['cityName'] as String,
        currentTemp: json['currentTemp'] as int,
        condition: json['condition'] as String,
        humidity: json['humidity'] as int,
        windDirection: json['windDirection'] as String,
        windLevel: json['windLevel'] as String,
        aqi: json['aqi'] as int,
        aqiLevel: json['aqiLevel'] as String,
        forecasts: (json['forecasts'] as List)
            .map((f) => DailyForecast.fromJson(f as Map<String, dynamic>))
            .toList(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class DailyForecast {
  final String day;
  final String condition;
  final int tempLow;
  final int tempHigh;
  final String wind;

  DailyForecast({
    required this.day,
    required this.condition,
    required this.tempLow,
    required this.tempHigh,
    required this.wind,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'condition': condition,
        'tempLow': tempLow,
        'tempHigh': tempHigh,
        'wind': wind,
      };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        day: json['day'] as String,
        condition: json['condition'] as String,
        tempLow: json['tempLow'] as int,
        tempHigh: json['tempHigh'] as int,
        wind: json['wind'] as String,
      );
}
