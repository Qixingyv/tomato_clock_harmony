# Phase 4: Backend Services - 后端服务层

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：规划中
>
> **目标**: 实现后端业务逻辑和API接口，使用 TDD 开发。
>
> **依赖**: Phase 1 完成
>
> **并行说明**: Phase 4 可与 Phase 2 并行开发，前后端通过接口契约协作

---

## Phase 4 任务列表

### 通用模块

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P4-001 | 编写 GlobalExceptionHandler 单元测试 | TST | pending | P1-013, P1-014 | 测试全局异常处理 |
| P4-002 | 实现 GlobalExceptionHandler | IMPL | pending | P4-001 | 全局异常处理器 |
| P4-003 | 编写 BusinessException 类 [P] | IMPL | pending | - | 业务异常类 |
| P4-004 | 实现 JwtUtil 单元测试 [P] | TST | pending | P1-024 | 测试JWT工具 |
| P4-005 | 实现 JwtUtil [P] | IMPL | pending | P4-004 | JWT工具类 |

---

### 用户认证模块

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P4-006 | 编写 UserService 单元测试 | TST | pending | P1-010 | 测试用户服务 |
| P4-007 | 实现 UserService | IMPL | pending | P4-006 | 用户服务实现 |
| P4-008 | 编写 UserMapper 单元测试 | TST | pending | P4-007 | 测试用户Mapper |
| P4-009 | 实现 UserMapper | IMPL | pending | P4-008 | 用户Mapper实现 |
| P4-010 | 编写 UserController 单元测试 | TST | pending | P4-007 | 测试用户控制器 |
| P4-011 | 实现 UserController | IMPL | pending | P4-010 | 用户控制器实现 |

---

### 任务模块

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P4-012 | 编写 TaskService 单元测试 | TST | pending | P1-011 | 测试任务服务 |
| P4-013 | 实现 TaskService | IMPL | pending | P4-012 | 任务服务实现 |
| P4-014 | 编写 TaskMapper 单元测试 | TST | pending | P4-013 | 测试任务Mapper |
| P4-015 | 实现 TaskMapper | IMPL | pending | P4-014 | 任务Mapper实现 |
| P4-016 | 编写 TaskController 单元测试 | TST | pending | P4-013 | 测试任务控制器 |
| P4-017 | 实现 TaskController | IMPL | pending | P4-016 | 任务控制器实现 |

---

### 番茄记录模块

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P4-018 | 编写 RecordService 单元测试 | TST | pending | P1-012 | 测试记录服务 |
| P4-019 | 实现 RecordService | IMPL | pending | P4-018 | 记录服务实现 |
| P4-020 | 编写 RecordMapper 单元测试 | TST | pending | P4-019 | 测试记录Mapper |
| P4-021 | 实现 RecordMapper | IMPL | pending | P4-020 | 记录Mapper实现 |

---

### 统计模块

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P4-022 | 编写 StatisticsService 单元测试 | TST | pending | P4-013, P4-019 | 测试统计服务 |
| P4-023 | 实现 StatisticsService | IMPL | pending | P4-022 | 统计服务实现 |
| P4-024 | 编写 StatisticsController 单元测试 | TST | pending | P4-023 | 测试统计控制器 |
| P4-025 | 实现 StatisticsController | IMPL | pending | P4-024 | 统计控制器实现 |

---

### 安全模块

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P4-026 | 编写 AuthInterceptor 单元测试 [P] | TST | pending | P4-005 | 测试认证拦截器 |
| P4-027 | 实现 AuthInterceptor [P] | IMPL | pending | P4-026 | 认证拦截器实现 |
| P4-028 | 编写 JwtFilter 单元测试 [P] | TST | pending | P4-005 | 测试JWT过滤器 |
| P4-029 | 实现 JwtFilter [P] | IMPL | pending | P4-028 | JWT过滤器实现 |

---

### 配置类

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P4-030 | 实现 MyBatisConfig [P] | CONF | pending | - | MyBatis配置 |
| P4-031 | 实现 WebConfig [P] | CONF | pending | - | Web配置（CORS） |
| P4-032 | 实现 AsyncConfig [P] | CONF | pending | - | 异步任务配置 |

---

## 详细任务说明

