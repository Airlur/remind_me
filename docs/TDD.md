一、需求概述
简要概述需求，必要时可附上相关产品需求文档、设计稿等链接
- 需求简介：
- 产品需求文档：PRD文档
- 设计稿：暂无

二、项目目录结构

lib/
├── blocs/               # 状态管理(VM)
│   ├── event/
│   │   ├── event_bloc.dart           # 事件状态管理逻辑
│   │   ├── event_event.dart          # 事件相关操作定义
│   │   └── event_state.dart          # 事件状态定义
│   ├── settings/
│   │   ├── settings_bloc.dart         # 设置状态管理逻辑
│   │   ├── settings_event.dart        # 设置相关操作定义
│   │   └── settings_state.dart        # 设置状态定义
│   └── timer/
│       ├── timer_bloc.dart           # 计时器状态管理逻辑
│       ├── timer_event.dart          # 计时器相关操作定义
│       └── timer_state.dart          # 计时器状态定义
├── constants/          # 常量
│   ├── colors.dart           # 应用颜色常量
│   ├── config.dart           # 全局配置常量
│   ├── date_constants.dart  # 日期功能常量
│   └── time_constants.dart  # 时间功能常量
├── core/                     # 核心功能
│   ├── app.dart             # 应用配置（主题、语言等全局配置）
│   ├── di.dart              # 依赖注入（服务和bloc注入）
│   └── routes.dart          # 路由管理（页面导航配置）
├── l10n/               # 国际化
│   ├── intl_en.arb           # 英文文本
│   ├── intl_zh.arb           # 中文文本
│   └── l10n.dart            # 国际化配置
├── models/                   # 数据模型层(M)
│   ├── event.dart           # 事件模型（倒数日/正数日事件定义）
│   ├── timer.dart           # 计时器模型（倒计时/秒表数据定义）
│   └── user_settings.dart   # 用户设置模型（主题、语言等配置定义）
├── services/           # 服务层
│   ├── log_service.dart              # 日志记录服务
│   ├── network_service.dart          # 网络请求服务
│   ├── notification_service.dart      # 通知管理服务
│   └── storage_service.dart          # 数据存储服务
├── utils/              # 工具类   
│   ├── common/            # 通用工具
│   │   ├── device_utils.dart       # 设备和平台相关
│   │   ├── permission_utils.dart    # 权限管理
│   │   └── security_utils.dart      # 安全相关
│   ├── datetime/           # 日期时间相关工具
│   │   ├── date_utils.dart         # 日期相关计算
│   │   ├── format_utils.dart       # 时间格式化
│   │   └── timer_utils.dart        # 计时相关计算
│   └── storage/           # 存储相关工具
│       ├── hive_utils.dart         # Hive操作工具
│       └── prefs_utils.dart        # SharedPreferences工具
├── views/                   # 视图层(V)
│   ├── pages/              # 页面
│   │   ├── date/          # 日期模块
│   │   │   ├── calendar_page.dart     # 日历页面
│   │   │   ├── components/            # 日期模块专用组件
│   │   │   │   ├── calendar_widget.dart # 日历展示组件
│   │   │   │   ├── event_form.dart    # 事件表单组件（新建/编辑用）
│   │   │   │   ├── event_item.dart    # 事件列表项组件（标题、日期、天数）
│   │   │   │   └── event_list.dart    # 事件列表容器组件
│   │   │   ├── countdown_page.dart    # 倒数日页面
│   │   │   ├── countup_page.dart      # 正数日页面
│   │   │   └── date_page.dart        # 日期主页面
│   │   ├── settings/     # 设置模块
│   │   │   └── settings_page.dart     # 设置页面
│   │   └── time/         # 时间模块
│   │       ├── components/            # 时间模块专用组件
│   │       │   ├── countdown_timer.dart # 倒计时组件（时分秒显示和控制）
│   │       │   ├── lap_list.dart       # 分段时间列表组件
│   │       │   ├── stopwatch_display.dart # 秒表显示组件（时间和分段显示）
│   │       │   └── time_picker.dart    # 时间选择器组件（设置目标时间）
│   │       ├── countdown_page.dart    # 倒计时页面
│   │       ├── stopwatch_page.dart    # 秒表页面
│   │       └── time_page.dart        # 时间主页面
│   └── widgets/          # UI组件
│       ├── common/        # 通用组件
│       │   ├── bottom_nav_bar.dart    # 底部导航栏
│       │   ├── empty_placeholder.dart  # 空状态占位组件
│       │   ├── loading.dart           # 加载状态组件
│       │   └── toast.dart             # Toast提示组件
│       ├── dialog/        # 弹窗组件
│       │   ├── action_sheet.dart    # 底部操作表
│       │   ├── confirm_dialog.dart  # 确认弹窗
│       │   └── input_dialog.dart    # 输入弹窗
│       └── feedback/      # 反馈组件
│           ├── progress.dart       # 进度条提示
│           ├── snackbar.dart       # Snackbar提示（撤销删除）
│           └── toast.dart          # Toast提示
└── main.dart                  # 应用入口文件

