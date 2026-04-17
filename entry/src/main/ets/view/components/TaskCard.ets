/**
 * TaskCard 任务卡片组件
 * 显示任务信息，支持编辑和开始操作
 */
import { ToDoListClass } from '../../viewmodel/ToDoListClass';
import { TaskMode } from '../../viewmodel/TaskMode';

@Component
export struct TaskCard {
  @Prop task: ToDoListClass;
  @Prop refreshKey: number = 0;  // 添加刷新键，强制重新渲染
  onEdit: () => void = () => {};
  onStart: () => void = () => {};

  /**
   * 获取任务模式文字
   */
  private getModeText(): string {
    return this.task.getMode === TaskMode.TODO ? '待办' : '计划';
  }

  /**
   * 获取任务模式颜色
   */
  private getModeColor(): Resource {
    return this.task.getMode === TaskMode.TODO ? $r('app.color.color_todo_mode') : $r('app.color.color_plan_mode');
  }

  /**
   * 获取进度百分比
   */
  private getProgress(): number {
    const total = this.task.getTotalTomatoNum;
    const completed = this.task.getCompletedTomatoNum;
    if (total === 0) return 0;
    return Math.round((completed / total) * 100);
  }

  build() {
    Column() {
      // 任务名称和模式标签
      Row() {
        Text(this.task.getName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.color_text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Text(this.getModeText())
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(this.getModeColor())
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 任务信息
      Column() {
        // 番茄时长和休息时长
        Row() {
          Row() {
            Text('番茄')
              .fontSize(12)
              .fontColor($r('app.color.color_text_tertiary'))
            Text(`${this.task.getTomatoMinutes}分钟`)
              .fontSize(12)
              .fontColor($r('app.color.color_text_secondary'))
              .margin({ left: 4 })
          }

          Blank()

          Row() {
            Text('休息')
              .fontSize(12)
              .fontColor($r('app.color.color_text_tertiary'))
            Text(`${this.task.getRestMinutes}分钟`)
              .fontSize(12)
              .fontColor($r('app.color.color_text_secondary'))
              .margin({ left: 4 })
          }
        }
        .width('100%')

        // 进度信息
        Row() {
          if (this.task.getMode === TaskMode.TODO) {
            // 待办模式：显示总进度
            Row() {
              Text('已完成')
                .fontSize(12)
                .fontColor($r('app.color.color_text_tertiary'))
              Text(`${this.task.getFinishedTomatoCount}/${this.task.getTargetTomatoCount || 0}`)
                .fontSize(12)
                .fontColor($r('app.color.color_text_secondary'))
                .margin({ left: 4 })
            }
          } else {
            // 计划模式：显示今日和累计
            Row() {
              Text('今日')
                .fontSize(12)
                .fontColor($r('app.color.color_text_tertiary'))
              Text(`${this.task.getTodayFinishedCount}/${this.task.getDailyTargetTomatoCount || 0}`)
                .fontSize(12)
                .fontColor($r('app.color.color_text_secondary'))
                .margin({ left: 4 })
            }

            Blank()

            Row() {
              Text('累计')
                .fontSize(12)
                .fontColor($r('app.color.color_text_tertiary'))
              Text(`${this.task.getFinishedTomatoCount}个`)
                .fontSize(12)
                .fontColor($r('app.color.color_text_secondary'))
                .margin({ left: 4 })
            }
          }
        }
        .width('100%')
        .margin({ top: 8 })

        // 进度条
        Progress({ value: this.getProgress(), total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(4)
          .color($r('app.color.color_theme'))
          .margin({ top: 8 })

        // 计划模式：显示截止日期
        if (this.task.getMode === TaskMode.PLAN && this.task.getDeadline) {
          Row() {
            Text('截止')
              .fontSize(12)
              .fontColor($r('app.color.color_text_tertiary'))
            Text(`${this.task.getDeadline!.toLocaleDateString()}`)
              .fontSize(12)
              .fontColor($r('app.color.color_text_secondary'))
              .margin({ left: 4 })
            Blank()
            Text(`剩余${this.task.getRemainingDays()}天`)
              .fontSize(12)
              .fontColor(this.task.getRemainingDays() <= 3 ? $r('app.color.color_warning') : $r('app.color.color_plan_mode'))
          }
          .width('100%')
          .margin({ top: 8 })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })

      // 开始按钮
      Button() {
        Row() {
          Image($r('app.media.todo_list'))
            .width(16)
            .height(16)
            .fillColor(Color.White)
            .margin({ right: 4 })
          Text('开始专注')
            .fontSize(14)
            .fontColor(Color.White)
        }
      }
      .type(ButtonType.Normal)
      .width('100%')
      .height(40)
      .backgroundColor($r('app.color.color_theme'))
      .borderRadius(8)
      .onClick(() => this.onStart())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: $r('app.color.color_shadow'),
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.onEdit())
  }
}
