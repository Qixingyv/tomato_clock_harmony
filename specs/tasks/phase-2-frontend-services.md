# Phase 2: Frontend Services - 前端服务层

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：规划中
>
> **目标**: 实现前端业务逻辑服务层，使用 TDD 开发。
>
> **依赖**: Phase 1 完成

---

## Phase 2 任务列表

### 存储服务

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P2-001 | 编写 StorageService 单元测试 | TST | pending | P1-xxx | 测试存储服务的增删改查 |
| P2-002 | 实现 StorageService | IMPL | pending | P2-001 | 本地存储服务实现 |

---

### 认证服务

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P2-003 | 编写 AuthService 单元测试 | TST | pending | P1-003, P2-002 | 测试认证服务 |
| P2-004 | 实现 AuthService | IMPL | pending | P2-003 | 认证服务实现 |

---

### 任务服务

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P2-005 | 编写 TaskService 单元测试 | TST | pending | P1-007, P2-002 | 测试任务CRUD |
| P2-006 | 实现 TaskService | IMPL | pending | P2-005 | 任务服务实现 |

---

### 计时器服务

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P2-007 | 编写 TimerService 单元测试 | TST | pending | P1-008 | 测试计时器逻辑 |
| P2-008 | 实现 TimerService | IMPL | pending | P2-007 | 计时器服务实现 |

---

### 统计服务

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P2-009 | 编写 StatisticsService 单元测试 | TST | pending | P1-009, P2-002 | 测试统计计算 |
| P2-010 | 实现 StatisticsService | IMPL | pending | P2-009 | 统计服务实现 |

---

### 网络层 (延期到 v2.0)

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P2-011 | 编写 ApiClient 单元测试 | TST | pending | - | 测试API调用 |
| P2-012 | 实现 ApiClient | IMPL | pending | P2-011 | API客户端实现 |

---

### 验证器

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P2-013 | 编写 TaskValidator 单元测试 | TST | pending | P1-007 | 测试任务验证 |
| P2-014 | 实现 TaskValidator | IMPL | pending | P2-013 | 任务验证器实现 |

---

## 详细任务说明

### P2-001: 编写 StorageService 单元测试

**文件**: `entry/src/main/ets/service/StorageService.test.ets`

**描述**: 测试本地存储服务的各项功能

**测试用例**:
1. `test_save_auth_state` - 测试保存认证状态
2. `test_get_auth_state` - 测试获取认证状态
3. `test_clear_auth_state` - 测试清除认证状态
4. `test_save_tasks` - 测试保存任务列表
5. `test_load_tasks` - 测试加载任务列表
6. `test_clear_tasks` - 测试清除任务列表
7. `test_save_timer_state` - 测试保存计时器状态
8. `test_restore_timer_state` - 测试恢复计时器状态

**验收标准**:
- [ ] 所有测试用例覆盖正常流程
- [ ] 包含异常情况测试
- [ ] 使用 mock 隔离外部依赖

---

### P2-002: 实现 StorageService

**文件**: `entry/src/main/ets/service/StorageService.ets`

**描述**: 本地存储服务，封装 Preferences API

**实现内容**:
```typescript
import { preferences } from '@kit.ArkData';
import { AuthState } from '../viewmodel/AuthState';
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TimerPersistState } from '../viewmodel/TimerViewModel';

export class StorageService {
  private static readonly AUTH_STORE = 'AUTH_STORE';
  private static readonly TASK_STORE = 'TomatoClock';
  private static readonly KEY_AUTH_STATE = 'auth_state';
  private static readonly KEY_USER_TASKS = 'user_tasks';
  private static readonly KEY_TIMER_STATE = 'timer_state';

  // 认证相关
  static async saveAuthState(state: AuthState): Promise<void>
  static async getAuthState(): Promise<AuthState | null>
  static async clearAuthState(): Promise<void>

  // 任务相关
  static async saveTasks(tasks: ToDoListClass[]): Promise<void>
  static async loadTasks(): Promise<ToDoListClass[]>
  static async clearTasks(): Promise<void>

  // 计时器相关
  static async saveTimerState(state: TimerPersistState): Promise<void>
  static async restoreTimerState(): Promise<TimerPersistState | null>
  static async clearTimerState(): Promise<void>
}
```

