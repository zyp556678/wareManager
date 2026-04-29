import 'dart:async';
import 'package:amap_flutter_location_plus/amap_flutter_location_plus.dart';
import 'package:amap_flutter_location_plus/amap_location_option.dart';
import 'package:flutter/foundation.dart';

class AMapLocationResult {
  final double latitude;
  final double longitude;
  final String? address;
  final String? province;
  final String? city;
  final String? district;
  final String? street;
  final String? streetNumber;
  final double? accuracy;
  final int errorCode;
  final String? errorInfo;

  AMapLocationResult({
    required this.latitude,
    required this.longitude,
    this.address,
    this.province,
    this.city,
    this.district,
    this.street,
    this.streetNumber,
    this.accuracy,
    this.errorCode = 0,
    this.errorInfo,
  });

  bool get isSuccess => errorCode == 0;
}

class AMapLocationService {
  static final AMapLocationService _instance = AMapLocationService._internal();
  factory AMapLocationService() => _instance;
  AMapLocationService._internal();

  Future<AMapLocationResult> getCurrentLocation() async {
    final completer = Completer<AMapLocationResult>();
    final locationPlugin = AMapFlutterLocation();
    StreamSubscription<Map<String, Object>>? subscription;

    subscription = locationPlugin.onLocationChanged().listen((result) {
      subscription?.cancel();

      debugPrint('AMapLocation: Raw result: $result');

      final locationType = result['locationType'] as int? ?? 0;
      final errorCode = result['errorCode'] as int?;
      final errorInfo = result['errorInfo'] as String?;

      // locationType > 0 表示定位成功，errorCode == 0 也表示成功
      if (locationType <= 0 && errorCode != null && errorCode != 0) {
        debugPrint('AMapLocation: Error $errorCode - $errorInfo');
        completer.complete(AMapLocationResult(
          latitude: 0,
          longitude: 0,
          errorCode: errorCode,
          errorInfo: errorInfo,
        ));
        return;
      }

      final locationResult = AMapLocationResult(
        latitude: (result['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (result['longitude'] as num?)?.toDouble() ?? 0,
        address: result['address'] as String?,
        province: result['province'] as String?,
        city: result['city'] as String?,
        district: result['district'] as String?,
        street: result['street'] as String?,
        streetNumber: result['streetNumber'] as String?,
        accuracy: (result['accuracy'] as num?)?.toDouble(),
      );

      debugPrint('AMapLocation: Success - lat=${locationResult.latitude}, lon=${locationResult.longitude}');
      debugPrint('AMapLocation: Address - ${locationResult.address}');
      debugPrint('AMapLocation: LocationType - $locationType');
      completer.complete(locationResult);
    });

    final option = AMapLocationOption(
      needAddress: true,
      onceLocation: true,
      locationMode: AMapLocationMode.Hight_Accuracy,
    );

    locationPlugin.setLocationOption(option);
    locationPlugin.startLocation();

    try {
      return await completer.future.timeout(const Duration(seconds: 30));
    } on TimeoutException {
      subscription.cancel();
      locationPlugin.stopLocation();
      locationPlugin.destroy();
      debugPrint('AMapLocation: Timeout after 30s');
      return AMapLocationResult(
        latitude: 0,
        longitude: 0,
        errorCode: -2,
        errorInfo: '定位超时',
      );
    }
  }
}
