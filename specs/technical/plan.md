# 番茄钟应用技术实现方案

> 版本：v1.1
> 创建日期：2026-03-19
> 更新日期：2026-03-19
> 状态：技术方案确认中

---

## 目录

1. [技术上下文](#1-技术上下文)
2. ["合宪性"审查](#2-合宪性审查)
3. [项目结构](#3-项目结构)
4. [核心数据结构](#4-核心数据结构)
5. [接口设计](#5-接口设计)
6. [技术实现要点](#6-技术实现要点)
7. [部署方案](#7-部署方案)

---

## 1. 技术上下文

### 1.1 技术选型

| 层级 | 技术选型 | 版本要求 | 说明 |
|------|----------|----------|------|
| **前端语言** | ArkTS | - | TypeScript超集，严格类型检查 |
| **前端框架** | ArkUI | API 21+ | 华为鸿蒙原生UI框架 |
| **后端语言** | Java | 17+ | LTS版本，稳定可靠 |
| **后端框架** | Spring Boot | 3.1+ | 企业级微服务框架 |
| **数据库** | MySQL | 8.0+ | 关系型数据库 |
| **ORM框架** | MyBatis | 3.5+ | 持久层框架，SQL映射 |
| **通信协议** | HTTP/RESTful | - | 前后端数据交互 |
| **数据格式** | JSON | - | 轻量级数据交换格式 |

### 1.2 系统架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      鸿蒙客户端 (ArkTS + ArkUI)               │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  任务模块   │  │  计时模块   │  │     统计模块        │  │
│  ├─────────────┤  ├─────────────┤  ├─────────────────────┤  │
│  │ TaskList    │  │ TimerEngine │  │ StatisticsService   │  │
│  │ TaskEdit    │  │ Notifier    │  │ HistoryView         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                     本地持久化层 (Preferences API)           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    后端服务 (Spring Boot + Java)             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  用户模块   │  │  任务模块   │  │     统计模块        │  │
│  ├─────────────┤  ├─────────────┤  ├─────────────────────┤  │
│  │ UserController│ TaskController│ StatisticsController │  │
│  │ UserService  │  TaskService  │ StatisticsService     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                     数据访问层 (MyBatis)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      MySQL 8.0 数据库                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   用户表    │  │   任务表    │  │    番茄记录表       │  │
│  │    user     │  │    task     │  │  tomato_record      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 技术架构特点

1. **前后端分离**：鸿蒙客户端与Spring Boot后端独立开发部署
2. **本地优先**：MVP阶段客户端本地存储，后端负责数据同步
3. **离线可用**：核心功能不依赖网络，支持离线使用
4. **渐进增强**：MVP聚焦核心功能，后续版本逐步添加云同步等高级特性

---

## 2. "合宪性"审查

### 2.1 对照constitution.md逐条审查

| 宪法条款 | 要求 | 技术方案 | 审查结果 |
|----------|------|----------|----------|
| **第三条** | 必须使用ArkTS，严格类型检查，禁用any | 项目使用ArkTS，所有类型定义明确，枚举替代魔术数字 | ✅ 合规 |
| **第四条** | Material Design，响应式布局，fp/vp单位 | ArkUI响应式组件，统一使用fp/vp单位 | ✅ 合规 |
| **第五条** | PersistentStorage持久化，日志记录 | 使用Preferences API，关键操作记录日志 | ✅ 合规 |
| **第六条** | 系统定时器API，后台运行，状态恢复 | TextTimer组件，后台计时机制，状态持久化 | ✅ 合规 |
| **第七条** | NotificationManager，区分优先级 | 系统通知API，根据场景设置优先级 | ✅ 合规 |
| **第八条** | 最小权限原则 | 仅申请通知、震动、声音、后台运行权限 | ✅ 合规 |
| **第九条** | ESLint检查，类型检查，测试覆盖率>80% | hvigor静态检查，ArkTS类型检查，单元测试覆盖 | ✅ 合规 |
| **第十条** | 异步操作try-catch，用户友好提示 | 所有async/await包裹try-catch，统一错误处理 | ✅ 合规 |

### 2.2 错误处理策略

**前端错误处理：**
```typescript
// 统一错误处理类
export class ErrorHandler {
  static async handleAsync<T>(
    operation: () => Promise<T>,
    errorMsg: string,
    showToUser: boolean = true
  ): Promise<T | null> {
    try {
      return await operation();
    } catch (error) {
      Logger.error(errorMsg, error);
      if (showToUser) {
        ToastUtil.showError(errorMsg);
      }
      return null;
    }
  }
}

// 使用示例
const result = await ErrorHandler.handleAsync(
  () => TaskService.createTask(task),
  '创建任务失败'
);
```

**后端错误处理：**
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<Result<?>> handleBusinessException(BusinessException e) {
        log.warn("业务异常：{}", e.getMessage());
        return ResponseEntity.badRequest()
            .body(Result.error(e.getCode(), e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Result<?>> handleException(Exception e) {
        log.error("系统异常", e);
        return ResponseEntity.status(500)
            .body(Result.error(500, "系统异常，请稍后重试"));
    }
}
```

### 2.3 测试策略

**前端测试：**
- 单元测试：覆盖所有Service层和ViewModel层
- 集成测试：覆盖关键业务流程
- 目标覆盖率：>80%

**后端测试：**
- 单元测试：JUnit 5 + Mockito
- 集成测试：@SpringBootTest
- API测试：RestAssured

---

## 3. 项目结构

### 3.1 前端项目结构（鸿蒙客户端）

```
tomato_clock_harmony/
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/              # 应用入口
│   │   │   │   └── EntryAbility.ets
│   │   │   │
│   │   │   ├── pages/                     # 页面组件（路由入口）
│   │   │   │   ├── Index.ets              # 登录/欢迎页
│   │   │   │   ├── MainPage.ets           # 主页（Tab容器）
│   │   │   │   ├── CountDownTimer.ets     # 计时器页面
│   │   │   │   └── TaskEdit.ets           # 任务编辑页面
│   │   │   │
│   │   │   ├── view/                      # 可复用视图组件
│   │   │   │   ├── ToDoList.ets           # 任务列表视图
│   │   │   │   ├── Statistics.ets         # 统计页面视图
│   │   │   │   ├── Profile.ets            # 个人中心视图
│   │   │   │   └── components/            # UI组件
│   │   │   │       ├── TaskCard.ets       # 任务卡片
│   │   │   │       ├── TimerProgress.ets  # 计时器进度环
│   │   │   │       └── StatCard.ets       # 统计卡片
│   │   │   │
│   │   │   ├── viewmodel/                 # 视图模型（数据+逻辑）
│   │   │   │   ├── ToDoListClass.ets      # 任务数据模型
│   │   │   │   ├── TaskType.ets           # 任务类型枚举
│   │   │   │   ├── TaskStatus.ets         # 任务状态枚举
│   │   │   │   └── TimerViewModel.ets     # 计时器视图模型
│   │   │   │
│   │   │   ├── service/                   # 业务服务层
│   │   │   │   ├── TaskService.ets        # 任务业务逻辑
│   │   │   │   ├── TimerService.ets       # 计时器服务
│   │   │   │   ├── StatisticsService.ets  # 统计服务
│   │   │   │   └── StorageService.ets     # 本地存储服务
│   │   │   │
│   │   │   ├── common/                    # 通用工具
│   │   │   │   ├── GlobalNavStack.ets     # 全局导航栈
│   │   │   │   ├── DateUtils.ets          # 日期工具
│   │   │   │   ├── Logger.ets             # 日志工具
│   │   │   │   ├── ToastUtil.ets          # 提示工具
│   │   │   │   └── validator/             # 验证器
│   │   │   │       └── TaskValidator.ets  # 任务验证
│   │   │   │
│   │   │   └── network/                   # 网络层（v2.0）
│   │   │       ├── ApiClient.ets          # API客户端
│   │   │       ├── ApiConfig.ets          # API配置
│   │   │       └── interceptor/           # 拦截器
│   │   │           ├── AuthInterceptor.ets
│   │   │           └── LogInterceptor.ets
│   │   │
│   │   └── resources/                     # 资源文件
│   │       ├── base/                      # 基础资源
│   │       │   ├── element/               # 字符串、颜色等
│   │       │   ├── media/                 # 图片、图标
│   │       │   └── profile/               # 配置文件
│   │       │       └── route_map.json     # 路由映射
│   │       └── rawfile/                   # 原始文件
│   │
│   └── build-profile.json5                # 模块构建配置
│
├── oh-package.json5                       # 依赖管理
├── build-profile.json5                    # 项目构建配置
└── code-linter.json5                      # 代码检查配置
```

### 3.2 页面组件关系图

```
┌─────────────────────────────────────────────────────────────────┐
│                         Navigation Root                          │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  Index.ets    │   │ MainPage.ets  │   │ TaskEdit.ets  │
│  (登录/欢迎)  │   │  (主Tab容器)  │   │  (任务编辑)   │
└───────────────┘   └───────────────┘   └───────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ ToDoList.ets  │   │ Statistics.ets│   │ Profile.ets   │
│  (任务列表)   │   │   (统计)      │   │  (个人中心)   │
└───────────────┘   └───────────────┘   └───────────────┘
        │
        ▼
┌───────────────┐
│CountDownTimer │
│    .ets       │
│  (计时器)     │
└───────────────┘
```

### 3.3 后端项目结构（Spring Boot）

```
tomato-clock-backend/
├── src/main/java/com/tomato/
│   │
│   ├── TomatoClockApplication.java           # 应用启动类
│   │
│   ├── common/                               # 公共模块
│   │   ├── aspect/                           # AOP切面
│   │   │   ├── LogAspect.java                # 日志切面
│   │   │   └── ValidateAspect.java           # 参数校验切面
│   │   ├── constant/                         # 常量定义
│   │   │   ├── TaskConstant.java             # 任务相关常量
│   │   │   └── RedisKey.java                 # Redis键常量（v2.0云同步预留）
│   │   ├── exception/                        # 异常定义
│   │   │   ├── BusinessException.java         # 业务异常
│   │   │   └── GlobalExceptionHandler.java   # 全局异常处理
│   │   ├── response/                         # 响应封装
│   │   │   ├── Result.java                   # 统一响应结构
│   │   │   └── ResultCode.java               # 响应码枚举
│   │   └── util/                             # 工具类
│   │       ├── DateUtil.java                 # 日期工具
│   │       ├── BeanUtil.java                 # Bean转换工具
│   │       └── JwtUtil.java                  # JWT工具
│   │
│   ├── config/                               # 配置类
│   │   ├── MyBatisConfig.java                # MyBatis配置
│   │   ├── WebConfig.java                    # Web配置（CORS等）
│   │   └── AsyncConfig.java                  # 异步任务配置
│   │
│   ├── modules/                              # 业务模块（按领域划分）
│   │   │
│   │   ├── user/                             # 用户模块
│   │   │   ├── controller/
│   │   │   │   └── UserController.java
│   │   │   ├── service/
│   │   │   │   ├── UserService.java
│   │   │   │   └── impl/UserServiceImpl.java
│   │   │   ├── entity/
│   │   │   │   └── User.java
│   │   │   ├── dto/
│   │   │   │   ├── UserDTO.java
│   │   │   │   ├── UserLoginRequest.java
│   │   │   │   └── UserRegisterRequest.java
│   │   │   └── mapper/
│   │   │       └── UserMapper.java
│   │   │
│   │   ├── task/                             # 任务模块
│   │   │   ├── controller/
│   │   │   │   └── TaskController.java
│   │   │   ├── service/
│   │   │   │   ├── TaskService.java
│   │   │   │   └── impl/TaskServiceImpl.java
│   │   │   ├── entity/
│   │   │   │   └── Task.java
│   │   │   ├── dto/
│   │   │   │   ├── TaskDTO.java
│   │   │   │   ├── TaskCreateRequest.java
│   │   │   │   ├── TaskUpdateRequest.java
│   │   │   │   └── TaskQueryRequest.java
│   │   │   ├── mapper/
│   │   │   │   └── TaskMapper.java
│   │   │   └── enums/
│   │   │       ├── TaskMode.java             # 任务模式枚举
│   │   │       └── TaskStatus.java           # 任务状态枚举
│   │   │
│   │   ├── record/                           # 番茄记录模块
│   │   │   ├── controller/
│   │   │   │   └── RecordController.java
│   │   │   ├── service/
│   │   │   │   ├── RecordService.java
│   │   │   │   └── impl/RecordServiceImpl.java
│   │   │   ├── entity/
│   │   │   │   └── TomatoRecord.java
│   │   │   ├── dto/
│   │   │   │   ├── RecordDTO.java
│   │   │   │   └── RecordCreateRequest.java
│   │   │   └── mapper/
│   │   │       └── RecordMapper.java
│   │   │
│   │   └── statistics/                       # 统计模块
│   │       ├── controller/
│   │       │   └── StatisticsController.java
│   │       ├── service/
│   │       │   ├── StatisticsService.java
│   │       │   └── impl/StatisticsServiceImpl.java
│   │       └── dto/
│   │           ├── StatisticsDTO.java
│   │           ├── DailyStatisticsDTO.java
│   │           └── TaskRankingDTO.java
│   │
│   └── security/                             # 安全模块
│       ├── interceptor/                      # 拦截器
│       │   └── AuthInterceptor.java          # 认证拦截器
│       └── filter/                           # 过滤器
│           └── JwtFilter.java                # JWT过滤器
│
├── src/main/resources/
│   ├── application.yml                       # 应用配置
│   ├── application-dev.yml                   # 开发环境配置
│   ├── application-prod.yml                  # 生产环境配置
│   └── mapper/                               # MyBatis映射文件
│       ├── UserMapper.xml
│       ├── TaskMapper.xml
│       └── RecordMapper.xml
│
└── src/test/java/                            # 测试代码
    └── com/tomato/
        ├── service/                          # 服务层测试
        └── controller/                       # 控制器测试
```

### 3.4 包内聚设计原则

**后端模块划分遵循DDD领域驱动设计：**

1. **user模块**：用户认证、用户信息管理
2. **task模块**：任务CRUD、状态流转、模式切换
3. **record模块**：番茄完成记录、历史查询
4. **statistics模块**：数据统计、报表生成

**包依赖原则：**
```
controller → service → mapper
    ↓         ↓         ↓
   dto     entity    数据库
```

---

## 4. 核心数据结构

### 4.1 前端数据模型

#### 4.1.1 任务模型（ToDoListClass.ets）

```typescript
export class ToDoListClass {
  // 基础字段
  id: number = 0;
  user_id: number = 0;
  name: string = '';

  // 模式标识
  mode: TaskMode = TaskMode.Todo;           // 1=待办, 2=计划

  // 时长配置
  tomato_minutes: number = 25;              // 番茄时长（分钟）
  rest_minutes: number = 5;                 // 休息时长（分钟）

  // 待办模式字段
  target_tomato_count: number | null = null;        // 目标番茄数

  // 计划模式字段
  daily_target_tomato_count: number | null = null; // 每日目标
  deadline: Date | null = null;                     // 截止日期
  last_reset_date: Date | null = null;              // 上次重置日期

  // 统计字段
  finished_tomato_count: number = 0;       // 累计已完成数
  today_finished_count: number = 0;        // 今日已完成数

  // 状态字段
  status: TaskStatus = TaskStatus.Working; // 1=进行中, 2=已完成, 4=已过期, 5=已取消

  // 时间戳
  created_at: Date = new Date();
  updated_at: Date = new Date();

  // 计算属性（计划模式）
  get total_target_tomato_count(): number {
    if (this.mode !== TaskMode.Plan || !this.deadline || !this.daily_target_tomato_count) {
      return 0;
    }
    const days = this.calculateDays();
    return this.daily_target_tomato_count * days;
  }

  get progress(): number {
    if (this.mode === TaskMode.Todo) {
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
    if (this.mode !== TaskMode.Plan) return false;
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
    if (this.status === TaskStatus.Cancelled || this.status === TaskStatus.Expired) {
      return false;
    }

    if (this.mode === TaskMode.Todo) {
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

#### 4.1.2 任务类型枚举（TaskType.ets）

```typescript
export enum TaskMode {
  Todo = 1,    // 待办模式：一次性任务
  Plan = 2     // 计划模式：每日重复任务
}

export enum TaskStatus {
  Working = 1,    // 进行中（通用）
  Completed = 2,  // 已完成（通用）
  Expired = 4,    // 已过期（计划模式专属）
  Cancelled = 5   // 已取消（通用）
}

export enum TimerMode {
  Working = 'working',    // 专注模式
  Resting = 'resting'     // 休息模式
}
```

#### 4.1.3 计时器状态模型

```typescript
// 计时器视图模型
@Observed
export class TimerViewModel {
  currentTask: ToDoListClass | null = null;
  timerMode: TimerMode = TimerMode.Working;

  // 计时器状态
  @Track isRunning: boolean = false;
  @Track isPaused: boolean = false;
  @Track remainingSeconds: number = 0;
  @Track totalSeconds: number = 0;

  // 进度
  get progress(): number {
    if (this.totalSeconds === 0) return 0;
    return ((this.totalSeconds - this.remainingSeconds) / this.totalSeconds) * 100;
  }

  get formattedTime(): string {
    const minutes = Math.floor(this.remainingSeconds / 60);
    const seconds = this.remainingSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  // 持久化状态（用于应用杀死恢复）
  toPersist(): TimerPersistState {
    return {
      taskId: this.currentTask?.id || 0,
      timerMode: this.timerMode,
      remainingSeconds: this.remainingSeconds,
      totalSeconds: this.totalSeconds,
      isPaused: this.isPaused,
      timestamp: Date.now()
    };
  }

  static fromPersist(state: TimerPersistState, task: ToDoListClass): TimerViewModel {
    const vm = new TimerViewModel();
    vm.currentTask = task;
    vm.timerMode = state.timerMode;
    vm.remainingSeconds = state.remainingSeconds;
    vm.totalSeconds = state.totalSeconds;
    vm.isPaused = state.isPaused;
    return vm;
  }
}

// 计时器持久化状态
export interface TimerPersistState {
  taskId: number;
  timerMode: TimerMode;
  remainingSeconds: number;
  totalSeconds: number;
  isPaused: boolean;
  timestamp: number;
}
```

#### 4.1.4 统计数据模型

```typescript
// 统计周期
export type StatisticsPeriod = 'today' | 'week' | 'month';

// 统计数据
export interface StatisticsData {
  period: StatisticsPeriod;
  startDate: Date;
  endDate: Date;

  // 核心指标
  completedTomatoes: number;        // 完成番茄数
  focusMinutes: number;             // 专注时长（分钟）
  completedTasks: number;           // 已完成任务数
  totalTasks: number;               // 总任务数
  completionRate: number;           // 完成率（百分比）

  // 每日数据
  dailyData: DailyData[];

  // 任务排行
  taskRanking: TaskRankingItem[];
}

// 每日数据
export interface DailyData {
  date: Date;
  completedTomatoes: number;
  focusMinutes: number;
}

// 任务排行项
export interface TaskRankingItem {
  taskId: number;
  taskName: string;
  taskMode: TaskMode;
  completedTomatoes: number;        // 周期内完成数
  totalCompletedTomatoes: number;   // 累计完成数（仅计划模式）
}
```

### 4.2 后端数据模型

#### 4.2.1 用户实体（User.java）

```java
package com.tomato.modules.user.entity;

import java.time.LocalDateTime;

/**
 * 用户实体
 */
public class User {

    /**
     * 用户ID（主键）
     */
    private Long id;

    /**
     * 鸿蒙设备ID（用于设备登录）
     */
    private String deviceId;

    /**
     * 用户昵称
     */
    private String nickname;

    /**
     * 头像URL
     */
    private String avatar;

    /**
     * 默认番茄时长（分钟）
     */
    private Integer defaultTomatoMinutes;

    /**
     * 默认休息时长（分钟）
     */
    private Integer defaultRestMinutes;

    /**
     * 状态：1=正常, 0=禁用
     */
    private Integer status;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

    // Getter and Setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getDeviceId() { return deviceId; }
    public void setDeviceId(String deviceId) { this.deviceId = deviceId; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public Integer getDefaultTomatoMinutes() { return defaultTomatoMinutes; }
    public void setDefaultTomatoMinutes(Integer defaultTomatoMinutes) { this.defaultTomatoMinutes = defaultTomatoMinutes; }

    public Integer getDefaultRestMinutes() { return defaultRestMinutes; }
    public void setDefaultRestMinutes(Integer defaultRestMinutes) { this.defaultRestMinutes = defaultRestMinutes; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
```

#### 4.2.2 任务实体（Task.java）

```java
package com.tomato.modules.task.entity;

import java.time.LocalDateTime;
import java.time.LocalDate;

/**
 * 任务实体
 */
public class Task {

    /**
     * 任务ID（主键）
     */
    private Long id;

    /**
     * 所属用户ID
     */
    private Long userId;

    /**
     * 任务名称
     */
    private String name;

    /**
     * 任务模式：1=待办, 2=计划
     */
    private Integer mode;

    /**
     * 番茄时长（分钟）
     */
    private Integer tomatoMinutes;

    /**
     * 休息时长（分钟）
     */
    private Integer restMinutes;

    /**
     * 目标番茄数（待办模式）
     */
    private Integer targetTomatoCount;

    /**
     * 每日目标番茄数（计划模式）
     */
    private Integer dailyTargetTomatoCount;

    /**
     * 截止日期（计划模式）
     */
    private LocalDate deadline;

    /**
     * 累计已完成番茄数
     */
    private Integer finishedTomatoCount;

    /**
     * 今日已完成番茄数（计划模式）
     */
    private Integer todayFinishedCount;

    /**
     * 上次重置日期（计划模式）
     */
    private LocalDate lastResetDate;

    /**
     * 累计总目标（计划模式，系统计算）
     */
    private Integer totalTargetTomatoCount;

    /**
     * 任务状态：1=进行中, 2=已完成, 4=已过期, 5=已取消
     */
    private Integer status;

    /**
     * 优先级
     */
    private Integer priority;

    /**
     * 删除标记：0=未删除, 1=已删除
     */
    private Integer deleted;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

    // Getter and Setter (省略，实际开发中可使用Lombok)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getMode() { return mode; }
    public void setMode(Integer mode) { this.mode = mode; }

    public Integer getTomatoMinutes() { return tomatoMinutes; }
    public void setTomatoMinutes(Integer tomatoMinutes) { this.tomatoMinutes = tomatoMinutes; }

    public Integer getRestMinutes() { return restMinutes; }
    public void setRestMinutes(Integer restMinutes) { this.restMinutes = restMinutes; }

    public Integer getTargetTomatoCount() { return targetTomatoCount; }
    public void setTargetTomatoCount(Integer targetTomatoCount) { this.targetTomatoCount = targetTomatoCount; }

    public Integer getDailyTargetTomatoCount() { return dailyTargetTomatoCount; }
    public void setDailyTargetTomatoCount(Integer dailyTargetTomatoCount) { this.dailyTargetTomatoCount = dailyTargetTomatoCount; }

    public LocalDate getDeadline() { return deadline; }
    public void setDeadline(LocalDate deadline) { this.deadline = deadline; }

    public Integer getFinishedTomatoCount() { return finishedTomatoCount; }
    public void setFinishedTomatoCount(Integer finishedTomatoCount) { this.finishedTomatoCount = finishedTomatoCount; }

    public Integer getTodayFinishedCount() { return todayFinishedCount; }
    public void setTodayFinishedCount(Integer todayFinishedCount) { this.todayFinishedCount = todayFinishedCount; }

    public LocalDate getLastResetDate() { return lastResetDate; }
    public void setLastResetDate(LocalDate lastResetDate) { this.lastResetDate = lastResetDate; }

    public Integer getTotalTargetTomatoCount() { return totalTargetTomatoCount; }
    public void setTotalTargetTomatoCount(Integer totalTargetTomatoCount) { this.totalTargetTomatoCount = totalTargetTomatoCount; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }

    public Integer getPriority() { return priority; }
    public void setPriority(Integer priority) { this.priority = priority; }

    public Integer getDeleted() { return deleted; }
    public void setDeleted(Integer deleted) { this.deleted = deleted; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
```

#### 4.2.3 番茄记录实体（TomatoRecord.java）

```java
package com.tomato.modules.record.entity;

import java.time.LocalDateTime;

/**
 * 番茄完成记录
 */
public class TomatoRecord {

    /**
     * 记录ID（主键）
     */
    private Long id;

    /**
     * 所属用户ID
     */
    private Long userId;

    /**
     * 任务ID
     */
    private Long taskId;

    /**
     * 任务名称（快照，防止任务删除后无法显示）
     */
    private String taskName;

    /**
     * 任务模式（快照）
     */
    private Integer taskMode;

    /**
     * 实际番茄时长（分钟）
     */
    private Integer actualMinutes;

    /**
     * 是否提前结束：0=否, 1=是
     */
    private Integer isEarlyEnd;

    /**
     * 完成时间
     */
    private LocalDateTime completedAt;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    // Getter and Setter (省略，实际开发中可使用Lombok)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getTaskId() { return taskId; }
    public void setTaskId(Long taskId) { this.taskId = taskId; }

    public String getTaskName() { return taskName; }
    public void setTaskName(String taskName) { this.taskName = taskName; }

    public Integer getTaskMode() { return taskMode; }
    public void setTaskMode(Integer taskMode) { this.taskMode = taskMode; }

    public Integer getActualMinutes() { return actualMinutes; }
    public void setActualMinutes(Integer actualMinutes) { this.actualMinutes = actualMinutes; }

    public Integer getIsEarlyEnd() { return isEarlyEnd; }
    public void setIsEarlyEnd(Integer isEarlyEnd) { this.isEarlyEnd = isEarlyEnd; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}

    /**
     * 目标番茄数（待办模式）
     */
    private Integer targetTomatoCount;

    /**
     * 每日目标番茄数（计划模式）
     */
    private Integer dailyTargetTomatoCount;

    /**
     * 截止日期（计划模式）
     */
    private LocalDate deadline;

    /**
     * 累计已完成番茄数
     */
    private Integer finishedTomatoCount;

    /**
     * 今日已完成番茄数（计划模式）
     */
    private Integer todayFinishedCount;

    /**
     * 上次重置日期（计划模式）
     */
    private LocalDate lastResetDate;

    /**
     * 累计总目标（计划模式，系统计算）
     */
    private Integer totalTargetTomatoCount;

    /**
     * 任务状态：1=进行中, 2=已完成, 4=已过期, 5=已取消
     */
    private Integer status;

    /**
     * 优先级
     */
    private Integer priority;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /**
     * 删除标记：0=未删除, 1=已删除
     */
    @TableLogic
    private Integer deleted;
}
```

#### 4.2.3 番茄记录实体（TomatoRecord.java）

```java
package com.tomato.modules.record.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 番茄完成记录
 */
@Data
@TableName("tomato_record")
public class TomatoRecord {

    /**
     * 记录ID（主键）
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 所属用户ID
     */
    private Long userId;

    /**
     * 任务ID
     */
    private Long taskId;

    /**
     * 任务名称（快照，防止任务删除后无法显示）
     */
    private String taskName;

    /**
     * 任务模式（快照）
     */
    private Integer taskMode;

    /**
     * 实际番茄时长（分钟）
     */
    private Integer actualMinutes;

    /**
     * 是否提前结束：0=否, 1=是
     */
    private Integer isEarlyEnd;

    /**
     * 完成时间
     */
    private LocalDateTime completedAt;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}
```

### 4.3 DTO定义

#### 4.3.1 任务相关DTO

```java
/**
 * 任务DTO
 */
@Data
public class TaskDTO {
    private Long id;
    private String name;
    private Integer mode;
    private Integer tomatoMinutes;
    private Integer restMinutes;
    private Integer targetTomatoCount;
    private Integer dailyTargetTomatoCount;
    private LocalDate deadline;
    private Integer finishedTomatoCount;
    private Integer todayFinishedCount;
    private Integer totalTargetTomatoCount;
    private Integer status;
    private Integer progress;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

/**
 * 创建任务请求
 */
@Data
public class TaskCreateRequest {
    @NotBlank(message = "任务名称不能为空")
    private String name;

    @NotNull(message = "任务模式不能为空")
    private Integer mode;

    @NotNull(message = "番茄时长不能为空")
    @Positive(message = "番茄时长必须大于0")
    private Integer tomatoMinutes;

    @NotNull(message = "休息时长不能为空")
    @PositiveOrZero(message = "休息时长不能为负数")
    private Integer restMinutes;

    // 待办模式必填
    @Positive(message = "目标番茄数必须大于0", groups = TodoMode.class)
    private Integer targetTomatoCount;

    // 计划模式必填
    @Positive(message = "每日目标必须大于0", groups = PlanMode.class)
    private Integer dailyTargetTomatoCount;

    @NotNull(message = "截止日期不能为空", groups = PlanMode.class)
    @Future(message = "截止日期必须晚于今天", groups = PlanMode.class)
    private LocalDate deadline;

    // 校验分组接口
    public interface TodoMode {}
    public interface PlanMode {}
}

/**
 * 更新任务请求
 */
@Data
public class TaskUpdateRequest {
    @NotNull(message = "任务ID不能为空")
    private Long id;

    private String name;
    private Integer tomatoMinutes;
    private Integer restMinutes;
    private Integer targetTomatoCount;
    private Integer dailyTargetTomatoCount;
    private LocalDate deadline;
    private Integer status;
    private Integer priority;
}

/**
 * 任务查询请求
 */
@Data
public class TaskQueryRequest {
    private Integer status;        // 状态筛选
    private Integer mode;          // 模式筛选
    private String keyword;        // 关键词搜索
    private Integer pageNum = 1;
    private Integer pageSize = 20;
}
```

#### 4.3.2 统计相关DTO

```java
/**
 * 统计数据DTO
 */
@Data
public class StatisticsDTO {
    private String period;            // today/week/month
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer completedTomatoes;
    private Long focusMinutes;
    private Integer completedTasks;
    private Integer totalTasks;
    private Integer completionRate;
    private List<DailyStatisticsDTO> dailyData;
    private List<TaskRankingDTO> taskRanking;
}

/**
 * 每日统计DTO
 */
@Data
public class DailyStatisticsDTO {
    private LocalDate date;
    private Integer completedTomatoes;
    private Long focusMinutes;
}

/**
 * 任务排行DTO
 */
@Data
public class TaskRankingDTO {
    private Long taskId;
    private String taskName;
    private Integer taskMode;
    private Integer completedTomatoes;      // 周期内完成数
    private Integer totalCompletedTomatoes; // 累计完成数
}
```

#### 4.3.3 统一响应结构

```java
/**
 * 统一响应结果
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {
    private Integer code;
    private String message;
    private T data;
    private Long timestamp;

    public static <T> Result<T> success(T data) {
        return new Result<>(200, "success", data, System.currentTimeMillis());
    }

    public static <T> Result<T> error(Integer code, String message) {
        return new Result<>(code, message, null, System.currentTimeMillis());
    }

    public static <T> Result<T> error(ResultCode resultCode) {
        return new Result<>(resultCode.getCode(),
                            resultCode.getMessage(),
                            null,
                            System.currentTimeMillis());
    }
}

/**
 * 响应码枚举
 */
@Getter
@AllArgsConstructor
public enum ResultCode {
    SUCCESS(200, "操作成功"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未授权"),
    FORBIDDEN(403, "无权限访问"),
    NOT_FOUND(404, "资源不存在"),
    INTERNAL_ERROR(500, "系统内部错误"),

    // 业务错误码 1000-1999
    TASK_NOT_FOUND(1001, "任务不存在"),
   _TASK_NAME_EMPTY(1002, "任务名称不能为空"),
    TASK_MODE_INVALID(1003, "任务模式不合法"),
    TASK_STATUS_INVALID(1004, "任务状态不合法"),
    TASK_ALREADY_COMPLETED(1005, "任务已完成"),
    ;

    private final Integer code;
    private final String message;
}
```

---

## 5. 接口设计

### 5.1 接口规范

**请求规范：**
- Content-Type: application/json
- 认证方式: Bearer Token
- 字符编码: UTF-8

**响应规范：**
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1710835200000
}
```

**错误响应：**
```json
{
  "code": 1001,
  "message": "任务不存在",
  "data": null,
  "timestamp": 1710835200000
}
```

### 5.2 用户认证接口（MVP）

#### 5.2.1 微信登录

```
POST /api/v1/auth/wechat/login

Request Body:
{
  "code": "091a3b5a2b5c4d1e2f3a4b5c6d7e8f9g"
}

Response 200:
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 604800,
    "user": {
      "id": 1,
      "openid": "oXXXXXXXXXXXXXXXXXXX",
      "unionid": "uxXXXXXXXXXXXXXXXXXX",
      "nickname": "番茄用户",
      "avatar": "https://thirdwx.qlogo.cn/...",
      "login_type": "wechat",
      "created_at": "2026-03-19T10:00:00Z"
    }
  }
}
```

#### 5.2.2 华为账号登录

```
POST /api/v1/auth/huawei/login

Request Body:
{
  "code": "CjAaBhkrCKD...",
  "grant_type": "authorization_code"
}

Response 200:
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 604800,
    "user": {
      "id": 2,
      "huawei_uid": "123456789",
      "nickname": "番茄用户",
      "avatar": "https://account.cloud.huawei.com/...",
      "login_type": "huawei",
      "created_at": "2026-03-19T10:00:00Z"
    }
  }
}
```

#### 5.2.3 Token验证

```
GET /api/v1/auth/validate

Headers:
  Authorization: Bearer {access_token}

Response 200:
{
  "code": 200,
  "message": "Token有效",
  "data": {
    "user": {
      "id": 1,
      "nickname": "番茄用户",
      "avatar": "https://..."
    }
  }
}
```

#### 5.2.4 Token刷新

```
POST /api/v1/auth/refresh

Request Body:
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

Response 200:
{
  "code": 200,
  "message": "刷新成功",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 604800
  }
}
```

#### 5.2.5 登出

```
POST /api/v1/auth/logout

Headers:
  Authorization: Bearer {access_token}

Response 200:
{
  "code": 200,
  "message": "登出成功"
}
```

### 5.3 任务模块接口（MVP）

#### 5.3.1 获取任务列表

```
GET /api/v1/tasks

Headers:
  Authorization: Bearer {access_token}

Query Parameters:
  - status: Integer (可选) - 任务状态筛选
  - mode: Integer (可选) - 任务模式筛选

Response 200:
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 10,
    "list": [
      {
        "id": 1,
        "name": "学习高数第三章",
        "mode": 1,
        "tomato_minutes": 25,
        "rest_minutes": 5,
        "target_tomato_count": 8,
        "finished_tomato_count": 3,
        "status": 1,
        "progress": 37.5
      }
    ]
  }
}
```

#### 5.3.2 创建任务

```
POST /api/v1/tasks

Headers:
  Authorization: Bearer {access_token}

Request Body:
{
  "name": "每日学习英语",
  "mode": 2,
  "daily_target_tomato_count": 5,
  "deadline": "2026-06-30"
}
```

#### 5.3.3 完成番茄钟

```
POST /api/v1/tasks/{id}/complete

Headers:
  Authorization: Bearer {access_token}

Request Body:
{
  "actual_minutes": 25,
  "is_early_end": false
}
```

### 5.4 用户信息接口（MVP）

#### 5.4.1 获取用户信息

```
GET /api/v1/user/profile

Headers:
  Authorization: Bearer {access_token}

Response 200:
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "nickname": "番茄用户",
    "avatar": "https://...",
    "login_type": "wechat"
  }
}
```

### 5.5 统计接口（v1.1）

> 统计功能延期到v1.1版本

#### 5.5.1 获取统计数据

```
GET /api/v1/statistics

Headers:
  Authorization: Bearer {access_token}

Query Parameters:
  - period: String - "today" | "week" | "month"
```

### 5.6 接口汇总表

| 模块 | 接口 | 方法 | 版本 | 说明 |
|------|------|------|------|------|
| 认证 | /v1/auth/wechat/login | POST | MVP | 微信登录 |
| 认证 | /v1/auth/huawei/login | POST | MVP | 华为账号登录 |
| 认证 | /v1/auth/validate | GET | MVP | Token验证 |
| 认证 | /v1/auth/refresh | POST | MVP | Token刷新 |
| 认证 | /v1/auth/logout | POST | MVP | 登出 |
| 任务 | /v1/tasks | GET | MVP | 获取任务列表 |
| 任务 | /v1/tasks | POST | MVP | 创建任务 |
| 任务 | /v1/tasks/{id} | PUT | MVP | 更新任务 |
| 任务 | /v1/tasks/{id} | DELETE | MVP | 删除/取消任务 |
| 任务 | /v1/tasks/{id}/complete | POST | MVP | 完成番茄钟 |
| 用户 | /v1/user/profile | GET | MVP | 获取用户信息 |
| 统计 | /v1/statistics | GET | v1.1 | 获取统计数据 |

---

## 6. 技术实现要点

### 6.1 前端关键技术点

#### 6.1.1 计时器实现

```typescript
// 使用TextTimer组件实现倒计时
@Entry
@Component
struct CountDownTimer {
  @State viewModel: TimerViewModel = new TimerViewModel();
  private timerController: TextTimerController = new TextTimerController();

  build() {
    Column() {
      // 环形进度条
      Progress({
        value: this.viewModel.progress,
        total: 100,
        type: ProgressType.Ring
      })
      .width(200)
      .height(200)

      // 倒计时显示
      Text(this.viewModel.formattedTime)
        .fontSize(48)
        .fontWeight(FontWeight.Bold)

      // 操作按钮
      if (this.viewModel.isRunning) {
        Button('暂停')
          .onClick(() => this.pauseTimer())
      } else {
        Button('继续')
          .onClick(() => this.resumeTimer())
      }

      Button('结束')
        .onClick(() => this.showEndDialog())
    }
  }

  private pauseTimer(): void {
    this.timerController.pause();
    this.viewModel.isPaused = true;
    StorageService.saveTimerState(this.viewModel.toPersist());
  }

  private resumeTimer(): void {
    this.timerController.start();
    this.viewModel.isPaused = false;
  }
}
```

#### 6.1.2 本地数据存储

```typescript
import { preferences } from '@kit.ArkData';

export class StorageService {
  private static readonly TASKS_KEY = 'user_tasks';
  private static readonly TIMER_STATE_KEY = 'timer_state';
  private static readonly SETTINGS_KEY = 'app_settings';

  // 保存任务列表
  static async saveTasks(tasks: ToDoListClass[]): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
      await prefs.put(this.TASKS_KEY, JSON.stringify(tasks));
      await prefs.flush();
    } catch (error) {
      Logger.error('保存任务失败', error);
      throw error;
    }
  }

  // 加载任务列表
  static async loadTasks(): Promise<ToDoListClass[]> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
      const data = await prefs.get(this.TASKS_KEY, '[]');
      return JSON.parse(data as string);
    } catch (error) {
      Logger.error('加载任务失败', error);
      return [];
    }
  }

  // 保存计时器状态
  static async saveTimerState(state: TimerPersistState): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
      await prefs.put(this.TIMER_STATE_KEY, JSON.stringify(state));
      await prefs.flush();
    } catch (error) {
      Logger.error('保存计时器状态失败', error);
    }
  }

  // 恢复计时器状态
  static async restoreTimerState(): Promise<TimerPersistState | null> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'TomatoClock');
      const data = await prefs.get(this.TIMER_STATE_KEY, null);
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
    } catch (error) {
      Logger.error('恢复计时器状态失败', error);
      return null;
    }
  }
}
```

#### 6.1.3 通知实现

```typescript
import { notificationManager } from '@kit.NotificationKit';
import { wantAgent } from '@kit.AbilityKit';