三、技术架构
3.1 客户端（Flutter）
- 状态管理：flutter_bloc
  - 管理全局状态和业务逻辑（EventBloc管理事件，TimerBloc管理计时，SettingsBloc管理设置）
  - 遵循 Event -> Bloc -> State 模式，使用 bloc_test 进行单元测试，使用 hydrated_bloc 实现状态持久化
- 本地存储：
  - Hive：存储结构化数据（事件数据、计时记录、时间线记录）
  - SharedPreferences：存储简单配置（用户设置、主题配置、语言设置）
- 通知管理：flutter_local_notifications（本地定时提醒、通知样式管理、重复提醒规则）
- 网络请求：Dio（会员功能接口、数据同步、错误处理）
- UI组件：flutter_screenutil（屏幕适配）、animations（动画效果）、custom_painter（自定义绘制）
- 工具库：intl（日期格式化）、timezone（时区处理）、path_provider（文件管理）、permission_handler（权限管理）、encrypt（数据加密）、bloc_test（Bloc测试支持）、hydrated_bloc（Bloc状态持久化）

3.2 状态管理设计
- EventBloc（事件管理）
  - 状态：事件列表、加载状态、筛选条件
  - 事件：添加事件、删除事件、更新事件、筛选事件、排序事件、导入导出事件
- TimerBloc（计时管理）
  - 状态：计时状态（运行/暂停/停止）、当前时间、计时记录
  - 事件：开始计时、暂停计时、重置计时、记录分段、保存记录
- SettingsBloc（设置管理）
  - 状态：主题设置、语言设置、通知设置、动画设置
  - 事件：更新主题、更新语言、更新通知设置、更新动画设置

3.3 数据存储设计
- Hive数据模型：
  - 事件数据模型：基础信息（ID、标题、目标日期等）、时间线记录、提醒设置、分类标签
  - 计时器数据模型：倒计时记录、秒表记录、分段记录
  - 用户数据模型：个性化设置、主题配置、通知偏好
- SharedPreferences配置：主题设置、语言设置、通知开关、动画设置、其他用户偏好

3.4 通知设计
1. 通知渠道：事件提醒通知、计时完成通知、系统通知
2. 通知优先级：高优先级（事件到期提醒）、中优先级（计时完成提醒）、低优先级（系统通知）

3.5 工具类设计
1. DateTimeUtils (时间工具类)
- 功能描述：处理日期时间相关的基础操作。
- 技术选型：
  - intl：日期格式化
  - timezone：时区处理
- 核心功能：
  - 日期格式化：支持公历和农历的日期转换，以及多种日期格式的显示
  - 时间计算：计算时间差值、倒数日期和重复周期
  - 时区处理：支持时区转换和跨时区日期计算
  - 提醒时间管理：检测提醒是否到期，计算下次提醒时间，并生成重复提醒的时间序列

2. StorageUtils (存储工具类)
- 功能描述：处理本地数据存储的基础操作。
- 技术选型：
  - shared_preferences：键值对存储
  - path_provider：文件路径管理
