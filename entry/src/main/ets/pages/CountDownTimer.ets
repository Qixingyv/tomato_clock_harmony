import { TaskType } from "../viewmodel/TaskType"
import { ToDoListClass } from "../viewmodel/ToDoListClass"
import { TaskStatus } from "../viewmodel/TaskStatus"
import { TimerMode } from "../viewmodel/TimerMode"
import { GlobalNavStack } from "../common/GlobalNavStack"
import { TaskService, TASK_REFRESH_TRIGGER } from "../service/TaskService"
import { Logger } from "../common/Logger"

@Builder
export function CountDownTimerBuilder() {
  CountDownTimer()
}

@Component
export struct CountDownTimer {

  // 文本计时器控制器
  textTimerController: TextTimerController = new TextTimerController();

  // 番茄钟对象（使用 @State 以支持运行时更新）
  @State toDoList: ToDoListClass | null = null;

  // 监听全局刷新触发器，当任务数据变化时更新
  @StorageProp(TASK_REFRESH_TRIGGER) @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;

  // 记录初始触发器值，避免首次加载时重复刷新
  private initialRefreshTrigger: number = -1;

  // 文本倒计时样式
  private textTimerFormat: string = "mm:ss"

  // 剩余时间（毫秒）
  @State progressValue: number = 0;

  // 总时间（毫秒）
  @State progressTotal: number = 0;

  // 当前番茄钟状态（计时器模式）
  @State private currentTomatoStatus: TimerMode = TimerMode.WORKING;

  // 是否暂停
  @State private isPause: boolean = false;

  // 是否显示结束弹窗
  @State private showEndDialog: boolean = false;

  // 是否显示跳过休息弹窗
  @State private showSkipRestDialog: boolean = false;

  // 当前完成的番茄钟序号（用于判断是否还有下一个番茄钟）
  private currentTomatoIndex: number = 0;

  /**
   * 监听刷新触发器变化
   * 当任务数据在其他页面被修改时，更新当前任务数据
   */
  onRefreshTriggerChange() {
    // 首次加载时记录初始值，不执行刷新
    if (this.initialRefreshTrigger === -1) {
      this.initialRefreshTrigger = this.refreshTrigger;
      return;
    }
    
    // 忽略与初始值相同的变化（避免不必要的刷新）
    if (this.refreshTrigger === this.initialRefreshTrigger) {
      return;
    }

    Logger.info(`CountDownTimer: Refresh trigger changed to ${this.refreshTrigger}, updating task data`);
    this.refreshTaskData();
  }

  /**
   * 刷新任务数据
   * 从 TaskService 获取最新的任务数据并更新 UI
   */
  private refreshTaskData(): void {
    if (!this.toDoList) {
      return;
    }

    const taskId = this.toDoList.getId;
    const latestTask = TaskService.getTaskById(taskId);
    
    if (latestTask) {
      Logger.info(`CountDownTimer: Task updated - TomatoMinutes: ${latestTask.getTomatoMinutes}, RestMinutes: ${latestTask.getRestMinutes}`);
      this.toDoList = latestTask;
      
      // 如果正在专注模式，需要更新计时器总时长
      if (this.currentTomatoStatus === TimerMode.WORKING && !this.isPause) {
        this.progressTotal = latestTask.getTomatoDuration * 1000 * 60;
      } else if (this.currentTomatoStatus === TimerMode.RESTING && !this.isPause) {
        this.progressTotal = latestTask.getRestDuration * 1000 * 60;
      }
    }
  }

  // 获取当前番茄钟模式
  getCurrentTaskType(taskType: TaskType): Resource {
    let result: Resource = $r("app.string.string_empty");
    if(taskType === TaskType.Todo) {
      result = $r("app.string.string_todo_mode")
    }
    else {
      result = $r("app.string.string_plan_mode")
    }
    return result;
  }

  // 获取页面当前状态
  getCurrentTaskStatus(timerMode: TimerMode, isPause: boolean): string {
    let result: string = "";
    if (timerMode === TimerMode.WORKING && isPause === false) {
      result = "专注模式";
    }
    else if (timerMode === TimerMode.WORKING && isPause === true) {
      result = "暂停";
    }
    else if (timerMode === TimerMode.RESTING && isPause === false) {
      result = "休息模式";
    }
    else if (timerMode === TimerMode.RESTING && isPause === true) {
      result = "休息暂停";
    }
    return result;
  }

