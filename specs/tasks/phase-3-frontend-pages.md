# Phase 3: Frontend Pages - 前端页面组件

> 版本：v1.0
> 创建日期：2026-03-19
> 状态：规划中
>
> **目标**: 实现用户界面页面和组件。
>
> **依赖**: Phase 1, Phase 2 完成

---

## Phase 3 任务列表

### 登录页面

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-001 | 实现 Index 登录页面 | IMPL | pending | P2-004, P1-023 | 登录/欢迎页面 |

---

### 主页面

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-002 | 实现 MainPage 主页面 | IMPL | pending | P1-023 | Tab导航容器 |

---

### 任务列表视图

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-003 | 实现 ToDoList 视图组件 | IMPL | pending | P2-006 | 任务列表视图 |
| P3-004 | 实现 TaskCard 组件 [P] | IMPL | pending | P3-003 | 任务卡片组件 |

---

### 计时器页面

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-005 | 实现 CountDownTimer 页面 | IMPL | pending | P2-008, P1-008 | 计时器页面 |
| P3-006 | 实现 TimerProgress 组件 [P] | IMPL | pending | P3-005 | 环形进度条组件 |

---

### 任务编辑页面

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-007 | 实现 TaskEdit 页面 | IMPL | pending | P2-006, P2-014 | 任务创建/编辑页面 |

---

### 个人中心视图

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-008 | 实现 Profile 视图组件 | IMPL | pending | P2-004 | 个人中心视图 |

---

### 统计页面

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-009 | 实现 Statistics 视图组件 | IMPL | pending | P2-010 | 统计页面视图 |
| P3-010 | 实现 StatCard 组件 [P] | IMPL | pending | P3-009 | 统计卡片组件 |

---

### 路由配置

| 任务ID | 任务名称 | 类型 | 状态 | 依赖 | 说明 |
|--------|----------|------|------|------|------|
| P3-011 | 配置 route_map.json | CONF | pending | P3-001, P3-002, P3-005, P3-007 | 路由映射配置 |

---

## 详细任务说明

### P3-001: 实现 Index 登录页面

**文件**: `entry/src/main/ets/pages/Index.ets`

**描述**: 登录/欢迎页面，支持微信和华为账号登录

**布局**: 见 `ui/pages.md` 第7.2节

**实现内容**:
```typescript
import { AuthService } from '../service/AuthService';
import { Router } from '@ohos.router';
import { GlobalNavStack } from '../common/GlobalNavStack';
import { Logger } from '../common/Logger';

@Entry
@Component
struct Index {
  @State private isLoading: boolean = false;
  @State private logoResource: Resource = $r('app.media.app_icon');

  async aboutToAppear() {
    // 检查自动登录
    const loggedIn = await this.checkAutoLogin();
    if (loggedIn) {
      this.navigateToMain();
    }
  }

  // 检查自动登录
  private async checkAutoLogin(): Promise<boolean> {
    try {
      await AuthService.init();
      return AuthService.isLoggedIn();
    } catch (error) {
      Logger.error('Auto login check failed', error as Error);
      return false;
    }
  }

  // 跳转到主页
  private navigateToMain(): void {
    GlobalNavStack.pushPathByName('MainPage', null);
  }

  // 微信登录
  private async handleWechatLogin(): Promise<void> {
    this.isLoading = true;
    try {
      // 拉起微信授权
      const code = await this.getWechatAuthCode();
      const result = await AuthService.wechatLogin(code);
      if (result.success) {
        this.navigateToMain();
      } else {
        ToastUtil.showError(result.error || '登录失败');
      }
    } catch (error) {
      Logger.error('Wechat login failed', error as Error);
      ToastUtil.showError('登录失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  // 华为登录
  private async handleHuaweiLogin(): Promise<void> {
    this.isLoading = true;
    try {
      // 拉起华为授权
      const code = await this.getHuaweiAuthCode();
      const result = await AuthService.huaweiLogin(code);
      if (result.success) {
        this.navigateToMain();
      } else {
        ToastUtil.showError(result.error || '登录失败');
      }
    } catch (error) {
      Logger.error('Huawei login failed', error as Error);
      ToastUtil.showError('登录失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  // 获取微信授权码
  private async getWechatAuthCode(): Promise<string> {
    // 微信SDK调用
    return 'mock_code';
  }

  // 获取华为授权码
  private async getHuaweiAuthCode(): Promise<string> {
    // 华为SDK调用
    return 'mock_code';
  }

  build() {
    NavDestination() {
      Column() {
        // Logo和标题
        Image(this.logoResource)
          .width(120)
          .height(120)
          .margin({ top: 80, bottom: 20 })

        Text('欢迎来到番茄钟')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 60 })

        // 登录按钮
        Button('微信一键登录')
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#07C160')
          .margin({ bottom: 16 })
          .enabled(!this.isLoading)
          .onClick(() => this.handleWechatLogin())

        Button('华为账号登录')
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#C4000F')
          .margin({ bottom: 40 })
          .enabled(!this.isLoading)
          .onClick(() => this.handleHuaweiLogin())

        // 用户协议
        Text('登录即表示同意《用户协议》和《隐私政策》')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
  }
}
```

