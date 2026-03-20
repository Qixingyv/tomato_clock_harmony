# 用户认证功能规格

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：MVP核心功能

---

## 1. 功能概述

用户认证系统是番茄钟应用MVP阶段的核心功能，支持用户通过微信和华为账号进行快速登录，实现跨设备数据同步。

### 1.1 功能目标

- 提供便捷的用户身份认证
- 支持跨设备数据同步
- 保护用户数据隐私
- 提供流畅的一键登录体验

### 1.2 MVP登录方式

| 登录方式 | MVP范围 | 优先级 | 说明 |
|---------|---------|--------|------|
| 微信登录 | ✅ 包含 | P0 | 主要登录方式 |
| 华为账号登录 | ✅ 包含 | P0 | 鸿蒙生态原生支持 |
| 手机号验证码登录 | ❌ 不包含 | P1 | 后续版本 |
| 密码登录 | ❌ 不包含 | P2 | 后续版本 |
| 游客模式 | ❌ 不包含 | P2 | 后续版本 |

---

## 2. 用户流程

### 2.1 首次登录流程

```
[用户打开App]
      │
      ▼
[检查本地登录状态]
      │
      ├─ 已登录 ──→ [进入主页]
      │
      └─ 未登录 ──→ [登录页]
                      │
                      ▼
         ┌────────────────────────┐
         │   选择登录方式          │
         ├────────────────────────┤
         │  [微信]  [华为账号]     │
         └────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
         ▼                         ▼
    [点击微信登录]          [点击华为登录]
         │                         │
         ▼                         ▼
    [拉起微信授权]          [拉起华为授权]
         │                         │
         ▼                         ▼
    [用户确认授权]          [用户确认授权]
         │                         │
         ▼                         │
    [获取授权码]                   │
         │                         │
         └────────────┬────────────┘
                      ▼
              [发送授权码到后端]
                      │
                      ▼
              [后端验证并创建/获取用户]
                      │
                      ▼
              [返回用户信息+Token]
                      │
                      ▼
              [保存Token到本地]
                      │
                      ▼
              [进入主页]
```

### 2.2 自动登录流程

```
[App启动或前台切换]
      │
      ▼
[读取本地Token]
      │
      ├─ 无Token ──→ [显示登录页]
      │
      └─ 有Token ──→ [调用Token验证接口]
                      │
          ┌───────────┼───────────┐
          │                       │
          ▼                       ▼
     [Token有效]            [Token无效]
          │                       │
          ▼                       ▼
    [获取用户信息]          [清除本地Token]
          │                       │
          ▼                       ▼
    [进入主页]              [显示登录页]
```

### 2.3 登出流程

```
[个人中心页]
      │
      ▼
[点击"退出登录"]
      │
      ▼
[确认弹窗]
      │
      ├─ 取消 ──→ [返回]
      │
      └─ 确认 ──→ [调用登出接口]
                    │
                    ▼
              [后端清除Token]
                    │
                    ▼
            [清除本地Token]
                    │
                    ▼
            [清除用户数据缓存]
                    │
                    ▼
            [返回登录页]
```

---

## 3. 功能详细设计

### 3.1 登录页（Index.ets）

#### 3.1.1 页面布局

```
┌─────────────────────────────────────┐
│                                     │
│         [Logo + App名称]            │
│                                     │
│      番茄钟 - 让专注成为习惯         │
│                                     │
├─────────────────────────────────────┤
│                                     │
│          登录方式                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   [微信图标]                │   │
│  │   微信一键登录              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   [华为图标]                │   │
│  │   华为账号登录              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ──────────── 分隔符 ────────────   │
│                                     │
│       登录即表示同意《用户协议》     │
│          和《隐私政策》             │
│                                     │
└─────────────────────────────────────┘
```

#### 3.1.2 交互规则

**登录按钮：**
- 默认状态：可点击，品牌色
- 点击后：显示加载状态（loading动画）
- 授权成功：跳转主页
- 授权失败：震动提示，显示错误Toast

**授权处理：**
- 用户取消授权：返回登录页，不提示错误
- 授权失败：显示"授权失败，请重试"
- 网络错误：显示"网络连接失败，请检查网络"

### 3.2 微信登录

#### 3.2.1 接入准备

**申请微信开放平台账号：**
1. 注册微信开放平台账号
2. 创建移动应用
3. 获取AppID和AppSecret
4. 配置应用签名和包名

**集成微信SDK：**
```json5
// oh-package.json5
{
  "dependencies": {
    "@wechat/oauth": "^1.0.0"  // 微信授权SDK
  }
}
```

#### 3.2.2 授权流程

```
[客户端]
   │
   │ 1. 拉起微信授权
   ▼
[微信App]
   │
   │ 2. 用户确认授权
   ▼
[微信服务器] ──→ 3. 返回授权码(code)
   │                    │
   │                    ▼
   │              [客户端接收code]
   │                    │
   │ 4. 发送code到后端   │
   ▼                    ▼
[后端服务器] ←──────────┘
   │
   │ 5. 用code换取access_token
   ▼
[微信服务器]
   │
   │ 6. 返回用户信息
   ▼
[后端服务器]
   │
   │ 7. 创建/获取用户，生成Token
   ▼
[返回客户端]
```