export class NotificationService {

  // 发送番茄完成通知
  static async sendTomatoCompleteNotification(taskName: string): Promise<void> {
    try {
      const notificationRequest = {
        id: Date.now(),
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '专注时间结束！',
            text: `你完成了"${taskName}"的一个番茄钟，休息一下吧。`,
            additionalText: '退出番茄钟'
          }
        },
        actionButtons: [
          {
            title: '开始休息',
            wantAgent: await this.createWantAgent('rest')
          },
          {
            title: '退出番茄钟',
            wantAgent: await this.createWantAgent('exit')
          }
        ]
      };

      await notificationManager.publish(notificationRequest);
    } catch (error) {
      Logger.error('发送通知失败', error);
    }
  }

  // 创建WantAgent（点击通知后的操作）
  private static async createWantAgent(action: string): Promise.wantAgent.WantAgent> {
    const wantAgentInfo = {
      wants: [
        {
          bundleName: 'com.tomato.clock',
          abilityName: 'EntryAbility',
          parameters: { action: action }
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    return await wantAgent.getWantAgent(wantAgentInfo);
  }
}
```

#### 6.1.4 用户认证实现

```typescript
import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';

// 登录类型枚举
export enum LoginType {
  WECHAT = 'wechat',
  HUAWEI = 'huawei'
}

// 用户信息模型
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

// 认证状态模型
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

// 认证服务
export class AuthService {
  private static readonly AUTH_KEY = 'auth_state';
  private static readonly BASE_URL = 'https://api.tomatoclock.com/api/v1';
  private preferences: preferences.Preferences | null = null;

  // 初始化
  private async getPreferences(): Promise<preferences.Preferences> {
    if (!this.preferences) {
      this.preferences = await preferences.getPreferences(getContext(), 'AUTH_STORE');
    }
    return this.preferences;
  }

  // 保存认证状态
  async saveAuthState(state: AuthState): Promise<void> {
    try {
      const prefs = await this.getPreferences();
      await prefs.put(AuthService.AUTH_KEY, JSON.stringify(state));
      await prefs.flush();
    } catch (error) {
      Logger.error('保存认证状态失败', error);
      throw error;
    }
  }

  // 获取认证状态
  async getAuthState(): Promise<AuthState | null> {
    try {
      const prefs = await this.getPreferences();
      const data = await prefs.get(AuthService.AUTH_KEY, '');
      if (data) {
        return JSON.parse(data as string) as AuthState;
      }
      return null;
    } catch (error) {
      Logger.error('获取认证状态失败', error);
      return null;
    }
  }

  // 清除认证状态
  async clearAuthState(): Promise<void> {
    try {
      const prefs = await this.getPreferences();
      await prefs.delete(AuthService.AUTH_KEY);
      await prefs.flush();
    } catch (error) {
      Logger.error('清除认证状态失败', error);
    }
  }

  // 微信登录
  async wechatLogin(code: string): Promise<AuthState> {
    try {
      const response = await http.createHttp().request(
        `${AuthService.BASE_URL}/auth/wechat/login`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({ code })
        }
      );

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string);
        if (data.code === 200) {
          const authState = new AuthState();
          authState.isLoggedIn = true;
          authState.user = data.data.user;
          authState.accessToken = data.data.access_token;
          authState.refreshToken = data.data.refresh_token;
          authState.tokenExpiresAt = new Date(Date.now() + data.data.expires_in * 1000);

          await this.saveAuthState(authState);
          return authState;
        }
      }
      throw new Error('微信登录失败');
    } catch (error) {
      Logger.error('微信登录失败', error);
      throw error;
    }
  }

  // 华为账号登录
  async huaweiLogin(code: string): Promise<AuthState> {
    try {
      const response = await http.createHttp().request(
        `${AuthService.BASE_URL}/auth/huawei/login`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({ code, grant_type: 'authorization_code' })
        }
      );

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string);
        if (data.code === 200) {
          const authState = new AuthState();
          authState.isLoggedIn = true;
          authState.user = data.data.user;
          authState.accessToken = data.data.access_token;
          authState.refreshToken = data.data.refresh_token;
          authState.tokenExpiresAt = new Date(Date.now() + data.data.expires_in * 1000);

          await this.saveAuthState(authState);
          return authState;
        }
      }
      throw new Error('华为登录失败');
    } catch (error) {
      Logger.error('华为登录失败', error);
      throw error;
    }
  }

  // Token验证
  async validateToken(): Promise<User | null> {
    try {
      const authState = await this.getAuthState();
      if (!authState || !authState.accessToken) {
        return null;
      }

      const response = await http.createHttp().request(
        `${AuthService.BASE_URL}/auth/validate`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authState.accessToken}`
          }
        }
      );

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string);
        if (data.code === 200) {
          return data.data.user;
        }
      }
      return null;
    } catch (error) {
      Logger.error('Token验证失败', error);
      return null;
    }
  }

  // Token刷新
  async refreshToken(): Promise<boolean> {
    try {
      const authState = await this.getAuthState();
      if (!authState || !authState.refreshToken) {
        return false;
      }

      const response = await http.createHttp().request(
        `${AuthService.BASE_URL}/auth/refresh`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({ refresh_token: authState.refreshToken })
        }
      );

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string);
        if (data.code === 200) {
          authState.accessToken = data.data.access_token;
          authState.tokenExpiresAt = new Date(Date.now() + data.data.expires_in * 1000);
          await this.saveAuthState(authState);
          return true;
        }
      }
      return false;
    } catch (error) {
      Logger.error('Token刷新失败', error);
      return false;
    }
  }

  // 登出
  async logout(): Promise<void> {
    try {
      const authState = await this.getAuthState();
      if (authState && authState.accessToken) {
        await http.createHttp().request(
          `${AuthService.BASE_URL}/auth/logout`,
          {
            method: http.RequestMethod.POST,
            header: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${authState.accessToken}`
            }
          }
        );
      }
    } catch (error) {
      Logger.error('登出请求失败', error);
    } finally {
      await this.clearAuthState();
    }
  }

  // 自动登录检查
  async checkAutoLogin(): Promise<boolean> {
    try {
      const authState = await this.getAuthState();
      if (!authState || !authState.isLoggedIn) {
        return false;
      }

      // 检查Token是否过期
      if (authState.isTokenExpired()) {
        // 尝试刷新Token
        const refreshed = await this.refreshToken();
        if (!refreshed) {
          await this.clearAuthState();
          return false;
        }
      }

      // 验证Token有效性
      const user = await this.validateToken();
      if (!user) {
        await this.clearAuthState();
        return false;
      }

      return true;
    } catch (error) {
      Logger.error('自动登录检查失败', error);
      await this.clearAuthState();
      return false;
    }
  }
}
```

### 6.2 后端关键技术点

#### 6.2.1 MyBatis配置

```java
@Configuration
@MapperScan("com.tomato.**.mapper")
public class MyBatisConfig {

