# 任务汇总表

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：规划中
>
> **说明**: 本文件汇总所有阶段的任务，方便查看整体进度。

---

## 任务统计

| 阶段 | 任务数 | 测试任务 | 实现任务 | 配置任务 | 可并行 |
|------|--------|----------|----------|----------|--------|
| Phase 1: Foundation | 24 | 0 | 23 | 0 | 6 |
| Phase 2: Frontend Services | 14 | 7 | 7 | 0 | 2 |
| Phase 3: Frontend Pages | 11 | 0 | 10 | 1 | 3 |
| Phase 4: Backend Services | 32 | 14 | 15 | 3 | 9 |
| Phase 5: Backend Database | 10 | 0 | 8 | 2 | 2 |
| Phase 6: Integration Testing | 9 | 9 | 0 | 0 | 2 |
| **总计** | **100** | **30** | **63** | **7** | **24** |

---

## 全部任务列表

### Phase 1: Foundation - 数据结构定义 (依赖: 无)

| ID | 任务名称 | 类型 | 并行 |
|----|----------|------|------|
| P1-001 | 创建 LoginType 枚举 | IMPL | - |
| P1-002 | 创建 User 数据模型 | IMPL | - |
| P1-003 | 创建 AuthState 数据模型 | IMPL | - |
| P1-004 | 创建 TaskMode 枚举 | IMPL | - |
| P1-005 | 创建 TaskStatus 枚举 | IMPL | - |
| P1-006 | 创建 TimerMode 枚举 | IMPL | - |
| P1-007 | 创建 ToDoListClass 数据模型 | IMPL | - |
| P1-008 | 创建 TimerViewModel 数据模型 | IMPL | - |
| P1-009 | 创建统计相关数据模型 | IMPL | - |
| P1-010 | 创建 User 实体类 | IMPL | - |
| P1-011 | 创建 Task 实体类 | IMPL | - |
| P1-012 | 创建 TomatoRecord 实体类 | IMPL | - |
| P1-013 | 创建 Result 统一响应类 | IMPL | - |
| P1-014 | 创建 ResultCode 响应码枚举 | IMPL | - |
| P1-015 | 创建 TaskDTO | IMPL | - |
| P1-016 | 创建 TaskCreateRequest | IMPL | - |
| P1-017 | 创建 TaskUpdateRequest | IMPL | - |
| P1-018 | 创建 StatisticsDTO | IMPL | - |
| P1-019 | 创建 TaskConstant 常量类 [P] | IMPL | [P] |
| P1-020 | 创建 DateUtils 工具类 [P] | IMPL | [P] |
| P1-021 | 创建 Logger 工具类 [P] | IMPL | [P] |
| P1-022 | 创建 ToastUtil 工具类 [P] | IMPL | [P] |
| P1-023 | 创建 GlobalNavStack [P] | IMPL | [P] |
| P1-024 | 创建 JwtUtil 工具类 [P] | IMPL | [P] |

---

### Phase 2: Frontend Services - 前端服务层 (依赖: Phase 1)

| ID | 任务名称 | 类型 | 并行 |
|----|----------|------|------|
| P2-001 | 编写 StorageService 单元测试 | TST | - |
| P2-002 | 实现 StorageService | IMPL | - |
| P2-003 | 编写 AuthService 单元测试 | TST | - |
| P2-004 | 实现 AuthService | IMPL | - |
| P2-005 | 编写 TaskService 单元测试 | TST | - |
| P2-006 | 实现 TaskService | IMPL | - |
| P2-007 | 编写 TimerService 单元测试 | TST | - |
| P2-008 | 实现 TimerService | IMPL | - |
| P2-009 | 编写 StatisticsService 单元测试 | TST | - |
| P2-010 | 实现 StatisticsService | IMPL | - |
| P2-011 | 编写 ApiClient 单元测试 | TST | [P] |
| P2-012 | 实现 ApiClient | IMPL | [P] |
| P2-013 | 编写 TaskValidator 单元测试 | TST | - |
| P2-014 | 实现 TaskValidator | IMPL | - |

---

### Phase 3: Frontend Pages - 前端页面组件 (依赖: Phase 1, Phase 2)