### P4-001: 编写 GlobalExceptionHandler 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/common/exception/GlobalExceptionHandlerTest.java`

**描述**: 测试全局异常处理器

**测试用例**:
1. `test_handleBusinessException` - 测试业务异常处理
2. `test_handleException` - 测试系统异常处理
3. `test_handleMethodArgumentNotValidException` - 测试参数校验异常
4. `test_handleHttpRequestMethodNotSupported` - 测试方法不支持异常
5. `test_response_structure` - 测试响应结构

**验收标准**:
- [ ] 覆盖所有异常类型
- [ ] 验证响应结构正确
- [ ] 验证HTTP状态码正确

---

### P4-002: 实现 GlobalExceptionHandler

**文件**: `tomato-clock-backend/src/main/java/com/tomato/common/exception/GlobalExceptionHandler.java`

**描述**: 全局异常处理器

**实现内容**:
```java
@RestControllerAdvice
@Slf4j
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

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Result<?>> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getAllErrors().stream()
            .map(ObjectError::getDefaultMessage)
            .collect(Collectors.joining(", "));
        return ResponseEntity.badRequest()
            .body(Result.error(400, message));
    }
}
```

**验收标准**:
- [ ] 使用 @RestControllerAdvice
- [ ] 处理业务异常
- [ ] 处理系统异常
- [ ] 处理参数校验异常
- [ ] 记录日志

---

### P4-003: 编写 BusinessException 类 [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/common/exception/BusinessException.java`

**描述**: 业务异常类

**实现内容**:
```java
@Getter
@AllArgsConstructor
public class BusinessException extends RuntimeException {
    private final Integer code;
    private final String message;

    public BusinessException(ResultCode resultCode) {
        this.code = resultCode.getCode();
        this.message = resultCode.getMessage();
    }

    public BusinessException(String message) {
        this.code = 400;
        this.message = message;
    }
}
```

**验收标准**:
- [ ] 继承 RuntimeException
- [ ] 包含错误码和消息
- [ ] 支持ResultCode枚举

---

### P4-004: 实现 JwtUtil 单元测试 [P]

**文件**: `tomato-clock-backend/src/test/java/com/tomato/common/util/JwtUtilTest.java`

**描述**: 测试JWT工具类

**测试用例**:
1. `test_generateToken` - 测试生成Token
2. `test_parseToken_valid` - 测试解析有效Token
3. `test_parseToken_invalid` - 测试解析无效Token
4. `test_getUserIdFromToken` - 测试获取用户ID
5. `test_isTokenExpired` - 测试判断Token过期
6. `test_token_expiration` - 测试Token过期时间

**验收标准**:
- [ ] 覆盖所有方法
- [ ] 测试过期场景

---

### P4-005: 实现 JwtUtil [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/common/util/JwtUtil.java`

**描述**: JWT工具类

**实现内容**: 见 Phase 1 任务 P1-024

**验收标准**:
- [ ] 使用 io.jsonwebtoken 库
- [ ] 支持 RS256 算法
- [ ] Token包含用户ID和过期时间
- [ ] 正确判断Token是否过期

---

### P4-006: 编写 UserService 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/user/service/UserServiceTest.java`

**描述**: 测试用户服务

**测试用例**:
1. `test_wechatLogin_newUser` - 测试微信登录新用户
2. `test_wechatLogin_existingUser` - 测试微信登录老用户
3. `test_huaweiLogin_newUser` - 测试华为登录新用户
4. `test_huaweiLogin_existingUser` - 测试华为登录老用户
5. `test_getUserById` - 测试根据ID获取用户
6. `test_updateUser` - 测试更新用户信息
7. `test_invalidAuthCode` - 测试无效授权码

**验收标准**:
- [ ] Mock UserMapper
- [ ] Mock 外部API调用
- [ ] 验证数据正确保存

---

