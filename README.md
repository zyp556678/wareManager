# 穿戴管家 (WearWise)

一款跨平台衣橱管理应用，帮助您智能管理衣物、搭配穿搭、记录日常OOTD。内置 AI 搭配助手，基于 Gemma 4 端侧模型，无需联网即可使用。

## 功能特性

### 核心功能
- **首页**: 最近存入、快捷入口、个人信息、天气卡片
- **衣橱**: 衣物管理、分类浏览、瀑布流展示
- **闲置**: 闲置衣物管理、左滑唤醒、闲置时长显示
- **日志**: 操作记录时间线
- **录入**: 拍照/相册添加衣物、智能识别确认、闲置管理
- **我的**: 个人中心、地点管理、主题设置、穿搭日志

### AI 搭配助手 (v2.1.0)
- **文字对话**: 穿搭建议、衣橱分析、搭配方案、衣物护理
- **图片理解**: 拍照/上传图片识别衣物（需设备 GPU 支持）
- **流式输出**: AI 回复逐字显示，实时体验
- **衣物引用**: 选择衣橱中的衣物发送给 AI，自动附带照片
- **停止生成**: 回答过程中可随时终止
- **会话管理**: 多会话支持、历史对话、自动命名

### 主要特点
- 五组主题配色（冰川蓝、翡翠绿、玫瑰金、星空紫、月光银）
- 深色模式支持（浅色/深色/跟随系统三档）
- 自定义背景照片（支持透明度调节）
- 悬浮导航栏（胶囊型滑动指示器）
- 现代化拍照界面（V2.0）- 全屏预览、闪光灯切换、对焦动画、双指缩放
- Material Design 3 界面
- 高德定位 SDK（国内优化）
- Open-Meteo 天气 API（免费、全球支持）
- SQLite 本地数据持久化
- 本地 AI 推理（无需联网）

## 技术栈

- **框架**: Flutter (Dart) >= 3.44.3
- **状态管理**: Provider
- **数据库**: SQLite (sqflite)
- **图片处理**: image_picker, camera
- **定位**: amap_flutter_location_plus (高德定位)
- **天气**: Open-Meteo API (http)
- **AI**: flutter_gemma + flutter_gemma_litertlm (Gemma 4 E2B)
- **UI组件**: table_calendar, flutter_staggered_grid_view

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
│   ├── operation_log.dart       # 操作日志
│   └── chat_message.dart        # AI 消息/会话模型
├── providers/                   # 状态管理
│   ├── clothing_provider.dart   # 衣物状态
│   ├── weather_provider.dart    # 天气状态
│   └── theme_provider.dart      # 主题配色
├── screens/                     # 页面
│   ├── home_screen.dart         # 首页 (Bento Grid)
│   ├── wardrobe_screen.dart     # 衣橱（含3个Tab）
│   ├── capture_screen.dart      # 拍照 V2.0
│   ├── ai_chat_screen.dart      # AI 对话
│   ├── model_management_screen.dart  # 模型管理
│   ├── profile_screen.dart      # 我的
│   ├── settings_page.dart       # 设置
│   └── ...                      # 其他页面
├── services/                    # 服务
│   ├── database_helper.dart     # 数据库 (version=8)
│   ├── weather_scraper.dart     # Open-Meteo API
│   ├── amap_location_service.dart  # 高德定位
│   ├── ai_service.dart          # AI 核心服务
│   ├── model_downloader.dart    # 模型下载管理
│   └── ai_context_builder.dart  # AI 上下文构建
├── widgets/                     # 自定义组件
│   ├── glass_card.dart          # 毛玻璃卡片
│   ├── glass_nav_bar.dart       # 悬浮导航栏
│   ├── bento_grid.dart          # Bento 网格
│   ├── weather_card.dart        # 天气卡片
│   ├── chat_bubble.dart         # AI 对话气泡
│   └── model_download_dialog.dart  # 模型下载弹窗
└── utils/
    ├── image_utils.dart         # 图片工具
    └── idle_utils.dart          # 公共地点选择方法
```

## 快速开始

### 环境要求
- Flutter SDK >= 3.44.3
- Dart SDK >= 3.12.2
- Android minSdk: 24

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

## AI 功能使用

### 首次使用
1. 点击底部导航栏的 "AI" Tab
2. 点击 "下载 AI 模型" 按钮（约 2.5GB，建议 Wi-Fi 环境）
3. 下载完成后自动加载，即可开始对话

### 对话功能
- 输入文字提问穿搭、衣橱、搭配等问题
- 点击相机图标拍照或选择图片发送
- 点击衣物图标引用衣橱中的衣物
- AI 回复时可点击停止按钮终止生成

### 模型管理
- 点击 AI 页面右上角机器人图标进入模型管理
- 可切换、删除模型
- 可调节上下文窗口大小（2K/4K/8K/16K tokens）
- 可清理下载失败的残留文件

## 更新日志

### v2.1.0 (2026-06-24)
- 新增 AI 搭配助手（基于 Gemma 4 端侧模型）
- 新增自定义背景照片功能
- 导航栏改为悬浮样式，新增滑动指示器
- 底部导航栏扩展为 5 个 Tab
- Flutter SDK 升级到 3.44.3

### v2.0.0+3 (2026-05-16)
- 闲置设置流程重构
- 数据库升级至 version=7

### v2.0.0 (2026-04-29)
- 天气模块重构（Open-Meteo API）
- 全新液态玻璃 UI 设计
- 5 套主题配色

### v1.0 (2026-04-27)
- 项目基础架构
- 底部导航与四个主页面
- 相机拍照与相册选择

## 许可证

本项目仅供学习使用。
