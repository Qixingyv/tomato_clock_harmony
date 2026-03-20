# Phase 1: Foundation - 数据结构定义

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：规划中
>
> **目标**: 定义核心数据模型和枚举类型，建立项目基础。

---

## Phase 1 任务列表

### 前端数据模型

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P1-001 | 创建 LoginType 枚举 | IMPL | pending | - | 定义微信/华为登录类型枚举 |
| P1-002 | 创建 User 数据模型 | IMPL | pending | P1-001 | 用户信息模型 |
| P1-003 | 创建 AuthState 数据模型 | IMPL | pending | P1-002 | 认证状态模型 |
| P1-004 | 创建 TaskMode 枚举 | IMPL | pending | - | 任务模式枚举（待办/计划） |
| P1-005 | 创建 TaskStatus 枚举 | IMPL | pending | - | 任务状态枚举 |
| P1-006 | 创建 TimerMode 枚举 | IMPL | pending | - | 计时器模式枚举 |
| P1-007 | 创建 ToDoListClass 数据模型 | IMPL | pending | P1-004, P1-005 | 任务核心数据模型 |
| P1-008 | 创建 TimerViewModel 数据模型 | IMPL | pending | P1-006, P1-007 | 计时器视图模型 |
| P1-009 | 创建统计相关数据模型 | IMPL | pending | - | 统计数据接口定义 |

---

### 后端数据模型

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P1-010 | 创建 User 实体类 | IMPL | pending | - | 后端用户实体 |
| P1-011 | 创建 Task 实体类 | IMPL | pending | - | 后端任务实体 |
| P1-012 | 创建 TomatoRecord 实体类 | IMPL | pending | - | 番茄记录实体 |
| P1-013 | 创建 Result 统一响应类 | IMPL | pending | - | 统一API响应结构 |
| P1-014 | 创建 ResultCode 响应码枚举 | IMPL | pending | - | 响应码枚举定义 |
| P1-015 | 创建 TaskDTO | IMPL | pending | P1-011 | 任务数据传输对象 |
| P1-016 | 创建 TaskCreateRequest | IMPL | pending | - | 创建任务请求DTO |
| P1-017 | 创建 TaskUpdateRequest | IMPL | pending | - | 更新任务请求DTO |
| P1-018 | 创建 StatisticsDTO | IMPL | pending | - | 统计数据DTO |

---

### 工具类和常量

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P1-019 | 创建 TaskConstant 常量类 [P] | IMPL | pending | - | 任务相关常量 |
| P1-020 | 创建 DateUtils 工具类 [P] | IMPL | pending | - | 日期工具类 |
| P1-021 | 创建 Logger 工具类 [P] | IMPL | pending | - | 日志工具类 |
| P1-022 | 创建 ToastUtil 工具类 [P] | IMPL | pending | - | 提示工具类 |
| P1-023 | 创建 GlobalNavStack [P] | IMPL | pending | - | 全局导航栈 |
| P1-024 | 创建 JwtUtil 工具类 [P] | IMPL | pending | - | JWT工具类（后端） |

---

## 详细任务说明

### P1-001: 创建 LoginType 枚举

**文件**: `entry/src/main/ets/viewmodel/LoginType.ets`

**描述**: 定义用户登录类型枚举

**实现内容**:
```typescript
export enum LoginType {
  WECHAT = 'wechat',    // 微信登录
  HUAWEI = 'huawei'     // 华为账号登录
}
```

**验收标准**:
- [ ] 枚举包含 WECHAT 和 HUAWEI 两个值
- [ ] 导出为 TypeScript enum
- [ ] 值类型为 string

---

### P1-002: 创建 User 数据模型

**文件**: `entry/src/main/ets/viewmodel/User.ets`

**描述**: 定义用户信息数据模型

**实现内容**:
```typescript
import { LoginType } from './LoginType';

export class User {
  id: number = 0;
  nickname: string = '';
  avatar: string = '';
  loginType: LoginType = LoginType.WECHAT;
  createdAt: Date = new Date();

  get displayName(): string {
    return this.nickname || '番茄用户';
  }

  get avatarUrl(): string {
    return this.avatar || '';
  }
}
```

**验收标准**:
- [ ] 包含 id, nickname, avatar, loginType, createdAt 字段
- [ ] displayName 计算属性默认返回"番茄用户"
- [ ] avatarUrl 返回空字符串作为默认值
- [ ] 严格类型定义，无 any 类型

---

### P1-003: 创建 AuthState 数据模型

**文件**: `entry/src/main/ets/viewmodel/AuthState.ets`

