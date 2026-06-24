# AI 搭配助手实现计划

> 基于设计文档：`2026-06-23-ai-chat-design.md`

## 阶段一：基础设施（P0）

### 1.1 添加依赖

- `pubspec.yaml` 添加 `flutter_gemma` 包
- 配置 Android/iOS 平台设置

### 1.2 数据库扩展

- `database_helper.dart` 升级到 version=8
- 新建 `chat_sessions` 表和 `chat_messages` 表
- `_upgradeDB` 添加 v7→v8 迁移逻辑

### 1.3 消息模型

- 新建 `lib/models/chat_message.dart`
- 字段：id, role, text, imagePath, clothingCards, timestamp

### 1.4 模型下载服务

- 新建 `lib/services/model_downloader.dart`
- 功能：下载 Gemma 4 模型文件、进度回调、断点续传、文件校验
- 存储路径：`getApplicationSupportDirectory()/models/`
- SharedPreferences 记录 model_version 和 model_path

### 1.5 AI 核心服务

- 新建 `lib/services/ai_service.dart`
- 功能：加载模型、创建会话、发送消息、接收回复
- 依赖 `flutter_gemma` 的 API

### 1.6 上下文构建器

- 新建 `lib/services/ai_context_builder.dart`
- 功能：生成系统提示词、构建衣物摘要、按需注入衣物详情
- 从 `ClothingProvider` 读取数据

## 阶段二：导航与页面框架（P0）

### 2.1 导航栏扩展

- `main.dart` 底部导航栏从 4 项改为 5 项
- 新增 AI Tab（`Icons.auto_awesome`）
- 更新索引映射逻辑

### 2.2 对话页面框架

- 新建 `lib/screens/ai_chat_screen.dart`
- 基本结构：AppBar + 消息列表 + 输入区域
- 暂时只支持文字输入

### 2.3 消息气泡组件

- 新建 `lib/widgets/chat_bubble.dart`
- 支持用户消息和 AI 消息两种样式
- 显示文字内容

## 阶段三：核心对话链路（P0）

### 3.1 模型下载弹窗

- 新建 `lib/widgets/model_download_dialog.dart`
- 显示模型大小、Wi-Fi 提示、下载进度条
- 首次点击 AI Tab 时弹出

### 3.2 对话流程串联

- AiChatScreen 接入 AiService 和 AIContextBuilder
- 用户发送文字 → 注入上下文 → 调用模型 → 显示回复
- 加载动画（"AI 正在思考..."）
- 推理中禁用发送按钮

### 3.3 错误处理

- 模型未下载 → 引导下载
- 推理失败 → 错误提示 + 可重试
- 内存不足 → 清理旧会话

## 阶段四：图片能力（P1）

### 4.1 图片发送

- 输入区域添加拍照/选图按钮
- 使用 `image_picker` 获取图片
- 输入框上方显示图片预览
- 图片压缩到 512x512

### 4.2 衣物引用

- 输入区域添加"引用衣物"按钮
- 弹出衣物选择弹窗（衣橱/闲置列表）
- 选中后在输入框上方显示缩略图
- 发送时附带衣物元数据 + 图片

### 4.3 图片传给模型

- AIContextBuilder 支持图片输入
- 限制每次最多 3 张图片
- 图片读取失败时跳过，只发文字

## 阶段五：富文本回复（P2）

### 5.1 衣物卡片组件

- 新建 `lib/widgets/clothing_card_widget.dart`
- 显示：缩略图、类别、颜色、材质
- 点击跳转衣物详情页
- 支持横滑展示多件

### 5.2 AI 回复解析

- 解析模型回复中的衣物推荐
- 提取衣物 ID → 从数据库查询 → 生成卡片
- ChatBubble 支持嵌入衣物卡片

## 阶段六：会话持久化（P3）

### 6.1 会话管理

- 新建会话、保存消息、加载历史
- 每个 session 最多 50 条消息

### 6.2 历史记录

- AppBar 添加"历史记录"按钮
- 会话列表页：显示历史对话列表
- 点击恢复对话

### 6.3 新对话

- AppBar 添加"新对话"按钮
- 清空当前消息，创建新 session

## 文件清单

| 文件 | 操作 | 阶段 |
|------|------|------|
| `pubspec.yaml` | 修改 | 1.1 |
| `lib/services/database_helper.dart` | 修改 | 1.2 |
| `lib/models/chat_message.dart` | 新建 | 1.3 |
| `lib/services/model_downloader.dart` | 新建 | 1.4 |
| `lib/services/ai_service.dart` | 新建 | 1.5 |
| `lib/services/ai_context_builder.dart` | 新建 | 1.6 |
| `lib/main.dart` | 修改 | 2.1 |
| `lib/screens/ai_chat_screen.dart` | 新建 | 2.2 |
| `lib/widgets/chat_bubble.dart` | 新建 | 2.3 |
| `lib/widgets/model_download_dialog.dart` | 新建 | 3.1 |
| `lib/widgets/clothing_card_widget.dart` | 新建 | 5.1 |