**验收标准**:
- [ ] 所有 async 方法有 try-catch
- [ ] Preferences 操作后调用 flush()
- [ ] JSON 序列化/反序列化正确处理
- [ ] 通过 P2-001 的所有测试

---

### P2-003: 编写 AuthService 单元测试

**文件**: `entry/src/main/ets/service/AuthService.test.ets`

**描述**: 测试认证服务的各项功能

**测试用例**:
1. `test_wechat_login_success` - 测试微信登录成功
2. `test_wechat_login_failure` - 测试微信登录失败
3. `test_huawei_login_success` - 测试华为登录成功
4. `test_huawei_login_failure` - 测试华为登录失败
5. `test_validate_token_valid` - 测试Token有效
6. `test_validate_token_invalid` - 测试Token无效
7. `test_refresh_token_success` - 测试刷新Token成功
8. `test_refresh_token_failure` - 测试刷新Token失败
9. `test_logout` - 测试登出
10. `test_auto_login` - 测试自动登录

**验收标准**:
- [ ] 覆盖所有认证流程
- [ ] mock API 调用
- [ ] 验证存储服务调用

---

### P2-004: 实现 AuthService

**文件**: `entry/src/main/ets/service/AuthService.ets`

**描述**: 认证服务，处理用户登录、登出、Token管理

**实现内容**:
```typescript
import { AuthState } from '../viewmodel/AuthState';
import { User } from '../viewmodel/User';
import { LoginType } from '../viewmodel/LoginType';
import { StorageService } from './StorageService';
import { Logger } from '../common/Logger';
import { ToastUtil } from '../common/ToastUtil';

export interface LoginResult {
  success: boolean;
  user?: User;
  error?: string;
}

export class AuthService {
  private static authState: AuthState | null = null;
  private static initialized: boolean = false;

  // 初始化认证状态
  static async init(): Promise<void>

  // 检查是否已登录
  static isLoggedIn(): boolean

  // 获取当前用户
  static getCurrentUser(): User | null

  // 微信登录
  static async wechatLogin(code: string): Promise<LoginResult>

  // 华为登录
  static async huaweiLogin(code: string): Promise<LoginResult>

  // 验证Token
  static async validateToken(): Promise<boolean>

  // 刷新Token
  static async refreshToken(): Promise<boolean>

  // 登出
  static async logout(): Promise<void>

  // 获取认证状态
  static getAuthState(): AuthState | null

  // 保存认证状态
  private static saveAuthState(): Promise<void>
}
```

**验收标准**:
- [ ] 所有 async 方法有 try-catch
- [ ] 登录失败显示用户友好提示
- [ ] Token自动刷新机制
- [ ] 通过 P2-003 的所有测试

---

### P2-005: 编写 TaskService 单元测试

**文件**: `entry/src/main/ets/service/TaskService.test.ets`

**描述**: 测试任务服务的各项功能

**测试用例**:
1. `test_create_todo_task` - 测试创建待办任务
2. `test_create_plan_task` - 测试创建计划任务
3. `test_create_task_invalid_input` - 测试创建任务参数校验
4. `test_update_task` - 测试更新任务
5. `test_delete_task` - 测试删除任务
6. `test_complete_tomato` - 测试完成番茄
7. `test_get_tasks` - 测试获取任务列表
8. `test_get_task_by_id` - 测试根据ID获取任务
9. `test_check_today_reset` - 测试检查今日重置
10. `test_restore_cancelled_task` - 测试恢复已取消任务

**验收标准**:
- [ ] 覆盖所有CRUD操作
- [ ] 测试两种模式的特殊逻辑
- [ ] mock StorageService