**描述**: 定义认证状态模型，用于管理用户登录状态

**实现内容**:
```typescript
import { User } from './User';

export class AuthState {
  isLoggedIn: boolean = false;
  user: User | null = null;
  accessToken: string = '';
  refreshToken: string = '';
  tokenExpiresAt: Date = new Date();

  isTokenExpired(): boolean {
    return new Date() >= this.tokenExpiresAt;
  }

  shouldRefreshToken(): boolean {
    const now = new Date();
    const expiresAt = this.tokenExpiresAt;
    const refreshTime = new Date(expiresAt.getTime() - 24 * 60 * 60 * 1000);
    return now >= refreshTime;
  }
}
```

**验收标准**:
- [ ] 包含登录状态、用户信息、token相关字段
- [ ] isTokenExpired() 方法正确判断token是否过期
- [ ] shouldRefreshToken() 提前1天返回需要刷新
- [ ] 所有字段都有默认值

---

### P1-004: 创建 TaskMode 枚举

**文件**: `entry/src/main/ets/viewmodel/TaskMode.ets`

**描述**: 定义任务模式枚举

**实现内容**:
```typescript
export enum TaskMode {
  TODO = 1,    // 待办模式：一次性任务
  PLAN = 2     // 计划模式：每日重复任务
}
```

**验收标准**:
- [ ] TODO 值为 1
- [ ] PLAN 值为 2
- [ ] 注释清晰说明两种模式的区别

---

### P1-005: 创建 TaskStatus 枚举

**文件**: `entry/src/main/ets/viewmodel/TaskStatus.ets`

**描述**: 定义任务状态枚举

**实现内容**:
```typescript
export enum TaskStatus {
  WORKING = 1,    // 进行中（通用）
  COMPLETED = 2,  // 已完成（通用）
  EXPIRED = 4,    // 已过期（计划模式专属）
  CANCELLED = 5   // 已取消（通用）
}
```

**验收标准**:
- [ ] 包含4种状态
- [ ] 值符合设计文档要求
- [ ] 注释说明哪些是通用状态，哪些是专属状态

---

### P1-006: 创建 TimerMode 枚举

**文件**: `entry/src/main/ets/viewmodel/TimerMode.ets`

**描述**: 定义计时器模式枚举

**实现内容**:
```typescript
export enum TimerMode {
  WORKING = 'working',  // 专注模式
  RESTING = 'resting'   // 休息模式
}
```

**验收标准**:
- [ ] WORKING 和 RESTING 两个值
- [ ] 值类型为 string

---

### P1-007: 创建 ToDoListClass 数据模型

**文件**: `entry/src/main/ets/viewmodel/ToDoListClass.ets`

**描述**: 任务核心数据模型，支持待办和计划两种模式

**实现内容**: 见 `data-model.md` 第3.1节

**关键方法**:
- `total_target_tomato_count` getter: 计算计划模式总目标
- `progress` getter: 计算任务完成进度
- `isTodayResetNeeded()`: 检查是否需要重置今日计数
- `resetTodayCount()`: 重置今日计数
- `isCompleted()`: 判断任务是否完成

**验收标准**:
- [ ] 支持待办和计划两种模式
- [ ] 待办模式使用 target_tomato_count
- [ ] 计划模式使用 daily_target_tomato_count 和 deadline
- [ ] 计算属性正确计算进度
- [ ] 方法逻辑符合需求文档

---

### P1-008: 创建 TimerViewModel 数据模型

**文件**: `entry/src/main/ets/viewmodel/TimerViewModel.ets`

**描述**: 计时器视图模型，管理计时器状态

**实现内容**: 见 `plan.md` 第4.1.3节

**验收标准**:
- [ ] @Observed 装饰器使类可观察
- [ ] @Track 装饰器标记需要跟踪的字段
- [ ] progress 正确计算进度百分比
- [ ] formattedTime 返回 MM:SS 格式
- [ ] toPersist/fromPersist 支持状态持久化

---

### P1-009: 创建统计相关数据模型

**文件**: `entry/src/main/ets/viewmodel/StatisticsModels.ets`

**描述**: 统计相关接口定义

**实现内容**:
```typescript
import { TaskMode } from './TaskMode';

export type StatisticsPeriod = 'today' | 'week' | 'month';

export interface StatisticsData {
  period: StatisticsPeriod;
  startDate: Date;
  endDate: Date;
  completedTomatoes: number;
  focusMinutes: number;
  completedTasks: number;
  totalTasks: number;
  completionRate: number;
  dailyData: DailyData[];
  taskRanking: TaskRankingItem[];
}

export interface DailyData {
  date: Date;
  completedTomatoes: number;
  focusMinutes: number;
}

export interface TaskRankingItem {
  taskId: number;
  taskName: string;
  taskMode: TaskMode;
  completedTomatoes: number;
  totalCompletedTomatoes: number;
}
```

