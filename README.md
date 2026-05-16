# 穿戴管家 (WearWise)

一款跨平台衣橱管理应用，帮助您智能管理衣物、搭配穿搭、记录日常OOTD。

## 功能特性

### 核心功能
- **首页**: 最近存入、快捷入口、个人信息、天气卡片
- **衣橱**: 衣物管理、分类浏览、瀑布流展示
- **闲置**: 闲置衣物管理、左滑唤醒、闲置时长显示
- **日志**: 操作记录时间线
- **录入**: 拍照/相册添加衣物、智能识别确认、闲置管理（支持选择开始/结束日期和存放地点）
- **我的**: 个人中心、地点管理、主题设置、穿搭日志

### 主要特点
- 五组主题配色（冰川蓝、翡翠绿、玫瑰金、星空紫、月光银）
- 深色模式支持（浅色/深色/跟随系统三档）
- 现代化拍照界面（V2.0）- 全屏预览、闪光灯切换、对焦动画、双指缩放
- Material Design 3 界面
- 毛玻璃 UI 组件
- 高德定位 SDK（国内优化）
- Open-Meteo 天气 API（免费、全球支持）
- SQLite 本地数据持久化
- 操作日志记录

## 技术栈

- **框架**: Flutter (Dart)
- **状态管理**: Provider
- **数据库**: SQLite (sqflite)
- **图片处理**: image_picker, camera
- **定位**: amap_flutter_location_plus (高德定位)
- **天气**: Open-Meteo API (http)
- **UI组件**: table_calendar, flutter_staggered_grid_view, liquid_glass_easy

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型
│   ├── clothing_item.dart       # 衣物模型 (含 idleFrom/idleUntil)
│   ├── city_coords.dart         # 城市经纬度映射表
│   ├── outfit.dart              # 穿搭模型
│   ├── outfit_log.dart          # 穿搭日志
│   ├── location.dart            # 存储地点
│   ├── weather_data.dart        # 天气数据模型
│   └── operation_log.dart       # 操作日志
├── providers/                   # 状态管理
│   ├── clothing_provider.dart   # 衣物状态
│   ├── weather_provider.dart    # 天气状态
│   └── theme_provider.dart      # 主题配色
├── screens/                     # 页面
│   ├── home_screen.dart         # 首页 (Bento Grid)
│   ├── wardrobe_screen.dart     # 衣橱（含3个Tab）
│   ├── capture_screen.dart      # 拍照 V2.0
│   ├── photo_confirm_screen.dart
│   ├── recognition_confirm_page.dart  # 识别确认 (含闲置设置)
│   ├── clothing_detail_page.dart
│   ├── edit_clothing_page.dart
│   ├── profile_screen.dart      # 我的
│   ├── settings_page.dart       # 设置
│   ├── theme_color_screen.dart  # 主题配色
│   ├── version_info_screen.dart # 版本说明
│   ├── location_management_page.dart  # 地点管理
│   ├── weather_detail_screen.dart     # 天气详情
│   ├── city_search_screen.dart        # 城市选择
│   └── profile_edit_page.dart
├── widgets/                     # 自定义组件
│   ├── glass_card.dart          # 毛玻璃卡片
│   ├── glass_button.dart        # 毛玻璃按钮
│   ├── glass_nav_bar.dart       # 悬浮导航栏
│   ├── bento_grid.dart          # Bento 网格
│   └── weather_card.dart        # 天气卡片
├── services/
│   ├── database_helper.dart     # 数据库 (version=7)
│   ├── weather_scraper.dart     # Open-Meteo API
│   └── amap_location_service.dart  # 高德定位
└── utils/
    ├── image_utils.dart         # 图片工具
    └── idle_utils.dart          # 公共地点选择方法
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

### 静态分析
```bash
flutter analyze
```

## 更新日志

### v2.0.0+3 (2026-05-16)
- 闲置设置流程重构：支持选择闲置开始日期和结束日期
- 闲置设置支持从地点管理中选择存放地点，支持直接新建地点
- 识别确认页闲置设置真正保存数据（直接创建闲置状态衣物）
- 修复衣橱和闲置页面长按删除功能失效的问题
- 数据库版本升级至 7，新增 idleFrom 字段
- 新增公共地点选择方法 lib/utils/idle_utils.dart

### v2.0.0+2 (2026-04-29)
- 修复手动选择城市无法获取天气的问题（新增城市经纬度映射表）
- 移除天气详情页标题点击跳转城市选择的功能

### v2.0.0+1 (2026-04-28)
- 天气模块重构：改用 Open-Meteo API（免费、无需 Key、全球支持）
- 天气默认基于定位获取，支持手动切换城市
- 天气预报扩展至 7 天
- 相机界面新增放大功能（双指捏合缩放、双击切换、预设档位、滑动条微调）
- 相机界面支持调用系统相机拍照
- 地点管理支持地址显示与编辑，定位获取更稳定
- 修复缓存清理逻辑，确保数据正确清除
- 主题模式默认跟随系统
- 全新液态玻璃 UI 设计（v1.1.0 基础）
- Bento Grid 首页布局
- 悬浮玻璃导航栏
- 全新5套主题配色（冰川蓝/翡翠绿/玫瑰金/星空紫/月光银）

### v1.0.1+3 (2026-04-27)
- 新增五组主题配色切换
- 新增深色模式支持
- 重构现代化拍照界面（V2.0）
- 新增毛玻璃 UI 组件
- 全局毛玻璃底部导航
- 修复代码问题

### v1.0 (2026-04-27)
- 项目基础架构
- 底部导航与四个主页面
- 相机拍照与相册选择
- 识别确认页表单
- 数据模型与数据库

## 许可证

本项目仅供学习使用。