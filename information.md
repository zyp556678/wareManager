# WearWise (穿戴管家) — 接口文档

> Flutter 衣橱管理应用 | SDK >= 3.11.5 | 版本 2.0.0+3 | 单包 App

---

## 目录

- [1. 数据模型](#1-数据模型)
  - [1.1 ClothingItem — 衣物](#11-clothingitem--衣物)
  - [1.2 Outfit — 穿搭](#12-outfit--穿搭)
  - [1.3 OutfitLog — 穿搭日志](#13-outfitlog--穿搭日志)
  - [1.4 Location — 存放地点](#14-location--存放地点)
  - [1.5 WeatherData — 天气数据](#15-weatherdata--天气数据)
  - [1.6 OperationLog — 操作日志](#16-operationlog--操作日志)
  - [1.7 CityCoordinates — 城市经纬度映射表](#17-citycoordinates--城市经纬度映射表)
- [2. 服务层](#2-服务层)
  - [2.1 DatabaseHelper — 数据库](#21-databasehelper--数据库)
  - [2.2 WeatherScraper — 天气 API](#22-weatherscraper--天气-api)
  - [2.3 AMapLocationService — 高德定位](#23-amaplocationservice--高德定位)
- [3. 状态管理](#3-状态管理)
  - [3.1 ClothingProvider — 衣物状态](#31-clothingprovider--衣物状态)
  - [3.2 WeatherProvider — 天气状态](#32-weatherprovider--天气状态)
  - [3.3 ThemeProvider — 主题状态](#33-themeprovider--主题状态)
- [4. 工具函数](#4-工具函数)
  - [4.1 Idle Utils — 闲置工具](#41-idle-utils--闲置工具)
  - [4.2 Image Utils — 图片工具](#42-image-utils--图片工具)
- [5. 应用入口](#5-应用入口)
  - [5.1 main() — 初始化](#51-main--初始化)
  - [5.2 WearWiseApp — 根组件](#52-wearwiseapp--根组件)
  - [5.3 MainScreen — 主导航](#53-mainscreen--主导航)
- [6. 自定义组件](#6-自定义组件)
  - [6.1 GlassCard / GlassContainer](#61-glasscard--glasscontainer)
  - [6.2 GlassButton / GlassIconButton](#62-glassbutton--glassiconbutton)
  - [6.3 GlassNavBar / NavBarItem](#63-glassnavbar--navbaritem)
  - [6.4 BentoGrid / BentoItem](#64-bentogrid--bentoitem)
  - [6.5 WeatherCard](#65-weathercard)
- [7. 页面清单](#7-页面清单)

---

## 1. 数据模型

### 1.1 ClothingItem — 衣物

**文件:** `lib/models/clothing_item.dart`

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `id` | `int?` | `null` | 自增主键 |
| `imagePath` | `String` | 必填 | 本地图片路径 |
| `category` | `String` | 必填 | 上衣 / 裤子 / 裙装 / 外套 / 鞋子 / 配饰 |
| `color` | `String` | 必填 | 颜色 |
| `material` | `String` | 必填 | 棉 / 麻 / 丝 / 羊毛 / 涤纶 / 牛仔 |
| `style` | `String` | 必填 | 休闲 / 商务 / 运动 / 复古 / 简约 / 时尚 |
| `season` | `String` | `''` | 四季 / 春季 / 夏季 / 秋季 / 冬季 / 春秋 / 春秋冬 |
| `customTags` | `List<String>` | `[]` | 用户自定义标签 |
| `status` | `String` | `'active'` | `'active'` \| `'idle'` |
| `idleFrom` | `DateTime?` | `null` | 闲置开始日期 |
| `idleUntil` | `DateTime?` | `null` | 闲置结束日期 |
| `storageLocation` | `String` | `''` | 存放地点名称 |
| `createdDate` | `DateTime` | 必填 | 录入日期 |

**方法:**

```dart
// 序列化为数据库 map（customTags 用逗号拼接，DateTime 转毫秒时间戳）
Map<String, dynamic> toMap()

// 从数据库 map 反序列化（customTags 按逗号分割）
factory ClothingItem.fromMap(Map<String, dynamic> map)

// 不可变更新
ClothingItem copyWith({
  int? id, String? imagePath, String? category, String? color,
  String? material, String? style, String? season,
  List<String>? customTags, String? status,
  DateTime? idleFrom, DateTime? idleUntil,
  String? storageLocation, DateTime? createdDate,
})
```

---

### 1.2 Outfit — 穿搭

**文件:** `lib/models/outfit.dart`

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `id` | `int?` | `null` | 自增主键 |
| `clothingIds` | `List<int>` | 必填 | 衣物 ID 列表（DB 中逗号分隔） |
| `styleTag` | `String` | 必填 | 风格标签 |
| `createdDate` | `DateTime` | 必填 | 创建日期 |
| `timesWorn` | `int` | `0` | 穿着次数 |

**方法:** `toMap()`, `factory Outfit.fromMap(Map)`

---

### 1.3 OutfitLog — 穿搭日志

**文件:** `lib/models/outfit_log.dart`

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `id` | `int?` | `null` | 主键 |
| `outfitId` | `int` | 必填 | 关联穿搭 |
| `date` | `DateTime` | 必填 | 穿着日期 |
| `weather` | `String` | 必填 | 天气描述 |
| `occasion` | `String` | 必填 | 场合 |

**方法:** `toMap()`, `factory OutfitLog.fromMap(Map)`

---

### 1.4 Location — 存放地点

**文件:** `lib/models/location.dart`

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `id` | `int?` | `null` | 自增主键 |
| `name` | `String` | 必填 | 地点名称 |
| `type` | `String` | 必填 | `'home'` \| `'office'` \| `'gym'` \| `'travel'` \| `'other'` |
| `description` | `String?` | `null` | 备注 |
| `address` | `String?` | `null` | GPS 逆地理编码地址 |
| `createdAt` | `DateTime` | 必填 | 创建时间 |

**方法:** `toMap()`, `factory Location.fromMap(Map)`, `copyWith({...})`

**Getter:** `String get typeLabel` — 返回中文标签 (家 / 办公室 / 健身房 / 旅行 / 其他)

---

### 1.5 WeatherData — 天气数据

**文件:** `lib/models/weather_data.dart`

| 字段 | 类型 | 说明 |
|------|------|------|
| `cityName` | `String` | 城市名称 |
| `currentTemp` | `int` | 当前温度（取整） |
| `condition` | `String` | 中文天气描述 |
| `humidity` | `int` | 湿度百分比 |
| `windDirection` | `String` | 风向（当前未使用，恒为 `''`） |
| `windLevel` | `String` | 风速，如 `'12km/h'` |
| `aqi` | `int` | 空气质量（当前未使用，恒为 `0`） |
| `aqiLevel` | `String` | 空气质量等级（当前未使用，恒为 `''`） |
| `forecasts` | `List<DailyForecast>` | 7 天预报 |
| `updatedAt` | `DateTime` | 更新时间 |

**方法:** `toJson()`, `factory WeatherData.fromJson(Map)`

#### DailyForecast (嵌套类)

| 字段 | 类型 | 说明 |
|------|------|------|
| `day` | `String` | 今天 / 明天 / 后天 / 周一~周日 |
| `condition` | `String` | 中文天气描述 |
| `tempLow` | `int` | 最低温 |
| `tempHigh` | `int` | 最高温 |
| `wind` | `String` | 风速，如 `'25km/h'` |

**方法:** `toJson()`, `factory DailyForecast.fromJson(Map)`

---

### 1.6 OperationLog — 操作日志

**文件:** `lib/models/operation_log.dart`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | `int?` | 主键 |
| `type` | `String` | `'add'` \| `'idle'` \| `'wakeup'` \| `'delete'` \| `'edit'` |
| `clothingId` | `int?` | 关联衣物 ID |
| `clothingName` | `String?` | 格式: `'{category} · {color}'` （中间号分隔） |
| `content` | `String?` | 例如: 新增衣物 / 设为闲置 / 唤醒衣物 / 删除衣物 / 编辑衣物 |
| `extra` | `String?` | 例如: 闲置日期范围 + 存放地点 |
| `createdAt` | `DateTime` | 操作时间 |

**DB 字段映射:** `clothingId` → `clothing_id`, `clothingName` → `clothing_name`, `createdAt` → `created_at`

**方法:** `toMap()`, `factory OperationLog.fromMap(Map)`

**Getter:** `String get operationText` — 返回中文操作名称

---

### 1.7 CityCoordinates — 城市经纬度映射表

**文件:** `lib/models/city_coords.dart`

```dart
const Map<String, Map<String, double>> cityCoordinates
```

共 49 个中国城市，key 为城市名（如 `'北京市'`），value 包含 `'lat'` 和 `'lon'`。

| # | 城市 | 纬度 | 经度 |
|---|------|------|------|
| 1 | 北京市 | 39.9075 | 116.3972 |
| 2 | 上海市 | 31.2222 | 121.4581 |
| 3 | 天津市 | 39.1422 | 117.1767 |
| 4 | 重庆市 | 29.5603 | 106.5577 |
| 5 | 广州市 | 23.1167 | 113.2500 |
| 6 | 深圳市 | 22.5455 | 114.0683 |
| 7 | 杭州市 | 30.2937 | 120.1614 |
| 8 | 南京市 | 32.0617 | 118.7778 |
| 9 | 苏州市 | 31.3041 | 120.5954 |
| 10 | 成都市 | 30.6667 | 104.0667 |
| 11 | 武汉市 | 30.5833 | 114.2667 |
| 12 | 西安市 | 34.2583 | 108.9286 |
| 13 | 长沙市 | 28.2280 | 112.9390 |
| 14 | 郑州市 | 34.7578 | 113.6486 |
| 15 | 青岛市 | 36.0649 | 120.3804 |
| 16 | 大连市 | 38.9122 | 121.6022 |
| 17 | 沈阳市 | 41.7922 | 123.4328 |
| 18 | 哈尔滨市 | 45.7500 | 126.6500 |
| 19 | 长春市 | 43.8800 | 125.3228 |
| 20 | 济南市 | 36.6683 | 116.9972 |
| 21 | 福州市 | 26.0614 | 119.3061 |
| 22 | 厦门市 | 24.4798 | 118.0819 |
| 23 | 昆明市 | 25.0389 | 102.7183 |
| 24 | 贵阳市 | 26.5833 | 106.7167 |
| 25 | 南昌市 | 28.6840 | 115.8531 |
| 26 | 合肥市 | 31.8639 | 117.2808 |
| 27 | 太原市 | 37.8694 | 112.5603 |
| 28 | 石家庄市 | 38.0414 | 114.4786 |
| 29 | 兰州市 | 36.0570 | 103.8399 |
| 30 | 南宁市 | 22.8167 | 108.3167 |
| 31 | 海口市 | 20.0342 | 110.3465 |
| 32 | 银川市 | 38.4681 | 106.2731 |
| 33 | 西宁市 | 36.6255 | 101.7574 |
| 34 | 拉萨市 | 29.6500 | 91.1000 |
| 35 | 乌鲁木齐市 | 43.8010 | 87.6005 |
| 36 | 呼和浩特市 | 40.8106 | 111.6522 |
| 37 | 珠海市 | 22.2769 | 113.5678 |
| 38 | 佛山市 | 23.0268 | 113.1315 |
| 39 | 东莞市 | 23.0180 | 113.7487 |
| 40 | 无锡市 | 31.5689 | 120.2886 |
| 41 | 常州市 | 31.7736 | 119.9540 |
| 42 | 宁波市 | 29.8782 | 121.5495 |
| 43 | 温州市 | 27.9994 | 120.6668 |
| 44 | 嘉兴市 | 30.7522 | 120.7500 |
| 45 | 烟台市 | 37.4765 | 121.4408 |
| 46 | 潍坊市 | 36.7100 | 119.1019 |
| 47 | 洛阳市 | 34.6735 | 112.4368 |
| 48 | 三亚市 | 18.2544 | 109.5095 |
| 49 | 桂林市 | 25.2802 | 110.2964 |

---

## 2. 服务层

### 2.1 DatabaseHelper — 数据库

**文件:** `lib/services/database_helper.dart`  
**单例:** `DatabaseHelper.instance`  
**数据库:** `wearwise.db` (version=7, sqflite)

#### 表结构

**clothing_items**
```sql
id            INTEGER PRIMARY KEY AUTOINCREMENT
imagePath     TEXT NOT NULL
category      TEXT NOT NULL
color         TEXT NOT NULL
material      TEXT NOT NULL
style         TEXT NOT NULL
season        TEXT
customTags    TEXT                  -- 逗号分隔
status        TEXT DEFAULT 'active' -- 'active' | 'idle'
idleFrom      INTEGER               -- 毫秒时间戳
idleUntil     INTEGER               -- 毫秒时间戳
storageLocation TEXT
createdDate   INTEGER NOT NULL
```

**outfits**
```sql
id            INTEGER PRIMARY KEY AUTOINCREMENT
clothingIds   TEXT NOT NULL          -- 逗号分隔
styleTag      TEXT NOT NULL
createdDate   INTEGER NOT NULL
timesWorn     INTEGER NOT NULL DEFAULT 0
```

**outfit_logs**
```sql
id            INTEGER PRIMARY KEY AUTOINCREMENT
outfitId      INTEGER NOT NULL
date          INTEGER NOT NULL
weather       TEXT NOT NULL
occasion      TEXT NOT NULL
```

**locations**
```sql
id            INTEGER PRIMARY KEY AUTOINCREMENT
name          TEXT NOT NULL
type          TEXT NOT NULL           -- 'home'|'office'|'gym'|'travel'|'other'
description   TEXT
address       TEXT
createdAt     INTEGER NOT NULL
```

**operation_logs**
```sql
id            INTEGER PRIMARY KEY AUTOINCREMENT
type          TEXT NOT NULL           -- 'add'|'idle'|'wakeup'|'delete'|'edit'
clothing_id   INTEGER
clothing_name TEXT
content       TEXT
extra         TEXT
created_at    INTEGER NOT NULL
```

#### 数据库迁移

| 旧版本 | 变更 |
|--------|------|
| < 5 | `locations` 新增 `latitude REAL`, `longitude REAL` |
| < 6 | `locations` 删除 `latitude`/`longitude`，新增 `address TEXT` |
| < 7 | `clothing_items` 新增 `idleFrom INTEGER` |

#### 公共方法

```dart
// ===== 衣物 =====
Future<int>  createClothingItem(ClothingItem item)
Future<List<ClothingItem>> getAllClothingItems()           // 按 createdDate DESC
Future<List<ClothingItem>> getClothingByCategory(String category)
Future<List<ClothingItem>> getIdleClothingItems()          // status='idle', 按 idleUntil ASC
Future<int>  updateClothingItem(ClothingItem item)
Future<int>  deleteClothingItem(int id)

// ===== 穿搭 =====
Future<int>  createOutfit(Outfit outfit)
Future<List<Outfit>> getAllOutfits()                        // 按 createdDate DESC

// ===== 穿搭日志 =====
Future<int>  createOutfitLog(OutfitLog log)
Future<List<OutfitLog>> getOutfitLogsByMonth(DateTime month)

// ===== 地点 =====
Future<int>  createLocation(Location location)
Future<List<Location>> getAllLocations()                    // 按 createdAt DESC
Future<int>  updateLocation(Location location)
Future<int>  deleteLocation(int id)

// ===== 操作日志 =====
Future<int>  createOperationLog(OperationLog log)
Future<List<OperationLog>> getAllOperationLogs()            // 按 created_at DESC
Future<List<OperationLog>> getOperationLogsByMonth(DateTime month)

// ===== 生命周期 =====
Future<void> close()
```

---

### 2.2 WeatherScraper — 天气 API

**文件:** `lib/services/weather_scraper.dart`  
**所有方法均为 static**  
**数据源:** [Open-Meteo API](https://open-meteo.com/) (免费, 无需 Key)

#### 天气代码映射 (39 种)

| 代码 | 描述 |
|------|------|
| 0 | 晴 |
| 1 | 大部晴朗 |
| 2 | 多云 |
| 3 | 阴 |
| 45, 48 | 雾 / 结冰雾 |
| 51-57 | 毛毛雨（小/中/大） |
| 61-67 | 雨（小/中/大/暴/冰/雨夹雪） |
| 71-77 | 雪（小/中/大/暴/雪粒/钻石尘） |
| 80-82 | 阵雨（小/中/大） |
| 85-86 | 阵雪（小/大） |
| 95-99 | 雷暴（普通/小冰雹/大冰雹） |

#### 公共方法

```dart
/// 基于经纬度获取天气
/// 超时: 15s
static Future<WeatherData> fetchWeatherByCoords(
  double lat,
  double lon,
  {String? cityName}   // 可选，用于 WeatherData.cityName，不传则显示 '当前位置'
)

/// 基于城市名获取天气（先 geocoding → 再调用 fetchWeatherByCoords）
static Future<WeatherData> fetchWeather(String cityName)

/// 日期 → 中文星期名
/// 0 天差 → '今天', 1 → '明天', 2 → '后天', 其他 → 周一~周日
static String _getDayName(DateTime date)
```

#### Geocoding 三级查找策略

1. 优先查 `cityCoordinates` 静态映射表（命中即返回，无需网络）
2. 未命中则调用 Open-Meteo Geocoding API:  
   `GET https://geocoding-api.open-meteo.com/v1/search?name={name}&count=1&language=zh&format=json` (10s 超时)
3. 仍无结果则去掉"市"后缀重试

#### 请求接口

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude={lat}
  &longitude={lon}
  &current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,wind_direction_10m
  &daily=weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max
  &timezone=auto
  &forecast_days=7
```

#### 响应解析

- `currentTemperature` ← `current.temperature_2m` (取整)
- `condition` ← `current.weather_code` (查天气代码映射表)
- `humidity` ← `current.relative_humidity_2m`
- `windLevel` ← `current.wind_speed_10m` km/h
- `windDirection` — 恒为 `''`
- `aqi` / `aqiLevel` — 恒为 `0` / `''`
- `forecasts` ← `daily.time[i]` ~ `daily.wind_speed_10m_max[i]` (最多 7 天)

---

### 2.3 AMapLocationService — 高德定位

**文件:** `lib/services/amap_location_service.dart`  
**单例:** `AMapLocationService()`

#### AMapLocationResult (返回值)

| 字段 | 类型 | 说明 |
|------|------|------|
| `latitude` | `double` | 纬度 |
| `longitude` | `double` | 经度 |
| `address` | `String?` | 完整逆地理编码地址 |
| `province` | `String?` | 省份 |
| `city` | `String?` | 城市 |
| `district` | `String?` | 区县 |
| `street` | `String?` | 街道 |
| `streetNumber` | `String?` | 门牌号 |
| `accuracy` | `double?` | 定位精度 |
| `errorCode` | `int` | 0 = 成功 |
| `errorInfo` | `String?` | 错误信息 |
| `isSuccess` | `bool` | `errorCode == 0` |

#### 方法

```dart
/// 获取当前定位
/// 超时: 30s（超时返回 errorCode=-2, errorInfo='定位超时'）
/// 桌面端/Web 不支持
Future<AMapLocationResult> getCurrentLocation()
```

---

## 3. 状态管理

### 3.1 ClothingProvider — 衣物状态

**文件:** `lib/providers/clothing_provider.dart`  
**基类:** `ChangeNotifier`

#### 状态字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `_clothingItems` | `List<ClothingItem>` | 全部衣物（DB 数据源） |
| `_activeClothing` | `List<ClothingItem>` | 缓存: `status == 'active'` |
| `_idleClothing` | `List<ClothingItem>` | 缓存: `status == 'idle'` |
| `_operationLogs` | `List<OperationLog>` | 全部操作日志 |
| `_isLoading` | `bool` | 加载状态 |

#### Getters

```dart
List<ClothingItem> get clothingItems
List<ClothingItem> get activeClothing
List<ClothingItem> get idleClothing
List<OperationLog> get operationLogs
bool get isLoading
```

#### 方法

```dart
Future<void> loadClothingItems()                          // 全量重载: 衣物 + 日志 + 重建缓存

Future<void> addClothingItem(ClothingItem item)           // 插入 DB + 自动创建操作日志
                                                          //   status='idle' 且有日期 → 创建 'idle' 日志
                                                          //   否则 → 创建 'add' 日志

Future<void> updateClothingItem(ClothingItem item)        // 按 id 更新 DB + 本地列表
                                                          //   重建缓存，不通知删除日志

Future<void> deleteClothingItem(int id)                   // 删除 DB + 本地列表，创建 'delete' 日志

Future<void> setIdle(int id, DateTime from, DateTime to,
                     String location)                    // 设为闲置: copyWith + 创建 'idle' 日志
                                                          //   **会全量重载衣物列表**

Future<void> wakeUpIdle(int id)                           // 唤醒: status='active', idleUntil=null
                                                          //   创建 'wakeup' 日志
                                                          //   **不会重载列表，UI 可能过期**

List<ClothingItem> getByCategory(String category)         // 同步筛选 active 衣物按分类

Future<void> addOperationLog(OperationLog log)            // 插入操作日志到 DB + 本地列表
```

> ⚠️ **注意:** `setIdle` 会调用 `loadClothingItems()` 全量重载，`updateClothingItem` 和 `wakeUpIdle` 不会。删除方法和唤醒方法无错误处理（id 不存在时抛异常）。

---

### 3.2 WeatherProvider — 天气状态

**文件:** `lib/providers/weather_provider.dart`  
**基类:** `ChangeNotifier`  
**缓存:** SharedPreferences, 按城市名隔离, 30 分钟 TTL

#### 状态字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `_weather` | `WeatherData?` | 缓存的天气数据 |
| `_isLoading` | `bool` | 加载中 |
| `_error` | `String?` | 错误信息 |
| `_cityName` | `String?` | 当前城市 |

#### Getters

```dart
WeatherData? get weather
bool get isLoading
String? get error
String? get cityName
bool get hasData               // _weather != null
```

#### 方法

```dart
// 按城市名加载天气（先查缓存 → 过期则重新请求）
Future<void> loadWeather(String cityName)

// 强制刷新当前城市
Future<void> refreshWeather()

// 切换城市
Future<void> changeCity(String cityName)

// 基于定位加载天气（缓存键: 'current_location'）
Future<void> loadWeatherByCoords(double lat, double lon)

// 清除错误
void clearError()

// 从 SharedPreferences 恢复上一次的模式和城市
//   判断 weather_use_location:
//     true  → loadWeatherByLocation()
//     false → loadWeather(savedCity)
Future<void> loadFromPrefs()

// 基于高德定位获取天气
//   桌面端/Web 直接返回错误提示
//   缓存键: 'current_location'
Future<void> loadWeatherByLocation()

// 切换到定位模式，保存 weather_use_location = true
Future<void> switchToLocationWeather()

// 切换到城市模式，保存 weather_use_location = false
Future<void> switchToCityWeather(String cityName)
```

#### 缓存键格式

- 城市模式: `${_cacheKey}_$cityName` / `${_cacheTimeKey}_$cityName`
- 定位模式: `${_cacheKey}_current_location` / `${_cacheTimeKey}_current_location`

---

### 3.3 ThemeProvider — 主题状态

**文件:** `lib/providers/theme_provider.dart`  
**基类:** `ChangeNotifier`

#### 状态字段

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `_colorIndex` | `int` | `0` | 配色索引 0~4 |
| `_themeMode` | `ThemeMode` | `ThemeMode.system` | 0=system, 1=light, 2=dark |

#### Getters

```dart
int get colorIndex
ThemeMode get themeMode
ThemeData get lightTheme           // 根据 _colorIndex 构建 light ColorScheme
ThemeData get darkTheme            // 根据 _colorIndex 构建 dark ColorScheme

bool get isDark                    // 检查 _themeMode:
                                   //   dark → true, light → false
                                   //   system → platformDispatcher.platformBrightness

Color get glassColor               // 玻璃效果背景色
Color get glassBorderColor         // 玻璃效果边框色
Color get glassOverlayColor        // 玻璃效果叠加色
```

#### 方法

```dart
void setColorScheme(int index)     // 0~4, 持久化到 SharedPreferences
void setThemeMode(ThemeMode mode)  // 持久化到 SharedPreferences
```

#### 5 套配色方案

| 索引 | 名称 | Light 主色 | Dark 主色 |
|------|------|------------|-----------|
| 0 | 冰川蓝 | `#5B9BD5` | `#7BB8E0` |
| 1 | 翡翠绿 | `#4CAF50` | `#66BB6A` |
| 2 | 玫瑰金 | `#D4A574` | `#E0B88A` |
| 3 | 星空紫 | `#9B7ED8` | `#B09AE0` |
| 4 | 月光银 | `#95A5A6` | `#B0BEC5` |

每套配色包含完整 `ColorScheme.light` / `ColorScheme.dark`：  
`primary`, `onPrimary`, `secondary`, `onSecondary`, `surface`, `onSurface`, `error`, `onError`, `outline`

**静态:** `static const List<String> colorNames = ['冰川蓝', '翡翠绿', '玫瑰金', '星空紫', '月光银']`

> ⚠️ `ThemeProvider.isDark` 不等同于 `Theme.of(context).brightness`——它直接检查 `_themeMode` 并回退到 `platformDispatcher`。

---

## 4. 工具函数

### 4.1 Idle Utils — 闲置工具

**文件:** `lib/utils/idle_utils.dart`

```dart
/// 弹出底部弹窗展示所有地点列表
/// 返回选中地点的 name，若无地点则引导新增
Future<String?> showLocationPicker(BuildContext context)

/// 弹出新增地点对话框（含名称、类型、描述、地址，支持 GPS 定位）
/// 返回新创建地点的 name
Future<String?> showAddLocationDialog(BuildContext context)
```

类型图标/颜色映射: home→🏠(蓝), office→💼(紫), gym→🏃(绿), travel→✈️(橙), other→📍(灰)

---

### 4.2 Image Utils — 图片工具

**文件:** `lib/utils/image_utils.dart`

```dart
/// 将临时图片复制到应用持久化目录
/// 目标路径: {appDir}/images/{timestamp}{ext}
/// 返回新的绝对路径
Future<String> saveImageToAppDir(String tempPath)
```

---

## 5. 应用入口

### 5.1 main() — 初始化

**文件:** `lib/main.dart:16`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 高德定位 SDK 隐私合规初始化
  AMapFlutterLocation.updatePrivacyShow(true, true);
  AMapFlutterLocation.updatePrivacyAgree(true);
  AMapFlutterLocation.setApiKey('be44cd468bf141674cc696c89cc7c07e', '');

  // 同步请求权限: camera → storage → photos → location
  await _requestPermissions();

  runApp(const WearWiseApp());
}
```

### 5.2 WearWiseApp — 根组件

**文件:** `lib/main.dart:51`

```dart
class WearWiseApp extends StatelessWidget {
  // MultiProvider 注入 3 个 Provider:
  //   1. ChangeNotifierProvider<ClothingProvider>()
  //   2. ChangeNotifierProvider<ThemeProvider>()
  //   3. ChangeNotifierProvider<WeatherProvider>(..loadFromPrefs())

  // MaterialApp:
  //   title: '穿戴管家'
  //   themeMode: ThemeProvider.themeMode       (system/light/dark)
  //   locale: Locale('zh', 'CN')              (硬编码)
  //   supportedLocales: [zh_CN, en_US]        (无切换入口)
  //   home: MainScreen()
}
```

### 5.3 MainScreen — 主导航

**文件:** `lib/main.dart:87`  
**State 类:** `MainScreenState` (public)  
`_wardrobeKey`: `GlobalKey<WardrobeScreenState>`

#### 导航架构

```
IndexedStack (3 个子页面):
  [0] HomeScreen     → 首页
  [1] WardrobeScreen → 衣橱（内含 3 个子 tab: 衣物/闲置/穿搭日志）
  [2] ProfileScreen  → 我的

GlassNavBar (4 个导航项):
  [0] 🏠 首页
  [1] 👔 衣橱
  [2] 📸 录入   → Navigator.push → CaptureScreen（不在 IndexedStack 中）
  [3] 👤 我的

索引映射: navIndex >= 2 ? navIndex - 1 : navIndex → stackIndex
```

#### 公共方法

```dart
void setTabIndex(int index)          // index=2 触发 Navigator.push(CaptureScreen)
                                     // index=1 重置衣橱到衣物tab并返回首页tab
                                     // 其他 → 切换 IndexedStack

void setWardrobeTab(int tabIndex)    // 切换到衣橱 tab (stackIndex=1)
                                     //   并调用 WardrobeScreenState.switchToTab(tabIndex)
```

---

## 6. 自定义组件

### 6.1 GlassCard / GlassContainer

**文件:** `lib/widgets/glass_card.dart`

```dart
// 毛玻璃卡片 — 半透明背景 + 1.5px 边框 + 主色投影
const GlassCard({
  required Widget child,           // 内容
  double borderRadius = 20,        // 圆角
  EdgeInsetsGeometry? padding,     // 内边距 (默认 all(16))
  EdgeInsetsGeometry? margin,      // ⚠️ 实为外层 Padding，非 Container.margin
  VoidCallback? onTap,             // 点击回调
  double? height,                  // 固定高度
  double? width,                   // 固定宽度
})

// 简化玻璃容器 — 无投影
const GlassContainer({
  required Widget child,
  double borderRadius = 20,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  Color? color,                    // 覆盖默认半透明背景
})
```

> ⚠️ `GlassCard.margin` 实为 `Padding` 包裹，非 `Container.margin`，影响 `SingleChildScrollView` 布局。

### 6.2 GlassButton / GlassIconButton

**文件:** `lib/widgets/glass_button.dart`

```dart
// 毛玻璃按钮 — 按压缩放 (1.0→0.96) + 触觉反馈
const GlassButton({
  required Widget child,
  VoidCallback? onTap,
  double borderRadius = 14,
  Color? backgroundColor,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  bool isSelected = false,         // true → 填充主色
})

// 圆形毛玻璃图标按钮
const GlassIconButton({
  required IconData icon,
  VoidCallback? onTap,
  double size = 48,                // 按钮直径
  Color? iconColor,
  bool isSelected = false,
})
```

### 6.3 GlassNavBar / NavBarItem

**文件:** `lib/widgets/glass_nav_bar.dart`

```dart
// 悬浮玻璃导航栏 — 胶囊形 (height=64, border-radius=50)，带动画选中指示器
const GlassNavBar({
  required int currentIndex,       // 当前选中索引
  required Function(int) onTap,    // 切换回调
  required List<NavBarItem> items, // 导航项列表
})

const NavBarItem({
  required IconData icon,          // 普通图标
  required IconData selectedIcon,  // 选中图标
  required String label,           // 文字标签
})
```

### 6.4 BentoGrid / BentoItem

**文件:** `lib/widgets/bento_grid.dart`

```dart
// Bento 网格 — 基于 Wrap 的灵活网格布局
const BentoGrid({
  required List<BentoItem> items,
  int crossAxisCount = 2,
  double mainAxisSpacing = 12,
  double crossAxisSpacing = 12,
})

const BentoItem({
  required Widget child,
  int? span,                       // 跨列数 (默认 1)
  double? height,                  // 固定高度 (默认 140)
})
```

### 6.5 WeatherCard

**文件:** `lib/widgets/weather_card.dart`

```dart
const WeatherCard({super.key})     // 无参数
```

根据 `WeatherProvider` 状态展示不同 UI：

| 状态 | 展示 |
|------|------|
| 加载中（无数据） | 旋转指示器 + "正在获取天气..." |
| 错误（无数据） | 错误信息 + "定位获取" / "选择城市" 按钮 |
| 无数据 | 提示文字 + "定位获取"（实心）/ "选择城市"（描边）按钮 |
| 有数据 | 城市名 + 天气图标 + 温度 + 天气描述 + 湿度/风速/AQI 详情行 |
| 城市模式 | 显示"定位"徽章，可一键切回定位模式 |

点击卡片 → 跳转 `WeatherDetailScreen`

---

## 7. 页面清单

| 文件 | 类名 | State | 关键公共接口 |
|------|------|-------|-------------|
| `home_screen.dart` | `HomeScreen` | private | `onNavigateToTab(int)` / `onNavigateToWardrobeTab(int)` |
| `wardrobe_screen.dart` | `WardrobeScreen` | **public**: `WardrobeScreenState` | `switchToTab(int)` (0=衣物, 1=闲置, 2=日志) |
| `capture_screen.dart` | `CaptureScreen` | private | 相机拍照 / 系统相机 / 相册 / 闪光灯 / 对焦 / 缩放 / 切换摄像头 |
| `photo_confirm_screen.dart` | `PhotoConfirmScreen` | private | `imagePath` 参数, 重拍 / 使用照片 |
| `recognition_confirm_page.dart` | `RecognitionConfirmPage` | private | `imagePath` 参数, 保存为 active / 保存为 idle |
| `clothing_detail_page.dart` | `ClothingDetailPage` | StatelessWidget | `item` 参数, 编辑 / 删除 / 设为闲置 / 唤醒 |
| `edit_clothing_page.dart` | `EditClothingPage` | private | `item` 参数, 编辑表单 → `provider.updateClothingItem()` |
| `profile_screen.dart` | `ProfileScreen` | private | `onNavigateToTab(int)` / `onNavigateToWardrobeTab(int)` |
| `settings_page.dart` | `SettingsPage` | private | 主题配色 / 深色模式 / 闲置提醒 / 清理缓存 / 关于 |
| `theme_color_screen.dart` | `ThemeColorScreen` | StatelessWidget | 展示 5 套配色卡片 |
| `version_info_screen.dart` | `VersionInfoScreen` | StatelessWidget | 版本更新日志 |
| `location_management_page.dart` | `LocationManagementPage` | private | 增删改查存放地点 |
| `weather_detail_screen.dart` | `WeatherDetailScreen` | StatelessWidget | 实时天气详情 + 7 天预报 + 穿衣建议 |
| `city_search_screen.dart` | `CitySearchScreen` | private | 49 个城市搜索 + 最近城市 (SharedPreferences 最多 10 个) |
| `profile_edit_page.dart` | `ProfileEditPage` | private | 头像 (相册/系统相机) + 用户名, 返回 `true` 触发刷新 |

---

## 附录

### SharedPreferences 键清单

| 键 | 值类型 | 说明 |
|----|--------|------|
| `themeColorIndex` | `int` | 配色索引 0~4 |
| `themeMode` | `int` | 0=system, 1=light, 2=dark |
| `username` | `String` | 用户昵称 |
| `avatar_path` | `String` | 头像本地路径 |
| `idleReminder` | `bool` | 闲置提醒开关 |
| `weather_use_location` | `bool` | 是否使用定位模式 |
| `saved_city` | `String` | 城市模式下的城市名 |
| `recent_weather_cities` | `List<String>` | 最近搜索城市 (最多 10 个) |
| `weather_cache_{city}` | `String` | 天气 JSON 缓存 |
| `weather_cache_time_{city}` | `int` | 缓存时间戳 |