    /**
     * 分页插件（PageHelper）
     */
    @Bean
    public PageInterceptor pageInterceptor() {
        PageInterceptor interceptor = new PageInterceptor();
        Properties properties = new Properties();
        properties.setProperty("helperDialect", "mysql");
        properties.setProperty("reasonable", "true");       // 合理化参数
        properties.setProperty("supportMethodsArguments", "true");
        properties.setProperty("params", "count=countSql");
        interceptor.setProperties(properties);
        return interceptor;
    }

    /**
     * 数据源配置
     */
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.hikari")
    public DataSource dataSource() {
        return DataSourceBuilder.create().build();
    }

    /**
     * SqlSessionFactory配置
     */
    @Bean
    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
        SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
        factoryBean.setDataSource(dataSource);
        factoryBean.setTypeAliasesPackage("com.tomato.modules.**.entity");
        factoryBean.setMapperLocations(new PathMatchingResourcePatternResolver()
            .getResources("classpath:mapper/*.xml"));

        // MyBatis配置
        org.apache.ibatis.session.Configuration config = new org.apache.ibatis.session.Configuration();
        config.setMapUnderscoreToCamelCase(true); // 驼峰命名转换
        config.setCallSettersOnNulls(true);       // 空值调用setter
        config.setJdbcTypeForNull(JdbcType.NULL);
        factoryBean.setConfiguration(config);

