# 穿戴管家 (WearWise) - 项目状态日志

> 最后更新: 2026-04-28 | v2.0.0 发布

---

## 📌 当前状态

- **版本**: 2.0.0+1
- **框架**: Flutter SDK >= 3.11.5
- **状态管理**: Provider (ClothingProvider, ThemeProvider)
- **数据库**: sqflite 单例, db version=6
- **静态分析**: `flutter analyze` 通过，无错误

---

## 🎨 UI 重设计 (v2.0.0 基础) - 已完成

### 设计核心
- **视觉语言**: 毛玻璃效果 (BackdropFilter + ImageFilter.blur)
- **首页布局**: Bento Grid 不规则网格
- **导航栏**: 悬浮玻璃条 (圆角24 + 模糊sigma:20 + 白色边框)
- **卡片**: 玻璃态卡片 (模糊sigma:12 + 半透明背景 + 边框光效)
- **按钮**: 玻璃态按钮 (按压缩放动画 + 选中发光)

### 全新配色 (5套)
| 索引 | 名称 | 主色 |
|------|------|------|
| 0 | 冰川蓝 | `#5B9BD5` |
| 1 | 翡翠绿 | `#4CAF50` |
| 2 | 玫瑰金 | `#D4A574` |
| 3 | 星空紫 | `#9B7ED8` |
| 4 | 月光银 | `#95A5A6` |

### 重写的文件清单
**新增组件**:
- `lib/widgets/glass_nav_bar.dart` - 悬浮玻璃导航栏 (BackdropFilter)
- `lib/widgets/bento_grid.dart` - Bento 网格布局

**重写组件**:
- `lib/widgets/glass_card.dart` - 玻璃卡片 (BackdropFilter blur:12)
- `lib/widgets/glass_button.dart` - 玻璃按钮

**重写页面 (16个)**:
- `lib/main.dart` - 主框架 (悬浮导航栏 + 索引映射修复)
- `lib/screens/home_screen.dart` - Bento 首页
- `lib/screens/wardrobe_screen.dart` - 衣橱 (玻璃标签栏)
- `lib/screens/wardrobe_tab.dart` - 衣橱网格
- `lib/screens/idle_tab.dart` - 闲置列表 (玻璃卡片+滑动唤醒)
- `lib/screens/outfit_log_tab.dart` - 操作日志 (玻璃时间线)
- `lib/screens/capture_screen.dart` - 拍照 (玻璃控制栏)
- `lib/screens/photo_confirm_screen.dart` - 照片确认
- `lib/screens/recognition_confirm_page.dart` - 识别确认表单
- `lib/screens/clothing_detail_page.dart` - 衣物详情 (SliverAppBar)
- `lib/screens/edit_clothing_page.dart` - 编辑衣物
- `lib/screens/profile_screen.dart` - 个人中心 (Bento布局)
- `lib/screens/profile_edit_page.dart` - 编辑资料
- `lib/screens/settings_page.dart` - 设置 (玻璃列表)
- `lib/screens/theme_color_screen.dart` - 主题选择器
- `lib/screens/version_info_screen.dart` - 版本说明
- `lib/screens/location_management_page.dart` - 地点管理

**重写主题**:
- `lib/providers/theme_provider.dart` - 5套新配色 + 玻璃配置

### 关键修复
- **导航栏索引映射**: 导航栏4项 (0首页/1衣橱/2录入/3我的) vs PageView 3页 (0首页/1衣橱/2我的)
  - `setTabIndex(3)` → `pageIndex = 2`
  - `onPageChanged(2)` → `navIndex = 3`

---

## 🗄️ 数据库表 (5张, version=6)

| 表名 | 说明 |
|------|------|
| `clothing_items` | 衣物 (status: active/idle) |
| `outfits` | 穿搭 |
| `outfit_logs` | 穿搭日志 |
| `locations` | 存储地点 (含 address 字段) |
| `operation_logs` | 操作日志 (add/idle/wakeup/delete/edit) |

---

## 📦 依赖

```yaml
dependencies:
  provider: ^6.1.1
  sqflite: ^2.3.0
  image_picker: ^1.0.7
  camera: ^0.10.5+9
  liquid_glass_easy: ^1.1.1  # 新增
  flutter_staggered_grid_view: ^0.7.0
  table_calendar: ^3.0.9
  geolocator: ^12.0.0
  geocoding: ^3.0.0
  shared_preferences: ^2.2.2
  permission_handler: ^11.2.0
  path_provider: ^2.1.1
  url_launcher: ^6.2.5
  flutter_local_notifications: ^17.0.0
  intl: ^0.20.2
```

---

## 🔧 常用命令

```bash
flutter pub get                   # 安装依赖
flutter run                       # 运行
flutter analyze                   # 静态分析
flutter test                      # 运行测试
flutter build apk --release       # 构建 APK
dart run flutter_launcher_icons   # 生成图标
```

---

## ⚠️ 注意事项

1. **assets/images/** 目录必须存在 (否则 `flutter pub get` 警告)
2. **analysis_options.yaml**: `deprecated_member_use` 和 `use_build_context_synchronously` 设为 ignore
3. **偏好单引号**: `prefer_single_quotes: true`
4. **新 clone 后**: 需 `flutter create .` 生成平台工程文件
5. **数据库升级**: 需同时改 `version` + `onUpgrade` 逻辑
6. **权限请求**: 在 `main()` 中同步执行 (camera/storage/photos)
7. **MainScreenState 是 public**: 供子页面调用 `setTabIndex`/`setWardrobeTab`
8. **BackdropFilter 性能**: 模糊效果在低端设备可能影响性能，如需优化可降低 sigma 值或使用 snapshot 模式

---

## 📁 架构概览

```
lib/
├── main.dart                    # 入口 (MainScreen + 导航逻辑)
├── models/                      # 数据模型
│   ├── clothing_item.dart
│   ├── outfit.dart
│   ├── outfit_log.dart
│   ├── location.dart
│   └── operation_log.dart
├── providers/                   # 状态管理
│   ├── clothing_provider.dart
│   └── theme_provider.dart      # 5套主题配色
├── screens/                     # 页面 (16个)
│   ├── home_screen.dart         # Bento 首页
│   ├── wardrobe_screen.dart     # 衣橱容器
│   ├── wardrobe_tab.dart        # 衣橱网格
│   ├── idle_tab.dart            # 闲置列表
│   ├── outfit_log_tab.dart      # 操作日志
│   ├── capture_screen.dart      # 拍照
│   ├── photo_confirm_screen.dart
│   ├── recognition_confirm_page.dart
│   ├── clothing_detail_page.dart
│   ├── edit_clothing_page.dart
│   ├── profile_screen.dart      # 个人中心
│   ├── profile_edit_page.dart
│   ├── settings_page.dart
│   ├── theme_color_screen.dart
│   ├── version_info_screen.dart
│   └── location_management_page.dart
├── services/
│   └── database_helper.dart     # sqflite 单例
└── widgets/
    ├── glass_card.dart          # 玻璃卡片 (BackdropFilter)
    ├── glass_button.dart        # 玻璃按钮
    ├── glass_nav_bar.dart       # 悬浮导航栏 (BackdropFilter)
    └── bento_grid.dart          # Bento 网格
```

---

## 🎯 下一步建议 (未完成)

- [ ] 数据导出与备份功能
- [ ] 场合管理功能
- [ ] 隐私设置功能
- [ ] 闲置提醒通知
- [ ] AI 智能搭配推荐
- [ ] 性能优化 (低端设备 BackdropFilter 降级)
