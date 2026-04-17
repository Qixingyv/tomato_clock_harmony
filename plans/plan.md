# 番茄钟项目 — 华为账号登录技术实现方案

> 版本：v1.0
> 创建日期：2026-04-16
> 范围：华为账号授权登录（Account Kit LoginWithHuaweiIDButton）
> 状态：待评审

---

## 一、技术上下文总结

### 1.1 技术选型

| 层面 | 技术点 | 说明 |
|------|--------|------|
| 前端语言 | ArkTS | 严格 TypeScript，禁用 `any`，优先 `const` |
| 前端框架 | ArkUI | 声明式：`@Component`、`@Builder`、`build()` |
| 认证 SDK | `@kit.AccountKit` | 华为 Account Kit，`LoginWithHuaweiIDButton` 组件 + `loginComponentManager` 控制器 |
| 网络 | `@ohos.net.http` | HTTP 客户端，封装于 `ApiClient` |
| 本地存储 | Preferences API | 通过 `StorageService` 封装，JSON 序列化 |
| 认证架构 | 服务端 Session 模式 | 客户端仅持有 `session_id`，Token 刷新由后端内部处理 |
| 后端 | Spring Boot 4.0.3 + MyBatis + MySQL 8.0 | JWT (HS512) 签发业务 Token，Session 表管理 |

### 1.2 核心技术决策

1. **Session 模式取代客户端持 Token 方案**：客户端只存 `session_id`，不接触 access_token / refresh_token。Token 验证与刷新全部由后端 `AuthInterceptor` 内部处理。
2. **华为 Account Kit 登录按钮组件**：使用 `LoginWithHuaweiIDButton` 原生组件，内部完成授权流程，回调返回 `authorizationCode`。
3. **Authorization Code → 后端换 Token → UnionID**：客户端拿到 `authorizationCode` 发送到后端，后端调用华为服务器换取 Access Token 再获取 UnionID，查找/创建用户。

### 1.3 MVP 范围确认

| 功能项 | 本次是否包含 |
|--------|-------------|
| 华为账号登录 | **是** |
| 微信登录 | 否（延期至 v2.0） |
| 游客模式 | 否（延期至 v2.0） |
| 登出 | **是** |
| 自动登录（Session 验证） | **是** |
| 离线模式降级 | **是** |

---

## 二、"合宪性"审查

逐条对照 `constitution.md` 审查本方案：

### 第二章第三条 · 开发语言

| 要求 | 方案符合情况 |
|------|-------------|
| 必须使用 ArkTS | 所有新增代码均为 `.ets` 文件，严格 ArkTS |
| 禁止使用 `any` | 不使用 `any`，所有函数参数和返回值均有明确类型 |
| 优先使用 `const` | 遵循，常量和不可变引用使用 `const` |

### 第二章第四条 · UI 规范

| 要求 | 方案符合情况 |
|------|-------------|
| 支持 deep/light 主题 | `LoginWithHuaweiIDButton` 设置 `supportDarkMode: true` |
| 响应式布局 | 登录页使用弹性布局，适配不同屏幕 |
| fp 字体 / vp 间距 | 登录页布局严格使用 fp/vp |

### 第二章第五条 · 数据管理

| 要求 | 方案符合情况 |
|------|-------------|
| 使用 PersistentStorage | 通过 `StorageService`（封装 Preferences API）持久化 `session_id` 和用户数据 |
| 重要操作记录日志 | 所有认证操作通过 `Logger` 记录 |
| 异常数据自动修复 | `AuthService.init()` 中检测 `session_id` 有效性，失效时自动清除 |

### 第四章第十条 · 错误处理

| 要求 | 方案符合情况 |
|------|-------------|
| 所有异步操作 try-catch | `AuthService` 所有 async 方法均包裹 try-catch |
| 用户友好错误提示 | 通过 `promptAction.showToast()` 展示友好错误信息 |
| 错误日志记录 | 所有 catch 块调用 `Logger.error()` |
| 自动恢复机制 | 网络错误时信任本地缓存进入离线模式；401 时清除状态跳转登录页 |

### 第四章第九条 · 代码审查标准

| 要求 | 方案符合情况 |
|------|-------------|
| 单元测试覆盖率 > 80% | 为 `AuthService` 核心方法编写单元测试（见第七节） |
| 关键功能需添加注释 | 认证流程关键节点添加注释 |