**验收标准**:
- [ ] 页面加载时自动检查登录状态
- [ ] 支持微信登录按钮
- [ ] 支持华为登录按钮
- [ ] 登录中显示加载状态
- [ ] 登录失败显示错误提示
- [ ] 登录成功跳转主页

---

### P3-002: 实现 MainPage 主页面

**文件**: `entry/src/main/ets/pages/MainPage.ets`

**描述**: 主页面，底部Tab导航容器

**布局**: 见 `ui/navigation.md` 第6.3.2节

**实现内容**:
```typescript
import { GlobalNavStack } from '../common/GlobalNavStack';
import { ToDoList } from '../view/ToDoList';
import { Profile } from '../view/Profile';

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Component
struct MainPage {
  @State private currentTabIndex: number = 0;

  build() {
    NavDestination() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          ToDoList()
        }
        .tabBar(this.tabBuilder(0, '任务列表', $r('app.media.ic_todo')))

        TabContent() {
          Profile()
        }
        .tabBar(this.tabBuilder(1, '我的', $r('app.media.ic_profile')))
      }
      .barHeight(56)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  tabBuilder(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? $r('app.color.color_theme') : $r('app.color.color_unselected'))

      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? $r('app.color.color_theme') : $r('app.color.color_unselected'))
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

**验收标准**:
- [ ] 包含两个Tab：任务列表、我的
- [ ] 底部Tab导航正常工作
- [ ] 选中状态高亮显示
- [ ] 图标和文字正确显示

---

### P3-003: 实现 ToDoList 视图组件

**文件**: `entry/src/main/ets/view/ToDoList.ets`

**描述**: 任务列表视图组件

**布局**: 见 `ui/pages.md` 第7.3节

**实现内容**:
```typescript
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TaskService } from '../service/TaskService';
import { GlobalNavStack } from '../common/GlobalNavStack';
import { TaskStatus } from '../viewmodel/TaskStatus';
import { TaskMode } from '../viewmodel/TaskMode';
import { ToastUtil } from '../common/ToastUtil';

@Component
export struct ToDoList {
  @State private tasks: ToDoListClass[] = [];
  @State private selectedStatus: TaskStatus | null = null;
  @State private selectedMode: TaskMode | null = null;

  async aboutToAppear() {
    await this.loadTasks();
  }

  // 加载任务列表
  private async loadTasks(): Promise<void> {
    try {
      await TaskService.init();
      this.tasks = TaskService.getTasks();
      await TaskService.checkTodayReset();
    } catch (error) {
      ToastUtil.showError('加载任务失败');
    }
  }