### P4-007: 实现 UserService

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/user/service/impl/UserServiceImpl.java`

**描述**: 用户服务实现

**实现内容**:
```java
@Service
@Slf4j
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${wechat.appid}")
    private String wechatAppId;

    @Value("${wechat.secret}")
    private String wechatSecret;

    @Value("${huawei.client-id}")
    private String huaweiClientId;

    @Value("${huawei.client-secret}")
    private String huaweiClientSecret;

    @Override
    public User wechatLogin(String code) {
        // 调用微信API获取openid和access_token
        // 查询或创建用户
        // 返回用户信息
    }

    @Override
    public User huaweiLogin(String code) {
        // 调用华为API获取uid
        // 查询或创建用户
        // 返回用户信息
    }

    @Override
    public User getUserById(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND);
        }
        return user;
    }

    @Override
    public User updateUser(User user) {
        userMapper.updateById(user);
        return user;
    }
}
```

**验收标准**:
- [ ] 微信登录正确处理
- [ ] 华为登录正确处理
- [ ] 新用户自动创建
- [ ] 老用户返回现有信息
- [ ] 所有操作记录日志

---

### P4-008: 编写 UserMapper 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/user/mapper/UserMapperTest.java`

**描述**: 测试用户Mapper

**测试用例**:
1. `test_insert` - 测试插入用户
2. `test_selectById` - 测试根据ID查询
3. `test_selectByOpenid` - 测试根据openid查询
4. `test_selectByHuaweiUid` - 测试根据华为uid查询
5. `test_updateById` - 测试更新用户

**验收标准**:
- [ ] 使用 @MybatisTest
- [ ] 测试SQL正确性

---

### P4-009: 实现 UserMapper

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/user/mapper/UserMapper.java`

**描述**: 用户Mapper接口

**实现内容**:
```java
@Mapper
public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM user WHERE openid = #{openid} AND deleted = 0")
    User selectByOpenid(@Param("openid") String openid);

    @Select("SELECT * FROM user WHERE huawei_uid = #{huaweiUid} AND deleted = 0")
    User selectByHuaweiUid(@Param("huaweiUid") String huaweiUid);
}
```

**验收标准**:
- [ ] 继承 BaseMapper
- [ ] 定义自定义查询方法
- [ ] 使用 @Select 注解

---

### P4-010: 编写 UserController 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/user/controller/UserControllerTest.java`

**描述**: 测试用户控制器

**测试用例**:
1. `test_wechatLogin_success` - 测试微信登录成功
2. `test_wechatLogin_failure` - 测试微信登录失败
3. `test_huaweiLogin_success` - 测试华为登录成功
4. `test_validateToken_valid` - 测试Token有效
5. `test_validateToken_invalid` - 测试Token无效
6. `test_refreshToken` - 测试刷新Token
7. `test_logout` - 测试登出

**验收标准**:
- [ ] 使用 MockMvc
- [ ] Mock UserService
- [ ] 验证响应状态和内容

---

### P4-011: 实现 UserController

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/user/controller/UserController.java`

**描述**: 用户控制器

**实现内容**:
```java
@RestController
@RequestMapping("/api/v1/auth")
@Slf4j
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/wechat/login")
    public Result<LoginResponse> wechatLogin(@RequestBody WechatLoginRequest request) {
        User user = userService.wechatLogin(request.getCode());
        String token = jwtUtil.generateToken(user.getId());
        return Result.success(new LoginResponse(token, user));
    }

    @PostMapping("/huawei/login")
    public Result<LoginResponse> huaweiLogin(@RequestBody HuaweiLoginRequest request) {
        User user = userService.huaweiLogin(request.getCode());
        String token = jwtUtil.generateToken(user.getId());
        return Result.success(new LoginResponse(token, user));
    }

    @GetMapping("/validate")
    public Result<User> validateToken(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        Long userId = jwtUtil.getUserIdFromToken(token);
        User user = userService.getUserById(userId);
        return Result.success(user);
    }

    @PostMapping("/refresh")
    public Result<TokenResponse> refreshToken(@RequestBody TokenRefreshRequest request) {
        // 刷新Token逻辑
    }

    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader("Authorization") String authHeader) {
        // 登出逻辑
        return Result.success();
    }
}
```

**验收标准**:
- [ ] 所有接口使用 /api/v1 前缀
- [ ] 返回统一的Result结构
- [ ] 请求参数使用 @Valid 校验

---

### P4-012: 编写 TaskService 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/task/service/TaskServiceTest.java`

**描述**: 测试任务服务

