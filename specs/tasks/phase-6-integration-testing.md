# Phase 6: Integration Testing - 集成测试

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：规划中
>
> **目标**: 端到端测试和集成测试。
>
> **依赖**: Phase 2, Phase 3, Phase 4, Phase 5 完成

---

## Phase 6 任务列表

### 前端集成测试

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P6-001 | 编写登录流程集成测试 | TST | pending | P3-001, P2-004 | 测试完整登录流程 |
| P6-002 | 编写任务管理集成测试 | TST | pending | P3-003, P3-007 | 测试任务CRUD流程 |
| P6-003 | 编写计时器流程集成测试 | TST | pending | P3-005, P2-008 | 测试计时器完整流程 |

---

### 后端集成测试

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P6-004 | 编写API集成测试 | TST | pending | P4-xxx | 测试所有API接口 |
| P6-005 | 编写数据库集成测试 | TST | pending | P5-xxx | 测试数据库操作 |

---

### 端到端测试

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P6-006 | 编写用户注册到创建任务E2E测试 | TST | pending | P6-001, P6-002, P6-004 | 端到端测试 |
| P6-007 | 编写完整番茄钟流程E2E测试 | TST | pending | P6-003, P6-006 | 端到端测试 |

---

### 性能测试

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P6-008 | 编写API性能测试 [P] | TST | pending | P6-004 | 测试接口响应时间 |
| P6-009 | 编写数据库查询性能测试 [P] | TST | pending | P6-005 | 测试查询效率 |

---

## 详细任务说明

### P6-001: 编写登录流程集成测试

**文件**: `entry/src/main/ets/test/integration/LoginFlow.test.ets`

**描述**: 测试完整登录流程

**测试用例**:
1. `test_auto_login_with_valid_token` - 有效Token自动登录
2. `test_auto_login_with_expired_token` - 过期Token刷新
3. `test_wechat_login_flow` - 微信登录完整流程
4. `test_huawei_login_flow` - 华为登录完整流程
5. `test_logout_flow` - 登出流程

**验收标准**:
- [ ] 覆盖所有登录场景
- [ ] Mock外部依赖
- [ ] 验证页面跳转

---

### P6-002: 编写任务管理集成测试

**文件**: `entry/src/main/ets/test/integration/TaskManagement.test.ets`

**描述**: 测试任务CRUD流程

**测试用例**:
1. `test_create_todo_task_flow` - 创建待办任务流程
2. `test_create_plan_task_flow` - 创建计划任务流程
3. `test_update_task_flow` - 更新任务流程
4. `test_delete_task_flow` - 删除任务流程
5. `test_complete_tomato_flow` - 完成番茄流程
6. `test_task_list_filtering` - 任务列表筛选

**验收标准**:
- [ ] 覆盖所有CRUD操作
- [ ] 验证数据持久化
- [ ] 验证UI更新

---

### P6-003: 编写计时器流程集成测试

**文件**: `entry/src/main/ets/test/integration/TimerFlow.test.ets`

**描述**: 测试计时器完整流程

**测试用例**:
1. `test_working_to_resting_flow` - 专注到休息流程
2. `test_pause_resume_flow` - 暂停继续流程
3. `test_complete_tomato_early` - 提前完成番茄
4. `test_complete_tomato_full` - 完整完成番茄
5. `test_timer_state_persistence` - 计时器状态持久化
6. `test_timer_state_restoration` - 计时器状态恢复

**验收标准**:
- [ ] 覆盖所有计时器操作
- [ ] 验证状态持久化
- [ ] 验证任务数据更新

---

### P6-004: 编写API集成测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/integration/ApiIntegrationTest.java`

**描述**: 测试所有API接口