  // 获取筛选后的任务
  private getFilteredTasks(): ToDoListClass[] {
    let filtered = this.tasks.filter(t => t.status === TaskStatus.WORKING);

    if (this.selectedMode !== null) {
      filtered = filtered.filter(t => t.mode === this.selectedMode);
    }

    return filtered;
  }

  // 跳转到任务编辑页面（新建）
  private navigateToTaskEdit(): void {
    GlobalNavStack.pushPathByName('TaskEditPage', {
      isNew: true,
      task: null
    });
  }

  // 跳转到任务编辑页面（编辑）
  private navigateToTaskEdit(task: ToDoListClass): void {
    GlobalNavStack.pushPathByName('TaskEditPage', {
      isNew: false,
      task: task
    });
  }

  // 跳转到计时器页面
  private navigateToTimer(task: ToDoListClass): void {
    GlobalNavStack.pushPathByName('CountDownTimerPage', task);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('任务列表')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)

        Blank()

        Button('+')
          .fontSize(20)
          .width(40)
          .height(40)
          .onClick(() => this.navigateToTaskEdit())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 任务列表
      List() {
        ForEach(this.getFilteredTasks(), (task: ToDoListClass) => {
          ListItem() {
            TaskCard({
              task: task,
              onEdit: () => this.navigateToTaskEdit(task),
              onStart: () => this.navigateToTimer(task)
            })
          }
        }, (task: ToDoListClass) => task.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 8, right: 8 })
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
    }
    .width('100%')
    .height('100%')
  }
}
```

**验收标准**:
- [ ] 显示所有进行中的任务
- [ ] 点击卡片跳转编辑页面
- [ ] 点击开始按钮跳转计时器
- [ ] 点击+号创建新任务
- [ ] 应用启动时自动检查今日重置

---

### P3-004: 实现 TaskCard 组件 [P]

**文件**: `entry/src/main/ets/view/components/TaskCard.ets`

**描述**: 任务卡片组件

**实现内容**:
```typescript
import { ToDoListClass } from '../../viewmodel/ToDoListClass';
import { TaskMode } from '../../viewmodel/TaskMode';

@Component
export struct TaskCard {
  @Prop task: ToDoListClass;
  onEdit: () => void = () => {};
  onStart: () => void = () => {};

  build() {
    Column() {
      // 标题和标签
      Row() {
        Text(this.task.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Text(this.task.mode === TaskMode.TODO ? '待办' : '计划')
          .fontSize(12)
          .fontColor(this.task.mode === TaskMode.TODO ? '#2196F3' : '#4CAF50')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 任务信息
      Column() {
        Text(`番茄: ${this.task.tomato_minutes}分钟  休息: ${this.task.rest_minutes}分钟`)
          .fontSize(12)
          .fontColor('#666666')

        if (this.task.mode === TaskMode.TODO) {
          Text(`已完成: ${this.task.finished_tomato_count}/${this.task.target_tomato_count}个番茄`)
            .fontSize(12)
            .fontColor('#666666')
        } else {
          Text(`今日: ${this.task.today_finished_count}/${this.task.daily_target_tomato_count}个`)
            .fontSize(12)
            .fontColor('#666666')

          Text(`累计: ${this.task.finished_tomato_count}/${this.task.total_target_tomato_count}个 (${this.task.progress.toFixed(0)}%)`)
            .fontSize(12)
            .fontColor('#666666')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 8 })

      // 开始按钮
      Button('开始专注')
        .width('100%')
        .height(36)
        .fontSize(14)
        .backgroundColor('#FF6B6B')
        .onClick(() => this.onStart())
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ top: 4, bottom: 4 })
    .onClick(() => this.onEdit())
  }
}
```

**验收标准**:
- [ ] 显示任务名称
- [ ] 显示任务模式标签
- [ ] 待办模式显示目标进度
- [ ] 计划模式显示今日和累计进度
- [ ] 点击卡片触发编辑回调
- [ ] 点击按钮触发开始回调

---

### P3-005: 实现 CountDownTimer 页面

**文件**: `entry/src/main/ets/pages/CountDownTimer.ets`

**描述**: 计时器页面

**布局**: 见 `ui/pages.md` 第7.4节

**实现内容**:
```typescript
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TimerViewModel } from '../viewmodel/TimerViewModel';
import { TimerMode } from '../viewmodel/TimerMode';
import { TimerService } from '../service/TimerService';
import { TaskService } from '../service/TaskService';
import { GlobalNavStack } from '../common/GlobalNavStack';
import { Logger } from '../common/Logger';
import promptAction from '@ohos.promptAction';