### 第三章第八条 · 权限管理

| 要求 | 方案符合情况 |
|------|-------------|
| 最小权限原则 | 仅需 `ohos.permission.INTERNET`（网络请求）和 `ohos.permission.GET_NETWORK_INFO`（网络状态检测） |

**结论：本方案完全符合 `constitution.md` 全部条款。**

---

## 三、项目结构细化

### 3.1 本次变更涉及的文件

```
entry/src/main/ets/
├── pages/
│   └── Index.ets                          # 【修改】集成华为登录按钮组件
│
├── view/
│   └── components/
│       └── HuaweiLoginButton.ets          # 【新增】华为账号登录按钮封装组件
│
├── viewmodel/
│   ├── LoginType.ets                      # 【修改】移除 GUEST 枚举值（延期）
│   ├── User.ets                           # 【新增】用户数据模型
│   └── AuthState.ets                      # 【新增】认证状态模型（Session 模式）
│
├── service/
│   ├── AuthService.ets                    # 【重写】从 mock 改为真实华为登录 + Session
│   └── StorageService.ets                # 【修改】增加 session_id 存取方法
│
├── common/
│   ├── network/
│   │   └── ApiClient.ets                  # 【新增】HTTP 客户端（X-Session-Id 拦截器）
│   └── constants/
│       └── AuthConstant.ets               # 【新增】认证相关常量
│
└── entryability/
    └── EntryAbility.ets                   # 【修改】更新服务初始化链

entry/src/main/resources/
└── base/profile/route_map.json            # 不变（路由无新增）
```

### 3.2 页面与组件关系图

```
┌─────────────────────────────────────────────────────┐
│                    Index.ets (登录页)                │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │               Logo + App 名称                  │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │  HuaweiLoginButton (封装 LoginWithHuaweiIDButton)│ │
│  │  ┌─────────────────────────────────────────┐  │ │
│  │  │  Account Kit 原生登录按钮               │  │ │
│  │  │  style: BUTTON_RED                       │  │ │
│  │  │  borderRadius: 24                        │  │ │
│  │  │  supportDarkMode: true                   │  │ │
│  │  └─────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │       用户协议与隐私政策文字链接              │ │
│  └───────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘

调用关系：
Index.ets
  ├── HuaweiLoginButton          # 点击 → Account Kit 授权
  │     └── controller.onClick() → 回调返回 authorizationCode
  │
  ├── AuthService                # 登录/登出/验证
  │     ├── loginWithHuawei()    # 发送 authCode 到后端
  │     ├── validateSession()    # 验证 session_id 有效性
  │     └── logout()             # 登出
  │
  └── GlobalNavStack             # 登录成功后跳转
        └── pushPathByName('MainPage')
```

### 3.3 登录成功后的导航流

```
Index (登录页)
  │ 登录成功
  ▼
MainPage (Tab 主页)
  ├── Tab 0: ToDoList    → 任务列表（已有）
  ├── Tab 1: Statistics  → 统计页（已有）
  └── Tab 2: Profile     → 个人中心
                              │
                              └── "退出登录" → AuthService.logout()
                                                │
                                                ▼
                                          Index (登录页)
```

---

## 四、核心数据结构

### 4.1 认证状态模型 — AuthState

```typescript
// viewmodel/AuthState.ets

/**
 * 认证状态模型（Session 模式）
 * 客户端仅持有 session_id，不持有任何 Token
 */
@Observed
export class AuthState {
  isLoggedIn: boolean = false;
  user: User | null = null;
  sessionId: string = '';

  // 离线模式标记
  isOfflineMode: boolean = false;
}
```

### 4.2 用户数据模型 — User

```typescript
// viewmodel/User.ets

/**
 * 用户数据模型
 */
export class User {
  id: number = 0;
  huaweiUid: string = '';
  nickname: string = '';
  avatar: string = '';
  loginType: LoginType = LoginType.HUAWEI;
  createdAt: number = 0;      // 时间戳
  lastLoginAt: number = 0;    // 时间戳

  get displayName(): string {
    return this.nickname || '番茄用户';
  }

  get avatarUrl(): string {
    return this.avatar || '';
  }

  // JSON 序列化/反序列化（用于 Preferences 存储）
  static fromJson(json: Record<string, Object>): User { ... }
  toJson(): Record<string, Object> { ... }
}
```