**测试用例**:
1. `test_createTask_todo` - 测试创建待办任务
2. `test_createTask_plan` - 测试创建计划任务
3. `test_createTask_invalid` - 测试创建任务参数校验
4. `test_updateTask` - 测试更新任务
5. `test_deleteTask` - 测试删除任务
6. `test_completeTomato` - 测试完成番茄
7. `test_getTasksByStatus` - 测试根据状态获取任务
8. `test_checkTodayReset` - 测试检查今日重置
9. `test_restoreCancelledTask` - 测试恢复已取消任务

**验收标准**:
- [ ] Mock TaskMapper 和 RecordMapper
- [ ] 验证两种模式的特殊逻辑
- [ ] 测试数据校验

---

### P4-013: 实现 TaskService

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/task/service/impl/TaskServiceImpl.java`

**描述**: 任务服务实现

**实现内容**:
```java
@Service
@Slf4j
public class TaskServiceImpl implements TaskService {

    @Autowired
    private TaskMapper taskMapper;

    @Autowired
    private TomatoRecordMapper recordMapper;

    @Override
    @Transactional
    public Task createTask(TaskCreateRequest request, Long userId) {
        Task task = new Task();
        task.setUserId(userId);
        task.setName(request.getName());
        task.setMode(request.getMode());
        task.setTomatoMinutes(request.getTomatoMinutes());
        task.setRestMinutes(request.getRestMinutes());
        task.setStatus(TaskStatus.WORKING.getCode());
        task.setPriority(0);

        if (request.getMode() == TaskMode.TODO) {
            task.setTargetTomatoCount(request.getTargetTomatoCount());
        } else {
            task.setDailyTargetTomatoCount(request.getDailyTargetTomatoCount());
            task.setDeadline(request.getDeadline());
            task.setTodayFinishedCount(0);
        }

        taskMapper.insert(task);
        return task;
    }

    @Override
    @Transactional
    public boolean updateTask(TaskUpdateRequest request, Long userId) {
        Task task = taskMapper.selectById(request.getId());
        if (task == null || !task.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.TASK_NOT_FOUND);
        }

        if (request.getName() != null) {
            task.setName(request.getName());
        }
        if (request.getTomatoMinutes() != null) {
            task.setTomatoMinutes(request.getTomatoMinutes());
        }
        // ... 其他字段更新

        return taskMapper.updateById(task) > 0;
    }

    @Override
    @Transactional
    public boolean deleteTask(Long id, Long userId) {
        Task task = taskMapper.selectById(id);
        if (task == null || !task.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.TASK_NOT_FOUND);
        }

        task.setStatus(TaskStatus.CANCELLED.getCode());
        return taskMapper.updateById(task) > 0;
    }

    @Override
    @Transactional
    public boolean completeTomato(Long taskId, Long userId, CompleteTomatoRequest request) {
        Task task = taskMapper.selectById(taskId);
        if (task == null || !task.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.TASK_NOT_FOUND);
        }

        // 更新任务计数
        task.setFinishedTomatoCount(task.getFinishedTomatoCount() + 1);
        if (task.getMode() == TaskMode.PLAN) {
            task.setTodayFinishedCount(task.getTodayFinishedCount() + 1);
        }

        // 检查是否完成
        if (task.isCompleted()) {
            task.setStatus(TaskStatus.COMPLETED.getCode());
        }

        // 创建番茄记录
        TomatoRecord record = new TomatoRecord();
        record.setUserId(userId);
        record.setTaskId(taskId);
        record.setTaskName(task.getName());
        record.setTaskMode(task.getMode());
        record.setActualMinutes(request.getActualMinutes());
        record.setIsEarlyEnd(request.getIsEarlyEnd() ? 1 : 0);
        record.setCompletedAt(LocalDateTime.now());
        recordMapper.insert(record);

        return taskMapper.updateById(task) > 0;
    }

    // ... 其他方法
}
```

**验收标准**:
- [ ] 使用 @Transactional 确保事务
- [ ] 验证用户权限
- [ ] 正确处理两种模式
- [ ] 创建番茄记录

---

### P4-014: 编写 TaskMapper 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/task/mapper/TaskMapperTest.java`

**描述**: 测试任务Mapper

**测试用例**:
1. `test_insert` - 测试插入任务
2. `test_selectById` - 测试根据ID查询
3. `test_selectByUserId` - 测试根据用户ID查询
4. `test_selectByUserIdAndStatus` - 测试根据用户ID和状态查询
5. `test_updateById` - 测试更新任务