| ID | 任务名称 | 类型 | 并行 |
|----|----------|------|------|
| P3-001 | 实现 Index 登录页面 | IMPL | - |
| P3-002 | 实现 MainPage 主页面 | IMPL | - |
| P3-003 | 实现 ToDoList 视图组件 | IMPL | - |
| P3-004 | 实现 TaskCard 组件 [P] | IMPL | [P] |
| P3-005 | 实现 CountDownTimer 页面 | IMPL | - |
| P3-006 | 实现 TimerProgress 组件 [P] | IMPL | [P] |
| P3-007 | 实现 TaskEdit 页面 | IMPL | - |
| P3-008 | 实现 Profile 视图组件 | IMPL | - |
| P3-009 | 实现 Statistics 视图组件 | IMPL | - |
| P3-010 | 实现 StatCard 组件 [P] | IMPL | [P] |
| P3-011 | 配置 route_map.json | CONF | - |

---

### Phase 4: Backend Services - 后端服务层 (依赖: Phase 1)

| ID | 任务名称 | 类型 | 并行 |
|----|----------|------|------|
| P4-001 | 编写 GlobalExceptionHandler 单元测试 | TST | - |
| P4-002 | 实现 GlobalExceptionHandler | IMPL | - |
| P4-003 | 编写 BusinessException 类 [P] | IMPL | [P] |
| P4-004 | 实现 JwtUtil 单元测试 [P] | TST | [P] |
| P4-005 | 实现 JwtUtil [P] | IMPL | [P] |
| P4-006 | 编写 UserService 单元测试 | TST | - |
| P4-007 | 实现 UserService | IMPL | - |
| P4-008 | 编写 UserMapper 单元测试 | TST | - |
| P4-009 | 实现 UserMapper | IMPL | - |
| P4-010 | 编写 UserController 单元测试 | TST | - |
| P4-011 | 实现 UserController | IMPL | - |
| P4-012 | 编写 TaskService 单元测试 | TST | - |
| P4-013 | 实现 TaskService | IMPL | - |
| P4-014 | 编写 TaskMapper 单元测试 | TST | - |
| P4-015 | 实现 TaskMapper | IMPL | - |
| P4-016 | 编写 TaskController 单元测试 | TST | - |
| P4-017 | 实现 TaskController | IMPL | - |
| P4-018 | 编写 RecordService 单元测试 | TST | - |
| P4-019 | 实现 RecordService | IMPL | - |
| P4-020 | 编写 RecordMapper 单元测试 | TST | - |
| P4-021 | 实现 RecordMapper | IMPL | - |
| P4-022 | 编写 StatisticsService 单元测试 | TST | - |
| P4-023 | 实现 StatisticsService | IMPL | - |
| P4-024 | 编写 StatisticsController 单元测试 | TST | - |
| P4-025 | 实现 StatisticsController | IMPL | - |
| P4-026 | 编写 AuthInterceptor 单元测试 [P] | TST | [P] |
| P4-027 | 实现 AuthInterceptor [P] | IMPL | [P] |
| P4-028 | 编写 JwtFilter 单元测试 [P] | TST | [P] |
| P4-029 | 实现 JwtFilter [P] | IMPL | [P] |
| P4-030 | 实现 MyBatisConfig [P] | CONF | [P] |
| P4-031 | 实现 WebConfig [P] | CONF | [P] |
| P4-032 | 实现 AsyncConfig [P] | CONF | [P] |

---

### Phase 5: Backend Database - 后端数据层 (依赖: Phase 1)

| ID | 任务名称 | 类型 | 并行 |
|----|----------|------|------|
| P5-001 | 创建 user 表 SQL | IMPL | - |
| P5-002 | 创建 task 表 SQL | IMPL | - |
| P5-003 | 创建 tomato_record 表 SQL | IMPL | - |
| P5-004 | 创建 user_bind 表 SQL [P] | IMPL | [P] |
| P5-005 | 创建 token_blacklist 表 SQL [P] | IMPL | [P] |
| P5-006 | 创建 UserMapper.xml | IMPL | - |
| P5-007 | 创建 TaskMapper.xml | IMPL | - |
| P5-008 | 创建 RecordMapper.xml | IMPL | - |
| P5-009 | 创建数据库初始化脚本 | IMPL | - |
| P5-010 | 创建测试数据脚本 | IMPL | - |

---

### Phase 6: Integration Testing - 集成测试 (依赖: Phase 2~5)

| ID | 任务名称 | 类型 | 并行 |
|----|----------|------|------|
| P6-001 | 编写登录流程集成测试 | TST | - |
| P6-002 | 编写任务管理集成测试 | TST | - |
| P6-003 | 编写计时器流程集成测试 | TST | - |
| P6-004 | 编写API集成测试 | TST | - |
| P6-005 | 编写数据库集成测试 | TST | - |
| P6-006 | 编写用户注册到创建任务E2E测试 | TST | - |
| P6-007 | 编写完整番茄钟流程E2E测试 | TST | - |
| P6-008 | 编写API性能测试 [P] | TST | [P] |
| P6-009 | 编写数据库查询性能测试 [P] | TST | [P] |