---

### P2-006: 实现 TaskService

**文件**: `entry/src/main/ets/service/TaskService.ets`

**描述**: 任务服务，处理任务的增删改查

**实现内容**:
```typescript
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TaskMode } from '../viewmodel/TaskMode';
import { TaskStatus } from '../viewmodel/TaskStatus';
import { StorageService } from './StorageService';
import { TaskValidator } from '../common/validator/TaskValidator';
import { Logger } from '../common/Logger';

export class TaskService {
  private static tasks: ToDoListClass[] = [];
  private static loaded: boolean = false;

  // 初始化任务列表
  static async init(): Promise<void>

  // 获取所有任务
  static getTasks(): ToDoListClass[]

  // 根据状态获取任务
  static getTasksByStatus(status: TaskStatus): ToDoListClass[]

  // 根据模式获取任务
  static getTasksByMode(mode: TaskMode): ToDoListClass[]

  // 根据ID获取任务
  static getTaskById(id: number): ToDoListClass | null

  // 创建任务
  static async createTask(task: ToDoListClass): Promise<ToDoListClass | null>

  // 更新任务
  static async updateTask(task: ToDoListClass): Promise<boolean>

  // 删除任务（状态改为已取消）
  static async deleteTask(id: number): Promise<boolean>

  // 完成番茄
  static async completeTomato(taskId: number, actualMinutes: number, isEarlyEnd: boolean): Promise<boolean>

  // 恢复已取消任务
  static async restoreTask(id: number): Promise<boolean>

  // 检查并重置今日计数
  static checkTodayReset(): Promise<void>

  // 保存任务列表
  private static saveTasks(): Promise<void>

  // 生成任务ID
  private static generateId(): number
}
```

**验收标准**:
- [ ] 所有 async 方法有 try-catch
- [ ] 使用 TaskValidator 进行参数校验
- [ ] 操作后自动保存
- [ ] 检查今日重置逻辑正确
- [ ] 通过 P2-005 的所有测试

---

### P2-007: 编写 TimerService 单元测试

**文件**: `entry/src/main/ets/service/TimerService.test.ets`

**描述**: 测试计时器服务的各项功能

**测试用例**:
1. `test_start_working_mode` - 测试开始专注模式
2. `test_start_resting_mode` - 测试开始休息模式
3. `test_pause_timer` - 测试暂停计时
4. `test_resume_timer` - 测试继续计时
5. `test_stop_timer` - 测试停止计时
6. `test_complete_tomato_early` - 测试提前完成番茄
7. `test_complete_tomato_full` - 测试完整完成番茄
8. `test_switch_mode` - 测试切换模式
9. `test_restore_timer_state` - 测试恢复计时器状态
10. `test_timer_tick` - 测试计时器滴答

**验收标准**:
- [ ] 覆盖所有计时器操作
- [ ] 测试状态持久化
- [ ] 测试时间计算

---

### P2-008: 实现 TimerService

**文件**: `entry/src/main/ets/service/TimerService.ets`

**描述**: 计时器服务，管理计时器状态和逻辑

**实现内容**:
```typescript
import { TimerViewModel } from '../viewmodel/TimerViewModel';
import { TimerMode } from '../viewmodel/TimerMode';
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { StorageService } from './StorageService';
import { Logger } from '../common/Logger';

export class TimerService {
  private static timerViewModel: TimerViewModel = new TimerViewModel();
  private static timerId: number = -1;
  private static readonly TICK_INTERVAL: number = 1000; // 1秒

  // 获取计时器视图模型
  static getTimerViewModel(): TimerViewModel

  // 设置当前任务
  static setCurrentTask(task: ToDoListClass): void

  // 开始专注模式
  static startWorkingMode(): void

  // 开始休息模式
  static startRestMode(): void

  // 暂停计时
  static pauseTimer(): void

  // 继续计时
  static resumeTimer(): void

  // 停止计时
  static stopTimer(): void

  // 完成番茄（正常完成）
  static async completeTomato(): Promise<boolean>

  // 提前完成番茄
  static async completeTomatoEarly(actualMinutes: number): Promise<boolean>

  // 切换模式
  static switchMode(mode: TimerMode): void

  // 保存计时器状态
  static async saveTimerState(): Promise<void>

  // 恢复计时器状态
  static async restoreTimerState(): Promise<boolean>

  // 清除计时器状态
  static async clearTimerState(): Promise<void>

  // 计时器滴答
  private static timerTick(): void

  // 启动计时器
  private static startTimer(): void

  // 停止计时器
  private static stopTimerInternal(): void
}
```

