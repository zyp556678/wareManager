# 穿戴管家 (WearWise)

一款跨平台衣橱管理应用，帮助您智能管理衣物、搭配穿搭、记录日常OOTD。

## 功能特性

### 核心功能
- **首页**: 今日灵感穿搭推荐、天气信息、快捷搭配助手
- **衣橱**: 衣物管理、分类浏览、毛玻璃卡片展示
- **录入**: 拍照/相册添加衣物、智能识别确认、闲置管理
- **我的**: 个人中心、主题设置、穿搭日志

### 主要特点
- 五组主题配色（晨间燕麦、海盐薄荷、摩卡拿铁、薰衣草灰、极简石墨）
- 深色模式支持
- 现代化拍照界面（V2.0）- 全屏预览、闪光灯切换、对焦动画
- 毛玻璃 UI 组件
- Material Design 3 现代化界面
- 相机拍照与相册选择
- SQLite 本地数据持久化
- 月视图穿搭日历
- 智能标签分类

## 技术栈

- **框架**: Flutter (Dart)
- **状态管理**: Provider
- **数据库**: SQLite (sqflite)
- **图片处理**: image_picker, camera
- **UI组件**: table_calendar, flutter_staggered_grid_view

## 项目结构

```
lib/
├── models/                   # 数据模型
│   ├── clothing_item.dart
│   ├── outfit.dart
│   └── outfit_log.dart
├── providers/               # 状态管理
│   ├── clothing_provider.dart
│   └── theme_provider.dart  # 主题配色管理
├── screens/                 # 页面
│   ├── home_screen.dart
│   ├── capture_screen.dart  # 拍照界面 V2.0
│   ├── photo_confirm_screen.dart
│   ├── recognition_confirm_page.dart
│   ├── theme_color_screen.dart
│   ├── wardrobe_tab.dart
│   ├── profile_screen.dart
│   └── settings_page.dart
├── widgets/                 # 自定义组件
│   ├── glass_card.dart      # 毛玻璃卡片
│   └── glass_button.dart   # 毛玻璃按钮
├── services/
│   └── database_helper.dart
└── main.dart
```

## 快速开始

### 环境要求
- Flutter SDK >= 3.11.5
- Dart SDK >= 3.11.5
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

## 更新日志

### v1.0.1 (2026-04-27)
- 新增五组主题配色切换
- 新增深色模式支持
- 重构现代化拍照界面（V2.0）
- 新增毛玻璃 UI 组件
- 全局毛玻璃底部导航
- 修复代码问题

### v1.0 (初始版本)
- 项目基础架构
- 底部导航与四个主页面
- 相机拍照与相册选择
- 识别确认页表单
- 数据模型与数据库

## 许可证

本项目仅供学习使用。