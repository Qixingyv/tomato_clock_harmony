# Phase 5: Backend Database - 后端数据层

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：规划中
>
> **目标**: 实现数据库访问层和表结构。
>
> **依赖**: Phase 1 完成

---

## Phase 5 任务列表

### 数据库表创建

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P5-001 | 创建 user 表 SQL | IMPL | pending | - | 用户表 |
| P5-002 | 创建 task 表 SQL | IMPL | pending | - | 任务表 |
| P5-003 | 创建 tomato_record 表 SQL | IMPL | pending | - | 番茄记录表 |
| P5-004 | 创建 user_bind 表 SQL [P] | IMPL | pending | - | 用户绑定表 |
| P5-005 | 创建 token_blacklist 表 SQL [P] | IMPL | pending | - | Token黑名单表 |

---

### MyBatis XML 映射文件

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P5-006 | 创建 UserMapper.xml | IMPL | pending | P5-001 | 用户Mapper映射 |
| P5-007 | 创建 TaskMapper.xml | IMPL | pending | P5-002 | 任务Mapper映射 |
| P5-008 | 创建 RecordMapper.xml | IMPL | pending | P5-003 | 记录Mapper映射 |

---

### 数据库初始化脚本

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P5-009 | 创建数据库初始化脚本 | IMPL | pending | P5-001~P5-005 | init.sql |
| P5-010 | 创建测试数据脚本 | IMPL | pending | P5-009 | test-data.sql |

---

## 详细任务说明

### P5-001: 创建 user 表 SQL

**文件**: `tomato-clock-backend/src/main/resources/db/migration/V1__create_user_table.sql`

**描述**: 创建用户表

**实现内容**: 见 `data-model.md` 第9.1节

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

**验收标准**:
- [ ] 字段定义与实体类一致
- [ ] 包含所有索引
- [ ] 包含默认值

---

### P5-002: 创建 task 表 SQL

**文件**: `tomato-clock-backend/src/main/resources/db/migration/V2__create_task_table.sql`

**描述**: 创建任务表

**实现内容**: 见 `data-model.md` 第9.4节

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

**验收标准**:
- [ ] 字段定义与实体类一致
- [ ] 支持两种模式的字段
- [ ] 包含逻辑删除字段

---

### P5-003: 创建 tomato_record 表 SQL

**文件**: `tomato-clock-backend/src/main/resources/db/migration/V3__create_tomato_record_table.sql`

**描述**: 创建番茄记录表

**实现内容**: 见 `data-model.md` 第9.5节

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

**验收标准**:
- [ ] 包含任务快照字段
- [ ] 索引正确设置

---

### P5-004: 创建 user_bind 表 SQL [P]

**文件**: `tomato-clock-backend/src/main/resources/db/migration/V4__create_user_bind_table.sql`

**描述**: 创建用户绑定表（v2.0功能）

**实现内容**: 见 `data-model.md` 第9.2节

---

### P5-005: 创建 token_blacklist 表 SQL [P]

**文件**: `tomato-clock-backend/src/main/resources/db/migration/V5__create_token_blacklist_table.sql`

**描述**: 创建Token黑名单表（v2.0功能）

**实现内容**: 见 `data-model.md` 第9.3节

---

### P5-006: 创建 UserMapper.xml

**文件**: `tomato-clock-backend/src/main/resources/mapper/UserMapper.xml`

**描述**: 用户Mapper映射文件

**实现内容**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.tomato.modules.user.mapper.UserMapper">

    <resultMap id="BaseResultMap" type="com.tomato.modules.user.entity.User">
        <id column="id" property="id"/>
        <result column="openid" property="openid"/>
        <result column="unionid" property="unionid"/>
        <result column="huawei_uid" property="huaweiUid"/>
        <result column="nickname" property="nickname"/>
        <result column="avatar" property="avatar"/>
        <result column="login_type" property="loginType"/>
        <result column="last_login_at" property="lastLoginAt"/>
        <result column="default_tomato_minutes" property="defaultTomatoMinutes"/>
        <result column="default_rest_minutes" property="defaultRestMinutes"/>
        <result column="status" property="status"/>
        <result column="created_at" property="createdAt"/>
        <result column="updated_at" property="updatedAt"/>
    </resultMap>

    <select id="selectByOpenid" resultMap="BaseResultMap">
        SELECT * FROM user
        WHERE openid = #{openid} AND deleted = 0
    </select>

    <select id="selectByHuaweiUid" resultMap="BaseResultMap">
        SELECT * FROM user
        WHERE huawei_uid = #{huaweiUid} AND deleted = 0
    </select>

</mapper>
```

**验收标准**:
- [ ] ResultMap与实体类一致
- [ ] SQL语句正确

---

### P5-007: 创建 TaskMapper.xml

**文件**: `tomato-clock-backend/src/main/resources/mapper/TaskMapper.xml`

**描述**: 任务Mapper映射文件

**实现内容**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.tomato.modules.task.mapper.TaskMapper">

    <resultMap id="BaseResultMap" type="com.tomato.modules.task.entity.Task">
        <id column="id" property="id"/>
        <!-- 其他字段映射 -->
    </resultMap>

    <select id="selectByUserId" resultMap="BaseResultMap">
        SELECT * FROM task
        WHERE user_id = #{userId} AND deleted = 0
        ORDER BY priority DESC, created_at DESC
    </select>

    <select id="selectByUserIdAndStatus" resultMap="BaseResultMap">
        SELECT * FROM task
        WHERE user_id = #{userId} AND status = #{status} AND deleted = 0
    </select>

</mapper>
```

---

### P5-008: 创建 RecordMapper.xml

**文件**: `tomato-clock-backend/src/main/resources/mapper/RecordMapper.xml`

**描述**: 记录Mapper映射文件

---

### P5-009: 创建数据库初始化脚本

**文件**: `tomato-clock-backend/src/main/resources/db/init.sql`

**描述**: 数据库初始化脚本

**实现内容**:
```sql
-- 创建数据库
CREATE DATABASE IF NOT EXISTS tomato_clock DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE tomato_clock;

-- 执行所有迁移脚本
SOURCE V1__create_user_table.sql;
SOURCE V2__create_task_table.sql;
SOURCE V3__create_tomato_record_table.sql;
-- ... 其他表
```

---

### P5-010: 创建测试数据脚本

**文件**: `tomato-clock-backend/src/main/resources/db/test-data.sql`

**描述**: 测试数据脚本

**实现内容**:
```sql
-- 插入测试用户
INSERT INTO user (id, openid, nickname, login_type) VALUES
(1, 'test_openid_1', '测试用户1', 'wechat'),
(2, 'test_openid_2', '测试用户2', 'huawei');

-- 插入测试任务
INSERT INTO task (id, user_id, name, mode, status) VALUES
(1, 1, '测试待办任务', 1, 1),
(2, 1, '测试计划任务', 2, 1);
```

---

## 阶段完成标准

- [ ] 所有表创建完成
- [ ] 所有Mapper XML创建完成
- [ ] 初始化脚本可执行
- [ ] 测试数据可导入

---

**相关文档：**
- [数据库设计](../technical/data-model.md#9-数据库表结构)
- [MyBatis配置](../technical/plan.md#621-mybatis配置)