**验收标准**:
- [ ] 使用 @MybatisTest
- [ ] 测试复杂查询

---

### P4-015: 实现 TaskMapper

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/task/mapper/TaskMapper.java`

**描述**: 任务Mapper接口

**实现内容**:
```java
@Mapper
public interface TaskMapper extends BaseMapper<Task> {

    @Select("SELECT * FROM task WHERE user_id = #{userId} AND deleted = 0 ORDER BY priority DESC, created_at DESC")
    List<Task> selectByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM task WHERE user_id = #{userId} AND status = #{status} AND deleted = 0")
    List<Task> selectByUserIdAndStatus(@Param("userId") Long userId, @Param("status") Integer status);
}
```

**验收标准**:
- [ ] 继承 BaseMapper
- [ ] 定义自定义查询

---

### P4-016: 编写 TaskController 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/task/controller/TaskControllerTest.java`

**描述**: 测试任务控制器

**测试用例**:
1. `test_createTask_success` - 测试创建任务成功
2. `test_createTask_invalid` - 测试创建任务参数校验
3. `test_updateTask_success` - 测试更新任务成功
4. `test_deleteTask_success` - 测试删除任务成功
5. `test_completeTomato_success` - 测试完成番茄成功
6. `test_getTasks` - 测试获取任务列表
7. `test_unauthorized_access` - 测试未授权访问

**验收标准**:
- [ ] 使用 MockMvc
- [ ] Mock TaskService
- [ ] 测试认证拦截

---

### P4-017: 实现 TaskController

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/task/controller/TaskController.java`

**描述**: 任务控制器

**实现内容**:
```java
@RestController
@RequestMapping("/api/v1/tasks")
@Slf4j
public class TaskController {

    @Autowired
    private TaskService taskService;

    @GetMapping
    public Result<List<TaskDTO>> getTasks(
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer mode,
            @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        List<Task> tasks = taskService.getTasks(userId, status, mode);
        List<TaskDTO> dtos = tasks.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
        return Result.success(dtos);
    }

    @PostMapping
    public Result<TaskDTO> createTask(
            @Valid @RequestBody TaskCreateRequest request,
            @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        Task task = taskService.createTask(request, userId);
        return Result.success(convertToDTO(task));
    }

    @PutMapping("/{id}")
    public Result<Void> updateTask(
            @PathVariable Long id,
            @RequestBody TaskUpdateRequest request,
            @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        request.setId(id);
        taskService.updateTask(request, userId);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteTask(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        taskService.deleteTask(id, userId);
        return Result.success();
    }

    @PostMapping("/{id}/complete")
    public Result<CompleteTomatoResponse> completeTomato(
            @PathVariable Long id,
            @RequestBody CompleteTomatoRequest request,
            @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        boolean success = taskService.completeTomato(id, userId, request);
        // 返回更新后的任务状态
    }

    private Long getUserIdFromToken(String authHeader) {
        // 从Token获取用户ID
    }

    private TaskDTO convertToDTO(Task task) {
        // 转换为DTO
    }
}
```

**验收标准**:
- [ ] 所有接口需要认证
- [ ] 返回统一的Result结构
- [ ] 正确处理请求参数

---

### P4-018: 编写 RecordService 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/record/service/RecordServiceTest.java`

**描述**: 测试番茄记录服务

**测试用例**:
1. `test_createRecord` - 测试创建记录
2. `test_getRecordsByUserId` - 测试获取用户记录
3. `test_getRecordsByTaskId` - 测试获取任务记录
4. `test_getRecordsByDateRange` - 测试获取日期范围记录

**验收标准**:
- [ ] Mock RecordMapper
- [ ] 测试日期范围查询

---

### P4-019: 实现 RecordService

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/record/service/impl/RecordServiceImpl.java`

**描述**: 番茄记录服务实现

**实现内容**:
```java
@Service
@Slf4j
public class RecordServiceImpl implements RecordService {

    @Autowired
    private TomatoRecordMapper recordMapper;

    @Override
    public List<TomatoRecord> getRecordsByUserId(Long userId) {
        return recordMapper.selectByUserId(userId);
    }

