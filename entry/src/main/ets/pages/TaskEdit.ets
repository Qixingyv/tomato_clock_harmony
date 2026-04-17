/**
 * TaskEdit 任务创建/编辑页面
 * 支持待办模式和计划模式两种任务类型
 */
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TaskMode } from '../viewmodel/TaskMode';
import { TaskStatus } from '../viewmodel/TaskStatus';
import { TaskService } from '../service/TaskService';
import { TaskValidator } from '../common/validator/TaskValidator';
import { GlobalNavStack } from '../common/GlobalNavStack';
import { ToastUtil } from '../common/ToastUtil';
import { Logger } from '../common/Logger';
import { promptAction } from '@kit.ArkUI';

/**
 * 任务编辑页面参数接口
 */
interface TaskEditParams {
  isNew: boolean;
  task: ToDoListClass | null;
}

/**
 * TaskEdit组件的Builder函数
 * 用于路由注册
 */
@Builder
export function TaskEditBuilder() {
  TaskEdit()
}

@Component
export struct TaskEdit {
  @State private isNew: boolean = true;
  @State private task: ToDoListClass | null = null;

  // 表单状态
  @State private taskName: string = '';
  @State private taskMode: TaskMode = TaskMode.TODO;
  @State private tomatoMinutes: number = 25;
  @State private restMinutes: number = 5;
  @State private targetTomatoCount: number = 5;
  @State private dailyTargetTomatoCount: number = 5;
  @State private deadline: Date | null = null;

  // UI状态
  @State private isSaving: boolean = false;

  /**
   * 初始化表单数据
   */
  private initFormData(): void {
    if (this.task) {
      this.taskName = this.task.getName;
      this.taskMode = this.task.getMode as TaskMode;
      this.tomatoMinutes = this.task.getTomatoMinutes;
      this.restMinutes = this.task.getRestMinutes;
      this.targetTomatoCount = this.task.getTargetTomatoCount || 5;
      this.dailyTargetTomatoCount = this.task.getDailyTargetTomatoCount || 5;
      this.deadline = this.task.getDeadline;
    }
  }

  async aboutToAppear() {
    // aboutToAppear 在 onReady 之前执行，此时 params 还未接收
    // 实际初始化在 onReady 中调用 initFormData
  }