@Builder
export function CountDownTimerBuilder(task: ToDoListClass) {
  CountDownTimer({ task: task })
}

@Component
struct CountDownTimer {
  @Prop task: ToDoListClass;
  @State timerViewModel: TimerViewModel = new TimerViewModel();
  @State showEndDialog: boolean = false;

  async aboutToAppear() {
    TimerService.setCurrentTask(this.task);
    this.timerViewModel = TimerService.getTimerViewModel();

    // 尝试恢复计时器状态
    const restored = await TimerService.restoreTimerState();
    if (!restored) {
      TimerService.startWorkingMode();
    }
  }

  aboutToDisappear() {
    TimerService.saveTimerState();
  }

  // 暂停/继续
  private handlePauseResume(): void {
    if (this.timerViewModel.isPaused) {
      TimerService.resumeTimer();
    } else {
      TimerService.pauseTimer();
    }
  }

  // 结束计时
  private handleEnd(): void {
    this.showEndDialog = true;
  }

  // 确认结束并记录
  private async confirmEndAndRecord(): Promise<void> {
    const success = await TimerService.completeTomato();
    if (success) {
      ToastUtil.showSuccess('番茄完成！');
      GlobalNavStack.pop();
    } else {
      ToastUtil.showError('记录失败');
    }
    this.showEndDialog = false;
  }

  // 结束不记录
  private confirmEndWithoutRecord(): void {
    TimerService.stopTimer();
    GlobalNavStack.pop();
    this.showEndDialog = false;
  }

  // 取消结束
  private cancelEnd(): void {
    this.showEndDialog = false;
  }

  build() {
    Stack() {
      Column() {
        // 任务标签
        Text(this.task.mode === 1 ? '[待办模式]' : '[计划模式]')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 40, bottom: 20 })

        // 环形进度条和计时器
        Stack() {
          // 环形进度条
          Progress({ value: this.timerViewModel.progress, total: 100, type: ProgressType.Ring })
            .width(200)
            .height(200)
            .color('#FF6B6B')
            .style({ strokeWidth: 12 })

          // 时间显示
          Text(this.timerViewModel.formattedTime)
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
        }
        .margin({ top: 40, bottom: 20 })

        // 状态文字
        Text(this.timerViewModel.currentMode === TimerMode.WORKING ? '专注模式' : '休息模式')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 40 })

        // 任务名称
        Text(this.task.name)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 60 })

        // 操作按钮
        Row() {
          Button(this.timerViewModel.isPaused ? '继续' : '暂停')
            .width('40%')
            .height(48)
            .fontSize(16)
            .onClick(() => this.handlePauseResume())

          Button('结束')
            .width('40%')
            .height(48)
            .fontSize(16)
            .backgroundColor('#F44336')
            .onClick(() => this.handleEnd())
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('100%')
      .height('100%')

      // 结束确认弹窗
      if (this.showEndDialog) {
        this.EndDialog.build()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  EndDialog() {
    Column() {
      Column() {
        Text('确认结束专注模式？')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 24 })

        Button('继续番茄钟')
          .width('100%')
          .height(44)
          .margin({ bottom: 12 })
          .onClick(() => this.cancelEnd())

        Button('结束并记录')
          .width('100%')
          .height(44)
          .backgroundColor('#4CAF50')
          .margin({ bottom: 12 })
          .onClick(() => this.confirmEndAndRecord())

        Button('结束不记录')
          .width('100%')
          .height(44)
          .backgroundColor('#F44336')
          .onClick(() => this.confirmEndWithoutRecord())
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .justifyContent(FlexAlign.Center)
  }
}
```

**验收标准**:
- [ ] 显示环形进度条
- [ ] 显示倒计时时间
- [ ] 显示当前模式（专注/休息）
- [ ] 暂停/继续按钮正确切换
- [ ] 结束按钮显示确认弹窗
- [ ] 弹窗提供三个选项

---

### P3-006: 实现 TimerProgress 组件 [P]

**文件**: `entry/src/main/ets/view/components/TimerProgress.ets`

**描述**: 环形进度条组件（如果ArkUI的Progress组件不满足需求）

**实现内容**: 使用ArkUI的Progress组件或自定义Canvas绘制

**验收标准**:
- [ ] 显示环形进度
- [ ] 支持自定义颜色和宽度
- [ ] 支持进度动画

---

### P3-007: 实现 TaskEdit 页面

**文件**: `entry/src/main/ets/pages/TaskEdit.ets`

**描述**: 任务创建/编辑页面

**布局**: 见 `ui/pages.md` 第7.5节

**实现内容**:
```typescript
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TaskMode } from '../viewmodel/TaskMode';
import { TaskStatus } from '../viewmodel/TaskStatus';
import { TaskService } from '../service/TaskService';
import { TaskValidator, ValidationResult } from '../common/validator/TaskValidator';
import { ToastUtil } from '../common/ToastUtil';
import { GlobalNavStack } from '../common/GlobalNavStack';
import promptAction from '@ohos.promptAction';