**验收标准**:
- [ ] 定义 StatisticsPeriod 类型
- [ ] 定义 StatisticsData 接口
- [ ] 定义 DailyData 接口
- [ ] 定义 TaskRankingItem 接口

---

### P1-010: 创建 User 实体类

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/user/entity/User.java`

**描述**: 后端用户实体类

**实现内容**: 见 `plan.md` 第4.2.1节

**验收标准**:
- [ ] 使用 Lombok @Data 注解
- [ ] @TableName("user") 指定表名
- [ ] @TableId(type = IdType.AUTO) 主键自增
- [ ] 包含所有字段定义

---

### P1-011: 创建 Task 实体类

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/task/entity/Task.java`

**描述**: 后端任务实体类

**实现内容**: 见 `plan.md` 第4.2.2节

**验收标准**:
- [ ] 使用 MyBatis-Plus 注解
- [ ] @TableLogic 逻辑删除字段
- [ ] @TableField(fill = FieldFill.INSERT) 自动填充
- [ ] 所有字段都有 getter/setter

---

### P1-012: 创建 TomatoRecord 实体类

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/record/entity/TomatoRecord.java`

**描述**: 番茄完成记录实体

**实现内容**: 见 `plan.md` 第4.2.3节

**验收标准**:
- [ ] 包含任务快照字段（taskName, taskMode）
- [ ] 记录实际完成时长
- [ ] 记录是否提前结束

---

### P1-013: 创建 Result 统一响应类

**文件**: `tomato-clock-backend/src/main/java/com/tomato/common/response/Result.java`

**描述**: 统一API响应结构

**实现内容**: 见 `plan.md` 第4.3.3节

**验收标准**:
- [ ] 泛型支持
- [ ] success() 静态方法
- [ ] error() 静态方法
- [ ] 包含 timestamp 字段

---

### P1-014: 创建 ResultCode 响应码枚举

**文件**: `tomato-clock-backend/src/main/java/com/tomato/common/response/ResultCode.java`

**描述**: 响应码枚举定义

**实现内容**: 见 `plan.md` 第4.3.3节

**验收标准**:
- [ ] 包含通用HTTP状态码
- [ ] 包含业务错误码 (1000-1999)
- [ ] 每个错误码有清晰的描述

---

### P1-015: 创建 TaskDTO

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/task/dto/TaskDTO.java`

**描述**: 任务数据传输对象

**实现内容**: 见 `plan.md` 第4.3.1节

**验收标准**:
- [ ] 包含前端需要的所有字段
- [ ] progress 字段为计算属性

---

### P1-016: 创建 TaskCreateRequest

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/task/dto/TaskCreateRequest.java`

**描述**: 创建任务请求DTO

**实现内容**: 见 `plan.md` 第4.3.1节

**验收标准**:
- [ ] 包含校验注解 (@NotBlank, @NotNull, @Positive)
- [ ] 定义校验分组接口 (TodoMode, PlanMode)

---

### P1-017: 创建 TaskUpdateRequest

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/task/dto/TaskUpdateRequest.java`

**描述**: 更新任务请求DTO

**实现内容**: 见 `plan.md` 第4.3.1节

**验收标准**:
- [ ] id 字段必填
- [ ] 其他字段可选

---

### P1-018: 创建 StatisticsDTO

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/statistics/dto/StatisticsDTO.java`

**描述**: 统计数据DTO

**实现内容**: 见 `plan.md` 第4.3.2节

**验收标准**:
- [ ] 包含 period, startDate, endDate
- [ ] 包含核心统计指标
- [ ] 包含 dailyData 和 taskRanking 列表

---

### P1-019: 创建 TaskConstant 常量类 [P]

**文件**: `entry/src/main/ets/common/constants/TaskConstant.ets` (前端)
**文件**: `tomato-clock-backend/src/main/java/com/tomato/common/constant/TaskConstant.java` (后端)

**描述**: 任务相关常量定义

**实现内容**:
```typescript
export class TaskConstant {
  static readonly DEFAULT_TOMATO_MINUTES: number = 25;
  static readonly DEFAULT_REST_MINUTES: number = 5;
  static readonly DEFAULT_DAILY_TARGET: number = 5;
}
```

**验收标准**:
- [ ] 定义默认番茄时长
- [ ] 定义默认休息时长
- [ ] 定义默认每日目标

---

### P1-020: 创建 DateUtils 工具类 [P]

**文件**: `entry/src/main/ets/common/DateUtils.ets`

**描述**: 日期工具类

**实现内容**:
```typescript
export class DateUtils {
  static getToday(): Date {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return today;
  }