        return factoryBean.getObject();
    }
}
```

#### 6.2.2 任务Service实现

```java
@Service
@Slf4j
public class TaskServiceImpl implements TaskService {

    @Autowired
    private TaskMapper taskMapper;

    @Autowired
    private TomatoRecordMapper recordMapper;

    /**
     * 创建任务
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public TaskDTO createTask(TaskCreateRequest request) {
        // 1. 参数校验
        validateTaskRequest(request);

        // 2. 构建任务实体
        Task task = new Task();
        BeanUtils.copyProperties(request, task);
        task.setUserId(SecurityContextHolder.getUserId());
        task.setStatus(TaskStatus.WORKING.getCode());
        task.setFinishedTomatoCount(0);
        task.setTodayFinishedCount(0);
        task.setDeleted(0);
        task.setCreatedAt(LocalDateTime.now());
        task.setUpdatedAt(LocalDateTime.now());

        // 3. 计划模式特殊处理
        if (task.getMode().equals(TaskMode.PLAN.getCode())) {
            Integer days = calculateDays(task.getCreatedAt(), task.getDeadline());
            task.setTotalTargetTomatoCount(task.getDailyTargetTomatoCount() * days);
            task.setLastResetDate(LocalDate.now());
        }

        // 4. 保存任务
        taskMapper.insert(task);

        // 5. 返回DTO
        return convertToDTO(task);
    }

    /**
     * 完成番茄钟
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public void completeTomato(Long taskId, Integer actualMinutes, Boolean isEarlyEnd) {
        // 1. 查询任务
        Task task = taskMapper.selectById(taskId);
        if (task == null) {
            throw new BusinessException(ResultCode.TASK_NOT_FOUND);
        }

        // 2. 检查任务状态
        if (!TaskStatus.WORKING.getCode().equals(task.getStatus())) {
            throw new BusinessException(ResultCode.TASK_STATUS_INVALID);
        }

        // 3. 更新任务数据
        task.setFinishedTomatoCount(task.getFinishedTomatoCount() + 1);
        task.setUpdatedAt(LocalDateTime.now());

        if (task.getMode().equals(TaskMode.PLAN.getCode())) {
            task.setTodayFinishedCount(task.getTodayFinishedCount() + 1);
        }

        // 4. 检查是否完成
        if (isTaskCompleted(task)) {
            task.setStatus(TaskStatus.COMPLETED.getCode());
        }

        taskMapper.updateById(task);

        // 5. 创建番茄记录
        TomatoRecord record = new TomatoRecord();
        record.setUserId(task.getUserId());
        record.setTaskId(taskId);
        record.setTaskName(task.getName());
        record.setTaskMode(task.getMode());
        record.setActualMinutes(actualMinutes);
        record.setIsEarlyEnd(isEarlyEnd ? 1 : 0);
        record.setCompletedAt(LocalDateTime.now());
        record.setCreatedAt(LocalDateTime.now());
        recordMapper.insert(record);
    }

    /**
     * 检查并重置今日计数（计划模式）
     */
    @Override
    public void checkAndResetTodayCount() {
        TaskQuery query = new TaskQuery();
        query.setMode(TaskMode.PLAN.getCode());
        query.setStatus(TaskStatus.WORKING.getCode());

        List<Task> planTasks = taskMapper.selectByQuery(query);
        LocalDate today = LocalDate.now();

        for (Task task : planTasks) {
            if (task.getLastResetDate() == null || !task.getLastResetDate().equals(today)) {
                task.setTodayFinishedCount(0);
                task.setLastResetDate(today);
                task.setUpdatedAt(LocalDateTime.now());
                taskMapper.updateById(task);
            }
        }
    }