### 4.3 登录类型枚举 — LoginType

```typescript
// viewmodel/LoginType.ets

/**
 * 登录类型枚举
 * MVP 阶段仅包含 HUAWEI
 */
export enum LoginType {
  HUAWEI = 'huawei',
  // WECHAT = 'wechat',    // v2.0
  // GUEST = 'guest',      // v2.0
}
```

### 4.4 API 响应模型

```typescript
// common/network/ApiClient.ets 中定义

/**
 * 后端统一响应格式
 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: number;
}

/**
 * 华为登录响应
 */
export interface HuaweiLoginResponse {
  user: UserInfo;
  session_id: string;
}

/**
 * 用户信息（从后端返回）
 */
export interface UserInfo {
  id: number;
  huawei_uid: string;
  nickname: string;
  avatar: string;
  login_type: string;
  created_at: string;
  last_login_at: string;
}

/**
 * Session 验证响应
 */
export interface SessionValidateResponse {
  valid: boolean;
  user: UserInfo;
}

/**
 * 登录结果（内部使用）
 */
export interface LoginResult {
  success: boolean;
  user: User | null;
  error?: string;
}
```

### 4.5 网络请求配置常量

```typescript
// common/constants/AuthConstant.ets

export class AuthConstant {
  // API 路径
  static readonly AUTH_HUAWEI_LOGIN: string = '/auth/huawei/login';
  static readonly AUTH_VALIDATE: string = '/auth/validate';
  static readonly AUTH_LOGOUT: string = '/auth/logout';

  // 存储键
  static readonly STORAGE_SESSION_ID: string = 'session_id';
  static readonly STORAGE_USER: string = 'user_info';

  // 请求头
  static readonly HEADER_SESSION_ID: string = 'X-Session-Id';
  static readonly HEADER_CONTENT_TYPE: string = 'Content-Type';

  // 超时
  static readonly CONNECT_TIMEOUT: number = 10000;  // 10s
  static readonly READ_TIMEOUT: number = 10000;     // 10s
}
```

### 4.6 本地存储结构

```
Preferences: 'AUTH_STORE'
├── 'session_id'  → string    // Session ID（唯一标识）
├── 'user_info'   → string    // User JSON 序列化
└── 'is_offline'  → boolean   // 离线模式标记

Preferences: 'TOMATO_CLOCK_STORE'  (已有)
├── 'tasks'            → string   // 任务列表 JSON
├── 'task_id_counter'  → number   // 任务 ID 计数器
└── 'timer_state'      → string   // 计时器快照
```

---

## 五、接口设计

### 5.1 鸿蒙端 ↔ 后端 API 接口

#### 5.1.1 华为账号登录

```
POST /api/v1/auth/huawei/login
```

**请求：**
```json
{
  "authorizationCode": "SVDF2s%2F..."
}
```

**响应（200）：**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "user": {
      "id": 1,
      "huawei_uid": "unionid_xxx",
      "nickname": "番茄用户",
      "avatar": "https://...",
      "login_type": "huawei",
      "created_at": "2026-04-16T10:00:00Z",
      "last_login_at": "2026-04-16T10:00:00Z"
    },
    "session_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  },
  "timestamp": 1713273600000
}
```

**错误响应：**
| HTTP 状态 | 错误码 | 场景 |
|-----------|--------|------|
| 400 | 1001 | authorizationCode 无效或已过期 |
| 500 | 5000 | 华为服务器通信失败 |
| 500 | 5001 | 后端内部错误 |

#### 5.1.2 Session 验证（自动登录）

```
GET /api/v1/auth/validate
Header: X-Session-Id: {session_id}
```

**响应（200）：**
```json
{
  "code": 200,
  "message": "Session 有效",
  "data": {
    "valid": true,
    "user": {
      "id": 1,
      "huawei_uid": "unionid_xxx",
      "nickname": "番茄用户",
      "avatar": "https://...",
      "login_type": "huawei",
      "created_at": "2026-04-16T10:00:00Z",
      "last_login_at": "2026-04-16T10:30:00Z"
    }
  },
  "timestamp": 1713273600000
}
```

**错误响应：**
| HTTP 状态 | 说明 |
|-----------|------|
| 401 | Session 已失效，客户端清除本地状态跳转登录页 |

#### 5.1.3 登出

```
POST /api/v1/auth/logout
Header: X-Session-Id: {session_id}
```

**响应（200）：**
```json
{
  "code": 200,
  "message": "登出成功",
  "data": null,
  "timestamp": 1713273600000
}
```

### 5.2 ApiClient 设计

```typescript
// common/network/ApiClient.ets

