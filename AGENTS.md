# AGENTS.md — WearWise (穿戴管家)

Flutter 跨平台衣橱管理应用。SDK >= 3.11.5，Android minSdk 21。

## 关键命令

```bash
flutter pub get          # 安装依赖
flutter run              # 运行（连接设备或模拟器）
flutter analyze          # 静态分析
flutter test             # 运行测试（仅 1 个 widget test）
flutter build apk --release  # 构建 APK → build/app/outputs/flutter-apk/
```

## 架构要点

- **状态管理**: Provider (`ChangeNotifierProvider` 包裹 `ClothingProvider`)
- **数据库**: sqflite (单例 `DatabaseHelper`，4 张表：clothing_items, outfits, outfit_logs, locations)
- **UI**: Material Design 3，底部导航 4 tab（首页/衣橱/录入/我的），PageView + BottomNavigationBar
- **权限**: camera, storage, photos（在 `main.dart` 中启动时请求）
- **资源**: `assets/images/` 已在 pubspec.yaml 声明

## 项目结构

```
lib/
├── main.dart                  # 入口 + 主题配置 + 底部导航
├── models/                    # clothing_item, outfit, outfit_log, location
├── providers/                 # clothing_provider (ChangeNotifier)
├── screens/                   # 所有页面
└── services/                  # database_helper (sqflite 封装)
```

## 陷阱与注意事项

- **`.idea/` 和 `*.iml` 已 gitignore** — 新 clone 后在根目录执行 `flutter create .` 重新生成，否则 AndroidStudio 报 "Entrypoint isn't within the current project"
- **`lib/` 是 Dart 源码目录**，不是 Android resource 目录（Android resource 在 `android/app/src/main/res/`）
- **AndroidStudio 必须打开根目录**（`ware_01/`），不能只打开 `android/` 子目录
- **`flutter create` 必须带 `.`**，不带参数会报 "No option specified for the output directory"
- **`background` 属性已废弃** — 在 Flutter 3.x+ 中 `ThemeData` 的 `background` 和 `onBackground` 应该用 `surface` 代替（当前代码使用了 deprecated 属性）
- 数据库升级需要改 version 并处理 `onUpgrade` 回调