    /**
     * 判断任务是否完成
     */
    private boolean isTaskCompleted(Task task) {
        if (task.getMode().equals(TaskMode.TODO.getCode())) {
            return task.getFinishedTomatoCount() >= task.getTargetTomatoCount();
        } else {
            // 计划模式：检查是否到达截止日期或达到累计目标
            if (task.getDeadline() != null && LocalDate.now().isAfter(task.getDeadline())) {
                return true;
            }
            return task.getFinishedTomatoCount() >= task.getTotalTargetTomatoCount();
        }
    }

    /**
     * 计算天数
     */
    private Integer calculateDays(LocalDateTime start, LocalDate end) {
        return (int) ChronoUnit.DAYS.between(start.toLocalDate(), end) + 1;
    }

    /**
     * 参数校验
     */
    private void validateTaskRequest(TaskCreateRequest request) {
        if (StringUtils.isBlank(request.getName())) {
            throw new BusinessException(ResultCode.TASK_NAME_EMPTY);
        }
        if (request.getMode() == null) {
            throw new BusinessException(ResultCode.TASK_MODE_INVALID);
        }
        // 更多校验...
    }

    /**
     * 实体转DTO
     */
    private TaskDTO convertToDTO(Task task) {
        TaskDTO dto = new TaskDTO();
        BeanUtils.copyProperties(task, dto);

        // 计算进度
        if (task.getMode().equals(TaskMode.TODO.getCode())) {
            dto.setProgress(task.getTargetTomatoCount() != null
                ? (task.getFinishedTomatoCount() * 100 / task.getTargetTomatoCount())
                : 0);
        } else {
            dto.setProgress(task.getTotalTargetTomatoCount() != null
                ? (task.getFinishedTomatoCount() * 100 / task.getTotalTargetTomatoCount())
                : 0);
        }

        return dto;
    }
}
```

#### 6.2.3 Mapper接口示例

**TaskMapper.java**
```java
package com.tomato.modules.task.mapper;