**验收标准**:
- [ ] 正确处理计时器状态
- [ ] 支持暂停/继续
- [ ] 支持状态持久化和恢复
- [ ] 通过 P2-007 的所有测试

---

### P2-009: 编写 StatisticsService 单元测试

**文件**: `entry/src/main/ets/service/StatisticsService.test.ets`

**描述**: 测试统计服务的各项功能

**测试用例**:
1. `test_get_today_statistics` - 测试获取今日统计
2. `test_get_week_statistics` - 测试获取本周统计
3. `test_get_month_statistics` - 测试获取本月统计
4. `test_calculate_completion_rate` - 测试计算完成率
5. `test_get_task_ranking` - 测试获取任务排行
6. `test_get_daily_data` - 测试获取每日数据
7. `test_empty_tasks_statistics` - 测试空任务统计

**验收标准**:
- [ ] 覆盖所有统计维度
- [ ] 测试边界情况
- [ ] mock TaskService

---

### P2-010: 实现 StatisticsService

**文件**: `entry/src/main/ets/service/StatisticsService.ets`

**描述**: 统计服务，计算和返回统计数据

**实现内容**:
```typescript
import { StatisticsData, DailyData, TaskRankingItem, StatisticsPeriod } from '../viewmodel/StatisticsModels';
import { TaskService } from './TaskService';
import { DateUtils } from '../common/DateUtils';

export class StatisticsService {
  // 获取今日统计
  static getTodayStatistics(): StatisticsData

  // 获取本周统计
  static getWeekStatistics(): StatisticsData

  // 获取本月统计
  static getMonthStatistics(): StatisticsData

  // 获取指定时间段统计
  static getStatistics(period: StatisticsPeriod, startDate: Date, endDate: Date): StatisticsData

  // 计算完成率
  private static calculateCompletionRate(completedTasks: number, totalTasks: number): number

  // 获取任务排行
  private static getTaskRanking(startDate: Date, endDate: Date): TaskRankingItem[]

  // 获取每日数据
  private static getDailyData(startDate: Date, endDate: Date): DailyData[]

  // 筛选指定时间段内的完成记录
  private static filterRecordsByDateRange(tasks: any[], startDate: Date, endDate: Date): any[]
}
```

**验收标准**:
- [ ] 正确计算今日/本周/本月统计
- [ ] 正确计算完成率
- [ ] 正确生成任务排行
- [ ] 正确生成每日数据
- [ ] 通过 P2-009 的所有测试

---

### P2-011: 编写 ApiClient 单元测试

**文件**: `entry/src/main/ets/network/ApiClient.test.ets`

**描述**: 测试API客户端的调用功能

**测试用例**:
1. `test_get_request_success` - 测试GET请求成功
2. `test_get_request_failure` - 测试GET请求失败
3. `test_post_request_success` - 测试POST请求成功
4. `test_post_request_failure` - 测试POST请求失败
5. `test_request_with_token` - 测试带Token的请求
6. `test_token_refresh_on_401` - 测试401时自动刷新Token
7. `test_network_error_handling` - 测试网络错误处理

**验收标准**:
- [ ] 覆盖所有HTTP方法
- [ ] 测试认证机制
- [ ] mock HTTP请求

---

### P2-012: 实现 ApiClient

