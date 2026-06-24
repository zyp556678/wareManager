# AI 搭配助手功能设计

> 日期：2026-06-23 | 版本：1.0

## 概述

为穿戴管家 (WearWise) 增加本地 AI 对话功能，基于 Gemma 4 端侧模型，用户可以通过文字和图片与 AI 交流穿搭建议、衣橱分析、搭配方案。

## 技术选型

| 决策 | 选择 |
|------|------|
| 模型 | Gemma 4（端侧优化版） |
| 推理框架 | Google AI Edge / LiteRT |
| Dart 集成 | `flutter_gemma` 包 |
| 模型分发 | 首次启动下载，离线使用 |
| 入口 | 新增底部第 5 个 Tab |
| 交互 | 文字 + 图片输入，文字 + 衣物卡片输出 |
| 数据注入 | 自动注入衣物摘要 + 按需查询详情 |
| 图片传递 | 用户引用衣物时才传图 |

## 架构

### 文件结构

```
lib/
├── services/
│   ├── ai_service.dart          # AI 核心服务（模型加载、推理、会话管理）
│   ├── model_downloader.dart    # 模型文件下载与缓存管理
│   └── ai_context_builder.dart  # 构建上下文（衣物摘要、按需查询）
├── screens/
│   └── ai_chat_screen.dart      # AI 对话页面（新 Tab）
├── widgets/
│   ├── chat_bubble.dart         # 对话气泡（文字/图片/衣物卡片）
│   ├── clothing_card_widget.dart # AI 回复中的衣物卡片组件
│   └── model_download_dialog.dart # 模型下载进度弹窗
└── models/
    └── chat_message.dart        # 对话消息模型
```

### 数据流

```
用户输入（文字/图片）
  → AIContextBuilder 注入衣物摘要
  → 如果引用衣物，追加该衣物详情+图片
  → AiService 发送给 Gemma 4 模型
  → 模型返回文字回复
  → 如果包含衣物推荐，解析为衣物卡片
  → 展示在 ChatBubble 中
```

### 与现有架构的关系

- 复用 `ClothingProvider` 获取衣物数据
- 复用 `image_picker` 拍照/选图
- 新增第 5 个 Tab，导航栏从 4 项变 5 项

## 模型管理

### 模型文件

- 格式：`.task`（Google AI Edge 优化格式）
- 大小：约 2-4GB
- 存储位置：`getApplicationSupportDirectory()/models/`

### 下载流程

1. 用户首次点击 AI Tab → 弹出下载确认弹窗（显示模型大小、Wi-Fi 提示）
2. 用户确认 → 开始下载，显示进度条（可后台下载）
3. 下载完成 → 校验文件完整性 → 保存路径到 SharedPreferences
4. 后续启动 → 检查本地模型是否存在 → 存在则直接加载

### 模型版本管理

- SharedPreferences 存储 `model_version` 和 `model_path`
- 未来可通过比较版本号提示更新

### 异常处理

- 下载中断 → 支持断点续传
- 存储空间不足 → 提示清理
- 模型加载失败 → 提示重新下载

## 对话系统

### 消息模型

```dart
class ChatMessage {
  final String id;
  final String role;        // 'user' / 'assistant'
  final String? text;       // 文字内容
  final String? imagePath;  // 用户发送的图片路径
  final List<ClothingItem>? clothingCards; // AI 推荐的衣物卡片
  final DateTime timestamp;
}
```

### 上下文构建（AIContextBuilder）

- **系统提示词**：定义 AI 角色为"穿搭助手"，告知可使用的数据范围
- **衣物摘要**：自动注入，格式如 `"衣橱共23件：上衣8、裤子6、裙装3、外套4、闲置2件。季节分布：春秋10、夏8、冬5"`
- **按需详情**：用户提到某件衣物时，注入该衣物的完整元数据（类别/颜色/材质/风格/季节/标签）
- **图片传递**：仅当用户在对话中明确引用某件衣物时，读取 `imagePath` 传给模型