/**
 * HTTP 客户端，封装所有与后端的通信
 *
 * 核心职责：
 * 1. 封装 GET/POST/PUT/DELETE 请求
 * 2. 自动注入 X-Session-Id 请求头
 * 3. 401 响应自动跳转登录页（不做 Token 刷新，刷新由后端内部处理）
 * 4. 统一错误处理
 */
export class ApiClient {
  private static baseUrl: string = 'https://api.tomatoclock.com/api/v1';

  /**
   * 构建请求头，自动注入 session_id
   */
  private static buildHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    const sessionId = AuthService.getSessionId();
    if (sessionId) {
      headers['X-Session-Id'] = sessionId;
    }
    return headers;
  }

  /**
   * GET 请求
   */
  static async get<T>(url: string): Promise<ApiResponse<T>> { ... }

  /**
   * POST 请求
   */
  static async post<T>(url: string, data?: object): Promise<ApiResponse<T>> { ... }

  /**
   * 统一请求处理
   * - 自动加 X-Session-Id
   * - 401 → 清除状态 + 跳转登录页
   * - 网络错误 → 抛出 NetworkError
   */
  private static async request<T>(
    method: http.RequestMethod,
    url: string,
    data?: object
  ): Promise<ApiResponse<T>> { ... }
}
```

### 5.3 接口鉴权流程图

```
┌──────────────┐                          ┌──────────────┐
│    客户端     │                          │    后端       │
├──────────────┤                          ├──────────────┤
│ session_id   │                          │ Session 表    │
│ user 缓存    │                          │ access_token  │
│              │                          │ refresh_token │
└──────────────┘                          └──────────────┘
        │                                         │
        │ X-Session-Id: xxx                        │
        ├────────────────────────────────────────►│
        │                                         │
        │           后端内部验证 Token             │
        │           Token 过期自动刷新             │
        │           客户端完全无感知               │
        │                                         │
        │ ◄────────────────────────────────────────┤
        │         200 业务数据 / 401 失效          │
```

---

## 六、详细实现方案

### 6.1 华为登录按钮组件 — HuaweiLoginButton

```typescript
// view/components/HuaweiLoginButton.ets

import { LoginWithHuaweiIDButton, loginComponentManager } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../common/Logger';

const TAG = '[TomatoClock] HuaweiLoginButton';

/**
 * 华为账号登录按钮封装组件
 *
 * 封装 Account Kit 的 LoginWithHuaweiIDButton，
 * 处理授权回调和错误分发。
 */
@Component
export struct HuaweiLoginButton {
  // 登录成功回调
  onLoginSuccess: (authorizationCode: string) => void = () => {};
  // 登录失败回调
  onLoginError: (errorMessage: string) => void = () => {};
  // 登录中状态变化回调
  onLoadingChange: (isLoading: boolean) => void = () => {};

  private controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        if (error) {
          this.dealHuaweiLoginError(error);
          return;
        }
        if (response) {
          const authCode = response.authorizationCode;
          if (authCode) {
            Logger.info(TAG, 'Huawei auth success, got authorizationCode');
            this.onLoginSuccess(authCode);
          } else {
            Logger.error(TAG, 'authorizationCode is empty');
            this.onLoginError('登录失败，请重试');
          }
        }
      });

  build() {
    Column() {
      LoginWithHuaweiIDButton({
        params: {
          style: loginComponentManager.Style.BUTTON_RED,
          borderRadius: 24,
          loginType: loginComponentManager.LoginType.ID,
          supportDarkMode: true,
          extraStyle: {
            buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
              show: true
            })
          }
        },
        controller: this.controller
      })
    }
    .height(40)
    .width('100%')
  }

  /**
   * 华为登录错误处理
   */
  private dealHuaweiLoginError(error: BusinessError): void {
    Logger.error(TAG, `Huawei login error: ${error.code} - ${error.message}`);

    if (error.code === 1001502012) {
      // 用户取消，静默返回
      return;
    }
    if (error.code === 1001502001) {
      this.onLoginError('请登录华为账号后重试');
    } else if (error.code === 1001502005) {
      this.onLoginError('网络异常，请检查网络后重试');
    } else if (error.code === 12300001) {
      this.onLoginError('系统异常，请稍后重试');
    } else if (error.code === 1005300001) {
      this.onLoginError('请先同意用户协议');
    } else {
      this.onLoginError('登录失败，请重试');
    }
  }
}
```

### 6.2 AuthService 重写

```typescript
// service/AuthService.ets