  /**
   * 保存任务
   */
  private async saveTask(): Promise<void> {
    if (this.isSaving) {
      return;
    }

    // 前端验证
    const nameValidation = TaskValidator.validateName(this.taskName);
    if (!nameValidation.valid) {
      ToastUtil.showError(nameValidation.errors[0]);
      return;
    }

    const minutesValidation = TaskValidator.validateTomatoMinutes(this.tomatoMinutes);
    if (!minutesValidation.valid) {
      ToastUtil.showError(minutesValidation.errors[0]);
      return;
    }

    const restValidation = TaskValidator.validateRestMinutes(this.restMinutes);
    if (!restValidation.valid) {
      ToastUtil.showError(restValidation.errors[0]);
      return;
    }

    this.isSaving = true;
    try {
      if (this.isNew) {
        // 创建新任务
        const result = await TaskService.createTaskWithParams(
          this.taskName,
          this.taskMode,
          this.tomatoMinutes,
          this.restMinutes,
          this.taskMode === TaskMode.TODO ? this.targetTomatoCount : null,
          this.taskMode === TaskMode.PLAN ? this.dailyTargetTomatoCount : null,
          this.deadline
        );

        if (result) {
          ToastUtil.showSuccess('创建成功');
          GlobalNavStack.pop();
        } else {
          ToastUtil.showError('创建失败');
        }
      } else {
        // 更新任务
        if (!this.task) {
          return;
        }

        const updateData: Record<string, Object> = {};

        // 只更新修改的字段
        if (this.taskName !== this.task.getName) {
          updateData['name'] = this.taskName;
        }
        if (this.tomatoMinutes !== this.task.getTomatoMinutes) {
          updateData['tomatoMinutes'] = this.tomatoMinutes;
        }
        if (this.restMinutes !== this.task.getRestMinutes) {
          updateData['restMinutes'] = this.restMinutes;
        }

        if (this.taskMode === TaskMode.TODO && this.targetTomatoCount !== this.task.getTargetTomatoCount) {
          updateData['targetTomatoCount'] = this.targetTomatoCount;
        }

        if (this.taskMode === TaskMode.PLAN) {
          if (this.dailyTargetTomatoCount !== this.task.getDailyTargetTomatoCount) {
            updateData['dailyTargetTomatoCount'] = this.dailyTargetTomatoCount;
          }
          if (this.deadline !== this.task.getDeadline) {
            updateData['deadline'] = this.deadline || new Date();
          }
        }

        const success = Object.keys(updateData).length > 0
          ? await TaskService.updateTask(this.task.getId, updateData)
          : true;

        Logger.info(`TaskEdit: update result=${success}, updateData keys=${Object.keys(updateData).join(',')}`);

        if (success) {
          ToastUtil.showSuccess('保存成功');
          Logger.info('TaskEdit: calling GlobalNavStack.pop()');
          GlobalNavStack.pop();
        } else {
          ToastUtil.showError('保存失败');
        }
      }
    } catch (error) {
      Logger.error('Failed to save task', error as Error);
      ToastUtil.showError('操作失败');
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 取消
   */
  private cancel(): void {
    GlobalNavStack.pop();
  }

  /**
   * 删除任务
   */
  private async deleteTask(): Promise<void> {
    if (this.isNew || !this.task) {
      return;
    }

    const result = await promptAction.showDialog({
      title: '确认删除任务？',
      message: '删除后任务将不再显示',
      buttons: [
        { text: '取消', color: $r('app.color.color_text_tertiary') },
        { text: '删除', color: $r('app.color.color_warning') }
      ]
    });

    if (result.index === 1) {
      const success = await TaskService.deleteTask(this.task.getId);
      if (success) {
        ToastUtil.showSuccess('任务已删除');
        GlobalNavStack.pop();
      } else {
        ToastUtil.showError('删除失败');
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 标题栏
        Row() {
          Button('返回')
            .fontSize(16)
            .fontColor($r('app.color.color_theme'))
            .backgroundColor(Color.Transparent)
            .onClick(() => this.cancel())

          Text(this.isNew ? '新建任务' : '编辑任务')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          if (!this.isNew) {
            Button('删除')
              .fontSize(16)
              .fontColor($r('app.color.color_danger'))
              .backgroundColor(Color.Transparent)
              .onClick(() => this.deleteTask())
          }
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .border({ width: { bottom: 1 }, color: $r('app.color.color_border') })

        // 表单内容
        Scroll() {
          Column() {
            // 任务名称
            Column() {
              Text('任务名称 *')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入任务名称', text: this.taskName })
                .width('100%')
                .height(48)
                .maxLength(50)
                .onChange((value: string) => {
                  this.taskName = value;
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 8 })

            // 任务模式
            Column() {
              Text('任务模式')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ bottom: 8 })

              Row() {
                  Row() {
                    Radio({ value: 'todo', group: 'taskMode' })
                      .checked(this.taskMode === TaskMode.TODO)
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          this.taskMode = TaskMode.TODO;
                          this.deadline = null;
                        }
                      })

                    Text('待办任务')
                      .fontSize(14)
                      .margin({ left: 8 })
                  }

                  Row() {
                    Radio({ value: 'plan', group: 'taskMode' })
                      .checked(this.taskMode === TaskMode.PLAN)
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          this.taskMode = TaskMode.PLAN;
                          if (!this.deadline) {
                            this.deadline = new Date();
                          }
                        }
                      })

                    Text('计划任务')
                      .fontSize(14)
                      .margin({ left: 8 })
                  }
                  .margin({ left: 24 })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 8 })

            // 番茄时长
            Column() {
              Row() {
                Text('番茄时长 (分钟) *')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)

                Text(`${this.tomatoMinutes}分钟`)
                  .fontSize(14)
                  .fontColor($r('app.color.color_theme'))
              }
              .width('100%')
              .margin({ bottom: 8 })

              Slider({
                value: this.tomatoMinutes,
                min: 1,
                max: 120,
                step: 1,
                style: SliderStyle.OutSet
              })
                .blockColor($r('app.color.color_theme'))
                .trackColor($r('app.color.color_border'))
                .selectedColor($r('app.color.color_theme'))
                .onChange((value: number) => {
                  this.tomatoMinutes = Math.round(value);
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 8 })

            // 休息时长
            Column() {
              Row() {
                Text('休息时长 (分钟) *')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)

                Text(`${this.restMinutes}分钟`)
                  .fontSize(14)
                  .fontColor($r('app.color.color_theme'))
              }
              .width('100%')
              .margin({ bottom: 8 })

              Slider({
                value: this.restMinutes,
                min: 1,
                max: 60,
                step: 1,
                style: SliderStyle.OutSet
              })
                .blockColor($r('app.color.color_theme'))
                .trackColor($r('app.color.color_border'))
                .selectedColor($r('app.color.color_theme'))
                .onChange((value: number) => {
                  this.restMinutes = Math.round(value);
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 8 })

            // 待办模式：目标番茄数
            if (this.taskMode === TaskMode.TODO) {
              Column() {
                Row() {
                  Text('目标番茄数 *')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)

                  Text(`${this.targetTomatoCount}个`)
                    .fontSize(14)
                    .fontColor($r('app.color.color_theme'))
                }
                .width('100%')
                .margin({ bottom: 8 })

                Slider({
                  value: this.targetTomatoCount,
                  min: 1,
                  max: 100,
                  step: 1,
                  style: SliderStyle.OutSet
                })
                  .blockColor($r('app.color.color_theme'))
                  .trackColor($r('app.color.color_border'))
                  .selectedColor($r('app.color.color_theme'))
                  .onChange((value: number) => {
                    this.targetTomatoCount = Math.round(value);
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ top: 8 })
            }

            // 计划模式：每日目标番茄数和截止日期
            if (this.taskMode === TaskMode.PLAN) {
              Column() {
                Row() {
                  Text('每日目标番茄数 *')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)

                  Text(`${this.dailyTargetTomatoCount}个`)
                    .fontSize(14)
                    .fontColor($r('app.color.color_theme'))
                }
                .width('100%')
                .margin({ bottom: 8 })

                Slider({
                  value: this.dailyTargetTomatoCount,
                  min: 1,
                  max: 20,
                  step: 1,
                  style: SliderStyle.OutSet
                })
                  .blockColor($r('app.color.color_theme'))
                  .trackColor($r('app.color.color_border'))
                  .selectedColor($r('app.color.color_theme'))
                  .onChange((value: number) => {
                    this.dailyTargetTomatoCount = Math.round(value);
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ top: 8 })

              Column() {
                Text('截止日期')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 8 })

                DatePicker({
                  start: new Date(),
                  end: new Date(new Date().getFullYear() + 1, 11, 31),
                  selected: this.deadline || new Date()
                })
                  .onDateChange((value: Date) => {
                    this.deadline = value;
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ top: 8 })
            }

            // 底部按钮
            Row() {
              Button('取消')
                .width('40%')
                .height(48)
                .fontSize(16)
                .backgroundColor($r('app.color.color_divider'))
                .fontColor($r('app.color.color_text_secondary'))
                .onClick(() => this.cancel())

              Button(this.isNew ? '创建' : '保存')
                .width('60%')
                .height(48)
                .fontSize(16)
                .backgroundColor($r('app.color.color_theme'))
                .fontColor(Color.White)
                .enabled(!this.isSaving && this.taskName.trim().length > 0)
                .onClick(() => this.saveTask())
            }
            .width('100%')
            .padding(16)
            .margin({ top: 24 })
          }
          .width('100%')
          .padding({ bottom: 32 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.color_background_gray'))
    }
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as TaskEditParams;
      this.isNew = params.isNew;
      this.task = params.task;
      // 在接收到参数后初始化表单数据
      this.initFormData();
    })
  }
}