import com.tomato.modules.task.entity.Task;
import com.tomato.modules.task.dto.TaskQuery;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 任务Mapper接口
 */
@Mapper
public interface TaskMapper {

    /**
     * 根据ID查询
     */
    Task selectById(@Param("id") Long id);

    /**
     * 插入任务
     */
    int insert(Task task);

    /**
     * 更新任务
     */
    int updateById(Task task);

    /**
     * 根据ID删除（逻辑删除）
     */
    int deleteById(@Param("id") Long id);

    /**
     * 根据条件查询列表
     */
    List<Task> selectByQuery(TaskQuery query);

    /**
     * 统计数量
     */
    int countByQuery(TaskQuery query);
}
```

**TaskMapper.xml**
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.tomato.modules.task.mapper.TaskMapper">

    <!-- 结果映射 -->
    <resultMap id="BaseResultMap" type="com.tomato.modules.task.entity.Task">
        <id column="id" property="id"/>
        <result column="user_id" property="userId"/>
        <result column="name" property="name"/>
        <result column="mode" property="mode"/>
        <result column="tomato_minutes" property="tomatoMinutes"/>
        <result column="rest_minutes" property="restMinutes"/>
        <result column="target_tomato_count" property="targetTomatoCount"/>
        <result column="daily_target_tomato_count" property="dailyTargetTomatoCount"/>
        <result column="deadline" property="deadline"/>
        <result column="finished_tomato_count" property="finishedTomatoCount"/>
        <result column="today_finished_count" property="todayFinishedCount"/>
        <result column="last_reset_date" property="lastResetDate"/>
        <result column="total_target_tomato_count" property="totalTargetTomatoCount"/>
        <result column="status" property="status"/>
        <result column="priority" property="priority"/>
        <result column="deleted" property="deleted"/>
        <result column="created_at" property="createdAt"/>
        <result column="updated_at" property="updatedAt"/>
    </resultMap>

    <!-- 基础列 -->
    <sql id="Base_Column_List">
        id, user_id, name, mode, tomato_minutes, rest_minutes,
        target_tomato_count, daily_target_tomato_count, deadline,
        finished_tomato_count, today_finished_count, last_reset_date,
        total_target_tomato_count, status, priority, deleted,
        created_at, updated_at
    </sql>

    <!-- 根据ID查询 -->
    <select id="selectById" resultMap="BaseResultMap">
        SELECT <include refid="Base_Column_List"/>
        FROM task
        WHERE id = #{id} AND deleted = 0
    </select>

    <!-- 插入 -->
    <insert id="insert" parameterType="com.tomato.modules.task.entity.Task"
            useGeneratedKeys="true" keyProperty="id">
        INSERT INTO task (
            user_id, name, mode, tomato_minutes, rest_minutes,
            target_tomato_count, daily_target_tomato_count, deadline,
            finished_tomato_count, today_finished_count, last_reset_date,
            total_target_tomato_count, status, priority, deleted,
            created_at, updated_at
        ) VALUES (
            #{userId}, #{name}, #{mode}, #{tomatoMinutes}, #{restMinutes},
            #{targetTomatoCount}, #{dailyTargetTomatoCount}, #{deadline},
            #{finishedTomatoCount}, #{todayFinishedCount}, #{lastResetDate},
            #{totalTargetTomatoCount}, #{status}, #{priority}, 0,
            #{createdAt}, #{updatedAt}
        )
    </insert>

    <!-- 更新 -->
    <update id="updateById" parameterType="com.tomato.modules.task.entity.Task">
        UPDATE task
        <set>
            <if test="name != null">name = #{name},</if>
            <if test="tomatoMinutes != null">tomato_minutes = #{tomatoMinutes},</if>
            <if test="restMinutes != null">rest_minutes = #{restMinutes},</if>
            <if test="targetTomatoCount != null">target_tomato_count = #{targetTomatoCount},</if>
            <if test="dailyTargetTomatoCount != null">daily_target_tomato_count = #{dailyTargetTomatoCount},</if>
            <if test="deadline != null">deadline = #{deadline},</if>
            <if test="finishedTomatoCount != null">finished_tomato_count = #{finishedTomatoCount},</if>
            <if test="todayFinishedCount != null">today_finished_count = #{todayFinishedCount},</if>
            <if test="lastResetDate != null">last_reset_date = #{lastResetDate},</if>
            <if test="totalTargetTomatoCount != null">total_target_tomato_count = #{totalTargetTomatoCount},</if>
            <if test="status != null">status = #{status},</if>
            <if test="priority != null">priority = #{priority},</if>
            updated_at = #{updatedAt}
        </set>
        WHERE id = #{id}
    </update>

    <!-- 逻辑删除 -->
    <update id="deleteById">
        UPDATE task SET deleted = 1, updated_at = NOW()
        WHERE id = #{id}
    </update>

    <!-- 条件查询 -->
    <select id="selectByQuery" resultMap="BaseResultMap">
        SELECT <include refid="Base_Column_List"/>
        FROM task
        <where>
            deleted = 0
            <if test="userId != null">AND user_id = #{userId}</if>
            <if test="status != null">AND status = #{status}</if>
            <if test="mode != null">AND mode = #{mode}</if>
            <if test="keyword != null and keyword != ''">
                AND name LIKE CONCAT('%', #{keyword}, '%')
            </if>
        </where>
        ORDER BY priority DESC, created_at DESC
    </select>

    <!-- 统计数量 -->
    <select id="countByQuery" resultType="int">
        SELECT COUNT(*)
        FROM task
        <where>
            deleted = 0
            <if test="userId != null">AND user_id = #{userId}</if>
            <if test="status != null">AND status = #{status}</if>
            <if test="mode != null">AND mode = #{mode}</if>
        </where>
    </select>

</mapper>
```
     */
    private Integer calculateDays(LocalDateTime start, LocalDate end) {
        return (int) ChronoUnit.DAYS.between(start.toLocalDate(), end) + 1;
    }

    /**
     * 参数校验
     */
    private void validateTaskRequest(TaskCreateRequest request) {
        // 使用Validator进行校验
        Set<ConstraintViolation<TaskCreateRequest>> violations = validator.validate(request);

        if (!violations.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST);
        }
    }
}
```

#### 6.2.4 统计Service实现

```java
@Service
@Slf4j
public class StatisticsServiceImpl implements StatisticsService {

    @Autowired
    private TaskMapper taskMapper;

    @Autowired
    private TomatoRecordMapper recordMapper;

    /**
     * 获取统计数据
     */
    @Override
    public StatisticsDTO getStatistics(String period, Long userId) {
        // 1. 计算日期范围
        LocalDate[] dateRange = calculateDateRange(period);
        LocalDate startDate = dateRange[0];
        LocalDate endDate = dateRange[1];

        // 2. 查询番茄记录
        List<TomatoRecord> records = recordMapper.selectByDateRange(
            userId, startDate.atStartOfDay(), endDate.plusDays(1).atStartOfDay()
        );

        // 3. 计算核心指标
        Integer completedTomatoes = records.size();
        Long focusMinutes = records.stream()
            .mapToLong(TomatoRecord::getActualMinutes)
            .sum();

        // 4. 查询任务统计
        Integer completedTasks = taskMapper.countByStatusAndDateRange(
            userId, TaskStatus.COMPLETED.getCode(), startDate.atStartOfDay(), endDate.plusDays(1).atStartOfDay()
        );

        Integer totalTasks = taskMapper.countByDateRange(
            userId, startDate.atStartOfDay()
        );

        Integer completionRate = totalTasks > 0 ? (completedTasks * 100 / totalTasks) : 0;

        // 5. 每日数据统计
        List<DailyStatisticsDTO> dailyData = calculateDailyData(records, startDate, endDate);

        // 6. 任务排行
        List<TaskRankingDTO> taskRanking = calculateTaskRanking(records);

        // 7. 构建返回结果
        StatisticsDTO dto = new StatisticsDTO();
        dto.setPeriod(period);
        dto.setStartDate(startDate);
        dto.setEndDate(endDate);
        dto.setCompletedTomatoes(completedTomatoes);
        dto.setFocusMinutes(focusMinutes);
        dto.setCompletedTasks(completedTasks);
        dto.setTotalTasks(totalTasks);
        dto.setCompletionRate(completionRate);
        dto.setDailyData(dailyData);
        dto.setTaskRanking(taskRanking);

        return dto;
    }

    /**
     * 计算日期范围
     */
    private LocalDate[] calculateDateRange(String period) {
        LocalDate today = LocalDate.now();
        LocalDate startDate;

        switch (period) {
            case "today":
                startDate = today;
                break;
            case "week":
                startDate = today.minusDays(today.getDayOfWeek().getValue() - 1);
                break;
            case "month":
                startDate = today.withDayOfMonth(1);
                break;
            default:
                startDate = today;
        }

        return new LocalDate[]{startDate, today};
    }

    /**
     * 计算每日数据
     */
    private List<DailyStatisticsDTO> calculateDailyData(List<TomatoRecord> records, LocalDate start, LocalDate end) {
        Map<LocalDate, List<TomatoRecord>> groupedRecords = records.stream()
            .collect(Collectors.groupingBy(r -> r.getCompletedAt().toLocalDate()));

        List<DailyStatisticsDTO> dailyData = new ArrayList<>();
        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            List<TomatoRecord> dayRecords = groupedRecords.getOrDefault(date, Collections.emptyList());

            DailyStatisticsDTO dto = new DailyStatisticsDTO();
            dto.setDate(date);
            dto.setCompletedTomatoes(dayRecords.size());
            dto.setFocusMinutes(dayRecords.stream().mapToInt(TomatoRecord::getActualMinutes).sum());

            dailyData.add(dto);
        }