    @Override
    public List<TomatoRecord> getRecordsByTaskId(Long taskId) {
        return recordMapper.selectByTaskId(taskId);
    }

    @Override
    public List<TomatoRecord> getRecordsByDateRange(Long userId, LocalDate startDate, LocalDate endDate) {
        return recordMapper.selectByDateRange(userId, startDate, endDate);
    }
}
```

**验收标准**:
- [ ] 查询方法正确实现
- [ ] 日期范围处理正确

---

### P4-020: 编写 RecordMapper 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/record/mapper/RecordMapperTest.java`

**描述**: 测试记录Mapper

**测试用例**:
1. `test_insert` - 测试插入记录
2. `test_selectByUserId` - 测试根据用户ID查询
3. `test_selectByTaskId` - 测试根据任务ID查询
4. `test_selectByDateRange` - 测试日期范围查询

**验收标准**:
- [ ] 使用 @MybatisTest

---

### P4-021: 实现 RecordMapper

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/record/mapper/TomatoRecordMapper.java`

**描述**: 番茄记录Mapper接口

**实现内容**:
```java
@Mapper
public interface TomatoRecordMapper extends BaseMapper<TomatoRecord> {

    @Select("SELECT * FROM tomato_record WHERE user_id = #{userId} ORDER BY completed_at DESC")
    List<TomatoRecord> selectByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM tomato_record WHERE task_id = #{taskId} ORDER BY completed_at DESC")
    List<TomatoRecord> selectByTaskId(@Param("taskId") Long taskId);

    @Select("SELECT * FROM tomato_record WHERE user_id = #{userId} " +
            "AND DATE(completed_at) BETWEEN #{startDate} AND #{endDate}")
    List<TomatoRecord> selectByDateRange(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
```

**验收标准**:
- [ ] 继承 BaseMapper
- [ ] 定义日期范围查询

---

### P4-022: 编写 StatisticsService 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/statistics/service/StatisticsServiceTest.java`

**描述**: 测试统计服务

**测试用例**:
1. `test_getTodayStatistics` - 测试获取今日统计
2. `test_getWeekStatistics` - 测试获取本周统计
3. `test_getMonthStatistics` - 测试获取本月统计
4. `test_calculateCompletionRate` - 测试计算完成率
5. `test_getTaskRanking` - 测试获取任务排行
6. `test_emptyData` - 测试空数据情况

**验收标准**:
- [ ] Mock TaskMapper 和 RecordMapper
- [ ] 测试统计计算逻辑

---

### P4-023: 实现 StatisticsService

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/statistics/service/impl/StatisticsServiceImpl.java`

**描述**: 统计服务实现

**实现内容**:
```java
@Service
@Slf4j
public class StatisticsServiceImpl implements StatisticsService {

    @Autowired
    private TaskMapper taskMapper;

    @Autowired
    private TomatoRecordMapper recordMapper;

    @Override
    public StatisticsDTO getTodayStatistics(Long userId) {
        LocalDate today = LocalDate.now();
        return getStatistics(userId, today, today);
    }

    @Override
    public StatisticsDTO getWeekStatistics(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1);
        return getStatistics(userId, weekStart, today);
    }

    @Override
    public StatisticsDTO getMonthStatistics(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate monthStart = today.withDayOfMonth(1);
        return getStatistics(userId, monthStart, today);
    }

    private StatisticsDTO getStatistics(Long userId, LocalDate startDate, LocalDate endDate) {
        // 查询番茄记录
        List<TomatoRecord> records = recordMapper.selectByDateRange(userId, startDate, endDate);

        // 计算统计数据
        long completedTomatoes = records.size();
        long focusMinutes = records.stream()
            .mapToLong(TomatoRecord::getActualMinutes)
            .sum();

        // 查询任务统计
        List<Task> allTasks = taskMapper.selectByUserId(userId);
        long completedTasks = allTasks.stream()
            .filter(t -> t.getStatus() == TaskStatus.COMPLETED.getCode())
            .count();
        long totalTasks = allTasks.stream()
            .filter(t -> t.getStatus() == TaskStatus.WORKING.getCode() ||
                       t.getStatus() == TaskStatus.COMPLETED.getCode())
            .count();

        int completionRate = totalTasks > 0 ? (int) (completedTasks * 100 / totalTasks) : 0;

        // 生成每日数据
        List<DailyStatisticsDTO> dailyData = generateDailyData(records, startDate, endDate);

        // 生成任务排行
        List<TaskRankingDTO> taskRanking = generateTaskRanking(records);

        StatisticsDTO stats = new StatisticsDTO();
        stats.setPeriod("custom");
        stats.setStartDate(startDate);
        stats.setEndDate(endDate);
        stats.setCompletedTomatoes((int) completedTomatoes);
        stats.setFocusMinutes(focusMinutes);
        stats.setCompletedTasks((int) completedTasks);
        stats.setTotalTasks((int) totalTasks);
        stats.setCompletionRate(completionRate);
        stats.setDailyData(dailyData);
        stats.setTaskRanking(taskRanking);

        return stats;
    }

    // ... 其他辅助方法
}
```

**验收标准**:
- [ ] 正确计算今日/本周/本月统计
- [ ] 正确计算完成率
- [ ] 正确生成每日数据
- [ ] 正确生成任务排行

---

### P4-024: 编写 StatisticsController 单元测试

**文件**: `tomato-clock-backend/src/test/java/com/tomato/modules/statistics/controller/StatisticsControllerTest.java`

**描述**: 测试统计控制器

**测试用例**:
1. `test_getTodayStatistics` - 测试获取今日统计
2. `test_getWeekStatistics` - 测试获取本周统计
3. `test_getMonthStatistics` - 测试获取本月统计
4. `test_getCustomRangeStatistics` - 测试自定义范围统计

**验收标准**:
- [ ] 使用 MockMvc
- [ ] Mock StatisticsService

---

### P4-025: 实现 StatisticsController

**文件**: `tomato-clock-backend/src/main/java/com/tomato/modules/statistics/controller/StatisticsController.java`

**描述**: 统计控制器

**实现内容**:
```java
@RestController
@RequestMapping("/api/v1/statistics")
@Slf4j
public class StatisticsController {

