# 导航结构

> 版本：v1.1
> 创建日期：2026-03-18
> 更新日期：2026-03-19
> 状态：需求确认中

---

## 6.1 信息架构

```
登录页 (Index)
    ├─ 微信登录
    └─ 华为账号登录
        ↓
主页 (MainPage) - 底部Tab导航
    ├─ 任务列表Tab (ToDoList) ──────┐
    │   ├─ 任务列表展示              │
    │   ├─ 新建任务                 │
    │   ├─ 筛选/排序                │
    │   └─ 任务卡片交互             │
    │                               │
    └─ 我的Tab (Profile)            │
        ├─ 用户信息                 │
        │   ├─ 昵称/头像             │
        │   ├─ 登录方式             │
        │   └─ 退出登录             │
        └─ 设置                     │
                                    │
计时器页 (CountDownTimer) ←─────────┘
    ├─ 专注模式
    ├─ 休息模式
    └─ 结束弹窗

任务编辑页 (TaskEdit)
    ├─ 创建新任务
    └─ 编辑现有任务
```

---

## 6.2 页面流转

### 6.2.1 主要流转路径

```
┌──────────┐
│  登录页  │ ──→ 选择登录方式（微信/华为）
└─────┬────┘
      │ 授权成功
      ↓
┌──────────┐
│  主页    │ ──→ 任务列表Tab ──→ 点击任务 ──→ 计时器页 ──→ 完成 ──┐
│          │                                              │
│          │ ──→ 我的Tab ──→ 退出登录 ──────────────────────┤
│          │                                              │
└──────────┘                                              │
      │                                                   │
      ├─ 点击新建按钮 ──→ 任务编辑页 ──────────────────────┘
      │
      └─ 点击任务卡片 ──→ 任务编辑页
```

### 6.2.2 登录认证流程

```
[App启动]
    │
    ▼
[检查本地Token]
    │
    ├─ Token有效 ──→ [主页]
    │
    ├─ Token过期 ──→ [尝试刷新]
    │   │
    │   ├─ 刷新成功 ──→ [主页]
    │   └─ 刷新失败 ──→ [登录页]
    │
    └─ 无Token ──→ [登录页]
        │
        ▼
    [选择登录方式]
        │
        ├─ [微信登录]
        │   │
        │   ├─ 授权成功 ──→ [后端验证] ──→ [主页]
        │   └─ 授权失败 ──→ [登录页]
        │
        └─ [华为账号登录]
            │
            ├─ 授权成功 ──→ [后端验证] ──→ [主页]
            └─ 授权失败 ──→ [登录页]
```

### 6.2.2 页面跳转方式

使用 `NavPathStack` 进行页面导航：

```typescript
// 跳转到主页
GlobalNavStack.pushPathByName('MainPage', null);

// 跳转到计时器页（传递任务对象）
GlobalNavStack.pushPathByName('CountDownTimerPage', toDoList);

// 跳转到任务编辑页（传递编辑参数）
GlobalNavStack.pushPathByName('TaskEditPage', {
  isNew: true,
  task: null
});

// 返回上一页
GlobalNavStack.pop();
```

---

## 6.3 页面定义

### 6.3.1 登录页 (Index)

**路由名称**：`Index`

**功能**：
- 应用Logo和欢迎信息
- 微信一键登录入口
- 华为账号登录入口
- 用户协议和隐私政策链接
- 自动检查登录状态

**组件**：`Index.ets`

**交互说明**：
- 页面加载时自动检查本地Token状态
- Token有效则直接跳转主页
- Token无效或过期则显示登录选项
- 点击登录方式后拉起对应授权页面
- 授权成功后调用后端接口验证并获取用户信息

### 6.3.2 主页 (MainPage)

**路由名称**：`MainPage`

**Builder函数**：`MainPageBuilder()`

**功能**：
- 底部Tab导航容器
- 包含三个子页面
- Tab切换状态管理

**组件**：`MainPage.ets`

