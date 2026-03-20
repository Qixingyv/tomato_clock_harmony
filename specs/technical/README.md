# 技术文档

本目录包含番茄钟应用的技术实现相关文档。

## 文档索引

| 文档 | 说明 | 状态 |
|------|------|------|
| [plan.md](./plan.md) | 技术实现方案 | 技术方案确认中 |
| [data-model.md](./data-model.md) | 数据模型定义 | 需求确认中 |

---

## plan.md - 技术实现方案

**版本：** v1.0
**创建日期：** 2026-03-19

### 内容概要

1. **技术上下文总结**
   - 前端：ArkTS + ArkUI
   - 后端：Java 17 + Spring Boot 3.1
   - 数据库：MySQL 8.0
   - ORM：MyBatis-Plus 3.5

2. **"合宪性"审查**
   - 逐条对照 constitution.md 验证技术方案合规性
   - 定义错误处理策略
   - 制定测试策略

3. **项目结构细化**
   - 前端：页面、组件、服务层划分
   - 后端：DDD模块化设计

4. **核心数据结构**
   - ToDoListClass（任务模型）
   - TaskStatus、TaskMode 枚举
   - TimerViewModel（计时器模型）
   - 统计数据模型

5. **接口设计**
   - 任务模块 API（CRUD、完成番茄、恢复任务）
   - 统计模块 API（统计查询、历史记录）
   - 用户模块 API（设备登录、设置管理）
   - 数据同步 API（v2.0）

---

## 快速导航

### 按角色查看

**前端开发（鸿蒙客户端）**
- [plan.md - 3.1 前端项目结构](./plan.md#31-前端项目结构鸿蒙客户端)
- [plan.md - 4.1 前端数据模型](./plan.md#41-前端数据模型)
- [plan.md - 6.1 前端关键技术点](./plan.md#61-前端关键技术点)

**后端开发（Spring Boot + MyBatis）**
- [plan.md - 3.3 后端项目结构](./plan.md#33-后端项目结构spring-boot)
- [plan.md - 4.2 后端数据模型](./plan.md#42-后端数据模型)
- [plan.md - 5.2 任务模块接口](./plan.md#52-任务模块接口)
- [plan.md - 6.2 后端关键技术点](./plan.md#62-后端关键技术点)
- [plan.md - 6.2.1 MyBatis配置](./plan.md#621-mybatis配置)
- [plan.md - 6.2.2 Mapper接口示例](./plan.md#622-mapper接口示例)

**数据库设计**
- [plan.md - 7.1 数据库设计](./plan.md#71-数据库设计)
- [data-model.md - 数据模型定义](./data-model.md)

### 技术栈
- 前端：ArkTS + ArkUI
- 后端：Java 17 + Spring Boot 3.1 + MyBatis
- 数据库：MySQL 8.0

---

## 相关文档

- [产品概述](../functional/overview.md)
- [任务模式设计](../functional/task-modes.md)
- [任务管理](../functional/task-management.md)
- [计时器功能](../functional/timer-feature.md)
- [统计功能](../functional/statistics.md)
- [变更记录](../changelog.md)
