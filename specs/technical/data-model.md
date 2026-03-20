# 数据模型

> 版本：v1.1
> 创建日期：2026-03-18
> 更新日期：2026-03-19
> 状态：需求确认中

---

## 1. 概述

本文档定义番茄钟应用的核心数据模型，包括用户认证、任务管理、数据持久化等模块的数据结构。

### 1.1 数据模型分层

```
┌─────────────────────────────────────────────────────────────┐
│                      前端数据模型（ArkTS）                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   用户模型   │  │   任务模型   │  │     认证模型        │  │
│  │    User     │  │ ToDoListClass│  │    AuthState        │  │
│  │             │  │    Timer     │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                   本地持久化（Preferences API）              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ auth_state  │  │  user_tasks │  │   app_settings      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      后端数据库（MySQL）                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    user     │  │    task     │  │   tomato_record     │  │
│  │  user_bind  │  │             │  │  token_blacklist    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 用户认证数据模型

### 2.1 User（用户信息）

**文件位置**：`entry/src/main/ets/viewmodel/User.ets`

```typescript
export class User {
  id: number = 0;
  nickname: string = '';
  avatar: string = '';
  loginType: LoginType = LoginType.WECHAT;
  createdAt: Date = new Date();

  // 计算属性
  get displayName(): string {
    return this.nickname || '番茄用户';
  }

  get avatarUrl(): string {
    return this.avatar || '';
  }
}
```

### 2.2 LoginType（登录类型枚举）

**文件位置**：`entry/src/main/ets/viewmodel/LoginType.ets`

```typescript
export enum LoginType {
  WECHAT = 'wechat',    // 微信登录
  HUAWEI = 'huawei'     // 华为账号登录
}
```

### 2.3 AuthState（认证状态）

**文件位置**：`entry/src/main/ets/viewmodel/AuthState.ets`

```typescript
export class AuthState {
  isLoggedIn: boolean = false;
  user: User | null = null;
  accessToken: string = '';
  refreshToken: string = '';
  tokenExpiresAt: Date = new Date();

  // 检查Token是否过期
  isTokenExpired(): boolean {
    return new Date() >= this.tokenExpiresAt;
  }

  // 检查是否需要刷新Token
  shouldRefreshToken(): boolean {
    const now = new Date();
    const expiresAt = this.tokenExpiresAt;
    // 提前1天刷新
    const refreshTime = new Date(expiresAt.getTime() - 24 * 60 * 60 * 1000);
    return now >= refreshTime;
  }
}
```

### 2.4 用户认证接口定义

```typescript
// 微信登录请求
interface WechatLoginRequest {
  code: string;  // 微信授权码
}

// 华为登录请求
interface HuaweiLoginRequest {
  code: string;          // 华为授权码
  grant_type: string;    // 授权类型
}

// 登录响应
interface LoginResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  user: User;
}

// Token刷新请求
interface TokenRefreshRequest {
  refresh_token: string;
}

// Token刷新响应
interface TokenRefreshResponse {
  access_token: string;
  expires_in: number;
}
```

---

## 3. 任务数据模型

### 3.1 ToDoListClass（任务类）

**文件位置**：`entry/src/main/ets/viewmodel/ToDoListClass.ets`

```typescript
export class ToDoListClass {
  // 基础字段
  id: number = 0;                          // 任务唯一标识
  user_id: number = 0;                     // 所属用户ID
  name: string = '';                       // 任务名称

  // 模式标识
  mode: TaskMode = TaskMode.TODO;          // 1=待办, 2=计划

  // 时长配置
  tomato_minutes: number = 25;             // 番茄时长（分钟）
  rest_minutes: number = 5;                // 休息时长（分钟）

  // 待办模式字段
  target_tomato_count: number | null = null;  // 目标番茄数

  // 计划模式字段
  daily_target_tomato_count: number | null = null;  // 每日目标
  deadline: Date | null = null;                     // 截止日期
  last_reset_date: Date | null = null;              // 上次重置日期

  // 统计字段
  finished_tomato_count: number = 0;       // 累计已完成数
  today_finished_count: number = 0;        // 今日已完成数

  // 状态字段
  status: TaskStatus = TaskStatus.WORKING; // 任务状态

  // 时间戳
  created_at: Date = new Date();
  updated_at: Date = new Date();