interface TaskEditParams {
  isNew: boolean;
  task: ToDoListClass | null;
}

@Builder
export function TaskEditBuilder(params: TaskEditParams) {
  TaskEdit({ isNew: params.isNew, task: params.task })
}

@Component
struct TaskEdit {
  @Prop isNew: boolean = true;
  @Prop task: ToDoListClass | null = null;
  @State private taskName: string = '';
  @State private taskMode: TaskMode = TaskMode.TODO;
  @State private tomatoMinutes: number = 25;
  @State private restMinutes: number = 5;
  @State private targetTomatoCount: number = 1;
  @State private dailyTargetTomatoCount: number = 5;
  @State private deadline: Date | null = null;

  async aboutToAppear() {
    if (this.task) {
      this.taskName = this.task.name;
      this.taskMode = this.task.mode;
      this.tomatoMinutes = this.task.tomato_minutes;
      this.restMinutes = this.task.rest_minutes;
      this.targetTomatoCount = this.task.target_tomato_count || 1;
      this.dailyTargetTomatoCount = this.task.daily_target_tomato_count || 5;
      this.deadline = this.task.deadline;
    }
  }

  // 保存任务
  private async saveTask(): Promise<void> {
    const task = new ToDoListClass();
    if (this.task) {
      task.id = this.task.id;
    }
    task.name = this.taskName;
    task.mode = this.taskMode;
    task.tomato_minutes = this.tomatoMinutes;
    task.rest_minutes = this.restMinutes;
    task.status = TaskStatus.WORKING;
    task.created_at = this.task?.created_at || new Date();
    task.updated_at = new Date();

    if (this.taskMode === TaskMode.TODO) {
      task.target_tomato_count = this.targetTomatoCount;
    } else {
      task.daily_target_tomato_count = this.dailyTargetTomatoCount;
      task.deadline = this.deadline;
    }

    // 验证
    const result: ValidationResult = TaskValidator.validateTaskCreation(task);
    if (!result.valid) {
      ToastUtil.showError(result.errors[0]);
      return;
    }

    // 保存
    const success = this.isNew
      ? await TaskService.createTask(task) !== null
      : await TaskService.updateTask(task);

    if (success) {
      ToastUtil.showSuccess(this.isNew ? '创建成功' : '保存成功');
      GlobalNavStack.pop();
    } else {
      ToastUtil.showError('保存失败');
    }
  }