### 对话流程

1. 用户输入文字 → 直接发送
2. 用户拍照/选图 → 图片 + 文字一起发送
3. 用户点击衣橱中的某件衣物 → 追加为引用，附带该衣物信息和图片
4. 模型返回文字 → 解析是否有衣物推荐 → 有则展示衣物卡片

### 会话持久化

- 对话历史存在 SQLite（新建 `chat_sessions` 和 `chat_messages` 表）
- 支持多个会话（每次新对话 = 新 session）
- 会话列表页可以查看历史对话

## 界面设计

### 底部导航栏

- 5 个 Tab：首页、衣橱、录入、AI、我的
- AI Tab 图标：`Icons.auto_awesome`（选中）/ `Icons.auto_awesome_outlined`（未选中）
- 导航栏索引映射更新：录入仍通过 `Navigator.push` 跳转

### AI 对话页面（AiChatScreen）

```
┌─────────────────────────┐
│ AppBar: "AI 搭配助手"     │
│   [新对话] [历史记录]      │
├─────────────────────────┤
│                         │
│  对话消息列表             │
│  (ListView)             │
│                         │
│  ┌─────────────────┐    │
│  │ 👤 用户消息       │    │
│  │ 文字 + 图片      │    │
│  └─────────────────┘    │
│  ┌─────────────────┐    │
│  │ 🤖 AI 回复       │    │
│  │ 文字 + 衣物卡片   │    │
│  └─────────────────┘    │
│                         │
├─────────────────────────┤
│ [📷] [📎引用衣物] [输入框] [发送] │
└─────────────────────────┘
```

### 衣物引用交互

- 点击底部"引用衣物"按钮 → 弹出衣物选择弹窗（展示衣橱/闲置列表）
- 选中一件 → 在输入框上方显示缩略图预览
- 发送时，该衣物的元数据 + 图片一并传给模型

### 衣物卡片组件（AI 回复中）

- 显示：衣物缩略图、类别、颜色、材质
- 点击 → 跳转衣物详情页
- 可横滑展示多件衣物

## 性能与异常处理

### 内存管理

- 每次对话最多传 3 张图片给模型（防止 OOM）
- 图片压缩：传给模型前压缩到 512x512
- 会话历史限制：每个 session 最多保留 50 条消息，超出截断早期消息

### 推理性能

- 首次推理较慢（模型加载到内存），后续推理正常
- 显示"AI 正在思考..."的加载动画
- 推理过程中禁用发送按钮，防止重复请求

### 异常处理

| 场景 | 处理 |
|------|------|
| 模型未下载 | 引导下载，对话输入禁用 |
| 推理失败 | 显示错误提示，保留用户输入可重试 |
| 图片读取失败 | 跳过图片，只发文字 |
| 内存不足 | 清理旧会话，提示用户 |
| 网络断开（下载模型时）| 暂停下载，恢复后继续 |

### 离线能力

- 模型下载完成后，所有推理在本地进行，无需网络
- 衣物数据全部本地 SQLite，无外部依赖

## 数据库变更

新增两张表：

```sql
CREATE TABLE chat_sessions (
  id TEXT PRIMARY KEY,
  title TEXT,
  createdDate INTEGER,
  lastMessageDate INTEGER
);

CREATE TABLE chat_messages (
  id TEXT PRIMARY KEY,
  sessionId TEXT,
  role TEXT,
  text TEXT,
  imagePath TEXT,
  clothingIds TEXT,
  timestamp INTEGER,
  FOREIGN KEY (sessionId) REFERENCES chat_sessions(id)
);
```

## 实现优先级

1. **P0 - 核心链路**：模型下载 → 加载 → 文字对话 → 衣物摘要注入
2. **P1 - 图片能力**：拍照/选图发送 → 衣物引用 → 图片传给模型
3. **P2 - 富文本**：AI 回复中的衣物卡片展示 → 横滑列表
3. **P3 - 持久化**：会话保存 → 历史记录 → 会话列表