  static isSameDay(date1: Date, date2: Date): boolean {
    return date1.toDateString() === date2.toDateString();
  }

  static getWeekStart(): Date {
    const now = new Date();
    const day = now.getDay();
    const diff = now.getDate() - day + (day === 0 ? -6 : 1);
    const monday = new Date(now.setDate(diff));
    monday.setHours(0, 0, 0, 0);
    return monday;
  }

  static getMonthStart(): Date {
    const now = new Date();
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
    firstDay.setHours(0, 0, 0, 0);
    return firstDay;
  }

  static addDays(date: Date, days: number): Date {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  }

  static diffDays(date1: Date, date2: Date): number {
    const oneDay = 24 * 60 * 60 * 1000;
    return Math.floor((date2.getTime() - date1.getTime()) / oneDay);
  }
}
```

**验收标准**:
- [ ] getToday() 返回今天0点
- [ ] isSameDay() 判断是否同一天
- [ ] getWeekStart() 返回本周一0点
- [ ] getMonthStart() 返回本月1号0点
- [ ] addDays() 日期加减
- [ ] diffDays() 计算天数差

---

### P1-021: 创建 Logger 工具类 [P]

**文件**: `entry/src/main/ets/common/Logger.ets`

**描述**: 日志工具类

**实现内容**:
```typescript
export class Logger {
  private static readonly TAG: string = 'TomatoClock';

  static debug(message: string, ...args: unknown[]): void {
    console.debug(`[${Logger.TAG}] [DEBUG] ${message}`, ...args);
  }

  static info(message: string, ...args: unknown[]): void {
    console.info(`[${Logger.TAG}] [INFO] ${message}`, ...args);
  }

  static warn(message: string, ...args: unknown[]): void {
    console.warn(`[${Logger.TAG}] [WARN] ${message}`, ...args);
  }

  static error(message: string, error?: Error): void {
    console.error(`[${Logger.TAG}] [ERROR] ${message}`, error);
  }
}
```

**验收标准**:
- [ ] 支持 debug, info, warn, error 级别
- [ ] 统一日志格式
- [ ] error 方法支持 Error 对象

---

### P1-022: 创建 ToastUtil 工具类 [P]

**文件**: `entry/src/main/ets/common/ToastUtil.ets`

**描述**: 提示工具类

**实现内容**:
```typescript
import promptAction from '@ohos.promptAction';

export class ToastUtil {
  static showToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: '50%'
    });
  }

  static showError(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 3000,
      bottom: '50%'
    });
  }

  static showSuccess(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: '50%'
    });
  }
}
```

**验收标准**:
- [ ] showToast() 普通提示
- [ ] showError() 错误提示，时长3秒
- [ ] showSuccess() 成功提示

---

### P1-023: 创建 GlobalNavStack [P]

**文件**: `entry/src/main/ets/common/GlobalNavStack.ets`

**描述**: 全局导航栈单例

**实现内容**:
```typescript
import { NavPathStack } from '@kit.ArkUI';

export const GlobalNavStack: NavPathStack = new NavPathStack();
```

**验收标准**:
- [ ] 导出 NavPathStack 单例
- [ ] 全局唯一

---

### P1-024: 创建 JwtUtil 工具类 [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/common/util/JwtUtil.java`

**描述**: JWT工具类（后端）

**实现内容**:
```java
@Component
public class JwtUtil {
    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    public String generateToken(Long userId) {
        // JWT生成逻辑
    }

    public Claims parseToken(String token) {
        // JWT解析逻辑
    }

    public Long getUserIdFromToken(String token) {
        // 从token获取用户ID
    }

    public boolean isTokenExpired(String token) {
        // 判断token是否过期
    }
}
```

**验收标准**:
- [ ] generateToken() 生成JWT
- [ ] parseToken() 解析JWT
- [ ] getUserIdFromToken() 获取用户ID
- [ ] isTokenExpired() 判断过期

---

## 阶段完成标准

- [ ] 所有数据模型创建完成
- [ ] 所有枚举定义完成
- [ ] 所有工具类创建完成
- [ ] 代码通过静态检查
- [ ] 代码符合 constitution.md 规范

---

**相关文档：**
- [数据模型定义](../technical/data-model.md)
- [技术实现方案](../technical/plan.md)
- [开发规范](../../constitution.md)