**测试用例**:
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
public class ApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserService userService;

    @Test
    public void test_wechat_login_api() throws Exception {
        // 测试微信登录API
    }

    @Test
    public void test_create_task_api() throws Exception {
        // 测试创建任务API
    }

    @Test
    public void test_complete_tomato_api() throws Exception {
        // 测试完成番茄API
    }

    @Test
    public void test_get_statistics_api() throws Exception {
        // 测试获取统计API
    }
}
```

**验收标准**:
- [ ] 使用 @SpringBootTest
- [ ] 使用 MockMvc
- [ ] 覆盖所有API端点
- [ ] 验证请求/响应格式

---

### P6-005: 编写数据库集成测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/integration/DatabaseIntegrationTest.java`

**描述**: 测试数据库操作

**测试用例**:
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
public class DatabaseIntegrationTest {

    @Autowired
    private TaskMapper taskMapper;

    @Test
    public void test_insert_and_select_task() {
        // 测试插入和查询
    }

    @Test
    public void test_update_task() {
        // 测试更新
    }

    @Test
    public void test_transaction_rollback() {
        // 测试事务回滚
    }
}
```

**验收标准**:
- [ ] 使用真实数据库
- [ ] 测试事务正确性
- [ ] 测试数据一致性

---

### P6-006: 编写用户注册到创建任务E2E测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/e2e/UserCreateTaskE2ETest.java`

**描述**: 端到端测试：用户注册到创建任务

**测试场景**:
1. 用户通过微信登录
2. 系统创建用户记录
3. 用户创建待办任务
4. 用户创建计划任务
5. 验证数据正确保存

**验收标准**:
- [ ] 覆盖完整业务流程
- [ ] 验证各层数据一致性
- [ ] 验证API响应正确

---

### P6-007: 编写完整番茄钟流程E2E测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/e2e/CompleteTomatoE2ETest.java`

**描述**: 端到端测试：完整番茄钟流程

**测试场景**:
1. 用户登录
2. 创建任务
3. 开始专注模式
4. 完成番茄
5. 进入休息模式
6. 完成休息
7. 验证任务计数更新
8. 验证番茄记录创建

**验收标准**:
- [ ] 覆盖完整番茄钟流程
- [ ] 验证状态转换正确
- [ ] 验证数据统计正确

---

### P6-008: 编写API性能测试 [P]

**文件**: `tomato-clock-backend/src/test/java/com/tomato/performance/ApiPerformanceTest.java`

**描述**: 测试API接口响应时间

**测试用例**:
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
public class ApiPerformanceTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void test_get_tasks_response_time() {
        long startTime = System.currentTimeMillis();
        // 执行请求
        long duration = System.currentTimeMillis() - startTime;
        assertThat(duration).isLessThan(1000); // 1秒内响应
    }

    @Test
    public void test_concurrent_requests() throws InterruptedException {
        int threadCount = 100;
        CountDownLatch latch = new CountDownLatch(threadCount);
        // 并发测试
    }
}
```

**验收标准**:
- [ ] API响应时间 < 1s
- [ ] 支持100并发请求
- [ ] 无内存泄漏

---

### P6-009: 编写数据库查询性能测试 [P]

**文件**: `tomato-clock-backend/src/test/java/com/tomato/performance/DatabasePerformanceTest.java`

**描述**: 测试数据库查询效率

**测试用例**:
1. `test_select_tasks_with_1000_records` - 测试1000条记录查询
2. `test_select_statistics_with_large_data` - 测试大数据量统计
3. `test_index_effectiveness` - 测试索引有效性

**验收标准**:
- [ ] 1000条记录查询 < 100ms
- [ ] 统计查询 < 500ms
- [ ] 索引正确使用

---

## 阶段完成标准

- [ ] 所有集成测试通过
- [ ] 测试覆盖率 > 80%
- [ ] 性能测试达标
- [ ] 无已知Bug

---

**相关文档：**
- [开发规范 - 测试](../../constitution.md#第九条-代码审查标准)
- [技术实现方案 - 2.3 测试策略](../technical/plan.md#23-测试策略)
