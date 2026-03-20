# 产品设计文档目录

本目录存放番茄钟应用的所有产品设计相关文档。

## 目录结构

```
specs/
├── README.md                    # 本文件
├── functional/                  # 功能需求文档
│   ├── overview.md             # 产品概述
│   ├── task-modes.md           # 任务模式设计
│   ├── timer-feature.md        # 计时器功能
│   ├── task-management.md      # 任务管理
│   └── statistics.md           # 统计功能
├── ui/                          # 界面设计文档
│   ├── navigation.md           # 导航结构
│   ├── pages.md                # 页面布局
│   └── components.md           # 组件设计
├── technical/                   # 技术规格文档
│   ├── data-model.md           # 数据模型
│   ├── api-design.md           # API设计（未来）
│   └── sync-strategy.md        # 同步策略（未来）
└── changelog.md                 # 需求变更记录
```

## 文档说明

### functional/ - 功能需求
存放产品功能相关的详细需求文档：
- `overview.md` - 产品概述、愿景、目标用户
- `user-auth.md` - 用户认证功能（微信登录、华为账号登录）
- `task-modes.md` - 待办模式与计划模式详细设计
- `timer-feature.md` - 计时器功能详细说明
- `task-management.md` - 任务列表、筛选、排序等
- `statistics.md` - 统计功能需求（v1.1）

### ui/ - 界面设计
存放用户界面相关的设计文档：
- `navigation.md` - 应用导航结构、页面流转
- `pages.md` - 各页面布局设计
- `components.md` - 可复用组件设计规范

### technical/ - 技术规格
存放技术实现相关的文档：
- `data-model.md` - 数据模型设计
- `api-design.md` - API接口设计（云端同步功能）
- `sync-strategy.md` - 数据同步策略

## 文档规范

1. **命名规范**：使用小写字母和连字符，如 `task-modes.md`
2. **版本控制**：每次重大更新更新文档头部版本号
3. **交叉引用**：使用相对路径引用其他文档
4. **图片资源**：如有图片，放在对应目录的 `assets/` 子目录

## 更新日志

详见 `changelog.md`
