# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个HarmonyOS应用（tomato_clock_harmony）- 番茄钟生产力应用，包含任务管理功能。使用ArkTS（基于TypeScript的HarmonyOS开发语言）和Stage模型构建。

## 开发命令

### 构建项目
```bash
# 使用Hvigor构建HAP包
hvigorw --mode module -p module=entry@default -p product=default assembleHap
```

### 运行测试
```bash
# 运行所有测试
hvigorw --mode module -p module=entry@default -p product=default test
```

### 同步依赖
```bash
# 安装依赖
ohpm install
```

## 架构设计

### 导航架构
应用使用HarmonyOS Navigation组件，通过全局`NavPathStack`管理导航：
- **GlobalNavStack** (`common/GlobalNavStack.ets`): 所有页面共享的导航栈
- **路由配置** (`resources/base/profile/route_map.json`): 定义所有可导航页面
- 页面跳转使用: `GlobalNavStack.pushPathByName('页面名称', 参数)`

**已注册的页面名称**：
- `Index` - 登录/欢迎页
- `MainPage` - 主页面（包含3个Tab）
- `CountDownTimerPage` - 番茄钟计时页面
- `TaskEditPage` - 任务编辑页面

### 核心数据模型

**ToDoListClass** (`viewmodel/ToDoListClass.ets`)：支持两种任务模式
- **待办模式 (mode=1)**：一次性任务，有总目标番茄数
- **长期模式 (mode=2)**：每日重复任务，有每日目标番茄数

关键属性说明：
- `target_tomato_count`: 待办模式的总目标番茄数
- `daily_target_tomato_count`: 长期模式的每日目标番茄数
- `finished_tomato_count`: 历史累计完成番茄总数
- `today_finished_count`: 今日已完成番茄数（仅长期模式）
- `deadline`: 截止日期（仅长期模式）
- `last_reset_date`: 最后重置日期，用于判断是否需要重置今日计数

### 枚举类型
- **TaskType**: `Todo=1`（待办）, `Plan=2`（长期计划）
- **TaskStatus**: `Rest=1`（休息）, `Working=2`（专注中）

### 页面组件关系

1. **Index.ets** → 登录页，点击登录后跳转到 `MainPage`
2. **MainPage.ets** → 主Tab容器，包含3个Tab：
   - Tab 0: `ToDoList` 组件（任务列表）
   - Tab 1: `Statistics` 组件（统计页，待开发）
   - Tab 2: `Profile` 组件（个人中心，待开发）
3. **CountDownTimer.ets** → 计时器页面，接收 `ToDoListClass` 对象作为参数
4. **TaskEdit.ets** → 任务创建/编辑页面（未追踪，但在路由中注册）

### 计时器逻辑

**CountDownTimer组件** 的状态机：
- 初始化 → `startWorkingMode()` → 专注模式计时
- 专注结束 → `handleWorkingModeEnd()` → 判断是否有剩余番茄
  - 有剩余 → `startRestMode()` → 休息模式计时
  - 无剩余 → 返回任务列表
- 休息结束 → `handleRestModeEnd()` → 判断是否有剩余番茄
  - 有剩余 → `startWorkingMode()`
  - 无剩余 → 返回任务列表

### 网络层

**ConnectionUtils** (`common/network/ConnectionUtils.ets`) 目前被注释掉。应用使用模拟数据进行开发：
- `ToDoList.ets` 的 `loadTaskList()` 方法中定义了测试数据
- 当需要对接后端时，取消注释 ConnectionUtils 代码并更新 BASE_URL

## 资源引用

资源使用 `$r()` 函数引用：
- 字符串: `$r("app.string.string_name")`
- 颜色: `$r("app.color.color_name")`
- 图片: `$r("app.media.image_name")`

**重要颜色资源**：
- `color_theme`: 主题色（用于按钮、高亮等）
- `color_unselected`: 未选中状态颜色
- `color_todo_list_content`: 任务详情文本颜色

## 开发规范

### 页面导出模式
所有需要导航的页面都使用Builder模式导出：
```ets
@Builder
export function PageNameBuilder() {
  PageName()
}
```

### 路由注册
新增页面时需要：
1. 创建页面组件和对应的Builder函数
2. 在 `route_map.json` 中注册路由
3. 使用 `GlobalNavStack.pushPathByName('页面名', 参数)` 进行跳转

### 状态管理
- 组件内部状态使用 `@State` 装饰器
- 从父组件传入的属性使用 `@Prop` 装饰器
- 导航参数通过 `NavDestinationContext` 的 `pathInfo.param` 获取

### 样式复用
使用 `@Extend` 定义可复用样式：
```ets
@Extend(Text)
function textStyle() {
  .fontSize('14vp')
  .fontColor($r("app.color.color_theme"))
}
```

## 构建配置

- **目标SDK**: HarmonyOS 6.0.1 (API 21)
- **构建工具**: Hvigor
- **包格式**: HAP
- **应用模型**: Stage模型（非FA模型）
- **支持设备**: phone, tablet, 2in1, wearable

## 测试框架

- **@ohos/hypium**: 测试框架（版本 1.0.24）
- **@ohos/hamock**: Mock框架（版本 1.0.0）
- 单元测试位置: `entry/src/test/`
- 集成测试位置: `entry/src/ohosTest/`

## 重要提示

- 文件扩展名为 `.ets`（ArkTS文件）
- 布局单位使用 `vp`（如 `'24vp'`）
- 计时器功能使用 `@kit.ArkUI` 的 `TextTimerController`
- 网络权限已在 `module.json5` 中预配置
- 长期模式任务的"今日计数"需要在适当时候调用 `resetTodayCount()` 重置
