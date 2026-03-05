import {ToDoListClass} from "../viewmodel/ToDoListClass"
import DateUtils from "../common/DateUtils"
import {GlobalNavStack} from "../common/GlobalNavStack"
// import {ConnectionUtils} from "../common/network/ConnectionUtils"

// 任务编辑页面参数接口
interface TaskEditParams {
  isNew: boolean;
  task: ToDoListClass | null;
}

@Preview
@Component
export struct ToDoList {

  @State private toDoListArray: Array<ToDoListClass> = [];
  @State private isLoading: boolean = false;
  // 当前用户ID（应该从登录状态获取，这里暂时使用固定值）
  private currentUserId: number = 1;

  // 组件挂载时加载任务列表
  aboutToAppear() {
    this.loadTaskList();
  }

  // 从后端加载任务列表
  async loadTaskList() {
    this.isLoading = true;
    try {
      // TODO: 从实际后端获取数据
      // const tasks = await ConnectionUtils.getTaskList(this.currentUserId);
      // this.toDoListArray = tasks;
      
      // 临时使用测试数据
      this.toDoListArray = [
        new ToDoListClass(1, 1, '学习高数第三章', 1, 25, 5, 8, null, 0, 0, null, null, 1),
        new ToDoListClass(2, 1, '开发番茄钟', 1, 25, 5, 10, null, 3, 0, null, null, 1),
        new ToDoListClass(3, 1, '学习英语', 2, 25, 5, null, 5, 0, 2, new Date('2026-12-31'), null, 1),
        new ToDoListClass(4, 1, '番茄钟测试', 2, 2, 1, null, 5, 0, 2, new Date('2026-12-31'), null, 1)
      ];
    } catch (error) {
      console.error('加载任务列表失败:', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  // 跳转到新建任务页面
  navigateToNewTask() {
    const params: TaskEditParams = {
      isNew: true,
      task: null
    };
    GlobalNavStack.pushPathByName('TaskEditPage', params);
  }

  // 跳转到编辑任务页面
  navigateToEditTask(task: ToDoListClass) {
    const params: TaskEditParams = {
      isNew: false,
      task: task
    };
    GlobalNavStack.pushPathByName('TaskEditPage', params);
  }

  // 标题栏Builder
  @Builder
  titleBuilder() {
    Row() {
      Text($r("app.string.string_task_list"))
        .fontSize('24vp')
        .fontColor(Color.White)
        .fontFamily("Harmony Sans SC")
        .layoutWeight(1)

      // 显示新建按钮
      Button() {
        Text("+")
          .fontSize('28vp')
          .fontColor(Color.White)
      }
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.navigateToNewTask();
      })
    }
    .width('100%')
    .height('56vp')
    .padding({ left: '16vp', right: '16vp' })
    .backgroundColor($r("app.color.color_theme"))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Stack() {
      Column() {
        // 任务列表
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width('50vp')
              .height('50vp')
            Text("加载中...")
              .margin({ top: '16vp' })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(
              this.toDoListArray,
              (item: ToDoListClass) => {
                ListItem() {
                  ToDoListItem({
                    toDoListItem: item,
                    onTaskClick: () => {
                      this.navigateToEditTask(item);
                    },
                    onStartClick: () => {
                      GlobalNavStack.pushPathByName('CountDownTimerPage', item);
                    }
                  })
                }
                .margin({ top: '4vp', bottom: '4vp' })
              },
              (item: ToDoListClass) => item.getId.toString()
            )
          }
          .width('100%')
          .layoutWeight(1)
          .alignListItem(ListItemAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }

  }
}

@Component
struct ToDoListItem {
  @Prop private toDoListItem: ToDoListClass;
  private onTaskClick: () => void = () => {};
  private onStartClick: () => void = () => {};

  build() {
    Row() {
      Column() {
        // 任务名称行
        Row() {
          Text(this.toDoListItem.getTaskName)
            .fontSize('16vp')
            .fontWeight(700)
            .layoutWeight(1)

          // 长期目标：显示截止日期和剩余天数
          if (this.toDoListItem.getTaskType === 2) {
            Row() {
              if (this.toDoListItem.getDeadline) {
                Text(DateUtils.formatDate(this.toDoListItem.getDeadline))
                  .fontSize('12vp')
                  .fontColor($r("app.color.color_todo_list_content"))
                  .margin({ right: '8vp' })
              }
              Row() {
                Text($r("app.string.string_remaining_days"))
                  .fontSize('12vp')
                  .fontColor($r("app.color.color_todo_list_content"))
                Text(`: ${String(this.toDoListItem.getRemainingDays())}`)
                  .fontSize('12vp')
                  .fontColor($r("app.color.color_todo_list_content"))
              }
            }
          }
        }
        .width('100%')
        .margin({ top: '8vp', left: '16vp', right: '16vp' })

        // 任务详情
        Column() {
          // 番茄时长
          Row() {
            Text($r("app.string.string_tomato_duration"))
              .toDoListContent()
            Row() {
              Text(String(this.toDoListItem.getTomatoDuration))
                .toDoListContent()
              Text($r("app.string.string_minute"))
                .toDoListContent()
            }
          }
          .todoListRow()

          // 休息时长
          Row() {
            Text($r("app.string.string_rest_duration"))
              .toDoListContent()
            Row() {
              Text(String(this.toDoListItem.getRestDuration))
                .toDoListContent()
              Text($r("app.string.string_minute"))
                .toDoListContent()
            }
          }
          .todoListRow()

          // 已完成番茄个数
          Row() {
            if (this.toDoListItem.getTaskType === 1) {
              // 待办模式：显示总完成数/目标数
              Text($r("app.string.string_completed_tomato_count"))
                .toDoListContent()
              Text(`${String(this.toDoListItem.getCompletedTomatoNum)}/${String(this.toDoListItem.getTotalTomatoNum)}`)
                .toDoListContent()
            } else {
              // 长期模式：显示今日完成数/每日目标数
              Text($r("app.string.string_today_completed"))
                .toDoListContent()
              Text(`${String(this.toDoListItem.getTodayFinishedCount)}/${String(this.toDoListItem.getDailyTargetTomatoCount || 0)}`)
                .toDoListContent()
            }
          }
          .todoListRow()

          // 长期目标：显示截止日期
          if (this.toDoListItem.getTaskType === 2 && this.toDoListItem.getDeadline) {
            Row() {
              Text($r("app.string.string_deadline_duration"))
                .toDoListContent()
              Text(DateUtils.formatDate(this.toDoListItem.getDeadline))
                .toDoListContent()
            }
            .todoListRow()
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ left: '16vp', top: '4vp', bottom: '8vp' })

        // 开始按钮（居中显示）
        Row() {
          Button($r("app.string.string_start"))
            .width('40%')
            .height('40vp')
            .fontSize('16vp')
            .backgroundColor($r("app.color.color_theme"))
            .fontColor(Color.White)
            .onClick(() => {
              this.onStartClick();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: '8vp', bottom: '16vp' })
      }
      .layoutWeight(1)
    }
    .width('96%')
    .height('auto')
    .borderRadius('8vp')
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: $r('app.color.color_unselected'),
      offsetY: 2
    })
    .onClick(() => {
      this.onTaskClick();
    })
  }
}

@Extend(Text)
function toDoListContent() {
  .fontSize('14vp')
  .fontColor($r("app.color.color_todo_list_content"))
  .letterSpacing('1vp')
  .textAlign(TextAlign.Start)
}

@Extend(Row)
function todoListRow() {
  .margin({ bottom: '4vp', top: '4vp', left: '0vp', right: '0vp' })
}
