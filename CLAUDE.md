# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

鸿蒙番茄钟应用，基于番茄工作法的计时工具。使用 ArkTS + ArkUI 构建，面向 HarmonyOS 6.0.1(21)。当前以**完全离线/本地模式**运行，认证为模拟实现，网络层已注释。

**包名**: `com.paolua.tomato_clock_harmony` | **版本**: 1.0.0

## 构建与测试

```bash
# 构建（通过 DevEco Studio 或 CLI）
hvigorw assembleHap          # Debug 构建
hvigorw assembleHap --mode release  # Release 构建

# 代码检查
hvigorw codeLinter            # 运行 code-linter（@typescript-eslint + @performance + 安全规则）

# 测试
hvigorw @ohos/hypium/test     # 运行单元测试（describe/it/expect 模式）
# 单个测试文件需要通过 DevEco Studio IDE 运行或修改 test 配置指定
```

测试框架: `@ohos/hypium@1.0.24` + `@ohos/hamock@1.0.0`（Mock）
测试目录: `entry/src/test/`（单元测试）、`entry/src/ohosTest/`（设备测试）

## 架构

### 整体模式：服务层 + MVVM

```
pages/           → 可路由页面（NavDestination），注册于 route_map.json
view/            → Tab 内容视图，嵌入 MainPage
view/components/ → 可复用 UI 组件（TaskCard、StatCard）
viewmodel/       → 数据模型与枚举
service/         → 静态单例服务（核心业务逻辑）
common/          → 工具类、常量、验证器
```

### 导航

- 入口页面: `pages/Index`（在 `main_pages.json` 中声明）
- 其他页面通过 `NavPathStack` 单例（`GlobalNavStack`）+ `route_map.json` 路由
- 页面使用 `@Builder` 导出函数注册到路由表，通过 `pushPathByName()` 导航

### 服务初始化链（EntryAbility.onWindowStageCreate）

严格按顺序初始化，后者依赖前者：
1. `StorageService.init(context)` — 封装 Preferences API，JSON 序列化
2. `AuthService.init()` — 认证（当前为模拟实现）
3. `TaskService.init()` — 任务 CRUD
4. `TimerService.init()` — 计时器状态管理

所有服务遵循**静态单例模式**: `private constructor()` + `static init()` + 全静态方法。

### 状态管理

- **AppStorage** 全局总线：通过 `TASK_REFRESH_TRIGGER` 计数器广播变更
- 组件使用 `@StorageLink`/`@StorageProp` + `@Watch` 监听刷新
- `@State` 管理组件局部 UI 状态，`@Prop` 父到子单向绑定
- `@Observed/@Track` 用于 ViewModel 细粒度响应式（如 `TimerViewModel`）

### 任务模型（两种模式）

- **TODO**（一次性）: `target_tomato_count` → `finished_tomato_count`
- **PLAN**（每日循环）: `daily_target_tomato_count` + `deadline` → `today_finished_count`（每日重置）

### 数据持久化

使用 HarmonyOS Preferences API（键值对存储），通过 `StorageService` 封装。复杂对象 JSON 序列化。无数据库。

## 代码规范

- **ArkTS 严格 TypeScript**: 禁用 `any`，优先 `const`
- **代码检查**: `code-linter.json5` 启用 `@typescript-eslint/recommended` + `@performance/recommended` + 安全规则
- **日志**: 使用集中式 `Logger` 工具，前缀 `[TomatoClock]`
- **主题色**: `#FF684A`（番茄红），颜色定义在 `resources/base/element/color.json`
- **单位**: 间距用 vp，字体用 fp
- **验证**: 使用 `TaskValidator` + `ValidationResult` 模式（valid/invalid + 错误列表）
- **混淆**: `entry/obfuscation-rules.txt` 启用属性/顶层/文件名/导出混淆

## 路由表

| 路由名 | 页面文件 | Builder 函数 | 用途 |
|---|---|---|---|
| IndexPage | pages/Index.ets | IndexBuilder | 登录/欢迎页 |
| MainPage | pages/MainPage.ets | MainPageBuilder | Tab 主页 |
| CountDownTimerPage | pages/CountDownTimer.ets | CountDownTimerBuilder | 计时器 |
| TaskEditPage | pages/TaskEdit.ets | TaskEditBuilder | 任务编辑 |

## 目标设备

手机、平板、二合一设备、穿戴设备（`module.json5` 中声明）

## 当前状态

- 认证: **模拟实现**（伪造 token，无真实后端调用）
- 网络: `ConnectionUtils.ets` **已全部注释**
- 数据: 完全本地存储，无后端同步
- 已声明 `ohos.permission.INTERNET` 但未使用