  // 计算属性（计划模式）
  get total_target_tomato_count(): number {
    if (this.mode !== TaskMode.PLAN || !this.deadline || !this.daily_target_tomato_count) {
      return 0;
    }
    const days = this.calculateDays();
    return this.daily_target_tomato_count * days;
  }

  get progress(): number {
    if (this.mode === TaskMode.TODO) {
      return this.target_tomato_count ?
        (this.finished_tomato_count / this.target_tomato_count) * 100 : 0;
    } else {
      return this.total_target_tomato_count ?
        (this.finished_tomato_count / this.total_target_tomato_count) * 100 : 0;
    }
  }

  private calculateDays(): number {
    if (!this.deadline) return 0;
    const created = new Date(this.created_at);
    const end = new Date(this.deadline);
    return Math.ceil((end.getTime() - created.getTime()) / (1000 * 60 * 60 * 24));
  }

  // 方法
  isTodayResetNeeded(): boolean {
    if (this.mode !== TaskMode.PLAN) return false;
    if (!this.last_reset_date) return true;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const lastReset = new Date(this.last_reset_date);
    lastReset.setHours(0, 0, 0, 0);

    return today.getTime() > lastReset.getTime();
  }

  resetTodayCount(): void {
    this.today_finished_count = 0;
    this.last_reset_date = new Date();
  }

  isCompleted(): boolean {
    if (this.status === TaskStatus.CANCELLED || this.status === TaskStatus.EXPIRED) {
      return false;
    }

    if (this.mode === TaskMode.TODO) {
      return this.finished_tomato_count >= (this.target_tomato_count || 0);
    } else {
      // 计划模式：检查是否到达截止日期
      if (this.deadline && new Date() >= this.deadline) {
        return true;
      }
      // 或检查是否达到累计目标
      return this.finished_tomato_count >= this.total_target_tomato_count;
    }
  }
}
```

### 3.2 字段说明

#### 基础字段
| 字段 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| id | number | 任务唯一标识符，由后端生成 | 0（新建时） |
| user_id | number | 所属用户ID，数据隔离关键 | 0 |
| name | string | 任务名称，用户自定义 | '' |

#### 模式字段
| 字段 | 类型 | 说明 | 可选值 |
|------|------|------|--------|
| mode | TaskMode | 任务模式枚举 | TODO=待办, PLAN=计划 |

#### 时长字段
| 字段 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| tomato_minutes | number | 单个番茄钟时长（分钟） | 25 |
| rest_minutes | number | 休息时长（分钟） | 5 |

#### 目标字段（根据mode不同使用不同字段）
| 字段 | 类型 | 说明 | 适用模式 |
|------|------|------|----------|
| target_tomato_count | number \| null | 目标番茄总数 | 待办模式 |
| daily_target_tomato_count | number \| null | 每天目标番茄数（用户输入） | 计划模式 |
| deadline | Date \| null | 截止日期/坚持天数（用户输入） | 计划模式 |
| total_target_tomato_count | number | 累计总目标（系统计算 = 每天 × 天数） | 计划模式（只读） |

**说明：**
- **计划模式**：用户输入"每天多少"和"坚持天数"
  - `daily_target_tomato_count`：每天的目标（如5个/天）
  - `deadline`：截止日期，用于计算坚持天数
  - `total_target_tomato_count`：系统计算的总目标（如5×100=500）

#### 统计字段
| 字段 | 类型 | 说明 |
|------|------|------|
| finished_tomato_count | number | 历史累计完成番茄数 |
| today_finished_count | number | 今日已完成番茄数（每日重置） |

#### 状态字段
| 字段 | 类型 | 说明 | 可选值 |
|------|------|------|--------|
| status | TaskStatus | 任务状态枚举 | WORKING=进行中, COMPLETED=已完成, EXPIRED=已过期, CANCELLED=已取消 |
| last_reset_date | Date \| null | 上次重置"今日计数"的日期 | - |

---

## 4. 枚举定义

### 4.1 TaskMode（任务模式）

**文件位置**：`entry/src/main/ets/viewmodel/TaskMode.ets`

```typescript
export enum TaskMode {
  TODO = 1,    // 待办模式：一次性任务
  PLAN = 2     // 计划模式：每日重复任务
}
```

### 4.2 TaskStatus（任务状态）

**文件位置**：`entry/src/main/ets/viewmodel/TaskStatus.ets`

```typescript
export enum TaskStatus {
  WORKING = 1,    // 进行中（通用）
  COMPLETED = 2,  // 已完成（通用）
  EXPIRED = 4,    // 已过期（计划模式专属）
  CANCELLED = 5   // 已取消（通用）
}
```

### 4.3 状态流转图

```
通用状态（两种模式）：
  [创建] → WORKING(1) → COMPLETED(2)
              ↓
         CANCELLED(5)

