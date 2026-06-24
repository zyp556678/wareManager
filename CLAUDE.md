# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

穿戴管家 (WearWise) — Flutter 跨平台衣橱管理 App。单包结构，非 monorepo。版本 2.0.0+3。

## 常用命令

```bash
flutter pub get                   # 安装依赖
flutter run                       # 运行
flutter analyze                   # 静态分析（改代码后先跑这个）
flutter test                      # 运行 widget test
flutter build apk --release       # 构建 APK
dart run flutter_launcher_icons   # 生成应用图标
```

新 clone 后需 `flutter create .` 生成平台工程文件。

## 架构

**入口**: `lib/main.dart` → `WearWiseApp` → `MainScreen`

**导航**: 底部 4 tab（首页/衣橱/录入/我的），IndexedStack 只放 3 页。录入页通过 `Navigator.push` 路由跳转，不在 IndexedStack 中。索引映射: `navIndex >= 2 ? navIndex - 1 : navIndex` → stackIndex。

**状态管理**: Provider — `ClothingProvider`（衣物 CRUD + 闲置）、`ThemeProvider`（5 套配色 + 深色模式）、`WeatherProvider`（天气 + 定位/城市模式切换）。

**数据库**: `DatabaseHelper`（sqflite 单例，version=7）。5 张表: `clothing_items`、`outfits`、`outfit_logs`、`locations`、`operation_logs`。改 schema 必须同时改 `version` 和 `_upgradeDB` 中的 `onUpgrade` 逻辑。

**UI 风格**: Bento Grid 首页，毛玻璃组件（`GlassCard`/`GlassButton`/`GlassNavBar`），基于 `BackdropFilter` + `ImageFilter.blur`。

**衣橱页**: `WardrobeScreen` 内含 3 个子 tab（衣物 `WardrobeTab`、闲置 `IdleTab`、穿搭日志 `OutfitLogTab`）。

**天气模块**: Open-Meteo API（免费、无需 Key）。Geocoding 三级查找策略: 静态映射表 `city_coords.dart` → geocoding API → 去"市"后缀重试。定位用高德 SDK，桌面端/Web 跳过定位直接提示手动选城市。

**语言**: 硬编码 `zh_CN`，`supportedLocales` 含 `en_US` 但无切换入口。

## 关键代码模式

- **无枚举**: `category`（上衣/裤子/裙装/外套）、`status`（active/idle）、`season`、`operation_log.type`（add/delete/idle/wakeup）均为自由字符串，编译器不检查拼写。
- **操作日志**: `clothingName` 格式固定为 `'${category} · ${color}'`。
- **`setIdle` 会全量重载**衣物列表，其他变更方法（`updateClothingItem`/`wakeUpIdle`）不会，UI 可能过期。
- **`ThemeProvider.isDark`** 不等同于 `Theme.of(context).brightness` — 它检查 provider 的 `_themeMode` 并回退到 `platformDispatcher`。
- **`GlassCard` 的 `margin` 实为 `Padding`** 包裹组件，非 `Container.margin`。
- **`scaffoldBackgroundColor` 为实色背景** — 由主题 `cs.surface` 提供，页面不需要自行绘制。

## Lint 配置

基于 `flutter_lints`。`deprecated_member_use` 和 `use_build_context_synchronously` 设为 ignore。偏好单引号。

## 陷阱

- **数据库升级**: 必须同时改 `version` + `_upgradeDB` 中的 `onUpgrade` 逻辑，否则不会生效。
- **权限请求**: 在 `main()` 中同步执行（camera/storage/photos/location）。
- **`MainScreenState` 和 `WardrobeScreenState` 是 public**: 供子页面调用 `setTabIndex`/`setWardrobeTab`/`switchToTab`。
- **桌面端/Web 不支持高德定位**，天气模块会跳过定位。
- **camera 包无法直接获取 `maxAvailableZoom`**，最大缩放硬编码为 10.0。
- **天气缓存按城市名隔离**，定位天气使用 `'current_location'` 作为缓存键。
- **AMap API Key 硬编码在 `main.dart`**。
- **`showModalBottomSheet` context 遮蔽**: builder 回调中的 context 参数会遮挡外部 context，需用 `final pageContext = context;` 保存。
- **`pubspec.yaml` 版本号**: 改版本号时别忘了同步更新 `pubspec.yaml`（曾出现滞后）。

## 已知技术债

- 大量 `print()` 调试语句未清理
- `withOpacity` 已弃用，应用 `withValues(alpha:)`
- `ThemeData.background` 已弃用，应用 `surface`
- `FormField.value` → 用 `initialValue`
- `Radio.groupValue/onChanged` → 用 `RadioGroup`
- `test/widget_test.dart` 断言 `BottomNavigationBar` 但实际用的是 `GlassNavBar`，测试已过期

## 深入参考

详细架构说明、天气模块 Geocoding 策略、相机模块放大功能、主题系统配色表等见 `AGENTS.md`。更新日志见 `information/CHANGELOG.md`。项目状态见 `information/PROJECT_STATE.md`。