#### 3.2.3 错误处理

| 错误码 | 含义 | 处理方式 |
|--------|------|----------|
| -1     | 一般错误 | 提示"授权失败，请重试" |
| -2     | 用户取消 | 静默返回登录页 |
| -3     | 发送失败 | 提示"发送失败，请重试" |
| -4     | 授权失败 | 提示"授权失败，请重试" |
| -5     | 微信不支持 | 提示"请先安装微信" |

### 3.3 华为账号登录

#### 3.3.1 接入准备

**申请华为开发者账号：**
1. 注册华为开发者联盟
2. 创建项目和应用
3. 获取Client ID和Client Secret
4. 配置应用签名

**集成华为Account SDK：**
```json5
// oh-package.json5
{
  "dependencies": {
    "@hms.core/account": "^6.0.0"  // 华为账号SDK
  }
}
```

#### 3.3.2 授权流程

```
[客户端]
   │
   │ 1. 拉起华为账号授权
   ▼
[华为账号中心]
   │
   │ 2. 用户确认授权
   ▼
[华为服务器] ──→ 3. 返回授权码(code)
   │                    │
   │                    ▼
   │              [客户端接收code]
   │                    │
   │ 4. 发送code到后端   │
   ▼                    ▼
[后端服务器] ←──────────┘
   │
   │ 5. 用code换取access_token
   ▼
[华为服务器]
   │
   │ 6. 返回用户信息
   ▼
[后端服务器]
   │
   │ 7. 创建/获取用户，生成Token
   ▼
[返回客户端]
```

#### 3.3.3 错误处理

| 错误码 | 含义 | 处理方式 |
|--------|------|----------|
| 1001  | 网络异常 | 提示"网络连接失败" |
| 1002  | 解析错误 | 提示"授权失败，请重试" |
| 1003  | 用户取消 | 静默返回登录页 |
| 1004  | 授权失败 | 提示"授权失败，请重试" |
| 1005  | 账号未绑定 | 提示"请先绑定华为账号" |

---

## 4. API接口设计

### 4.1 微信登录

**请求：**
```http
POST /api/v1/auth/wechat/login

Content-Type: application/json

{
  "code": "091a3b5a2b5c4d1e2f3a4b5c6d7e8f9g"
}
```

**响应：**
```json
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

### 4.2 华为账号登录

**请求：**
```http
POST /api/v1/auth/huawei/login

Content-Type: application/json

{
  "code": "CjAaBhkrCKD...",
  "grant_type": "authorization_code"
}
```

**响应：**
```json
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

### 4.3 Token验证

**请求：**
```http
GET /api/v1/auth/validate

Authorization: Bearer {access_token}
```

**响应：**
```json
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

### 4.4 Token刷新

**请求：**
```http
POST /api/v1/auth/refresh

Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**响应：**
```json
{
  "code": 200,
  "message": "刷新成功",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 604800
  }
}
```

### 4.5 登出

**请求：**
```http
POST /api/v1/auth/logout

Authorization: Bearer {access_token}
```

**响应：**
```json
{
  "code": 200,
  "message": "登出成功"
}
```

---

## 5. 数据模型

### 5.1 用户表（user）

