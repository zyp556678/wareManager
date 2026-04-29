# 更新日志

## [2.0.0] - 2026-04-29

### Features
- 天气模块重构：改用 Open-Meteo API（免费、无需 Key、全球支持）
- 天气默认基于定位获取，支持手动切换城市
- 天气预报扩展至 7 天
- 天气卡片支持定位/城市模式一键切换
- 新增 WeatherProvider 天气状态管理
- 新增 CitySearchScreen 城市选择页
- 新增 WeatherDetailScreen 天气详情页
- 新增 WeatherCard 首页天气组件
- 天气详情页新增"立即定位"按钮
- 天气定位显示详细地址（城市 + 区 + 街道）
- 天气 API 请求时携带高德定位获取的详细地址
- 相机新增放大功能：双指捏合缩放、双击切换 1x/2x
- 相机预设档位按钮（0.5x/1x/2x/5x）与滑动条微调
- 相机支持直接调用系统相机拍照
- 地点管理支持地址显示与编辑
- 全新液态玻璃 UI 设计（Bento Grid 首页、悬浮导航栏）
- 5 套主题配色（冰川蓝/翡翠绿/玫瑰金/星空紫/月光银）

### 定位模块重构
- 替换定位 SDK：从 geolocator + geocoding 切换至高德定位 SDK (amap_flutter_location_plus)
- 国内定位优化：融合 GPS + WiFi + 基站多源定位，室内定位速度提升至 2-5 秒
- 逆地理编码：高德 SDK 自带逆地理编码，不再依赖 Google Play 服务
- 定位权限：应用启动时主动请求定位权限
- 新增 AMapLocationService 定位服务封装

### Fixes
- 修复地点管理获取定位失败（getLastKnownPosition 兜底 → 高德高精度模式）
- 修复地点管理页地址文本溢出（Expanded + ellipsis）
- 修复桌面端不支持定位导致天气获取失败
- 修复墨迹天气反爬虫导致获取失败（迁移至 Open-Meteo）
- 修复缓存清理逻辑，确保 SharedPreferences 和数据库数据正确清除
- 修复天气缓存按城市名隔离问题
- 修复 TimeoutException 未导入导致的编译错误
- 修复定位流重复监听问题（每次定位创建新实例）
- 修复定位成功结果误判为错误的问题（高德成功时不返回 errorCode）
- 修复天气卡片和详情页位置名称显示为"当前位置"的问题
- 修复天气卡片位置名称溢出问题（使用 Flexible 包裹）
- 修复天气详情页标题支持多行显示

### Chores
- 版本号更新为 2.0.0+2
- 主题模式默认跟随系统 (ThemeMode.system)
- 新增 AGENTS.md 项目记忆文件
- 新增 CHANGELOG.md 更新日志
- 新增 PROJECT_STATE.md 项目状态日志
- 更新 README.md 版本说明
- 更新 version_info_screen.dart 版本内容
- 依赖变更：移除 geolocator/geocoding，新增 amap_flutter_location_plus、http/html
