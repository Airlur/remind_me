# AGENTS.md（Remind Me / 醒我）

## 项目介绍
- 项目名称：Remind Me（中文名：醒我）
- 定位：简洁的时间管理与提醒应用，提供倒数日/正数日、日历、倒计时、秒表与通知提醒。

## 业务背景
来自 `docs/PRD.md`：
- 用户痛点：快节奏生活容易遗忘重要日期/任务，需要及时提醒与时间管理工具。
- 目标人群：学生、职场人士、家庭用户、健身爱好者等。
- 核心功能：倒数日/正数日、日历、倒计时、秒表、通知提醒。
- 特色方向：个性化主题、分享模板、小组件（桌面/锁屏/通知栏）、多场景计时。

## 技术栈与关键依赖
### 客户端与架构
- Flutter + Dart（当前目标版本：Flutter 3.35.7 / Dart 3.9.2）
- 状态管理：`flutter_bloc` + `hydrated_bloc`
- 依赖注入：`get_it`
- 本地存储：`hive` / `hive_flutter`、`shared_preferences`
- 网络：`dio`、`connectivity_plus`
- 通知：`flutter_local_notifications` + `timezone`
- 设备与应用信息：`device_info_plus`、`package_info_plus`
- 权限：`permission_handler`
- 工具与基础库：`intl`、`logger`、`path_provider`、`uuid`、`collection`
- UI与体验：`flutter_screenutil`、`flutter_slidable`、`cupertino_icons`
- 其他：`lunar`

### 依赖升级原则
- 所有依赖版本以 `https://pub.dev/` 官方发布为准，升级时必须逐个核对，不捏造版本号。
- 升级时优先保证 Flutter 3.35.7 / Dart 3.9.2 兼容性。

## 目录结构（精简）
```
docs/                  # PRD/TDD 等产品与技术文档
lib/
  blocs/               # BLoC 状态管理
  constants/           # 业务常量（日期/时间/配置）
  core/                # 应用核心（路由、依赖注入、App 入口配置）
  generated/           # 自动生成的本地化文件（勿手改）
  l10n/                # 国际化配置与 ARB
  models/              # 数据模型（含 *.g.dart）
  repositories/        # 数据仓储层
  services/            # 通知/存储/网络/日志等服务
  theme/               # 主题与颜色体系
  utils/               # 通用工具（时间、权限、设备、存储等）
  views/               # 页面与组件
  main.dart            # 应用入口
android/ ios/          # 原生平台工程
test/                  # 测试
pubspec.yaml           # 依赖与构建配置
analysis_options.yaml  # Lints 配置
l10n.yaml              # i18n 生成配置
```

## 关键模块说明
- `lib/core/app.dart`：应用级配置（主题、语言、路由等）
- `lib/core/di.dart`：依赖注入注册
- `lib/services/notification_service.dart`：本地通知与权限检查逻辑
- `lib/utils/common/permission_utils.dart`：权限请求与状态检查
- `lib/theme/app_theme.dart`：主题（Material 3）
- `lib/l10n/` + `lib/generated/`：国际化资源与生成代码

## 文档维护规则
- 每个功能在验收确认后更新本文件（仅更新事实性内容：结构、规范、依赖、流程等）。
- 不记录“已完成/当前状态/待办”等进度性内容，保持文档干净可复用。

## 运行与构建提示
- 安装依赖：`flutter pub get`
- 本地运行：`flutter run`
- 代码检查：`flutter analyze`
- 测试：`flutter test`
- 代码生成（Hive/序列化等）：`flutter pub run build_runner build --delete-conflicting-outputs`
- 国际化生成：依赖 `l10n.yaml`，使用 `flutter gen-l10n` 执行生成命令；`flutter pub get` 会触发生成（`flutter.generate: true`）

## 开发规范与注意事项（来自 `docs/TDD.md`）
- Git 分支：`main` / `develop` / `feature/*` / `bugfix/*` / `release/*`
- Commit 前缀：`feat` `fix` `docs` `style` `refactor` `test` `chore` 等；Commit信息使用中文。
- 版本号：`X.Y.Z+B`（语义化版本 + 构建号）
- CI/CD：PR 触发构建与测试，Tag 触发发布
- Lint：遵循 `flutter_lints`
- 版本兼容：遇到弃用 API 需替换为当前推荐写法（如 `Color.withValues(alpha: ...)`）

## 环境与兼容性
- 目标 SDK：Flutter 3.35.7 / Dart 3.9.2 / DevTools 2.48
- 兼容目标（PRD）：Android 8.0+、iOS 12+

## 已知问题
- `device_info_plus` 相关依赖识别异常（构建期报错）
- `CardTheme` 类型不匹配（Flutter 3.35.7 下要求 `CardThemeData?`）
- 报错文件：`lib/services/notification_service.dart`、`lib/theme/app_theme.dart`、`lib/utils/common/permission_utils.dart`

## 参考文档
- `docs/PRD.md`：产品需求与业务背景
- `docs/TDD.md`：技术设计与开发规范
- `pubspec.yaml`：依赖与构建配置