- 核心功能：
  - 键值对操作：支持用户设置和偏好的读写、批量操作和事务处理
  - 文件操作：支持文件的读写、加密和解密，以及缓存管理
  - 数据导出：支持数据的导入导出，包括txt和word格式
  - 缓存管理：支持文件的缓存和清理，确保存储空间的合理使用

3. DeviceUtils (设备工具类)
- 功能描述：处理设备相关的基础信息获取。
- 技术选型：
  - device_info_plus：设备信息
  - flutter_screenutil：屏幕适配
- 核心功能：
  - 设备信息：获取设备标识、系统版本和设备语言
  - 屏幕适配：支持屏幕尺寸的获取和适配计算
  - 系统设置：获取系统主题、语言等设置并监听系统变化
  - 设备性能：监控设备性能状态，确保应用流畅运行

4. PermissionUtils (权限工具类)
- 功能描述：处理应用权限相关的基础操作。
- 技术选型：
  - permission_handler：权限管理
- 核心功能：
  - 权限请求：动态请求通知、存储、日历等系统权限
  - 权限检查：检查权限状态，判断是否已授权
  - 权限说明：生成权限说明文案，提供用户友好的权限说明
  - 降级处理：在权限被拒绝时，提供降级方案以确保功能可用性

5. SecurityUtils (安全工具类)
- 功能描述：处理数据安全相关的基础操作。
- 技术选型：
  - encrypt：数据加密
  - flutter_secure_storage：安全存储
- 核心功能：
  - 数据加密：支持数据的加密和解密，确保敏感信息的安全性
  - 密钥管理：支持密钥的生成、存储和验证
  - 数据校验：支持数据完整性校验，防止数据被篡改
  - 安全存储：支持敏感数据的安全存储和访问控制

3.5 服务层设计
1. NotificationService (通知服务)
- 功能描述：管理应用内所有通知相关功能。
- 技术选型：
  - flutter_local_notifications：本地通知
- 核心功能：
  - 通知管理：创建通知渠道，发送、更新和取消通知
  - 通知样式：支持普通通知、横幅通知和锁屏通知
  - 定时任务：支持创建、取消和更新定时通知
  - 重复提醒：支持自定义重复规则的提醒设置
  - 通知权限：处理通知权限的申请和变更

2. StorageService (存储服务)
- 功能描述：管理事件数据、计时数据、用户设置的存储和同步。
- 技术选型：
  - sqflite：本地数据库
  - shared_preferences：配置存储
- 核心功能：
  - 数据库操作：支持数据的增删改查、批量操作和事务处理
  - 数据同步：支持本地数据备份、云端数据同步和数据导入导出
  - 数据迁移：支持版本升级时的数据迁移和数据结构变更处理
  - 存储优化：支持数据压缩和清理，优化存储空间使用

3. LogService (日志服务)
- 功能描述：管理应用日志和异常监控。
- 技术选型：
  - logger：日志记录
  - sentry_flutter：异常监控
- 核心功能：
  - 日志记录：支持不同级别的日志记录，并可将日志保存到文件
  - 异常捕获：捕获全局异常，记录错误信息并上报
  - 性能监控：记录关键操作的性能数据，帮助优化应用性能
  - 日志管理：支持日志文件的压缩、加密和清理

4. NetworkService (网络服务)
- 功能描述：管理应用的网络请求。
- 技术选型：
  - dio：网络请求
  - connectivity_plus：网络状态
- 核心功能：
  - 网络请求：支持GET、POST请求，以及文件的上传和下载
  - 状态监测：检测网络连接状态，获取网络类型并监听网络变化
  - 错误处理：支持超时处理、重试机制和错误回调
  - 数据同步：支持会员数据的云端同步和离线缓存
3.5 会员服务设计
- 安卓端：自行编写后端内购功能，使用国内云服务（如阿里云、腾讯云）进行用户认证和数据同步。
- iOS端： 使用In-App Purchase插件实现应用内购买功能，确保符合App Store审核规则。