/**
 * 认证服务（Session 模式）
 *
 * 职责：
 * 1. 管理登录/登出流程
 * 2. 维护 AuthState（session_id + user）
 * 3. App 启动时验证 Session 有效性
 * 4. 离线模式降级
 */
export class AuthService {
  private static authState: AuthState = new AuthState();
  private static storageService: StorageService | null = null;

  /**
   * 初始化 — 从本地恢复认证状态
   */
  static async init(): Promise<void> {
    // 从 StorageService 读取 session_id 和 user
    // 如果有 session_id，调用 validateSession() 验证
  }

  /**
   * 华为账号登录
   * @param authorizationCode Account Kit 返回的授权码
   */
  static async loginWithHuawei(authorizationCode: string): Promise<LoginResult> {
    // 1. 调用 ApiClient.post<HuaweiLoginResponse>('/auth/huawei/login', { authorizationCode })
    // 2. 成功 → 保存 session_id + user 到 StorageService
    // 3. 更新 authState
    // 4. 触发 notifyAuthStateChange()
  }

  /**
   * 验证 Session（自动登录）
   */
  static async validateSession(): Promise<boolean> {
    // 1. 从 authState 取 session_id
    // 2. 调用 ApiClient.get<SessionValidateResponse>('/auth/validate')
    // 3. 200 → 更新 user 缓存，返回 true
    // 4. 401 → clearLocalState()，返回 false
    // 5. 网络错误 → 如有本地 user 缓存则进入离线模式
  }

  /**
   * 登出
   */
  static async logout(forceLogout: boolean = false): Promise<boolean> {
    // 1. 调用 ApiClient.post('/auth/logout')
    // 2. 无论成功失败都 clearLocalState()
    // 3. forceLogout=true 时即使网络失败也清除本地状态
  }

  /**
   * 清除本地认证状态
   */
  private static clearLocalState(): void {
    // 1. 清除 StorageService 中的 session_id 和 user
    // 2. 重置 authState
    // 3. 触发 notifyAuthStateChange()
  }

  // --- 状态查询方法 ---
  static isLoggedIn(): boolean { ... }
  static getSessionId(): string { ... }
  static getCurrentUser(): User | null { ... }
  static getAuthState(): AuthState { ... }
  static isOfflineMode(): boolean { ... }

  // --- 状态变化回调 ---
  private static authStateChangeListener: ((state: AuthState) => void) | null = null;
  static setAuthStateChangeListener(listener: (state: AuthState) => void): void { ... }
  private static notifyAuthStateChange(): void { ... }
}
```

### 6.3 Index.ets 登录页改造

```
改造要点：
1. 移除微信登录按钮和游客登录按钮（MVP 仅华为登录）
2. 引入 HuaweiLoginButton 组件
3. 登录流程：
   a. 用户点击华为登录按钮
   b. Account Kit 内部处理授权（未登录则拉起华为登录页）
   c. 回调返回 authorizationCode
   d. 调用 AuthService.loginWithHuawei(authCode)
   e. 成功 → Toast "登录成功" → GlobalNavStack.pushPathByName('MainPage')
   f. 失败 → Toast 错误信息
4. 保留自动登录检测（aboutToAppear 中调用 AuthService.validateSession()）
```

### 6.4 服务初始化链更新

```typescript
// EntryAbility.onWindowStageCreate 中