        return dailyData;
    }

    /**
     * 计算任务排行
     */
    private List<TaskRankingDTO> calculateTaskRanking(List<TomatoRecord> records) {
        return records.stream()
            .collect(Collectors.groupingBy(
                TomatoRecord::getTaskId,
                Collectors.collectingAndThen(
                    Collectors.toList(),
                    list -> {
                        TaskRankingDTO dto = new TaskRankingDTO();
                        dto.setTaskId(list.get(0).getTaskId());
                        dto.setTaskName(list.get(0).getTaskName());
                        dto.setTaskMode(list.get(0).getTaskMode());
                        dto.setCompletedTomatoes(list.size());
                        return dto;
                    }
                )
            ))
            .values()
            .stream()
            .sorted(Comparator.comparing(TaskRankingDTO::getCompletedTomatoes).reversed())
            .collect(Collectors.toList());
    }
}
```

#### 6.2.5 TomatoRecordMapper示例

**TomatoRecordMapper.java**
```java
package com.tomato.modules.record.mapper;

import com.tomato.modules.record.entity.TomatoRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 番茄记录Mapper接口
 */
@Mapper
public interface TomatoRecordMapper {

    /**
     * 根据ID查询
     */
    TomatoRecord selectById(@Param("id") Long id);

    /**
     * 插入记录
     */
    int insert(TomatoRecord record);

    /**
     * 根据日期范围查询
     */
    List<TomatoRecord> selectByDateRange(
        @Param("userId") Long userId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );

    /**
     * 统计指定时间段的番茄数
     */
    int countByDateRange(
        @Param("userId") Long userId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
}
```

**TomatoRecordMapper.xml**
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.tomato.modules.record.mapper.TomatoRecordMapper">

    <!-- 结果映射 -->
    <resultMap id="BaseResultMap" type="com.tomato.modules.record.entity.TomatoRecord">
        <id column="id" property="id"/>
        <result column="user_id" property="userId"/>
        <result column="task_id" property="taskId"/>
        <result column="task_name" property="taskName"/>
        <result column="task_mode" property="taskMode"/>
        <result column="actual_minutes" property="actualMinutes"/>
        <result column="is_early_end" property="isEarlyEnd"/>
        <result column="completed_at" property="completedAt"/>
        <result column="created_at" property="createdAt"/>
    </resultMap>

    <!-- 基础列 -->
    <sql id="Base_Column_List">
        id, user_id, task_id, task_name, task_mode,
        actual_minutes, is_early_end, completed_at, created_at
    </sql>

    <!-- 根据ID查询 -->
    <select id="selectById" resultMap="BaseResultMap">
        SELECT <include refid="Base_Column_List"/>
        FROM tomato_record
        WHERE id = #{id}
    </select>

    <!-- 插入 -->
    <insert id="insert" parameterType="com.tomato.modules.record.entity.TomatoRecord"
            useGeneratedKeys="true" keyProperty="id">
        INSERT INTO tomato_record (
            user_id, task_id, task_name, task_mode,
            actual_minutes, is_early_end, completed_at, created_at
        ) VALUES (
            #{userId}, #{taskId}, #{taskName}, #{taskMode},
            #{actualMinutes}, #{isEarlyEnd}, #{completedAt}, #{createdAt}
        )
    </insert>

    <!-- 根据日期范围查询 -->
    <select id="selectByDateRange" resultMap="BaseResultMap">
        SELECT <include refid="Base_Column_List"/>
        FROM tomato_record
        WHERE user_id = #{userId}
        AND completed_at >= #{startDate}
        AND completed_at &lt; #{endDate}
        ORDER BY completed_at DESC
    </select>

    <!-- 统计指定时间段的番茄数 -->
    <select id="countByDateRange" resultType="int">
        SELECT COUNT(*)
        FROM tomato_record
        WHERE user_id = #{userId}
        AND completed_at >= #{startDate}
        AND completed_at &lt; #{endDate}
    </select>

</mapper>
```
            default:
                startDate = today;
        }

        return new LocalDate[]{startDate, today};
    }

    /**
     * 计算每日数据
     */
    private List<DailyStatisticsDTO> calculateDailyData(List<TomatoRecord> records, LocalDate start, LocalDate end) {
        Map<LocalDate, List<TomatoRecord>> groupedRecords = records.stream()
            .collect(Collectors.groupingBy(r -> r.getCompletedAt().toLocalDate()));

        List<DailyStatisticsDTO> dailyData = new ArrayList<>();
        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            List<TomatoRecord> dayRecords = groupedRecords.getOrDefault(date, Collections.emptyList());

            DailyStatisticsDTO dto = new DailyStatisticsDTO();
            dto.setDate(date);
            dto.setCompletedTomatoes(dayRecords.size());
            dto.setFocusMinutes(dayRecords.stream().mapToInt(TomatoRecord::getActualMinutes).sum());

            dailyData.add(dto);
        }

        return dailyData;
    }

    /**
     * 计算任务排行
     */
    private List<TaskRankingDTO> calculateTaskRanking(List<TomatoRecord> records) {
        return records.stream()
            .collect(Collectors.groupingBy(
                TomatoRecord::getTaskId,
                Collectors.collectingAndThen(
                    Collectors.toList(),
                    list -> {
                        TaskRankingDTO dto = new TaskRankingDTO();
                        dto.setTaskId(list.get(0).getTaskId());
                        dto.setTaskName(list.get(0).getTaskName());
                        dto.setTaskMode(list.get(0).getTaskMode());
                        dto.setCompletedTomatoes(list.size());
                        return dto;
                    }
                )
            ))
            .values()
            .stream()
            .sorted(Comparator.comparing(TaskRankingDTO::getCompletedTomatoes).reversed())
            .collect(Collectors.toList());
    }
}
```

#### 6.2.6 用户Service实现

```java
package com.tomato.modules.user.service.impl;

import com.tomato.common.exception.BusinessException;
import com.tomato.common.response.ResultCode;
import com.tomato.common.util.JwtUtil;
import com.tomato.modules.user.dto.*;
import com.tomato.modules.user.entity.User;
import com.tomato.modules.user.entity.UserBind;
import com.tomato.modules.user.mapper.UserBindMapper;
import com.tomato.modules.user.mapper.UserMapper;
import com.tomato.modules.user.service.UserService;
import com.tomato.modules.security.service.TokenBlacklistService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 用户服务实现
 */
@Service
@Slf4j
public class UserServiceImpl implements UserService {

    private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private UserBindMapper userBindMapper;

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private TokenBlacklistService tokenBlacklistService;

    @Value("${auth.wechat.appid}")
    private String wechatAppId;

    @Value("${auth.wechat.secret}")
    private String wechatSecret;

    @Value("${auth.huawei.client-id}")
    private String huaweiClientId;

    @Value("${auth.huawei.client-secret}")
    private String huaweiClientSecret;

    /**
     * 微信登录
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public UserLoginDTO wechatLogin(String code) {
        // 1. 调用微信接口获取access_token和用户信息
        WechatTokenResponse tokenResp = getWechatAccessToken(code);
        if (tokenResp == null || tokenResp.getAccess_token() == null) {
            throw new BusinessException(ResultCode.WECHAT_AUTH_FAILED);
        }

        // 2. 获取微信用户信息
        WechatUserInfo wechatUser = getWechatUserInfo(tokenResp.getAccess_token(), tokenResp.getOpenid());
        if (wechatUser == null) {
            throw new BusinessException(ResultCode.WECHAT_AUTH_FAILED);
        }

        // 3. 查找或创建用户
        User user = userMapper.selectByOpenid(wechatUser.getOpenid());
        if (user == null) {
            // 使用unionid查找（如果有）
            if (wechatUser.getUnionid() != null) {
                user = userMapper.selectByUnionid(wechatUser.getUnionid());
            }

            if (user == null) {
                // 创建新用户
                user = new User();
                user.setOpenid(wechatUser.getOpenid());
                user.setUnionid(wechatUser.getUnionid());
                user.setNickname(wechatUser.getNickname());
                user.setAvatar(wechatUser.getHeadimgurl());
                user.setLoginType("wechat");
                user.setStatus(1);
                user.setLastLoginAt(LocalDateTime.now());
                user.setCreatedAt(LocalDateTime.now());
                user.setUpdatedAt(LocalDateTime.now());
                userMapper.insert(user);
                log.info("创建新用户，openid: {}", wechatUser.getOpenid());
            } else {
                // 更新现有用户的openid
                user.setOpenid(wechatUser.getOpenid());
                user.setLastLoginAt(LocalDateTime.now());
                user.setUpdatedAt(LocalDateTime.now());
                userMapper.updateById(user);
            }
        } else {
            // 更新最后登录时间
            user.setLastLoginAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());
            userMapper.updateById(user);
        }

        // 4. 生成JWT Token
        String accessToken = JwtUtil.generateToken(user.getId(), 7 * 24 * 60 * 60); // 7天
        String refreshToken = JwtUtil.generateToken(user.getId(), 30 * 24 * 60 * 60); // 30天

        // 5. 构建返回结果
        UserLoginDTO dto = new UserLoginDTO();
        dto.setAccess_token(accessToken);
        dto.setRefresh_token(refreshToken);
        dto.setExpires_in(7 * 24 * 60 * 60);

        UserDTO userDTO = new UserDTO();
        userDTO.setId(user.getId());
        userDTO.setNickname(user.getNickname());
        userDTO.setAvatar(user.getAvatar());
        userDTO.setLoginType(user.getLoginType());
        dto.setUser(userDTO);

        return dto;
    }

    /**
     * 华为账号登录
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public UserLoginDTO huaweiLogin(String code) {
        // 1. 调用华为接口获取access_token
        HuaweiTokenResponse tokenResp = getHuaweiAccessToken(code);
        if (tokenResp == null || tokenResp.getAccess_token() == null) {
            throw new BusinessException(ResultCode.HUAWEI_AUTH_FAILED);
        }

        // 2. 获取华为用户信息
        HuaweiUserInfo huaweiUser = getHuaweiUserInfo(tokenResp.getAccess_token());
        if (huaweiUser == null) {
            throw new BusinessException(ResultCode.HUAWEI_AUTH_FAILED);
        }

        // 3. 查找或创建用户
        User user = userMapper.selectByHuaweiUid(huaweiUser.getSub());
        if (user == null) {
            // 创建新用户
            user = new User();
            user.setHuaweiUid(huaweiUser.getSub());
            user.setNickname(huaweiUser.getName());
            user.setAvatar(huaweiUser.getPicture());
            user.setLoginType("huawei");
            user.setStatus(1);
            user.setLastLoginAt(LocalDateTime.now());
            user.setCreatedAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());
            userMapper.insert(user);
            log.info("创建新用户，huawei_uid: {}", huaweiUser.getSub());
        } else {
            // 更新最后登录时间
            user.setLastLoginAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());
            userMapper.updateById(user);
        }

        // 4. 生成JWT Token
        String accessToken = JwtUtil.generateToken(user.getId(), 7 * 24 * 60 * 60); // 7天
        String refreshToken = JwtUtil.generateToken(user.getId(), 30 * 24 * 60 * 60); // 30天

        // 5. 构建返回结果
        UserLoginDTO dto = new UserLoginDTO();
        dto.setAccess_token(accessToken);
        dto.setRefresh_token(refreshToken);
        dto.setExpires_in(7 * 24 * 60 * 60);

        UserDTO userDTO = new UserDTO();
        userDTO.setId(user.getId());
        userDTO.setNickname(user.getNickname());
        userDTO.setAvatar(user.getAvatar());
        userDTO.setLoginType(user.getLoginType());
        dto.setUser(userDTO);

        return dto;
    }

    /**
     * Token验证
     */
    @Override
    public UserDTO validateToken(String token) {
        // 1. 检查Token是否在黑名单中
        if (tokenBlacklistService.isBlacklisted(token)) {
            throw new BusinessException(ResultCode.TOKEN_INVALID);
        }

        // 2. 解析Token
        Long userId = JwtUtil.parseToken(token);
        if (userId == null) {
            throw new BusinessException(ResultCode.TOKEN_INVALID);
        }

        // 3. 查询用户
        User user = userMapper.selectById(userId);
        if (user == null || user.getStatus() != 1) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        // 4. 构建返回结果
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setNickname(user.getNickname());
        dto.setAvatar(user.getAvatar());
        dto.setLoginType(user.getLoginType());

        return dto;
    }