  // 取消
  private cancel(): void {
    GlobalNavStack.pop();
  }

  // 删除任务
  private async deleteTask(): Promise<void> {
    if (this.isNew || !this.task) {
      return;
    }

    const result = await promptAction.showDialog({
      title: '确认取消此任务？',
      message: '取消后任务将不再显示在列表中，但可在历史记录中查看和恢复。',
      buttons: [
        { text: '返回', color: '#999999' },
        { text: '确认取消', color: '#FF6B6B' }
      ]
    });

    if (result.index === 1) {
      const success = await TaskService.deleteTask(this.task!.id);
      if (success) {
        ToastUtil.showSuccess('任务已取消');
        GlobalNavStack.pop();
      } else {
        ToastUtil.showError('操作失败');
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 标题栏
        Row() {
          Button('< 返回')
            .fontSize(16)
            .backgroundColor(Color.Transparent)
            .onClick(() => this.cancel())

          Text(this.isNew ? '新建任务' : '编辑任务')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button('保存')
            .fontSize(16)
            .backgroundColor(Color.Transparent)
            .onClick(() => this.saveTask())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        // 表单
        Scroll() {
          Column() {
            // 任务名称
            Text('任务名称 *')
              .fontSize(14)
              .margin({ bottom: 8 })

            TextInput({ placeholder: '请输入任务名称', text: this.taskName })
              .onChange((value: string) => this.taskName = value)
              .margin({ bottom: 16 })

            // 任务模式
            Text('任务模式')
              .fontSize(14)
              .margin({ bottom: 8 })

            Row() {
              Radio({ value: '待办', group: 'taskMode' })
                .checked(this.taskMode === TaskMode.TODO)
                .onChange(() => this.taskMode = TaskMode.TODO)

              Text('待办')
                .fontSize(14)
                .margin({ left: 8, right: 24 })

              Radio({ value: '计划', group: 'taskMode' })
                .checked(this.taskMode === TaskMode.PLAN)
                .onChange(() => this.taskMode = TaskMode.PLAN)

              Text('计划')
                .fontSize(14)
                .margin({ left: 8 })
            }
            .margin({ bottom: 16 })

            // 番茄时长
            Text('番茄时长 (分钟) *')
              .fontSize(14)
              .margin({ bottom: 8 })

            TextInput({ placeholder: '25', text: this.tomatoMinutes.toString() })
              .type(InputType.Number)
              .onChange((value: string) => this.tomatoMinutes = parseInt(value) || 25)
              .margin({ bottom: 16 })

            // 休息时长
            Text('休息时长 (分钟) *')
              .fontSize(14)
              .margin({ bottom: 8 })

            TextInput({ placeholder: '5', text: this.restMinutes.toString() })
              .type(InputType.Number)
              .onChange((value: string) => this.restMinutes = parseInt(value) || 5)
              .margin({ bottom: 16 })

            // 待办模式：目标番茄数
            if (this.taskMode === TaskMode.TODO) {
              Text('目标番茄数 *')
                .fontSize(14)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '1', text: this.targetTomatoCount.toString() })
                .type(InputType.Number)
                .onChange((value: string) => this.targetTomatoCount = parseInt(value) || 1)
                .margin({ bottom: 16 })
            }

            // 计划模式：每日目标和截止日期
            if (this.taskMode === TaskMode.PLAN) {
              Text('每日目标番茄数 *')
                .fontSize(14)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '5', text: this.dailyTargetTomatoCount.toString() })
                .type(InputType.Number)
                .onChange((value: string) => this.dailyTargetTomatoCount = parseInt(value) || 5)
                .margin({ bottom: 16 })

              Text('截止日期 (可选)')
                .fontSize(14)
                .margin({ bottom: 8 })

              DatePicker({
                start: new Date(),
                end: new Date(new Date().getFullYear() + 1, 11, 31)
              })
                .onChange((value: DatePickerResult) => {
                  this.deadline = new Date(value.year, value.month - 1, value.day);
                })
                .margin({ bottom: 16 })
            }

            // 底部按钮
            Row() {
              if (!this.isNew) {
                Button('取消')
                  .fontSize(16)
                  .backgroundColor('#999999')
                  .layoutWeight(1)
                  .margin({ right: 8 })
                  .onClick(() => this.cancel())

                Button('删除')
                  .fontSize(16)
                  .backgroundColor('#F44336')
                  .layoutWeight(1)
                  .onClick(() => this.deleteTask())
              } else {
                Button('取消')
                  .fontSize(16)
                  .backgroundColor('#999999')
                  .layoutWeight(1)
                  .onClick(() => this.cancel())
              }
            }
            .width('100%')
            .margin({ top: 24 })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
  }
}
```

**验收标准**:
- [ ] 新建任务时表单为空
- [ ] 编辑任务时表单填充现有数据
- [ ] 切换模式显示/隐藏相应字段
- [ ] 保存前进行表单验证
- [ ] 删除任务显示确认弹窗
- [ ] 成功后返回上一页

---

### P3-008: 实现 Profile 视图组件

**文件**: `entry/src/main/ets/view/Profile.ets`

**描述**: 个人中心视图组件

**实现内容**:
```typescript
import { User } from '../viewmodel/User';
import { LoginType } from '../viewmodel/LoginType';
import { AuthService } from '../service/AuthService';
import { ToastUtil } from '../common/ToastUtil';
import promptAction from '@ohos.promptAction';

@Component
export struct Profile {
  @State private user: User | null = null;