计划模式专属：
  WORKING(1) → 到达截止日期 → EXPIRED(4)
```

---

## 5. 计时器数据模型

### 5.1 TimerViewModel（计时器视图模型）

**文件位置**：`entry/src/main/ets/viewmodel/TimerViewModel.ets`

```typescript
export class TimerViewModel {
  // 关联任务
  task: ToDoListClass | null = null;

  // 计时器状态
  isRunning: boolean = false;
  isPaused: boolean = false;
  currentMode: TimerMode = TimerMode.WORKING;

  // 时间相关
  totalSeconds: number = 25 * 60;  // 总秒数
  remainingSeconds: number = 25 * 60;  // 剩余秒数
  elapsedSeconds: number = 0;  // 已过秒数

  // 进度
  get progress(): number {
    return ((this.totalSeconds - this.remainingSeconds) / this.totalSeconds) * 100;
  }

  get formattedTime(): string {
    const minutes = Math.floor(this.remainingSeconds / 60);
    const seconds = this.remainingSeconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }

  // 操作方法
  start(): void {
    this.isRunning = true;
    this.isPaused = false;
  }

  pause(): void {
    this.isPaused = true;
  }

  resume(): void {
    this.isPaused = false;
  }

  stop(): void {
    this.isRunning = false;
    this.isPaused = false;
  }

  switchMode(mode: TimerMode): void {
    this.currentMode = mode;
    // 根据模式设置时间
    if (mode === TimerMode.WORKING && this.task) {
      this.totalSeconds = this.task.tomato_minutes * 60;
    } else if (this.task) {
      this.totalSeconds = this.task.rest_minutes * 60;
    }
    this.remainingSeconds = this.totalSeconds;
  }
}
```

### 5.2 TimerMode（计时器模式）

```typescript
export enum TimerMode {
  WORKING = 'working',  // 专注模式
  RESTING = 'resting'   // 休息模式
}
```

---

## 6. 接口定义

### 6.1 任务编辑参数

```typescript
interface TaskEditParams {
  isNew: boolean;                    // 是否新建任务
  task: ToDoListClass | null;        // 任务对象（编辑时传入）
}
```

### 6.2 认证相关接口

```typescript
// 微信登录
interface WechatLoginRequest {
  code: string;
}

interface WechatLoginResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  user: User;
}

// 华为登录
interface HuaweiLoginRequest {
  code: string;
  grant_type: string;
}

interface HuaweiLoginResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  user: User;
}

// Token验证
interface ValidateTokenResponse {
  user: User;
}

// Token刷新
interface RefreshTokenRequest {
  refresh_token: string;
}

interface RefreshTokenResponse {
  access_token: string;
  expires_in: number;
}
```

### 6.3 任务相关接口

```typescript
// 获取任务列表
interface GetTasksRequest {
  status?: TaskStatus;
  mode?: TaskMode;
}

interface GetTasksResponse {
  total: number;
  list: ToDoListClass[];
}

// 创建任务
interface CreateTaskRequest {
  name: string;
  mode: TaskMode;
  tomato_minutes?: number;
  rest_minutes?: number;
  target_tomato_count?: number;
  daily_target_tomato_count?: number;
  deadline?: string;
}

interface CreateTaskResponse {
  id: number;
  name: string;
  mode: TaskMode;
}

// 完成番茄钟
interface CompleteTomatoRequest {
  actual_minutes: number;
  is_early_end: boolean;
}

interface CompleteTomatoResponse {
  task_id: number;
  finished_tomato_count: number;
  today_finished_count: number;
  is_completed: boolean;
}
```

---

## 7. 数据验证规则

### 7.1 创建任务验证

```typescript
interface ValidationResult {
  valid: boolean;
  errors: string[];
}