**Tab配置**：
| Tab索引 | 页面 | 图标 | 标题 |
|---------|------|------|------|
| 0 | ToDoList | todo_list | 任务列表 |
| 1 | Profile | profile | 我的 |

> 注：统计功能延期到v1.1版本

### 6.3.3 任务列表 (ToDoList)

**类型**：View Component

**功能**：
- 显示所有进行中的任务
- 新建任务入口
- 任务筛选和排序
- 长按拖拽调整优先级

**组件**：`view/ToDoList.ets`

### 6.3.4 计时器页 (CountDownTimer)

**路由名称**：`CountDownTimerPage`

**Builder函数**：`CountDownTimerBuilder()`

**参数**：`ToDoListClass` 对象

**功能**：
- 专注模式倒计时
- 休息模式倒计时
- 暂停/继续/结束操作
- 进度显示

**组件**：`pages/CountDownTimer.ets`

### 6.3.5 任务编辑页 (TaskEdit)

**路由名称**：`TaskEditPage`

**Builder函数**：`TaskEditBuilder()`

**参数**：`TaskEditParams` 对象
```typescript
interface TaskEditParams {
  isNew: boolean;
  task: ToDoListClass | null;
}
```

**功能**：
- 创建新任务
- 编辑现有任务
- 删除任务

**组件**：`pages/TaskEdit.ets`

### 6.3.6 统计页 (Statistics)

**类型**：View Component

**状态**：v1.1版本

**功能**：
- 今日/本周/本月统计切换
- 数据卡片展示
- 趋势图表

**组件**：`view/Statistics.ets`

> 注：此页面延期到v1.1版本

### 6.3.7 我的页 (Profile)

**类型**：View Component

**功能**：
- 用户信息展示（昵称、头像）
- 登录方式显示
- 退出登录
- 设置入口
- 关于信息

**组件**：`view/Profile.ets`

**交互说明**：
- 显示当前登录用户的昵称和头像
- 显示登录方式（微信/华为账号）
- 点击"退出登录"弹出确认弹窗
- 确认后清除本地Token并返回登录页

---

## 6.4 路由配置

路由配置文件：`entry/src/main/resources/base/profile/route_map.json`

```json
{
  "routerMap": [
    {
      "name": "MainPage",
      "pageSourceFile": "src/main/ets/pages/MainPage.ets",
      "buildFunction": "MainPageBuilder"
    },
    {
      "name": "CountDownTimerPage",
      "pageSourceFile": "src/main/ets/pages/CountDownTimer.ets",
      "buildFunction": "CountDownTimerBuilder"
    },
    {
      "name": "TaskEditPage",
      "pageSourceFile": "src/main/ets/pages/TaskEdit.ets",
      "buildFunction": "TaskEditBuilder"
    }
  ]
}
```

---

## 6.5 全局导航栈

使用全局单例的 `NavPathStack`：

```typescript
// common/GlobalNavStack.ets
export const GlobalNavStack = new NavPathStack();
```

所有页面共享同一个导航栈，确保页面跳转的一致性。

---

## 6.6 页面生命周期

### 6.6.1 NavDestination 生命周期

```typescript
NavDestination() {
  // 页面内容
}
.onReady((context: NavDestinationContext) => {
  // 页面创建完成，可以接收参数
})
.onActive(() => {
  // 页面激活
})
.onInactive(() => {
  // 页面失活
})
.onWillDisappear(() => {
  // 页面即将消失
})
```

### 6.6.2 应用生命周期

```typescript
// entryability/EntryAbility.ets
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 应用创建
  }

  onDestroy(): void {
    // 应用销毁
  }

  onForeground(): void {
    // 应用前台
  }

  onBackground(): void {
    // 应用后台
  }
}
```

---

**相关文档：**
- [产品概述](../functional/overview.md)
- [用户认证功能](../functional/user-auth.md)
- [任务管理](../functional/task-management.md)
- [页面布局](./pages.md)