  // 根据页面状态，获取左侧按钮值
  getLeftButtonValue(currentTomatoStatus: TimerMode, isPause: boolean): Resource {
    let leftButtonValue: Resource = $r("app.string.string_empty");
    if (currentTomatoStatus === TimerMode.WORKING && isPause === false) {
      leftButtonValue = $r("app.string.string_pause");
    }
    else if (currentTomatoStatus === TimerMode.WORKING && isPause === true) {
      leftButtonValue = $r("app.string.string_resume")
    }
    else if (currentTomatoStatus === TimerMode.RESTING && isPause === false) {
      leftButtonValue = $r("app.string.string_skip_break");
    }
    else if (currentTomatoStatus === TimerMode.RESTING && isPause === true) {
      leftButtonValue = $r("app.string.string_resume");
    }
    return leftButtonValue;
  }

  // 开始专注模式
  startWorkingMode() {
    if (!this.toDoList) {
      return;
    }
    this.currentTomatoStatus = TimerMode.WORKING;
    this.isPause = false;
    this.progressTotal = this.toDoList.getTomatoDuration * 1000 * 60;
    this.progressValue = this.progressTotal;
    // 先停止，再重置，延迟启动以确保组件状态稳定
    this.textTimerController.pause();
    this.textTimerController.reset();
    setTimeout(() => {
      this.textTimerController.start();
    }, 50);
  }

  // 开始休息模式
  startRestMode() {
    if (!this.toDoList) {
      return;
    }
    this.currentTomatoStatus = TimerMode.RESTING;
    this.isPause = false;
    this.progressTotal = this.toDoList.getRestDuration * 1000 * 60;
    this.progressValue = this.progressTotal;
    // 先停止，再重置，延迟启动以确保组件状态稳定
    this.textTimerController.pause();
    this.textTimerController.reset();
    setTimeout(() => {
      this.textTimerController.start();
    }, 50);
  }

  // 处理专注模式结束
  async handleWorkingModeEnd() {
    if (!this.toDoList) {
      return;
    }
    // 记录完成一个番茄钟（通过TaskService保存并通知）
    await TaskService.completeTomato(this.toDoList.getId);
    this.currentTomatoIndex++;

    // 检查是否还有未完成的番茄钟
    if (this.currentTomatoIndex < this.toDoList.getTotalTomatoNum) {
      // 还有未完成的番茄钟，自动进入休息模式
      this.startRestMode();
    } else {
      // 所有番茄钟已完成，返回任务列表
      GlobalNavStack.pop();
    }
  }

  // 处理休息模式结束
  handleRestModeEnd() {
    if (!this.toDoList) {
      return;
    }
    // 不需要pause()，startWorkingMode()会调用reset()重置状态
    // 检查是否还有未完成的番茄钟
    if (this.currentTomatoIndex < this.toDoList.getTotalTomatoNum) {
      // 还有未完成的番茄钟，自动进入下一个专注模式
      this.startWorkingMode();
    } else {
      // 所有番茄钟已完成，返回任务列表
      GlobalNavStack.pop();
    }
  }

  // 记录番茄钟并返回任务列表
  async recordTomatoAndReturn() {
    if (!this.toDoList) {
      return;
    }
    // 通过TaskService更新已完成番茄个数并保存
    await TaskService.completeTomato(this.toDoList.getId);

    // 返回任务列表
    GlobalNavStack.pop();
  }

  // 显示专注模式结束弹窗
  showWorkingEndDialog() {
    this.textTimerController.pause();
    this.showEndDialog = true;
    console.log('showWorkingEndDialog called, showEndDialog:', this.showEndDialog);
  }

  // 显示休息模式结束弹窗
  showRestEndDialog() {
    this.textTimerController.pause();
    this.showEndDialog = true;
  }

  // 显示跳过休息确认弹窗
  showSkipRestConfirmDialog() {
    this.textTimerController.pause();
    this.showSkipRestDialog = true;
  }