    /**
     * Token刷新
     */
    @Override
    public TokenRefreshDTO refreshToken(String refreshToken) {
        // 1. 解析refresh_token
        Long userId = JwtUtil.parseToken(refreshToken);
        if (userId == null) {
            throw new BusinessException(ResultCode.TOKEN_INVALID);
        }

        // 2. 查询用户
        User user = userMapper.selectById(userId);
        if (user == null || user.getStatus() != 1) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        // 3. 生成新的access_token
        String accessToken = JwtUtil.generateToken(user.getId(), 7 * 24 * 60 * 60);

        // 4. 构建返回结果
        TokenRefreshDTO dto = new TokenRefreshDTO();
        dto.setAccess_token(accessToken);
        dto.setExpires_in(7 * 24 * 60 * 60);

        return dto;
    }

    /**
     * 登出
     */
    @Override
    public void logout(String token) {
        // 将Token加入黑名单
        tokenBlacklistService.addToBlacklist(token, JwtUtil.getExpiration(token));
    }

    /**
     * 获取微信access_token
     */
    private WechatTokenResponse getWechatAccessToken(String code) {
        try {
            String url = "https://api.weixin.qq.com/sns/oauth2/access_token"
                + "?appid=" + wechatAppId
                + "&secret=" + wechatSecret
                + "&code=" + code
                + "&grant_type=authorization_code";

            return restTemplate.getForObject(url, WechatTokenResponse.class);
        } catch (Exception e) {
            log.error("获取微信access_token失败", e);
            return null;
        }
    }

    /**
     * 获取微信用户信息
     */
    private WechatUserInfo getWechatUserInfo(String accessToken, String openid) {
        try {
            String url = "https://api.weixin.qq.com/sns/userinfo"
                + "?access_token=" + accessToken
                + "&openid=" + openid;

            return restTemplate.getForObject(url, WechatUserInfo.class);
        } catch (Exception e) {
            log.error("获取微信用户信息失败", e);
            return null;
        }
    }

    /**
     * 获取华为access_token
     */
    private HuaweiTokenResponse getHuaweiAccessToken(String code) {
        try {
            String url = "https://oauth-login.cloud.huawei.com/oauth2/v3/token"
                + "?grant_type=authorization_code"
                + "&code=" + code
                + "&client_id=" + huaweiClientId
                + "&client_secret=" + huaweiClientSecret;

            return restTemplate.postForObject(url, null, HuaweiTokenResponse.class);
        } catch (Exception e) {
            log.error("获取华为access_token失败", e);
            return null;
        }
    }

    /**
     * 获取华为用户信息
     */
    private HuaweiUserInfo getHuaweiUserInfo(String accessToken) {
        try {
            String url = "https://account.cloud.huawei.com/rest/v1/userInfo"
                + "?access_token=" + accessToken;

            return restTemplate.getForObject(url, HuaweiUserInfo.class);
        } catch (Exception e) {
            log.error("获取华为用户信息失败", e);
            return null;
        }
    }
}
```

#### 6.2.7 用户Controller实现

```java
package com.tomato.modules.user.controller;

import com.tomato.common.response.Result;
import com.tomato.modules.user.dto.*;
import com.tomato.modules.user.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/**
 * 用户认证控制器
 */
@RestController
@RequestMapping("/v1/auth")
@Slf4j
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private UserService userService;

    /**
     * 微信登录
     */
    @PostMapping("/wechat/login")
    public Result<UserLoginDTO> wechatLogin(@RequestBody WechatLoginRequest request) {
        log.info("微信登录请求，code: {}", request.getCode());
        UserLoginDTO dto = userService.wechatLogin(request.getCode());
        return Result.success(dto);
    }

    /**
     * 华为账号登录
     */
    @PostMapping("/huawei/login")
    public Result<UserLoginDTO> huaweiLogin(@RequestBody HuaweiLoginRequest request) {
        log.info("华为账号登录请求，code: {}", request.getCode());
        UserLoginDTO dto = userService.huaweiLogin(request.getCode());
        return Result.success(dto);
    }

    /**
     * Token验证
     */
    @GetMapping("/validate")
    public Result<UserDTO> validateToken(HttpServletRequest request) {
        String token = extractToken(request);
        log.info("Token验证请求");
        UserDTO dto = userService.validateToken(token);
        return Result.success(dto);
    }

    /**
     * Token刷新
     */
    @PostMapping("/refresh")
    public Result<TokenRefreshDTO> refreshToken(@RequestBody TokenRefreshRequest request) {
        log.info("Token刷新请求");
        TokenRefreshDTO dto = userService.refreshToken(request.getRefresh_token());
        return Result.success(dto);
    }

    /**
     * 登出
     */
    @PostMapping("/logout")
    public Result<Void> logout(HttpServletRequest request) {
        String token = extractToken(request);
        log.info("用户登出");
        userService.logout(token);
        return Result.success();
    }

    /**
     * 从请求头中提取Token
     */
    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

---

## 7. 部署方案

### 7.1 数据库设计

#### 7.1.1 用户表（user）

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

#### 7.1.2 用户绑定表（user_bind）

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

#### 7.1.3 Token黑名单表（token_blacklist）

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

#### 7.1.4 任务表（task）

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

#### 7.1.5 番茄记录表（tomato_record）

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

### 7.2 应用配置

#### 7.2.1 application.yml

```yaml
# 服务器配置
server:
  port: 8080
  servlet:
    context-path: /api

# 数据源配置
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/tomato_clock?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: root
    password: ${DB_PASSWORD:}
    hikari:
      minimum-idle: 5
      maximum-pool-size: 20
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000

# MyBatis配置
mybatis:
  type-aliases-package: com.tomato.modules.**.entity
  mapper-locations: classpath:mapper/*.xml
  configuration:
    map-underscore-to-camel-case: true  # 驼峰命名转换
    log-impl: org.apache.ibatis.logging.slf4j.Slf4jImpl
    cache-enabled: true
    lazy-loading-enabled: true
    aggressive-lazy-loading: false

# 日志配置
logging:
  level:
    com.tomato: debug
    org.springframework: info
    org.mybatis: debug
  pattern:
    console: '%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n'

# JWT配置
jwt:
  secret: ${JWT_SECRET:your-secret-key}
  expiration: 604800000  # 7天

# 认证配置
auth:
  # 微信开放平台配置
  wechat:
    app-id: ${WECHAT_APPID:}
    secret: ${WECHAT_SECRET:}
  # 华为开发者联盟配置
  huawei:
    client-id: ${HUAWEI_CLIENT_ID:}
    client-secret: ${HUAWEI_CLIENT_SECRET:}
```

### 7.3 部署架构

```
┌─────────────────────────────────────────────────────────┐
│                       用户设备                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │         鸿蒙客户端 (TomatoClock)               │    │
│  │  - 本地Preferences存储                          │    │
│  │  - 离线可用                                     │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTPS
┌─────────────────────────────────────────────────────────┐
│                    Nginx 反向代理                       │
│                    (负载均衡 + SSL)                      │
└─────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Spring Boot    │ │  Spring Boot    │ │  Spring Boot    │
│  实例1          │ │  实例2          │ │  实例3          │
│  (8080)         │ │  (8080)         │ │  (8080)         │
└─────────────────┘ └─────────────────┘ └─────────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────┐
│              MySQL 8.0 主从集群                         │
│  ┌─────────────────┐        ┌─────────────────┐        │
│  │  Master         │ ←───→  │  Slave          │        │
│  │  (读写)         │  复制  │  (只读)         │        │
│  └─────────────────┘        └─────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

---

## 附录

### A. 相关文档

- [产品概述](../functional/overview.md)
- [用户认证功能](../functional/user-auth.md)
- [任务模式设计](../functional/task-modes.md)
- [任务管理](../functional/task-management.md)
- [计时器功能](../functional/timer-feature.md)
- [数据模型](./data-model.md)
- [变更记录](../changelog.md)

### B. 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-03-19 | 初始版本，定义完整技术方案 |
| v1.1 | 2026-03-19 | 新增用户认证功能，支持微信和华为账号登录 |

### C. 决策记录

| 决策 | 说明 |
|------|------|
| 前后端分离 | MVP阶段前端独立运行，后端负责数据同步 |
| 本地优先 | 使用Preferences API本地存储，核心功能离线可用 |
| 状态简化 | 移除"已归档"状态，简化状态机 |
| 历史集成 | 历史记录集成到统计页面，减少Tab数量 |
| 后台计时 | MVP支持后台计时，时间到后发送通知 |
| 第三方登录 | MVP支持微信和华为账号登录，无需注册门槛 |
| JWT认证 | 使用JWT进行Token认证，access_token有效期7天，refresh_token有效期30天 |
| 统计延期 | 统计功能延期到v1.1，聚焦核心计时和任务管理功能 |

---

**文档状态：** 待审核
**审核人：** 技术负责人
**更新日期：** 2026-03-19