// 1. StorageService.init(context)        — 不变
// 2. AuthService.init()                  — 重写：从本地恢复 session_id + user
//    → 如有 session_id，尝试 validateSession()
//    → 有效：标记已登录
//    → 无效：清除本地状态
//    → 网络错误：信任本地缓存（离线模式）
// 3. TaskService.init()                  — 不变
// 4. TimerService.init()                 — 不变
```

---

## 七、测试方案

### 7.1 单元测试

| 测试文件 | 测试内容 | 优先级 |
|----------|----------|--------|
| `AuthService.test.ets` | `loginWithHuawei()` 成功/失败/网络错误 | P0 |
| `AuthService.test.ets` | `validateSession()` 有效/无效/离线降级 | P0 |
| `AuthService.test.ets` | `logout()` 正常/强制登出 | P0 |
| `AuthService.test.ets` | `clearLocalState()` 状态清理完整性 | P1 |
| `ApiClient.test.ets` | `buildHeaders()` 注入 session_id | P0 |
| `ApiClient.test.ets` | 401 响应自动清除状态 | P0 |
| `ApiClient.test.ets` | 网络超时错误处理 | P1 |
| `User.test.ets` | `fromJson()` / `toJson()` 序列化一致性 | P1 |
| `AuthState.test.ets` | 初始值 / isLoggedIn 判定 | P1 |
| `HuaweiLoginButton.test.ets` | 错误码映射测试 | P1 |

### 7.2 集成测试

| 场景 | 验证点 |
|------|--------|
| 新用户首次登录 | Account Kit 拉起 → authCode → 后端创建用户 → 返回 session_id → 跳转主页 |
| 已有用户登录 | Account Kit → authCode → 后端找到用户 → 返回 session_id → 跳转主页 |
| 用户取消授权 | 静默返回登录页，不显示错误 |
| 网络异常登录 | Toast 提示"网络异常，请检查网络后重试" |
| 自动登录（Session 有效） | App 启动 → validateSession → 200 → 直接进主页 |
| 自动登录（Session 失效） | App 启动 → validateSession → 401 → 清除状态 → 显示登录页 |
| 自动登录（网络不可达） | App 启动 → validateSession → 网络错误 → 信任本地缓存 → 离线模式进主页 |
| 登出 → 后端成功 | 清除本地状态 → 跳转登录页 → Toast "已退出登录" |
| 登出 → 网络失败 → 强制登出 | 本地状态清除 → 跳转登录页 |
| 后台切前台 | 触发 validateSession 检查 |

### 7.3 TDD 测试用例示例

```typescript
// AuthService.test.ets

describe('AuthService', () => {
  describe('loginWithHuawei', () => {
    it('should return success when backend returns 200', async () => {
      // Arrange: mock ApiClient.post 返回 { user, session_id }
      // Act: await AuthService.loginWithHuawei('test_auth_code')
      // Assert: result.success === true, AuthService.isLoggedIn() === true
    });

    it('should return error when backend returns 400', async () => {
      // Arrange: mock ApiClient.post 抛出 BusinessError
      // Act: await AuthService.loginWithHuawei('invalid_code')
      // Assert: result.success === false, result.error === '授权失败，请重试'
    });

    it('should return network error on timeout', async () => {
      // Arrange: mock ApiClient.post 抛出 NetworkError
      // Act: await AuthService.loginWithHuawei('test_auth_code')
      // Assert: result.success === false, result.error === '网络连接失败，请重试'
    });
  });

  describe('validateSession', () => {
    it('should return true when session is valid', async () => {
      // Arrange: mock ApiClient.get 返回 { valid: true, user: {...} }
      // Assert: result === true, AuthService.getCurrentUser() !== null
    });

    it('should clear state and return false on 401', async () => {
      // Arrange: mock ApiClient.get 抛出 401 UnauthorizedError
      // Assert: result === false, AuthService.getSessionId() === ''
    });

    it('should enter offline mode on network error with cached user', async () => {
      // Arrange: mock ApiClient.get 抛出 NetworkError, 本地有 user 缓存
      // Assert: result === true, AuthService.isOfflineMode() === true
    });
  });
});
```

---

## 八、错误处理决策树

```
登录/请求出错
    │
    ├─ Account Kit 错误
    │   ├─ 1001502012 (用户取消)     → 静默返回
    │   ├─ 1001502001 (账号未登录)   → Toast "请登录华为账号后重试"
    │   ├─ 1001502005 (网络异常)     → Toast "网络异常，请检查网络后重试"
    │   ├─ 12300001  (系统异常)      → Toast "系统异常，请稍后重试"
    │   └─ 其他                      → Toast "登录失败，请重试"
    │
    ├─ 后端 API 错误
    │   ├─ 400 (参数错误)            → Toast "授权失败，请重试"
    │   ├─ 401 (Session 失效)        → 清除本地状态 → 跳转登录页
    │   ├─ 403 (无权限)              → Toast "无权限访问"
    │   └─ 500 (服务器错误)          → Toast "服务器异常，请稍后重试"
    │
    └─ 网络错误
        ├─ 无网络                    → Toast "网络连接失败"
        └─ 超时                      → Toast "请求超时，请重试"
