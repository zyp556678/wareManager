# WearWise (穿戴管家)

Flutter 衣橱管理应用。SDK >= 3.11.5, Dart >= 3.11.5。

## 命令

```bash
flutter pub get          # 安装依赖
flutter run             # 运行
flutter analyze        # 静态分析 (当前 56 个 info 警告)
flutter test           # 运行 widget test
flutter build apk --release  # 构建 APK
```

## 架构

- **入口**: `lib/main.dart`
- **状态管理**: `ClothingProvider`, `ThemeProvider` (Provider)
- **数据库**: `DatabaseHelper` (sqflite 单例)
- **UI**: 4 tab 底部导航 → HomeScreen, WardrobeScreen, CaptureScreen(路由跳转), ProfileScreen

## 数据库表

- `clothing_items` - 衣物
- `outfits` - 穿搭
- `outfit_logs` - 穿搭日志
- `locations` - 存储位置

## 待修复 (flutter analyze)

- `assets/images/` 目录不存在 (warning)
- `withOpacity` → `withValues()` (deprecated)
- `print()` 调试语句 (avoid_print)
- `FormField.value` → `initialValue` (deprecated)
- `Radio.groupValue/onChanged` → `RadioGroup` (deprecated)

## 陷阱

- 新 clone 后需 `flutter create .` 重新生成 `.idea/`
- AndroidStudio 必须打开根目录 `ware_01/`
- ThemeData `background` 已废弃 → 用 `surface`
- 数据库升级需改 `version` + `onUpgrade`