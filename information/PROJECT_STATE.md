# 穿戴管家 (WearWise) - 项目状态日志

> 最后更新: 2026-06-24 | v2.1.0 AI 搭配助手

---

## 📌 当前状态

- **版本**: 2.1.0
- **框架**: Flutter SDK >= 3.44.3 / Dart >= 3.12.2
- **状态管理**: Provider (ClothingProvider, ThemeProvider, WeatherProvider)
- **数据库**: sqflite 单例, db version=8
- **AI 引擎**: flutter_gemma + flutter_gemma_litertlm (Gemma 4 E2B)
- **静态分析**: `flutter analyze` 通过，无错误

---

## 🤖 AI 搭配助手 (v2.1.0)

### 核心功能
- **文字对话**: 穿搭建议、衣橱分析、搭配方案
- **图片理解**: 拍照/上传图片识别衣物（需 GPU 支持）
- **流式输出**: 逐字显示 AI 回复
- **衣物引用**: 选择衣橱衣物发送给 AI，自动附带照片
- **停止生成**: 随时终止 AI 回答

### 技术架构
```
lib/
├── services/
│   ├── ai_service.dart          # AI 核心服务（模型加载、推理、会话管理）
│   ├── model_downloader.dart    # 模型下载与管理
│   └── ai_context_builder.dart  # 上下文构建（衣物摘要、按需查询）
├── screens/
│   ├── ai_chat_screen.dart      # AI 对话页面
│   └── model_management_screen.dart  # 模型管理页面
├── widgets/
│   ├── chat_bubble.dart         # 对话气泡（支持 Markdown）
│   ├── model_download_dialog.dart    # 模型下载弹窗
│   └── clothing_card_widget.dart     # 衣物卡片组件
└── models/
    └── chat_message.dart        # 消息/会话模型
```

### 数据库表 (新增)
| 表名 | 说明 |
|------|------|
| `chat_sessions` | AI 会话（id, title, createdDate, lastMessageDate） |
| `chat_messages` | 对话消息（id, sessionId, role, text, imagePath, clothingIds, timestamp） |

### 模型信息
- **模型**: Gemma 4 E2B (2.5GB)
- **格式**: `.litertlm` (TFLite)
- **引擎**: LiteRT-LM (dart:ffi)
- **下载源**: hf-mirror.com
- **上下文窗口**: 可配置 2K/4K/8K/16K tokens

### GPU 限制
- Adreno 660 (骁龙 888) 不支持 OpenCL，回退到 WebGPU
- WebGPU 单次 buffer 限制 128MB
- Vision encoder 需要 152MB → 图片理解可能失败
- 纯文字推理不受影响

---

## 🎨 自定义背景 (v2.1.0)

### 功能
- 选择照片作为 App 全局背景
- 透明度滑动条调节（0-100%）
- 所有主页面统一显示

### 实现
- `ThemeProvider` 新增 `_backgroundPath`、`_backgroundEnabled`、`_backgroundOpacity`
- `MainScreen` 用 Stack 包裹，底层放背景图
- 子页面 Scaffold 设为透明

---

## 🧭 导航栏 (v2.1.0)

### 变更
- 从 4 个 Tab 扩展到 5 个：首页/衣橱/录入/AI/我的
- 改为悬浮定位（不再使用 Scaffold.bottomNavigationBar）
- 新增滑动指示器（胶囊型，300ms 动画）

### 索引映射
- 导航栏: 0=首页, 1=衣橱, 2=录入(push), 3=AI, 4=我的
- 页面: 0=首页, 1=衣橱, 2=AI, 3=我的
- 转换: navIndex > 2 ? navIndex - 1 : navIndex

---

## 🌤️ 天气模块 (v2.0.0)

### 核心文件
- `lib/services/weather_scraper.dart` — Open-Meteo API 封装
- `lib/providers/weather_provider.dart` — 天气状态管理
- `lib/models/weather_data.dart` — 天气数据模型
- `lib/models/city_coords.dart` — 城市经纬度静态映射表 (49 城市)

### Geocoding 策略
1. 优先查 `cityCoordinates` 静态映射表
2. 未命中则用原始名称调用 geocoding API
3. 仍无结果则去掉"市"后缀重试

---

## 🎨 主题系统

### 5 套配色
| 索引 | 名称 | 主色 |
|------|------|------|
| 0 | 冰川蓝 | `#5B9BD5` |
| 1 | 翡翠绿 | `#4CAF50` |
| 2 | 玫瑰金 | `#D4A574` |
| 3 | 星空紫 | `#9B7ED8` |
| 4 | 月光银 | `#95A5A6` |

### 深色模式
- 默认跟随系统 (`ThemeMode.system`)
- 可手动切换浅色/深色

---

## 🗄️ 数据库 (version=8)

| 表名 | 说明 |
|------|------|
| `clothing_items` | 衣物 (status: active/idle, 含 idleFrom/idleUntil) |
| `outfits` | 穿搭 |
| `outfit_logs` | 穿搭日志 |
| `locations` | 存储地点 (含 address) |
| `operation_logs` | 操作日志 (add/idle/wakeup/delete/edit) |
| `chat_sessions` | AI 会话 |
| `chat_messages` | 对话消息 |

---

## 📦 依赖

```yaml
dependencies:
  provider: ^6.1.1
  sqflite: ^2.3.0
  image_picker: ^1.0.7
  camera: ^0.10.5+9
  flutter_staggered_grid_view: ^0.7.0
  table_calendar: ^3.0.9
  amap_flutter_location_plus: ^3.1.2
  http: ^1.2.0
  html: ^0.15.4
  shared_preferences: ^2.2.2
  permission_handler: ^11.2.0
  path_provider: ^2.1.1
  url_launcher: ^6.2.5
  flutter_local_notifications: ^17.0.0
  intl: ^0.20.2
  uuid: ^4.5.1
  flutter_gemma: ^1.1.0
  flutter_gemma_litertlm: ^1.0.2
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

1. **数据库升级**: 需同时改 `version` + `onUpgrade` 逻辑
2. **权限请求**: 在 `main()` 中同步执行 (camera/storage/photos/location)
3. **MainScreenState 是 public**: 供子页面调用 `setTabIndex`/`setWardrobeTab`
4. **FlutterGemma 初始化**: 必须在 `main()` 中调用 `FlutterGemma.initialize()`
5. **GPU 限制**: 部分设备 vision encoder 超出 buffer 限制，需关闭图片理解
6. **模型文件**: `.task` 文件实际可能是 TFLite 格式，需用 LiteRT 引擎加载

---

## 🎯 下一步建议

- [ ] AI 对话支持更多模型（Gemma 3n、Phi-4 等）
- [ ] AI 衣物识别结果自动填入录入表单
- [ ] 数据导出与备份功能
- [ ] 场合管理功能
- [ ] 闲置提醒通知
- [ ] 性能优化（低端设备 BackdropFilter 降级）