    @Autowired
    private StatisticsService statisticsService;

    @GetMapping("/today")
    public Result<StatisticsDTO> getTodayStatistics(@RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        return Result.success(statisticsService.getTodayStatistics(userId));
    }

    @GetMapping("/week")
    public Result<StatisticsDTO> getWeekStatistics(@RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        return Result.success(statisticsService.getWeekStatistics(userId));
    }

    @GetMapping("/month")
    public Result<StatisticsDTO> getMonthStatistics(@RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        return Result.success(statisticsService.getMonthStatistics(userId));
    }
}
```

**验收标准**:
- [ ] 所有接口需要认证
- [ ] 返回统计数据

---

### P4-026: 编写 AuthInterceptor 单元测试 [P]

**文件**: `tomato-clock-backend/src/test/java/com/tomato/security/interceptor/AuthInterceptorTest.java`

**描述**: 测试认证拦截器

**测试用例**:
1. `test_preHandle_validToken` - 测试有效Token
2. `test_preHandle_invalidToken` - 测试无效Token
3. `test_preHandle_missingToken` - 测试缺少Token
4. `test_preHandle_expiredToken` - 测试过期Token

**验收标准**:
- [ ] Mock JwtUtil
- [ ] 验证拦截逻辑

---

### P4-027: 实现 AuthInterceptor [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/security/interceptor/AuthInterceptor.java`

**描述**: 认证拦截器

**实现内容**:
```java
@Component
@Slf4j
public class AuthInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // 只拦截Controller方法
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }

        // 检查是否有 @SkipAuth 注解
        HandlerMethod handlerMethod = (HandlerMethod) handler;
        if (handlerMethod.hasMethodAnnotation(SkipAuth.class)) {
            return true;
        }

        // 获取Token
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            sendUnauthorizedResponse(response, "缺少认证Token");
            return false;
        }

        String token = authHeader.substring(7);
        try {
            if (jwtUtil.isTokenExpired(token)) {
                sendUnauthorizedResponse(response, "Token已过期");
                return false;
            }

            Long userId = jwtUtil.getUserIdFromToken(token);
            request.setAttribute("userId", userId);
            return true;
        } catch (Exception e) {
            sendUnauthorizedResponse(response, "Token无效");
            return false;
        }
    }

    private void sendUnauthorizedResponse(HttpServletResponse response, String message) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        try {
            response.getWriter().write("{\"code\":401,\"message\":\"" + message + "\"}");
        } catch (IOException e) {
            log.error("发送响应失败", e);
        }
    }
}
```

**验收标准**:
- [ ] 验证Bearer Token
- [ ] 支持 @SkipAuth 跳过认证
- [ ] Token过期返回401
- [ ] 有效Token设置userId到request

---

### P4-028: 编写 JwtFilter 单元测试 [P]

**文件**: `tomato-clock-backend/src/test/java/com/tomato/security/filter/JwtFilterTest.java`

**描述**: 测试JWT过滤器

**测试用例**:
1. `test_doFilter_validToken` - 测试有效Token
2. `test_doFilter_invalidToken` - 测试无效Token
3. `test_doFilter_missingToken` - 测试缺少Token

**验收标准**:
- [ ] Mock JwtUtil
- [ ] 验证过滤逻辑

---

### P4-029: 实现 JwtFilter [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/security/filter/JwtFilter.java`

**描述**: JWT过滤器

**实现内容**:
```java
@Component
@WebFilter(urlPatterns = "/api/*")
@Slf4j
public class JwtFilter implements Filter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String authHeader = httpRequest.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                if (!jwtUtil.isTokenExpired(token)) {
                    Long userId = jwtUtil.getUserIdFromToken(token);
                    httpRequest.setAttribute("userId", userId);
                }
            } catch (Exception e) {
                log.warn("Token验证失败", e);
            }
        }

        chain.doFilter(request, response);
    }
}
```

**验收标准**:
- [ ] 过滤所有 /api/* 请求
- [ ] 解析并验证Token
- [ ] 验证失败不中断请求（由拦截器处理）

---

### P4-030: 实现 MyBatisConfig [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/config/MyBatisConfig.java`

**描述**: MyBatis配置类

**实现内容**:
```java
@Configuration
@MapperScan("com.tomato.modules.*.mapper")
public class MyBatisConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        // 分页插件
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        // 乐观锁插件
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        return interceptor;
    }

    @Bean
    public MetaObjectHandler metaObjectHandler() {
        return new MetaObjectHandler() {
            @Override
            public void insertFill(MetaObject metaObject) {
                this.strictInsertFill(metaObject, "createdAt", LocalDateTime.class, LocalDateTime.now());
                this.strictInsertFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
            }

            @Override
            public void updateFill(MetaObject metaObject) {
                this.strictUpdateFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
            }
        };
    }
}
```

**验收标准**:
- [ ] 配置分页插件
- [ ] 配置乐观锁插件
- [ ] 配置自动填充

---

### P4-031: 实现 WebConfig [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/config/WebConfig.java`

**描述**: Web配置类

**实现内容**:
```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private AuthInterceptor authInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
            .addPathPatterns("/api/**")
            .excludePathPatterns("/api/v1/auth/wechat/login", "/api/v1/auth/huawei/login");
    }

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.addAllowedOriginPattern("*");
        config.addAllowedMethod("*");
        config.addAllowedHeader("*");
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return new CorsFilter(source);
    }

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

**验收标准**:
- [ ] 配置认证拦截器
- [ ] 排除登录接口
- [ ] 配置CORS

---

### P4-032: 实现 AsyncConfig [P]

**文件**: `tomato-clock-backend/src/main/java/com/tomato/config/AsyncConfig.java`

**描述**: 异步任务配置

**实现内容**:
```java
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

    @Override
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}
```

**验收标准**:
- [ ] 配置线程池
- [ ] 配置异步执行

---

## 阶段完成标准

- [ ] 所有服务实现完成
- [ ] 所有控制器实现完成
- [ ] 所有测试通过
- [ ] 测试覆盖率 > 80%
- [ ] API接口符合RESTful规范
- [ ] 认证拦截器正常工作

---

**相关文档：**
- [技术实现方案 - 5. 接口设计](../technical/plan.md#5-接口设计)
- [技术实现方案 - 6.2 后端关键技术点](../technical/plan.md#62-后端关键技术点)
- [数据模型定义](../technical/data-model.md)
