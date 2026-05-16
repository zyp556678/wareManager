# WearWise (穿戴管家)

Flutter 衣橱管理应用。SDK >= 3.11.5。版本 2.0.0+2。单包 Flutter App，非 monorepo。

## 命令

```bash
flutter pub get                   # 安装依赖
flutter run                       # 运行
flutter analyze                   # 静态分析 (先跑这个再跑测试)
flutter test                      # 运行 widget test
flutter build apk --release       # 构建 APK
dart run flutter_launcher_icons   # 生成应用图标
```

## 架构

- **入口**: `lib/main.dart` → `WearWiseApp` → `MainScreen`
- **状态管理**: `ClothingProvider`, `ThemeProvider`, `WeatherProvider` (Provider)
- **数据库**: `DatabaseHelper` (sqflite 单例, db version=6)
- **导航**: 底部 4 tab (首页/衣橱/录入/我的)
  - IndexedStack 索引 0=首页, 1=衣橱, 2=我的
  - 导航栏索引 0=首页, 1=衣橱, 2=录入, 3=我的
  - 录入页通过 `Navigator.push` 路由跳转，不在 IndexedStack 中
  - 索引映射: `navIndex >= 2 ? navIndex - 1 : navIndex` → stackIndex
- **衣橱页**: `WardrobeScreen` 内含 3 个子 tab (衣物/闲置/穿搭日志)
- **语言**: 硬编码 `zh_CN`，`supportedLocales` 含 `en_US` 但无切换入口
- **UI 风格**: Bento Grid 首页，GlassCard/GlassButton/GlassNavBar 组件

## 天气模块 (v2.0.0 重构)

### 核心文件
- `lib/services/weather_scraper.dart` — Open-Meteo API 封装
- `lib/providers/weather_provider.dart` — 天气状态管理
- `lib/models/weather_data.dart` — 天气数据模型
- `lib/models/city_coords.dart` — 城市经纬度静态映射表 (49 城市)
- `lib/widgets/weather_card.dart` — 首页天气卡片
- `lib/screens/weather_detail_screen.dart` — 天气详情页
- `lib/screens/city_search_screen.dart` — 城市选择页

### API 说明
- **数据源**: Open-Meteo API (`https://api.open-meteo.com/v1/forecast`)
- **免费、无需 Key、支持全球任意经纬度**
- **请求参数**: `latitude`, `longitude`, `current`(温度/湿度/天气码/风速/风向), `daily`(天气码/最高温/最低温/最大风速), `timezone=auto`, `forecast_days=7`
- **天气代码映射**: 0=晴, 1=大部晴朗, 2=多云, 3=阴, 45/48=雾, 51-57=毛毛雨, 61-67=雨, 71-77=雪, 80-82=阵雨, 85-86=阵雪, 95-99=雷暴

### Geocoding 策略 (v2.0.0+2 修复)
- **问题**: Open-Meteo geocoding API 对带"市"后缀的城市（珠海市、佛山市等 22 个城市）返回空结果，上海市带"市"查询返回美国地名
- **解决方案**: 三级查找策略
  1. 优先查 `cityCoordinates` 静态映射表（命中即返回，无需网络请求）
  2. 未命中则用原始名称调用 geocoding API
  3. 仍无结果则去掉"市"后缀重试
- **城市列表**: `city_search_screen.dart:19-31` 定义了 43 个 `_allCities`，映射表覆盖 49 个城市（含直辖市变体）

### 定位策略
- **默认行为**: 启动时尝试基于定位获取天气
- **桌面端/Web**: 不支持定位，直接提示用户手动选择城市
- **移动端**: 使用高德定位 (`AMapLocationService`)，30 秒超时
- **权限处理**: 拒绝/永久拒绝时返回错误提示，不崩溃
- **缓存键**: 定位天气使用 `'current_location'` 作为缓存键，城市天气使用城市名

### 模式切换
- `switchToLocationWeather()` — 切换到定位模式，保存 `weather_use_location=true`
- `switchToCityWeather(cityName)` — 切换到城市模式，保存 `weather_use_location=false`
- `loadFromPrefs()` — 根据 `weather_use_location` 决定加载方式
- **UI 表现**: 天气卡片非定位模式时显示"定位"按钮可一键切换回定位

### 预报显示
- 返回 7 天预报
- 今天/明天/后天显示中文，其余显示星期几

## 相机模块 (v2.0.0 增强)

### 核心文件
- `lib/screens/capture_screen.dart` — 拍照主界面
- `lib/screens/photo_confirm_screen.dart` — 照片确认页

### 放大功能 (仿小米 Leica 策略)
- **双指捏合缩放**: `onScaleUpdate` 监听，`_currentZoom * details.scale` 计算新倍率
- **双击切换**: 双击在 1x 和 2x 之间快速切换
- **预设档位**: 动态生成 0.5x/1x/2x/5x 按钮（根据 `_maxZoom` 能力）
- **滑动条微调**: 点击 `zoom_in` 图标展开 `Slider`，范围 `_minZoom` ~ `_maxZoom`
- **最大缩放**: 硬编码 `_maxZoom = 10.0`（camera 包 API 限制，无法直接获取 `maxAvailableZoom`）
- **缩放设置**: `_controller!.setZoomLevel(clampedZoom)`