```

---

## 九、实施阶段与任务分解

### Phase 1：数据模型与基础设施（前置依赖）

| # | 任务 | 文件 | 说明 |
|---|------|------|------|
| 1.1 | 创建 `User.ets` 数据模型 | `viewmodel/User.ets` | 含序列化方法 |
| 1.2 | 创建 `AuthState.ets` | `viewmodel/AuthState.ets` | Session 模式 |
| 1.3 | 更新 `LoginType.ets` | `viewmodel/LoginType.ets` | 移除 GUEST |
| 1.4 | 创建 `AuthConstant.ets` | `common/constants/AuthConstant.ets` | 常量定义 |
| 1.5 | 创建 `ApiClient.ets` | `common/network/ApiClient.ets` | HTTP 客户端 + Session 拦截器 |

### Phase 2：认证服务层

| # | 任务 | 文件 | 说明 |
|---|------|------|------|
| 2.1 | 重写 `AuthService.ets` | `service/AuthService.ets` | Session 模式 + 华为登录 |
| 2.2 | 更新 `StorageService.ets` | `service/StorageService.ets` | 增加 session_id 存取 |
| 2.3 | 编写 AuthService 单元测试 | `entry/src/test/AuthService.test.ets` | TDD |

### Phase 3：UI 层集成

| # | 任务 | 文件 | 说明 |
|---|------|------|------|
| 3.1 | 创建 `HuaweiLoginButton.ets` | `view/components/HuaweiLoginButton.ets` | 封装 Account Kit 按钮 |
| 3.2 | 改造 `Index.ets` 登录页 | `pages/Index.ets` | 集成华为登录按钮 |
| 3.3 | 更新 `EntryAbility.ets` | `entryability/EntryAbility.ets` | 初始化链 |

### Phase 4：集成测试与验证

| # | 任务 | 说明 |
|---|------|------|
| 4.1 | 端到端登录测试 | 真机/模拟器验证完整流程 |
| 4.2 | 自动登录测试 | 冷启动/热启动场景 |
| 4.3 | 离线降级测试 | 断网场景验证 |
| 4.4 | 错误处理测试 | 各错误码验证 |

---

## 十、风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 华为开发者账号审核未通过 | 无法使用 Account Kit | 提前申请，同时准备测试环境 Client ID |
| `LoginWithHuaweiIDButton` 组件在低版本 HarmonyOS 不支持 | 部分设备无法登录 | SDK 版本要求 HarmonyOS 6.0.1(21)+，已在 module.json5 声明 |
| 后端 Session 表性能 | 每次请求查 DB | MVP 阶段用户量小，可接受；后续可引入 Redis 缓存 |
| Authorization Code 一次性使用 | 网络重试时 code 已失效 | 后端做好幂等处理，客户端不重试登录请求 |

---

## 附录 A：华为 Account Kit 错误码速查

| 错误码 | 含义 | 客户端处理 |
|--------|------|-----------|
| 1001502001 | 账号未登录 | Toast 提示 |
| 1001502005 | 网络异常 | Toast 提示 |
| 1001502009 | 内部错误 | Toast 提示 |
| 1001502012 | 用户取消 | 静默返回 |
| 1001500002 | 重复请求 | 自动忽略 |
| 1005300001 | 未同意用户协议 | Toast 提示 |
| 12300001 | 系统服务异常 | Toast 提示 |

## 附录 B：与登录流程图（v2.1）的对照

本方案完全遵循 `specs/functional/登录流程图.md` v2.1 中定义的 Session 模式：

| 流程图章节 | 本方案对应 |
|-----------|-----------|
| §0 方案总览 | 第五节 5.3 接口鉴权流程图 |
| §1 App 启动与自动登录 | 第六节 6.4 服务初始化链 + 6.2 AuthService.validateSession() |
| §2 华为账号登录流程 | 第六节 6.1 HuaweiLoginButton + 6.2 loginWithHuawei() |
| §3 请求鉴权全流程 | 第五节 5.2 ApiClient 设计 |
| §5 登出流程 | 第六节 6.2 AuthService.logout() |
| §6 错误处理决策树 | 第八节 |
| §7 客户端数据模型 | 第四节 |