function validateTaskCreation(task: Partial<ToDoListClass>): ValidationResult {
  const errors: string[] = [];

  // === 通用验证（所有模式） ===
  if (!task.name || task.name.trim() === '') {
    errors.push('任务名称不能为空');
  }

  if (task.tomato_minutes === undefined || task.tomato_minutes <= 0) {
    errors.push('番茄时长必须大于0');
  }

  if (task.rest_minutes === undefined || task.rest_minutes < 0) {
    errors.push('休息时长不能为负数');
  }

  // === 模式特定验证 ===
  if (task.mode === TaskMode.TODO) {
    // 待办模式验证
    if (task.target_tomato_count === undefined || task.target_tomato_count <= 0) {
      errors.push('请设置目标任务需要完成几个番茄钟');
    }

  } else if (task.mode === TaskMode.PLAN) {
    // 计划模式验证
    if (task.daily_target_tomato_count === undefined || task.daily_target_tomato_count <= 0) {
      errors.push('请设置每天要完成几个番茄钟');
    }

    if (!task.deadline) {
      errors.push('请选择计划截止日期');
    } else if (task.deadline <= new Date()) {
      errors.push('截止日期必须晚于今天');
    }
  }

  return {
    valid: errors.length === 0,
    errors
  };
}
```

---

## 8. 数据持久化

### 8.1 本地存储结构

使用 Preferences API 存储数据：

```typescript
import { preferences } from '@kit.ArkData';

// 存储键定义
const StorageKeys = {
  AUTH_STATE: 'auth_state',        // 认证状态
  USER_TASKS: 'user_tasks',        // 用户任务列表
  TIMER_STATE: 'timer_state',      // 计时器状态
  APP_SETTINGS: 'app_settings'     // 应用设置
};

// 保存认证状态
async function saveAuthState(state: AuthState): Promise<void> {
  const prefs = await preferences.getPreferences(getContext(), 'AUTH_STORE');
  await prefs.put(StorageKeys.AUTH_STATE, JSON.stringify(state));
  await prefs.flush();
}

// 获取认证状态
async function getAuthState(): Promise<AuthState | null> {
  const prefs = await preferences.getPreferences(getContext(), 'AUTH_STORE');
  const data = await prefs.get(StorageKeys.AUTH_STATE, '');
  return data ? JSON.parse(data as string) : null;
}

// 清除认证状态
async function clearAuthState(): Promise<void> {
  const prefs = await preferences.getPreferences(getContext(), 'AUTH_STORE');
  await prefs.delete(StorageKeys.AUTH_STATE);
  await prefs.flush();
}

// 保存任务列表
async function saveTasks(tasks: ToDoListClass[]): Promise<void> {
  const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
  await prefs.put(StorageKeys.USER_TASKS, JSON.stringify(tasks));
  await prefs.flush();
}

// 加载任务列表
async function loadTasks(): Promise<ToDoListClass[]> {
  const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
  const data = await prefs.get(StorageKeys.USER_TASKS, '[]');
  return JSON.parse(data as string);
}
```

### 8.2 计时器状态持久化

```typescript
interface TimerPersistState {
  taskId: number;
  mode: 'working' | 'resting';
  remainingSeconds: number;
  totalSeconds: number;
  isPaused: boolean;
  timestamp: number;  // 保存时的时间戳
}

async function saveTimerState(state: TimerPersistState): Promise<void> {
  const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
  await prefs.put(StorageKeys.TIMER_STATE, JSON.stringify(state));
  await prefs.flush();
}