### 系统相机
- `_takePhotoWithSystemCamera()` — 使用 `image_picker.pickImage(source: ImageSource.camera)`
- 底部按钮布局: 相册 → 系统相机 → 应用内快门 → 切换摄像头

### 其他功能
- 闪光灯切换: off → auto → always → off (循环)
- 点击对焦: `setFocusPoint` + `setExposurePoint` + 对焦动画
- 快门动画: 按压缩放 1.0 → 0.85
- 切换摄像头: 后置/前置切换，重新初始化相机

## 地点管理 (v2.0.0 修复)

### 核心文件
- `lib/screens/location_management_page.dart`
- `lib/models/location.dart`

### 修复内容
- **定位兜底**: `getLastKnownPosition()` 优先 → 兜底 `getCurrentPosition(medium)`，解决模拟器无 GPS 超时问题
- **地址溢出**: 地址文本使用 `Expanded` + `TextOverflow.ellipsis`，防止长地址溢出 Row
- **地址列**: `locations` 表 `address` 列已在 `_createDB` 中包含（v6 迁移通过 `ALTER TABLE` 添加，对旧库兼容）

## 主题系统

### 默认行为
- **`ThemeMode.system`** — 默认跟随系统（`_prefs.getInt('themeMode') ?? 0`）
- 索引: 0=system, 1=light, 2=dark

### 5 套配色
| 索引 | 名称 | 主色 |
|------|------|------|
| 0 | 冰川蓝 | `#5B9BD5` |
| 1 | 翡翠绿 | `#4CAF50` |
| 2 | 玫瑰金 | `#D4A574` |
| 3 | 星空紫 | `#9B7ED8` |
| 4 | 月光银 | `#95A5A6` |

### 关键属性
- `ThemeProvider.isDark` — 检查 `_themeMode` 并回退到 `platformDispatcher.platformBrightness`
- `glassColor` / `glassBorderColor` / `glassOverlayColor` — 玻璃效果颜色配置

## 数据库 (version=6)

5 张表: `clothing_items`(status: active/idle), `outfits`, `outfit_logs`, `locations`, `operation_logs`(type: add/idle/wakeup/delete/edit)

- **`locations` 表**: `address` 列已在 `_createDB` 中包含（v6 迁移通过 `ALTER TABLE` 添加，对旧库兼容）
- **升级逻辑**: `_upgradeDB` in `database_helper.dart` — 改 schema 必须同时改 `version` 和 `onUpgrade`

## 缓存清理 (v2.0.0 修复)

- 缓存清理逻辑已修复，确保 SharedPreferences 和数据库数据正确清除
- 天气缓存使用 `${_cacheKey}_$cityName` 和 `${_cacheTimeKey}_$cityName` 格式

## 代码模式

- **无枚举**: `category`(上衣/裤子/裙装/外套), `status`(active/idle), `season`, `operation_log.type`(add/delete/idle/wakeup) 均为自由字符串，编译器不检查拼写
- **操作日志**: `clothingName` 固定格式 `'${category} · ${color}'`（中间号分隔）
- **`setIdle` 会全量重载**衣物列表 (`loadClothingItems()`)，其他变更方法 (`updateClothingItem`/`wakeUpIdle`) 不会，UI 可能过期
- **`deleteClothingItem`/`wakeUpIdle` 无错误处理** — id 不存在时直接抛异常
- **`ThemeProvider.isDark`** 不等同于 `Theme.of(context).brightness` — 它检查 provider 的 `_themeMode` 并回退到 `platformDispatcher`
- **`scaffoldBackgroundColor` 为实色背景** — 由主题 `cs.surface` 提供，不需要页面自行绘制
- **GlassCard 的 `margin` 实为 `Padding`** 包裹组件，非 `Container.margin`，影响 `SingleChildScrollView` 布局

## Lint 配置 (analysis_options.yaml)

- 基于 `flutter_lints`
- `deprecated_member_use`: ignore
- `use_build_context_synchronously`: ignore
- 偏好单引号 `prefer_single_quotes`

## 已知问题

- `assets/images/` 目录不存在 → `flutter pub get` 会有 warning
- `withOpacity` 已弃用 → 用 `withValues(alpha:)`
- `ThemeData.background` 已弃用 → 用 `surface`
- 大量 `print()` 调试语句
- `FormField.value` → 用 `initialValue`
- `Radio.groupValue/onChanged` → 用 `RadioGroup`
- `test/widget_test.dart` 断言 `BottomNavigationBar` 但实际用的是 `GlassNavBar`，测试已过期

## 陷阱

- 新 clone 后需 `flutter create .` 生成平台工程文件
- AndroidStudio 必须打开根目录 `wareManager/`
- 数据库升级需同时改 `version` + `onUpgrade` 逻辑
- 权限请求在 `main()` 中同步执行 (camera/storage/photos/location)
- `MainScreenState` 是 public (供子页面调用 `setTabIndex`/`setWardrobeTab`)
- `WardrobeScreenState` 也是 public (供外部调用 `switchToTab`)
- **桌面端/Web 不支持高德定位**，天气模块会跳过定位直接提示
- **camera 包无法直接获取 `maxAvailableZoom`**，最大缩放硬编码为 10.0
- **天气缓存按城市名隔离**，定位天气使用 `'current_location'` 作为缓存键
- **AMap API Key 硬编码在 `main.dart:22`**，隐私合规初始化在 `main()` 中同步执行
