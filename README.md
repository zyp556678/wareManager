# 穿戴管家 (WearWise)

一款跨平台衣橱管理应用，帮助您智能管理衣物、搭配穿搭、记录日常OOTD。

## 功能特性

### 📱 核心功能
- **首页**: 今日灵感穿搭推荐、天气信息、快捷搭配助手
- **录入**: 拍照/相册添加衣物、智能识别确认、闲置管理
- **我的**: 衣橱管理、闲置追踪、穿搭日志

### 🎯 主要特点
- ✨ Material Design 3 现代化界面
- 📸 相机拍照与相册选择
- 🗄️ SQLite 本地数据持久化
- 📊 月视图穿搭日历
- 🏷️ 智能标签分类
- 🔄 闲置衣物管理（左滑唤醒）
- 💡 智能搭配建议

## 技术栈

- **框架**: Flutter (Dart)
- **状态管理**: Provider
- **数据库**: SQLite (sqflite)
- **图片处理**: image_picker, camera
- **UI组件**: table_calendar, flutter_staggered_grid_view
- **通知**: flutter_local_notifications

## 项目结构

```
lib/
├── models/              # 数据模型
│   ├── clothing_item.dart
│   ├── outfit.dart
│   └── outfit_log.dart
├── providers/           # 状态管理
│   └── clothing_provider.dart
├── screens/             # 页面
│   ├── home_screen.dart
│   ├── capture_screen.dart
│   ├── recognition_confirm_page.dart
│   ├── profile_screen.dart
│   ├── wardrobe_tab.dart
│   ├── idle_tab.dart
│   └── outfit_log_tab.dart
├── services/            # 服务层
│   └── database_helper.dart
└── main.dart            # 应用入口
```

## 快速开始

### 环境要求
- Flutter SDK >= 3.11.5
- Dart SDK >= 3.11.5
- Android Studio / VS Code
- Android minSdk: 21

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
flutter run
```

### 构建APK
```bash
flutter build apk --release
```

生成的APK位于: `build/app/outputs/flutter-apk/app-release.apk`

## 开发计划

### 第一版（已完成）✅
- [x] 项目基础架构
- [x] 底部导航与三个主页面
- [x] 首页完整布局
- [x] 录入页相机功能骨架
- [x] 识别确认页表单
- [x] 我的页面整体结构
- [x] 数据模型与数据库

### 后续迭代 🚧
- [ ] 相机功能完善（需要配置权限）
- [ ] AI图像识别集成
- [ ] 天气API接入
- [ ] 推送通知功能
- [ ] 数据导出备份
- [ ] iOS适配
- [ ] 鸿蒙系统支持

## 注意事项

1. **相机功能**: 需要在AndroidManifest.xml中添加相机权限
2. **存储权限**: 访问相册需要存储权限
3. **通知权限**: 推送通知需要相应权限配置

## 许可证

本项目仅供学习使用。

## 联系方式

如有问题或建议，欢迎反馈！