  build() {
    NavDestination() {
      Stack() {
        // 主内容区域
        if (this.toDoList) {
          Column() {

            // 任务类型
            Row() {
              Text(this.getCurrentTaskType(this.toDoList.getTaskType))
                .fontSize('16vp')
                .fontColor($r("app.color.color_theme"))
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: '20vp' })

          // 计时区域
          Stack() {

            // 环形区域
            Progress({ value: this.progressValue, total: this.progressTotal, type: ProgressType.Ring })
              .color($r("app.color.color_theme"))
              .style({ strokeWidth: 24 })
              .width('80%')

            // 信息展示
            Column() {
              // 文本计时器
              TextTimer({ isCountDown: true, count: this.progressTotal, controller: this.textTimerController })
                .format(this.textTimerFormat)
                .fontColor(Color.Black)
                .fontSize(50)
                .onTimer((utcTime: number, elapsedTime: number) => {
                  this.progressValue = Math.max(0, this.progressValue - 1000);
                  if (elapsedTime >= this.progressTotal / 1000) {
                    // 倒计时结束
                    if (this.currentTomatoStatus === TimerMode.WORKING) {
                      this.handleWorkingModeEnd();
                    } else if (this.currentTomatoStatus === TimerMode.RESTING) {
                      this.handleRestModeEnd();
                    }
                  }
                })

              // 任务状态
              Text(this.getCurrentTaskStatus(this.currentTomatoStatus, this.isPause))
                .fontSize('18vp')
                .fontColor(Color.Gray)
                .margin({ top: '10vp' })
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .alignContent(Alignment.Center)

          // 任务名称
          Row() {
            Text(this.toDoList.getTaskName.toString())
              .fontSize('20vp')
              .fontWeight(600)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: '20vp', bottom: '20vp' })

          // 按钮区域
          Row() {
            // 左侧按钮（暂停/继续/跳过休息）
            Button(this.getLeftButtonValue(this.currentTomatoStatus, this.isPause))
              .onClick(() => {
                if (this.currentTomatoStatus === TimerMode.WORKING && this.isPause === false) {
                  // 专注模式：暂停
                  this.textTimerController.pause();
                  this.isPause = true;
                } else if (this.currentTomatoStatus === TimerMode.WORKING && this.isPause === true) {
                  // 专注模式：继续
                  this.textTimerController.start();
                  this.isPause = false;
                } else if (this.currentTomatoStatus === TimerMode.RESTING && this.isPause === false) {
                  // 休息模式：跳过休息
                  this.showSkipRestConfirmDialog();
                } else if (this.currentTomatoStatus === TimerMode.RESTING && this.isPause === true) {
                  // 休息模式：继续
                  this.textTimerController.start();
                  this.isPause = false;
                }
              })
              .width('40%')
              .backgroundColor($r("app.color.color_theme"))
              .fontColor(Color.White)

            // 右侧按钮（结束）
            Button($r("app.string.string_finish"))
              .onClick(() => {
                if (this.currentTomatoStatus === TimerMode.WORKING) {
                  this.showWorkingEndDialog();
                } else if (this.currentTomatoStatus === TimerMode.RESTING) {
                  this.showRestEndDialog();
                }
              })
              .width('40%')
              .backgroundColor(Color.White)
              .fontColor($r("app.color.color_theme"))
              .border({
                width: 1,
                color: $r("app.color.color_theme")
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
          .margin({ bottom: '40vp' })
        }
        .width('100%')
        .height('100%')
        .padding({ left: '20vp', right: '20vp' })
        }

        // 结束弹窗遮罩层
        if (this.showEndDialog) {
          Stack({ alignContent: Alignment.Center }) {
            // 半透明遮罩
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor(Color.Black)
              .opacity(0.3)
              .onClick(() => {
                // 点击空白处：如果是专注模式，继续番茄钟
                if (this.currentTomatoStatus === TimerMode.WORKING) {
                  this.showEndDialog = false;
                  this.textTimerController.start();
                  this.isPause = false;
                }
              })

            // 弹窗内容
            this.endDialogBuilder()
          }
          .width('100%')
          .height('100%')
          .position({ x: 0, y: 0 })
        }

        // 跳过休息确认弹窗遮罩层
        if (this.showSkipRestDialog) {
          Stack({ alignContent: Alignment.Center }) {
            // 半透明遮罩
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor(Color.Black)
              .opacity(0.3)
              .onClick(() => {
                this.showSkipRestDialog = false;
              })

            // 弹窗内容
            this.skipRestDialogBuilder()
          }
          .width('100%')
          .height('100%')
          .position({ x: 0, y: 0 })
        }
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.toDoList = context.pathInfo.param as ToDoListClass;
      this.currentTomatoIndex = this.toDoList.getCompletedTomatoNum;
      // 初始化专注模式
      this.startWorkingMode();
    })
    .onActive(() => {
      // 页面激活时确保计时器启动（此时组件已完全就绪）
      if (this.currentTomatoStatus === TimerMode.WORKING || this.currentTomatoStatus === TimerMode.RESTING) {
        this.textTimerController.start();
      }
    })
    .onInactive(() => {
      // 页面失活时不自动暂停
      // 让用户手动控制暂停/继续，避免干扰模式切换时的自动启动
    })
    .hideBackButton(true)
  }

  // 专注模式结束弹窗
  @Builder
  endDialogBuilder() {
    Column() {
      if (this.currentTomatoStatus === TimerMode.WORKING) {
        // 专注模式结束弹窗
        Text("确认结束专注模式？")
          .fontSize('18vp')
          .fontWeight(600)
          .margin({ bottom: '20vp' })

        // 点击空白处或继续按钮：继续番茄钟
        Button($r("app.string.string_continue_tomato"))
          .onClick(() => {
            this.showEndDialog = false;
            this.textTimerController.start();
            this.isPause = false;
          })
          .width('100%')
          .backgroundColor($r("app.color.color_theme"))
          .fontColor(Color.White)
          .margin({ bottom: '10vp' })

        // 结束并记录番茄钟
        Button($r("app.string.string_end_and_record"))
          .onClick(() => {
            this.showEndDialog = false;
            this.recordTomatoAndReturn();
          })
          .width('100%')
          .backgroundColor(Color.White)
          .fontColor($r("app.color.color_theme"))
          .border({
            width: 1,
            color: $r("app.color.color_theme")
          })
          .margin({ bottom: '10vp' })

        // 结束不记录番茄钟
        Button($r("app.string.string_end_without_record"))
          .onClick(() => {
            this.showEndDialog = false;
            // 不记录数据，直接返回
            GlobalNavStack.pop();
          })
          .width('100%')
          .backgroundColor(Color.White)
          .fontColor(Color.Gray)
          .border({
            width: 1,
            color: Color.Gray
          })
      } else if (this.currentTomatoStatus === TimerMode.RESTING) {
        // 休息模式结束弹窗
        Text("确认结束休息？")
          .fontSize('18vp')
          .fontWeight(600)
          .margin({ bottom: '20vp' })

        // 继续休息
        Button($r("app.string.string_continue"))
          .onClick(() => {
            this.showEndDialog = false;
            this.textTimerController.start();
            this.isPause = false;
          })
          .width('100%')
          .backgroundColor($r("app.color.color_theme"))
          .fontColor(Color.White)
          .margin({ bottom: '10vp' })

        // 结束并返回任务列表
        Button($r("app.string.string_finish"))
          .onClick(() => {
            this.showEndDialog = false;
            this.recordTomatoAndReturn();
          })
          .width('100%')
          .backgroundColor(Color.White)
          .fontColor($r("app.color.color_theme"))
          .border({
            width: 1,
            color: $r("app.color.color_theme")
          })
      }
    }
    .width('80%')
    .padding('20vp')
    .backgroundColor(Color.White)
    .borderRadius('12vp')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  // 跳过休息确认弹窗
  @Builder
  skipRestDialogBuilder() {
    Column() {
      Text($r("app.string.string_confirm_skip_rest"))
        .fontSize('18vp')
        .fontWeight(600)
        .margin({ bottom: '20vp' })

      // 跳过：进入下一个专注模式
      Button($r("app.string.string_skip"))
        .onClick(() => {
          this.showSkipRestDialog = false;
          // 检查是否还有未完成的番茄钟
          if (this.toDoList && this.currentTomatoIndex < this.toDoList.getTotalTomatoNum) {
            // 直接进入下一个专注模式（不增加索引，因为专注模式完成时已经增加过了）
            this.startWorkingMode();
          } else {
            // 所有番茄钟已完成，返回任务列表
            GlobalNavStack.pop();
          }
        })
        .width('100%')
        .backgroundColor($r("app.color.color_theme"))
        .fontColor(Color.White)
        .margin({ bottom: '10vp' })

      // 继续休息
      Button($r("app.string.string_continue_rest"))
        .onClick(() => {
          this.showSkipRestDialog = false;
          this.textTimerController.start();
          this.isPause = false;
        })
        .width('100%')
        .backgroundColor(Color.White)
        .fontColor($r("app.color.color_theme"))
        .border({
          width: 1,
          color: $r("app.color.color_theme")
        })
    }
    .width('80%')
    .padding('20vp')
    .backgroundColor(Color.White)
    .borderRadius('12vp')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

}