四、API接口设计
4.1 基础规范
- 基础域名：api.remindme.com
- 请求方式：POST/GET
- 数据格式：JSON
- 认证方式：Bearer Token
- 版本控制：URL中包含v1
- 响应格式：
{
    "code": 0,
    "message": "success",
    "data": {}
}

4.2 用户接口
- POST /v1/user/register - 用户注册
- POST /v1/user/login - 用户登录
- GET /v1/user/info - 获取用户信息
- PUT /v1/user/info - 更新用户信息
- POST /v1/user/vip - 开通会员
- GET /v1/user/vip/info - 获取会员信息

4.3 数据同步接口
- GET /v1/sync/events - 获取事件列表
- POST /v1/sync/events - 上传事件数据
- GET /v1/sync/settings - 获取设置数据
- POST /v1/sync/settings - 上传设置数据
- POST /v1/sync/backup - 创建备份
- GET /v1/sync/backup - 获取备份列表
- POST /v1/sync/restore - 恢复备份

4.4 错误码定义
4.4.1 HTTP状态码使用
- 2xx 成功
  - 200 OK：请求成功
  - 201 Created：备份创建成功
- 4xx 客户端错误
  - 401 Unauthorized：未登录/Token失效（会员相关）
  - 403 Forbidden：非会员功能访问限制
  - 429 Too Many Requests：同步频率限制
- 5xx 服务端错误
  - 500 Internal Server Error：服务器错误
  - 503 Service Unavailable：同步服务不可用

五、测试计划
5.1 单元测试
- Bloc测试
  - EventBloc测试用例
  - TimerBloc测试用例
  - SettingsBloc测试用例
- 工具类测试
  - DateTimeUtils测试用例
  - StorageUtils测试用例
  - SecurityUtils测试用例
- 服务层测试
  - NotificationService测试用例
  - StorageService测试用例
  - NetworkService测试用例

5.2 集成测试
- 页面交互测试
  - 导航流程测试
  - 表单操作测试
  - 列表操作测试
- 数据流测试
  - 数据存储测试
  - 数据同步测试
  - 状态管理测试
- 性能测试
  - 启动时间测试
  - 内存占用测试
  - 页面切换测试
  - 大数据量测试

5.3 测试覆盖率要求
- 代码覆盖率
  - 整体代码覆盖率 > 80%
  - 核心功能覆盖率 > 90%
  - UI组件覆盖率 > 70%
- 测试类型覆盖
  - 单元测试占比 > 60%
  - 集成测试占比 > 30%
  - UI测试占比 > 10%

六、开发规范
6.1 Git规范
- 分支管理
  - main：主分支，保持稳定
  - develop：开发分支
  - feature/*：功能分支
  - bugfix/*：修复分支
  - release/*：发布分支
- 提交规范
  - feat: 新功能
  - fix: 修复bug
  - docs: 文档更新
  - style: 代码格式（不影响功能的更改，如空格、格式化、缺少分号等）
  - refactor: 重构（既不修复bug也不添加功能的代码更改）
  - test: 测试相关（添加缺失的测试或更正现有测试）
  - chore: 构建相关的更改（例如，依赖项的更新或其他非源代码的更改）
  - perf: 性能优化
  - build: 构建相关的更改（例如，构建工具或依赖项的更改）
  - ci: 持续集成相关的更改（例如，CI配置文件的修改）
  - revert: 撤销之前的提交
  - wip: 进行中的工作（Work In Progress）
  - config: 配置文件的更改
  - security: 安全相关的更改
  - lint: 代码检查和修复
  - ui: 用户界面相关的更改
  - locale: 国际化和本地化相关的更改
- Code Review流程
  - 提交PR前自测
  - 至少1人Review通过
  - 所有CI检查通过
  - 合并后删除分支

6.2 CI/CD流程
- 自动化构建
  - 触发条件：PR提交、Tag创建
  - 构建环境：Flutter stable
  - 构建产物：APK、IPA
- 自动化测试
  - 单元测试执行
  - 集成测试执行
  - 代码质量检查
  - 覆盖率统计
- 发布流程
  - 测试环境：PR合并后自动发布
  - 预发环境：手动触发发布
  - 生产环境：Tag触发发布