```sql
CREATE TABLE user (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
  openid          VARCHAR(64) COMMENT '微信OpenID',
  unionid         VARCHAR(64) COMMENT '微信UnionID',
  huawei_uid      VARCHAR(64) COMMENT '华为账号UID',
  nickname        VARCHAR(100) COMMENT '昵称',
  avatar          VARCHAR(512) COMMENT '头像URL',
  login_type      VARCHAR(20) NOT NULL COMMENT '登录类型：wechat/huawei',
  last_login_at   DATETIME COMMENT '最后登录时间',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  UNIQUE KEY uk_openid (openid),
  UNIQUE KEY uk_huawei_uid (huawei_uid),
  INDEX idx_login_type (login_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

### 5.2 用户绑定表（user_bind）

用于支持用户绑定多种登录方式：

```sql
CREATE TABLE user_bind (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '绑定ID',
  user_id         BIGINT NOT NULL COMMENT '用户ID',
  bind_type       VARCHAR(20) NOT NULL COMMENT '绑定类型：wechat/huawei',
  bind_id         VARCHAR(64) NOT NULL COMMENT '绑定ID',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',

  UNIQUE KEY uk_bind (bind_type, bind_id),
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户绑定表';
```

### 5.3 Token黑名单表（token_blacklist）

```sql
CREATE TABLE token_blacklist (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '记录ID',
  token           VARCHAR(512) NOT NULL COMMENT 'Token',
  expired_at      DATETIME NOT NULL COMMENT '过期时间',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

  INDEX idx_token (token),
  INDEX idx_expired_at (expired_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Token黑名单表';
```

---

## 6. 安全设计

### 6.1 Token安全

| 安全措施 | 说明 |
|---------|------|
| JWT签名 | 使用RS256算法签名，防止篡改 |
| 过期时间 | access_token有效期7天，refresh_token有效期30天 |
| Token刷新 | refresh_token只能使用一次，使用后失效 |
| 黑名单机制 | 登出时将Token加入黑名单 |
| HTTPS传输 | 全部使用HTTPS加密传输 |

### 6.2 授权安全

| 安全措施 | 说明 |
|---------|------|
| 授权码有效期 | 授权码只能使用一次，有效期5分钟 |
| 防重放攻击 | 授权码使用后立即失效 |
| 验证来源 | 验证请求来源的合法性 |
| 限流保护 | 同一IP限制请求频率 |

### 6.3 数据安全

| 安全措施 | 说明 |
|---------|------|
| 敏感数据加密 | 敏感信息加密存储 |
| 最小权限原则 | 仅获取必要的用户信息 |
| 数据隔离 | 用户数据严格隔离 |
| 审计日志 | 记录所有认证操作 |

---

## 7. 前端数据模型

### 7.1 用户信息模型

```typescript
// User.ets
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

// 登录类型枚举
export enum LoginType {
  WECHAT = 'wechat',
  HUAWEI = 'huawei'
}
```

### 7.2 认证状态模型

```typescript
// AuthState.ets
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

### 7.3 本地存储

```typescript
// AuthService.ets
import preferences from '@ohos.data.preferences';

export class AuthService {
  private static readonly AUTH_KEY = 'auth_state';
  private preferences: preferences.Preferences | null = null;

  // 保存认证状态
  async saveAuthState(state: AuthState): Promise<void> {
    if (!this.preferences) {
      this.preferences = await preferences.getPreferences(getContext(), 'AUTH_STORE');
    }
    await this.preferences.put(AuthService.AUTH_KEY, JSON.stringify(state));
    await this.preferences.flush();
  }

  // 获取认证状态
  async getAuthState(): Promise<AuthState | null> {
    if (!this.preferences) {
      this.preferences = await preferences.getPreferences(getContext(), 'AUTH_STORE');
    }
    const data = await this.preferences.get(AuthService.AUTH_KEY, '');
    if (data) {
      return JSON.parse(data as string) as AuthState;
    }
    return null;
  }

  // 清除认证状态
  async clearAuthState(): Promise<void> {
    if (!this.preferences) {
      this.preferences = await preferences.getPreferences(getContext(), 'AUTH_STORE');
    }
    await this.preferences.delete(AuthService.AUTH_KEY);
    await this.preferences.flush();
  }
}
```

---

## 8. 错误处理

### 8.1 网络错误

| 错误 | 处理 |
|------|------|
| 网络不可达 | 显示"网络连接失败，请检查网络" |
| 请求超时 | 显示"请求超时，请重试" |
| 服务器错误(500) | 显示"服务器异常，请稍后重试" |

### 8.2 授权错误

| 错误 | 处理 |
|------|------|
| 用户取消 | 静默返回，不显示错误 |
| 授权失败 | 显示"授权失败，请重试" |
| 未安装应用 | 显示"请先安装对应应用" |
| 授权过期 | 显示"授权已过期，请重新授权" |

### 8.3 业务错误

| 错误 | 处理 |
|------|------|
| Token无效 | 清除本地Token，显示登录页 |
| Token过期 | 自动刷新Token |
| 用户被封禁 | 显示"账号已被封禁，请联系客服" |

---

## 9. 用户体验设计

### 9.1 加载状态

| 场景 | 反馈 |
|------|------|
| 点击登录按钮 | 按钮显示loading动画 |
| 授权中 | 全屏loading |
| Token刷新中 | 静默刷新，不显示loading |

### 9.2 反馈提示

| 操作 | 反馈 |
|------|------|
| 授权成功 | Toast提示"登录成功"，跳转主页 |
| 登出成功 | Toast提示"已退出登录" |
| 自动登录失败 | 静默处理，显示登录页 |

### 9.3 动画效果

- 页面切换：淡入淡出
- 按钮点击：缩放动画
- Loading：旋转动画

---

## 10. 集成配置

### 10.1 微信开放平台配置

**申请信息：**
- 应用名称：番茄钟
- 应用包名：com.tomato.clock
- 应用签名：MD5签名

**回调配置：**
- 无需配置回调（移动应用）

### 10.2 华为开发者联盟配置

**申请信息：**
- 应用名称：番茄钟
- 包名：com.tomato.clock
- SHA256指纹证书

**授权范围：**
- 基础账号信息
- 昵称
- 头像

---

## 11. 后续扩展计划

### 11.1 v1.1计划

- 手机号验证码登录
- 账号绑定功能
- 修改昵称头像
- 第三方账号解绑

### 11.2 v2.0计划

- 生物识别登录（指纹、面部）
- 多设备登录管理
- 登录设备提醒
- 账号安全中心

---

**相关文档：**
- [产品概述](./overview.md)
- [技术实现方案](../technical/plan.md)
- [数据模型](../technical/data-model.md)
- [导航设计](../ui/navigation.md)