  async aboutToAppear() {
    this.user = AuthService.getCurrentUser();
  }

  // 退出登录
  private async handleLogout(): Promise<void> {
    const result = await promptAction.showDialog({
      title: '确认退出登录？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确认', color: '#FF6B6B' }
      ]
    });

    if (result.index === 1) {
      await AuthService.logout();
      ToastUtil.showSuccess('已退出登录');
      // 跳转到登录页
      router.replaceUrl({ url: 'pages/Index' });
    }
  }

  // 获取登录类型文字
  private getLoginTypeText(type: LoginType): string {
    return type === LoginType.WECHAT ? '微信登录' : '华为账号登录';
  }

  build() {
    Column() {
      // 用户信息卡片
      Column() {
        // 头像
        Image(this.user?.avatarUrl || $r('app.media.default_avatar'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .margin({ bottom: 16 })

        // 昵称
        Text(this.user?.displayName || '番茄用户')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })

        // 登录类型
        Text(this.getLoginTypeText(this.user?.loginType || LoginType.WECHAT))
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .padding(32)
      .backgroundColor('#FFFFFF')
      .margin({ bottom: 8 })

      // 菜单列表
      Column() {
        // 设置
        this.MenuItem('设置', () => {
          ToastUtil.showToast('功能开发中');
        })

        // 关于
        this.MenuItem('关于', () => {
          ToastUtil.showToast('番茄钟 v1.0.0');
        })

        // 退出登录
        Button('退出登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#FFFFFF')
          .fontColor('#F44336')
          .margin({ top: 16 })
          .onClick(() => this.handleLogout())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  MenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(16)
        .layoutWeight(1)

      Text('>')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(onClick)
  }
}
```

**验收标准**:
- [ ] 显示用户头像和昵称
- [ ] 显示登录类型
- [ ] 退出登录显示确认弹窗
- [ ] 退出后清除数据并跳转登录页

---

### P3-009: 实现 Statistics 视图组件

**文件**: `entry/src/main/ets/view/Statistics.ets`

**描述**: 统计页面视图组件

**布局**: 见 `ui/pages.md` 第7.6节

**实现内容**:
```typescript
import { StatisticsData, StatisticsPeriod } from '../viewmodel/StatisticsModels';
import { StatisticsService } from '../service/StatisticsService';

@Component
export struct Statistics {
  @State private currentPeriod: StatisticsPeriod = 'today';
  @State private statistics: StatisticsData | null = null;

  aboutToAppear() {
    this.loadStatistics();
  }

  // 加载统计数据
  private loadStatistics(): void {
    switch (this.currentPeriod) {
      case 'today':
        this.statistics = StatisticsService.getTodayStatistics();
        break;
      case 'week':
        this.statistics = StatisticsService.getWeekStatistics();
        break;
      case 'month':
        this.statistics = StatisticsService.getMonthStatistics();
        break;
    }
  }

  build() {
    Column() {
      // 标题
      Text('数据统计')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .padding(16)

      // 时间维度切换
      Row() {
        this.TabButton('今日', this.currentPeriod === 'today', () => {
          this.currentPeriod = 'today';
          this.loadStatistics();
        })

        this.TabButton('本周', this.currentPeriod === 'week', () => {
          this.currentPeriod = 'week';
          this.loadStatistics();
        })

        this.TabButton('本月', this.currentPeriod === 'month', () => {
          this.currentPeriod = 'month';
          this.loadStatistics();
        })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceEvenly)

      // 统计卡片
      if (this.statistics) {
        Column() {
          StatCard({
            title: '完成番茄数',
            value: this.statistics.completedTomatoes.toString(),
            unit: '个'
          })

          StatCard({
            title: '专注时长',
            value: (this.statistics.focusMinutes / 60).toFixed(1),
            unit: '小时'
          })

          StatCard({
            title: '任务完成率',
            value: this.statistics.completionRate.toFixed(0),
            unit: '%'
          })
        }
        .width('100%')
        .padding(16)
      }

      Blank()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabButton(title: string, isSelected: boolean, onClick: () => void) {
    Text(title)
      .fontSize(14)
      .fontColor(isSelected ? '#FF6B6B' : '#999999')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(isSelected ? '#FFF0F0' : 'transparent')
      .borderRadius(16)
      .onClick(onClick)
  }
}
```

**验收标准**:
- [ ] 支持今日/本周/本月切换
- [ ] 显示完成番茄数
- [ ] 显示专注时长
- [ ] 显示任务完成率
- [ ] 数据实时更新

---

### P3-010: 实现 StatCard 组件 [P]

**文件**: `entry/src/main/ets/view/components/StatCard.ets`

**描述**: 统计卡片组件

**实现内容**:
```typescript
@Component
export struct StatCard {
  @Prop title: string = '';
  @Prop value: string = '0';
  @Prop unit: string = '';

  build() {
    Column() {
      Text(this.title)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 8 })

      Text(`${this.value} ${this.unit}`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }
}
```

**验收标准**:
- [ ] 显示标题
- [ ] 显示数值和单位
- [ ] 样式统一

---

### P3-011: 配置 route_map.json

**文件**: `entry/src/main/resources/base/profile/route_map.json`

**描述**: 路由映射配置

**实现内容**:
```json
{
  "routerMap": [
    {
      "name": "MainPage",
      "pageSourceFile": "src/main/ets/pages/MainPage.ets",
      "buildFunction": "MainPageBuilder"
    },
    {
      "name": "CountDownTimerPage",
      "pageSourceFile": "src/main/ets/pages/CountDownTimer.ets",
      "buildFunction": "CountDownTimerBuilder"
    },
    {
      "name": "TaskEditPage",
      "pageSourceFile": "src/main/ets/pages/TaskEdit.ets",
      "buildFunction": "TaskEditBuilder"
    }
  ]
}
```

**验收标准**:
- [ ] 包含所有页面路由
- [ ] buildFunction 名称正确
- [ ] pageSourceFile 路径正确

---

## 阶段完成标准

- [ ] 所有页面实现完成
- [ ] 所有组件实现完成
- [ ] 页面跳转正常工作
- [ ] 表单验证正确
- [ ] UI响应式适配
- [ ] 代码通过静态检查

---

**相关文档：**
- [导航结构](../ui/navigation.md)
- [页面布局](../ui/pages.md)
- [技术实现方案](../technical/plan.md)