**文件**: `entry/src/main/ets/network/ApiClient.ets`

**描述**: API客户端，封装HTTP请求（v2.0功能，延期）

**实现内容**:
```typescript
import http from '@ohos.net.http';
import { AuthService } from '../service/AuthService';
import { Logger } from '../common/Logger';

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: number;
}

export class ApiClient {
  private static readonly BASE_URL: string = 'https://api.tomatoclock.com/v1';
  private static readonly TIMEOUT: number = 10000;

  // GET请求
  static async get<T>(url: string, params?: Record<string, string>): Promise<ApiResponse<T>>

  // POST请求
  static async post<T>(url: string, data?: object): Promise<ApiResponse<T>>

  // PUT请求
  static async put<T>(url: string, data?: object): Promise<ApiResponse<T>>

  // DELETE请求
  static async delete<T>(url: string): Promise<ApiResponse<T>>

  // 创建HTTP请求
  private static createRequest(): http.HttpRequest

  // 添加认证头
  private static async addAuthHeaders(headers: Record<string, string>): Promise<void>

  // 处理响应
  private static handleResponse<T>(response: http.HttpResponse): Promise<ApiResponse<T>>

  // 处理错误
  private static handleError(error: Error): never
}
```

**验收标准**:
- [ ] 支持GET/POST/PUT/DELETE
- [ ] 自动添加Token认证头
- [ ] 401自动刷新Token
- [ ] 统一错误处理
- [ ] 通过 P2-011 的所有测试

---

### P2-013: 编写 TaskValidator 单元测试

**文件**: `entry/src/main/ets/common/validator/TaskValidator.test.ets`

**描述**: 测试任务验证器的各项校验规则

**测试用例**:
1. `test_validate_todo_task_valid` - 测试有效待办任务
2. `test_validate_todo_task_empty_name` - 测试任务名为空
3. `test_validate_todo_task_invalid_minutes` - 测试无效番茄时长
4. `test_validate_todo_task_invalid_target` - 测试无效目标数
5. `test_validate_plan_task_valid` - 测试有效计划任务
6. `test_validate_plan_task_missing_daily_target` - 测试缺少每日目标
7. `test_validate_plan_task_invalid_deadline` - 测试无效截止日期
8. `test_validate_plan_task_past_deadline` - 测试过去日期

**验收标准**:
- [ ] 覆盖所有校验规则
- [ ] 测试两种模式的不同校验

---

### P2-014: 实现 TaskValidator

**文件**: `entry/src/main/ets/common/validator/TaskValidator.ets`

**描述**: 任务验证器，校验任务数据

**实现内容**:
```typescript
import { ToDoListClass } from '../../viewmodel/ToDoListClass';
import { TaskMode } from '../../viewmodel/TaskMode';

export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

export class TaskValidator {
  // 验证任务创建
  static validateTaskCreation(task: ToDoListClass): ValidationResult

  // 验证任务更新
  static validateTaskUpdate(task: ToDoListClass): ValidationResult

  // 通用验证
  private static validateCommon(task: ToDoListClass): ValidationResult

  // 待办模式验证
  private static validateTodoMode(task: ToDoListClass): ValidationResult

  // 计划模式验证
  private static validatePlanMode(task: ToDoListClass): ValidationResult
}
```

**验收标准**:
- [ ] 通用验证适用于所有模式
- [ ] 待办模式校验 target_tomato_count
- [ ] 计划模式校验 daily_target_tomato_count 和 deadline
- [ ] 返回清晰的错误信息
- [ ] 通过 P2-013 的所有测试

---

## 阶段完成标准

- [ ] 所有服务实现完成
- [ ] 所有测试通过
- [ ] 测试覆盖率 > 80%
- [ ] 代码通过静态检查
- [ ] 服务层无UI相关代码

---

**相关文档：**
- [技术实现方案 - 3.1 前端项目结构](../technical/plan.md#31-前端项目结构鸿蒙客户端)
- [开发规范](../../constitution.md)