---

## 依赖关系图

```
Phase 1 (Foundation)
    │
    ├─────────────┬─────────────┐
    ▼             ▼             ▼
Phase 2       Phase 3       Phase 4       Phase 5
(Frontend)   (Pages)      (Backend)    (Database)
    │             │             │             │
    └─────────────┴─────────────┴─────────────┘
                        ▼
                  Phase 6
              (Integration)
```

---

## 并行开发策略

### 前后端并行开发
- **Phase 2** (前端服务) 和 **Phase 4** (后端服务) 可以并行开发
- 通过接口契约协作：
  - 前端 Mock API 响应
  - 后端提供 Swagger 文档
  - 定期同步接口变更

### 同阶段并行开发
标记 **[P]** 的任务可以并行执行：
- Phase 1: P1-019 ~ P1-024 (6个任务)
- Phase 2: P2-011 ~ P2-012 (2个任务)
- Phase 3: P3-004, P3-006, P3-010 (3个任务)
- Phase 4: P4-003 ~ P4-005, P4-026 ~ P4-032 (9个任务)
- Phase 5: P5-004 ~ P5-005 (2个任务)
- Phase 6: P6-008 ~ P6-009 (2个任务)

---

## TDD 顺序要求

根据测试先行原则，每个实现任务必须先完成对应的测试任务：

| 实现任务 | 必须先完成的测试任务 |
|----------|---------------------|
| P2-002 | P2-001 |
| P2-004 | P2-003 |
| P2-006 | P2-005 |
| P2-008 | P2-007 |
| P2-010 | P2-009 |
| P2-012 | P2-011 |
| P2-014 | P2-013 |
| P4-002 | P4-001 |
| P4-005 | P4-004 |
| P4-007 | P4-006 |
| P4-009 | P4-008 |
| P4-011 | P4-010 |
| P4-013 | P4-012 |
| P4-015 | P4-014 |
| P4-017 | P4-016 |
| P4-019 | P4-018 |
| P4-021 | P4-020 |
| P4-023 | P4-022 |
| P4-025 | P4-024 |
| P4-027 | P4-026 |
| P4-029 | P4-028 |

---

## 任务状态说明

- **pending**: 待开始
- **in_progress**: 进行中
- **completed**: 已完成
- **blocked**: 已阻塞
- **skipped**: 已跳过

---

## 快速查找

### 按类型查找
- **所有测试任务**: P2-001, P2-003, P2-005, P2-007, P2-009, P2-011, P2-013, P4-001, P4-004, P4-006, P4-008, P4-010, P4-012, P4-014, P4-016, P4-018, P4-020, P4-022, P4-024, P4-026, P4-028, P6-001~P6-009
- **所有实现任务**: P1-xxx, P2-002, P2-004, P2-006, P2-008, P2-010, P2-012, P2-014, P3-xxx, P4-002, P4-003, P4-005, P4-007, P4-009, P4-011, P4-013, P4-015, P4-017, P4-019, P4-021, P4-023, P4-025, P4-027, P4-029, P5-xxx
- **所有配置任务**: P3-011, P4-030, P4-031, P4-032

### 按模块查找
- **用户认证**: P1-001~P1-003, P1-010, P1-013~P1-014, P2-003~P2-004, P3-001, P3-008, P4-003~P4-011, P4-026~P4-029, P5-001, P5-004~P5-005, P6-001, P6-004
- **任务管理**: P1-004~P1-005, P1-007, P1-011, P1-015~P1-017, P2-005~P2-006, P2-013~P2-014, P3-002~P3-004, P3-007, P4-012~P4-017, P5-002, P5-006~P5-007, P6-002, P6-006
- **计时器**: P1-006, P1-008, P2-007~P2-008, P3-005~P3-006, P6-003, P6-007
- **统计**: P1-009, P1-018, P2-009~P2-010, P3-009~P3-010, P4-022~P4-025, P6-009
- **番茄记录**: P1-012, P4-018~P4-021, P5-003, P5-008

---

**相关文档：**
- [README](./README.md)
- [Phase 1: Foundation](./phase-1-foundation.md)
- [Phase 2: Frontend Services](./phase-2-frontend-services.md)
- [Phase 3: Frontend Pages](./phase-3-frontend-pages.md)
- [Phase 4: Backend Services](./phase-4-backend-services.md)
- [Phase 5: Backend Database](./phase-5-backend-database.md)
- [Phase 6: Integration Testing](./phase-6-integration-testing.md)