async function restoreTimerState(): Promise<TimerPersistState | null> {
  const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
  const data = await prefs.get(StorageKeys.TIMER_STATE, null);
  if (!data) return null;

  const state = JSON.parse(data as string) as TimerPersistState;

  // 检查是否过期（超过1小时则不恢复）
  const elapsed = Date.now() - state.timestamp;
  if (elapsed > 60 * 60 * 1000) {
    return null;
  }

  // 计算剩余时间
  state.remainingSeconds = Math.max(0, state.remainingSeconds - Math.floor(elapsed / 1000));

  return state;
}
```

---

## 9. 数据库表结构

### 9.1 用户表（user）

```sql
CREATE TABLE `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `openid` VARCHAR(64) DEFAULT NULL COMMENT '微信OpenID',
  `unionid` VARCHAR(64) DEFAULT NULL COMMENT '微信UnionID',
  `huawei_uid` VARCHAR(64) DEFAULT NULL COMMENT '华为账号UID',
  `nickname` VARCHAR(100) DEFAULT '番茄用户' COMMENT '昵称',
  `avatar` VARCHAR(512) DEFAULT NULL COMMENT '头像URL',
  `login_type` VARCHAR(20) NOT NULL COMMENT '登录类型：wechat/huawei',
  `last_login_at` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `default_tomato_minutes` INT DEFAULT 25 COMMENT '默认番茄时长（分钟）',
  `default_rest_minutes` INT DEFAULT 5 COMMENT '默认休息时长（分钟）',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1=正常, 0=禁用',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_openid` (`openid`),
  UNIQUE KEY `uk_huawei_uid` (`huawei_uid`),
  KEY `idx_login_type` (`login_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

### 9.2 用户绑定表（user_bind）

```sql
CREATE TABLE `user_bind` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '绑定ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `bind_type` VARCHAR(20) NOT NULL COMMENT '绑定类型：wechat/huawei',
  `bind_id` VARCHAR(64) NOT NULL COMMENT '绑定ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bind` (`bind_type`, `bind_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户绑定表';
```

### 9.3 Token黑名单表（token_blacklist）

```sql
CREATE TABLE `token_blacklist` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `token` VARCHAR(512) NOT NULL COMMENT 'Token',
  `expired_at` DATETIME NOT NULL COMMENT '过期时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_token` (`token`),
  KEY `idx_expired_at` (`expired_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Token黑名单表';
```

### 9.4 任务表（task）

```sql
CREATE TABLE `task` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `user_id` BIGINT NOT NULL COMMENT '所属用户ID',
  `name` VARCHAR(100) NOT NULL COMMENT '任务名称',
  `mode` TINYINT NOT NULL COMMENT '任务模式：1=待办, 2=计划',
  `tomato_minutes` INT NOT NULL DEFAULT 25 COMMENT '番茄时长（分钟）',
  `rest_minutes` INT NOT NULL DEFAULT 5 COMMENT '休息时长（分钟）',
  `target_tomato_count` INT DEFAULT NULL COMMENT '目标番茄数（待办模式）',
  `daily_target_tomato_count` INT DEFAULT NULL COMMENT '每日目标番茄数（计划模式）',
  `deadline` DATE DEFAULT NULL COMMENT '截止日期（计划模式）',
  `finished_tomato_count` INT NOT NULL DEFAULT 0 COMMENT '累计已完成番茄数',
  `today_finished_count` INT NOT NULL DEFAULT 0 COMMENT '今日已完成番茄数（计划模式）',
  `last_reset_date` DATE DEFAULT NULL COMMENT '上次重置日期（计划模式）',
  `total_target_tomato_count` INT DEFAULT NULL COMMENT '累计总目标（计划模式）',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '任务状态：1=进行中, 2=已完成, 4=已过期, 5=已取消',
  `priority` INT NOT NULL DEFAULT 0 COMMENT '优先级',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记：0=未删除, 1=已删除',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_mode` (`mode`),
  KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务表';
```

### 9.5 番茄记录表（tomato_record）

```sql
CREATE TABLE `tomato_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '所属用户ID',
  `task_id` BIGINT NOT NULL COMMENT '任务ID',
  `task_name` VARCHAR(100) NOT NULL COMMENT '任务名称（快照）',
  `task_mode` TINYINT NOT NULL COMMENT '任务模式（快照）',
  `actual_minutes` INT NOT NULL COMMENT '实际番茄时长（分钟）',
  `is_early_end` TINYINT NOT NULL DEFAULT 0 COMMENT '是否提前结束：0=否, 1=是',
  `completed_at` DATETIME NOT NULL COMMENT '完成时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_completed_at` (`completed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='番茄完成记录表';
```

---

## 10. 数据安全设计

### 10.1 用户数据隔离

| 安全措施 | 实现方式 |
|---------|----------|
| Token认证 | JWT包含用户ID，服务端解析验证 |
| 上下文隔离 | ThreadLocal存储当前用户ID |
| 强制过滤 | 所有查询强制带上user_id条件 |
| 必填约束 | 数据库user_id字段NOT NULL |

### 10.2 敏感数据保护

| 数据类型 | 保护措施 |
|---------|----------|
| Token | 本地加密存储，HTTPS传输 |
| 用户信息 | 仅存储必要字段，敏感信息不落地 |
| 授权码 | 一次性使用，使用后立即失效 |

---

**相关文档：**
- [产品概述](../functional/overview.md)
- [用户认证功能](../functional/user-auth.md)
- [任务模式设计](../functional/task-modes.md)
- [技术实现方案](./plan.md)
- [变更记录](../changelog.md)
