/**
 * ToDoList 任务列表视图组件
 */
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TaskMode } from '../viewmodel/TaskMode';
import { TaskStatus } from '../viewmodel/TaskStatus';
import { TaskService, TASK_REFRESH_TRIGGER } from '../service/TaskService';
import { GlobalNavStack } from '../common/GlobalNavStack';
import { ToastUtil } from '../common/ToastUtil';
import { Logger } from '../common/Logger';
import { TaskCard } from './components/TaskCard';

/**
 * 任务编辑页面参数接口
 */
interface TaskEditParams {
  isNew: boolean;
  task: ToDoListClass | null;
}

@Component
export struct ToDoList {
  @State private tasks: ToDoListClass[] = []; // 任务列表数据
  @State private isLoading: boolean = true; // 是否正在加载任务
  @State private selectedMode: TaskMode | null = null; // 当前选中的任务模式筛选条件
  // 使用 @StorageLink 双向绑定，确保能及时响应 AppStorage 变化
  @StorageLink(TASK_REFRESH_TRIGGER) @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;
  // 父组件传递的刷新触发器（用于页面显示时刷新）
  @Prop @Watch('onParentRefreshChange') refreshTriggerFromParent: number = 0;
  // 使用 @State 确保这些追踪变量在组件生命周期中持久化
  @State private lastProcessedTrigger: number = -1; // 上次处理的刷新触发器值，用于检测变化
  @State private lastProcessedParentTrigger: number = -1; // 上次处理的父组件刷新触发器值，用于检测变化
  @State private isInitialized: boolean = false; // 组件是否已初始化完成

  async aboutToAppear() {
    Logger.info(`ToDoList aboutToAppear, trigger: ${this.refreshTrigger}, parentTrigger: ${this.refreshTriggerFromParent}`);
    await this.loadTasks();
    // 初始化完成后设置标记
    this.lastProcessedTrigger = this.refreshTrigger;
    this.lastProcessedParentTrigger = this.refreshTriggerFromParent;
    this.isInitialized = true;
  }

  /**
   * 监听刷新触发器变化
   */
  onRefreshTriggerChange() {
    Logger.info(`onRefreshTriggerChange: trigger=${this.refreshTrigger}, last=${this.lastProcessedTrigger}, initialized=${this.isInitialized}`);
    
    // 忽略初始化前的触发
    if (!this.isInitialized) {
      return;
    }
    // 检查是否是新的变化
    if (this.refreshTrigger !== this.lastProcessedTrigger) {
      this.lastProcessedTrigger = this.refreshTrigger;
      Logger.info(`Refresh trigger changed, reloading tasks`);
      this.loadTasks();
    }
  }

  /**
   * 监听父组件刷新触发器变化（页面显示时）
   */
  onParentRefreshChange() {
    Logger.info(`onParentRefreshChange: parentTrigger=${this.refreshTriggerFromParent}, last=${this.lastProcessedParentTrigger}, initialized=${this.isInitialized}`);
    
    // 忽略初始化前的触发
    if (!this.isInitialized) {
      return;
    }
    // 检查是否是新的变化
    if (this.refreshTriggerFromParent !== this.lastProcessedParentTrigger) {
      this.lastProcessedParentTrigger = this.refreshTriggerFromParent;
      Logger.info(`Parent refresh trigger changed, reloading tasks`);
      this.loadTasks();
    }
  }

  /**
   * 加载任务列表
   */
  private async loadTasks(): Promise<void> {
    Logger.info('loadTasks called');
    this.isLoading = true;
    try {
      await TaskService.init();
      // TaskService.getTasks() 现在返回深拷贝，直接使用即可
      const freshTasks = TaskService.getTasks();
      Logger.info(`Got ${freshTasks.length} tasks from TaskService`);

      // 打印每个任务的信息
      freshTasks.forEach(t => {
        Logger.info(`Task: ID=${t.getId}, Name=${t.getName}, Finished=${t.getFinishedTomatoCount}, Today=${t.getTodayFinishedCount}`);
      });

      this.tasks = freshTasks;
      await TaskService.checkTodayReset();
      Logger.info(`Loaded ${this.tasks.length} tasks, isLoading: ${this.isLoading}`);
    } catch (error) {
      Logger.error('Failed to load tasks', error as Error);
      ToastUtil.showError('加载任务失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 获取筛选后的任务列表
   */
  private getFilteredTasks(): ToDoListClass[] {
    let filtered = this.tasks.filter(t => t.getStatus === TaskStatus.WORKING);

    if (this.selectedMode !== null) {
      filtered = filtered.filter(t => t.getMode === this.selectedMode);
    }

    return filtered;
  }

  /**
   * 跳转到任务编辑页面（新建）
   */
  private navigateToTaskEdit(): void {
    const params: TaskEditParams = {
      isNew: true,
      task: null
    };
    GlobalNavStack.pushPathByName('TaskEditPage', params);
  }

  /**
   * 跳转到任务编辑页面（编辑）
   */
  private navigateToEditTask(task: ToDoListClass): void {
    const params: TaskEditParams = {
      isNew: false,
      task: task
    };
    GlobalNavStack.pushPathByName('TaskEditPage', params);
  }

  /**
   * 跳转到计时器页面
   */
  private navigateToTimer(task: ToDoListClass): void {
    GlobalNavStack.pushPathByName('CountDownTimerPage', task);
  }

  /**
   * 切换模式筛选
   */
  private toggleModeFilter(mode: TaskMode | null): void {
    if (this.selectedMode === mode) {
      this.selectedMode = null;
    } else {
      this.selectedMode = mode;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('任务列表')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .layoutWeight(1)

        // 新建按钮
        Button() {
          Text('+')
            .fontSize(24)
            .fontColor(Color.White)
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .onClick(() => this.navigateToTaskEdit())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.color_theme'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 筛选栏
      Row() {
        // 全部
        Text('全部')
          .fontSize(14)
          .fontColor(this.selectedMode === null ? Color.White : $r('app.color.color_text_secondary'))
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor(this.selectedMode === null ? $r('app.color.color_theme') : $r('app.color.color_divider'))
          .borderRadius(16)
          .onClick(() => this.toggleModeFilter(null))

        // 待办
        Text('待办')
          .fontSize(14)
          .fontColor(this.selectedMode === TaskMode.TODO ? Color.White : $r('app.color.color_text_secondary'))
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor(this.selectedMode === TaskMode.TODO ? $r('app.color.color_theme') : $r('app.color.color_divider'))
          .borderRadius(16)
          .onClick(() => this.toggleModeFilter(TaskMode.TODO))

        // 计划
        Text('计划')
          .fontSize(14)
          .fontColor(this.selectedMode === TaskMode.PLAN ? Color.White : $r('app.color.color_text_secondary'))
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor(this.selectedMode === TaskMode.PLAN ? $r('app.color.color_theme') : $r('app.color.color_divider'))
          .borderRadius(16)
          .onClick(() => this.toggleModeFilter(TaskMode.PLAN))
      }
      .width('100%')
      .padding(12)
      .backgroundColor($r('app.color.color_white'))
      .justifyContent(FlexAlign.SpaceEvenly)

      // 任务列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color($r('app.color.color_theme'))
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.color_text_tertiary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.getFilteredTasks().length === 0) {
        Column() {
          Image($r('app.media.todo_list'))
            .width(120)
            .height(120)
            .opacity(0.5)
            .margin({ bottom: 16 })

          Text('暂无任务')
            .fontSize(16)
            .fontColor($r('app.color.color_text_tertiary'))
            .margin({ bottom: 8 })

          Text('点击右上角 + 创建新任务')
            .fontSize(14)
            .fontColor($r('app.color.color_text_hint'))

          Button('创建任务')
            .fontSize(14)
            .backgroundColor($r('app.color.color_theme'))
            .margin({ top: 24 })
            .onClick(() => this.navigateToTaskEdit())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.getFilteredTasks(), (task: ToDoListClass) => {
            ListItem() {
              TaskCard({
                task: task,
                refreshKey: this.refreshTrigger,  // 传递刷新键
                onEdit: () => this.navigateToEditTask(task),
                onStart: () => this.navigateToTimer(task)
              })
            }
          }, (task: ToDoListClass) => `${task.getId}_${this.refreshTrigger}_${this.refreshTriggerFromParent}`)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 12, right: 12, top: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_background_gray'))
  }
}
