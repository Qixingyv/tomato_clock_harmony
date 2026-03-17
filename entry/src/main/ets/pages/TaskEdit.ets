import { ToDoListClass } from "../viewmodel/ToDoListClass"
import { TaskType } from "../viewmodel/TaskType"
import { GlobalNavStack } from "../common/GlobalNavStack"
// import { ConnectionUtils } from "../common/network/ConnectionUtils"

/**
 * 任务编辑页面参数接口
 * 用于在页面跳转时传递任务编辑相关的参数
 */
interface TaskEditParams {
  /** 是否为新建任务，true=新建，false=编辑 */
  isNew: boolean;
  /** 要编辑的任务对象，新建时为null */
  task: ToDoListClass | null;
}

/**
 * TaskEdit组件的Builder函数
 * 用于在路由配置中创建TaskEdit实例
 */
@Builder
export function TaskEditBuilder() {
  TaskEdit()
}

/**
 * 任务编辑页面组件
 * 用于新建或编辑番茄钟任务，包含任务名称、模式、时长等配置项
 */
@Component
export struct TaskEdit {
  /** 任务名称输入框的状态 */
  @State private taskName: string = '';
  /** 任务模式：待办模式或长期模式 */
  @State private taskMode: TaskType = TaskType.Todo;
  /** 番茄时长（分钟），默认25分钟 */
  @State private tomatoMinutes: number = 25;
  /** 休息时长（分钟），默认5分钟 */
  @State private restMinutes: number = 5;
  /** 重复次数：待办模式为目标番茄数，长期模式为每日目标番茄数 */
  @State private repeatCount: number = 1;
  /** 截止日期（仅长期模式使用） */
  @State private deadline: Date | null = null;
  /** 是否正在保存中，用于防止重复提交 */
  @State private isSaving: boolean = false;
  
  /** 是否为新建任务 */
  private isNew: boolean = true;
  /** 任务ID，编辑模式时使用 */
  private taskId: number = 0;
  /** 用户ID，应该从登录状态获取，目前使用固定值 */
  private userId: number = 1;

  /**
   * 验证表单是否完整有效
   * 检查必填项是否已填写：任务名称必填，长期模式必须设置截止日期
   * @returns true表示表单有效，false表示表单无效
   */
  private isFormValid(): boolean {
    if (!this.taskName.trim()) {
      return false;
    }
    if (this.taskMode === TaskType.Plan && !this.deadline) {
      return false;
    }
    return true;
  }

  /**
   * 保存任务
   * 根据isNew标志决定是创建新任务还是更新现有任务
   * 保存成功后自动返回上一页面
   */
  async saveTask() {
    if (!this.isFormValid()) {
      return;
    }

    this.isSaving = true;
    try {
      let task: ToDoListClass;
      
      if (this.isNew) {
        // 新建任务
        task = new ToDoListClass(
          0,
          this.userId,
          this.taskName,
          this.taskMode,
          this.tomatoMinutes,
          this.restMinutes,
          this.taskMode === TaskType.Todo ? this.repeatCount : null,
          this.taskMode === TaskType.Plan ? this.repeatCount : null,
          0,
          0,
          this.taskMode === TaskType.Plan ? this.deadline : null,
          null,
          1
        );
        // TODO: 调用后端API
        // await ConnectionUtils.createTask(task);
      } else {
        // 更新任务
        // TODO: 从现有任务获取其他字段
        task = new ToDoListClass(
          this.taskId,
          this.userId,
          this.taskName,
          this.taskMode,
          this.tomatoMinutes,
          this.restMinutes,
          this.taskMode === TaskType.Todo ? this.repeatCount : null,
          this.taskMode === TaskType.Plan ? this.repeatCount : null,
          0,
          0,
          this.taskMode === TaskType.Plan ? this.deadline : null,
          null,
          1
        );
        // TODO: 调用后端API
        // await ConnectionUtils.updateTask(task);
      }

      // 保存成功后返回
      GlobalNavStack.pop();
    } catch (error) {
      console.error('保存任务失败:', JSON.stringify(error));
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 构建任务编辑页面UI
   * 包含标题栏、表单输入区域和保存按钮
   */
  build() {
    NavDestination() {
      Column() {
        // 标题栏：显示"新建任务"或"编辑任务"，右侧有取消按钮
        Row() {
          Text(this.isNew ? $r("app.string.string_new_task") : $r("app.string.string_edit_task"))
            .fontSize('20vp')
            .fontWeight(600)
            .layoutWeight(1)

          // 取消按钮：点击后返回上一页面
          Button($r("app.string.string_cancel"))
            .type(ButtonType.Normal)
            .fontColor($r("app.color.color_theme"))
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              GlobalNavStack.pop();
            })
        }
        .width('100%')
        .height('56vp')
        .padding({ left: '16vp', right: '16vp' })
        .backgroundColor(Color.White)
        .border({
          width: { bottom: 1 },
          color: '#E5E5E5'
        })

        // 表单内容区域（可滚动）
        Scroll() {
          Column() {
            // 任务名称输入区域
            Column() {
              Text($r("app.string.string_task_name"))
                .fontSize('16vp')
                .fontWeight(600)
                .width('100%')
                .margin({ bottom: '8vp' })

              TextInput({ placeholder: $r("app.string.string_please_enter_task_name") })
                .width('100%')
                .height('48vp')
                .onChange((value: string) => {
                  this.taskName = value;
                })
            }
            .width('100%')
            .padding('16vp')
            .margin({ top: '16vp' })
            .backgroundColor(Color.White)

            // 任务模式选择区域：待办模式或长期模式
            Column() {
              Text($r("app.string.string_task_mode"))
                .fontSize('16vp')
                .fontWeight(600)
                .width('100%')
                .margin({ bottom: '8vp' })

              Select([
                { value: $r("app.string.string_todo_mode") },
                { value: $r("app.string.string_plan_mode") }
              ])
                .width('100%')
                .height('48vp')
                .value(this.taskMode === TaskType.Todo ? $r("app.string.string_todo_mode") : $r("app.string.string_plan_mode"))
                .onSelect((index: number, value: ResourceStr) => {
                  this.taskMode = index === 0 ? TaskType.Todo : TaskType.Plan;
                  if (this.taskMode === TaskType.Todo) {
                    // 切换到待办模式时清空截止日期
                    this.deadline = null;
                  } else if (!this.deadline) {
                    // 切换到长期模式时，如果没有截止日期则设置为今天
                    // 计划模式下 DatePicker 默认会展示一个日期；这里同步状态，避免界面显示已选但 deadline 仍为 null 导致无法保存
                    this.deadline = new Date();
                  }
                })
            }
            .width('100%')
            .padding('16vp')
            .margin({ top: '16vp' })
            .backgroundColor(Color.White)

            // 番茄时长设置区域：使用滑块调整，范围1-120分钟
            Column() {
              Row() {
                Text($r("app.string.string_tomato_time"))
                  .fontSize('16vp')
                  .fontWeight(600)
                  .layoutWeight(1)
                Text(`${this.tomatoMinutes}${$r("app.string.string_minute")}`)
                  .fontSize('16vp')
                  .fontColor($r("app.color.color_theme"))
              }
              .width('100%')
              .margin({ bottom: '12vp' })

              Slider({
                value: this.tomatoMinutes,
                min: 1,
                max: 120,
                step: 1,
                style: SliderStyle.OutSet
              })
                .width('100%')
                .height('40vp')
                .blockColor($r("app.color.color_theme"))
                .trackColor('#E5E5E5')
                .selectedColor($r("app.color.color_theme"))
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.tomatoMinutes = Math.round(value);
                })
            }
            .width('100%')
            .padding('16vp')
            .margin({ top: '16vp' })
            .backgroundColor(Color.White)

            // 休息时长设置区域：使用滑块调整，范围1-120分钟
            Column() {
              Row() {
                Text($r("app.string.string_rest_time"))
                  .fontSize('16vp')
                  .fontWeight(600)
                  .layoutWeight(1)
                Text(`${this.restMinutes}${$r("app.string.string_minute")}`)
                  .fontSize('16vp')
                  .fontColor($r("app.color.color_theme"))
              }
              .width('100%')
              .margin({ bottom: '12vp' })

              Slider({
                value: this.restMinutes,
                min: 1,
                max: 120,
                step: 1,
                style: SliderStyle.OutSet
              })
                .width('100%')
                .height('40vp')
                .blockColor($r("app.color.color_theme"))
                .trackColor('#E5E5E5')
                .selectedColor($r("app.color.color_theme"))
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.restMinutes = Math.round(value);
                })
            }
            .width('100%')
            .padding('16vp')
            .margin({ top: '16vp' })
            .backgroundColor(Color.White)

            // 重复次数设置区域：待办模式为目标番茄数，长期模式为每日目标番茄数，范围1-20
            Column() {
              Row() {
                Text(this.taskMode === TaskType.Todo ? $r("app.string.string_repeat_count") : $r("app.string.string_daily_repeat_count"))
                  .fontSize('16vp')
                  .fontWeight(600)
                  .layoutWeight(1)
                Text(this.repeatCount.toString())
                  .fontSize('16vp')
                  .fontColor($r("app.color.color_theme"))
              }
              .width('100%')
              .margin({ bottom: '12vp' })

              Slider({
                value: this.repeatCount,
                min: 1,
                max: 20,
                step: 1,
                style: SliderStyle.OutSet
              })
                .width('100%')
                .height('40vp')
                .blockColor($r("app.color.color_theme"))
                .trackColor('#E5E5E5')
                .selectedColor($r("app.color.color_theme"))
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.repeatCount = Math.round(value);
                })
            }
            .width('100%')
            .padding('16vp')
            .margin({ top: '16vp' })
            .backgroundColor(Color.White)

            // 截止日期选择区域（仅长期模式显示）
            if (this.taskMode === TaskType.Plan) {
              Column() {
                Text($r("app.string.string_deadline_duration"))
                  .fontSize('16vp')
                  .fontWeight(600)
                  .width('100%')
                  .margin({ bottom: '8vp' })

                DatePicker({
                  start: new Date(),
                  selected: this.deadline || new Date()
                })
                  .width('100%')
                  .height('48vp')
                  .onDateChange((date: Date) => {
                    this.deadline = date;
                  })
              }
              .width('100%')
              .padding('16vp')
              .margin({ top: '16vp' })
              .backgroundColor(Color.White)
            }
          }
          .width('100%')
        }
        .layoutWeight(1)

        // 保存按钮：表单有效且未在保存中时可用
        Button($r("app.string.string_save"))
          .width('90%')
          .height('48vp')
          .fontSize('16vp')
          .backgroundColor(this.isFormValid() ? $r("app.color.color_theme") : Color.Gray)
          .enabled(this.isFormValid() && !this.isSaving)
          .onClick(() => {
            this.saveTask();
          })
          .margin({ bottom: '32vp' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    /**
     * 页面准备就绪时的回调
     * 从路由参数中获取任务信息，如果是编辑模式则填充现有数据
     */
    .onReady((context: NavDestinationContext) => {
      // 从路由参数中获取任务编辑参数
      const params = context.pathInfo.param as TaskEditParams;
      this.isNew = params.isNew;
      
      if (!params.isNew && params.task) {
        // 编辑模式：从现有任务对象中填充表单数据
        this.taskId = params.task.getId;
        this.taskName = params.task.getName;
        this.taskMode = params.task.getMode as TaskType;
        this.tomatoMinutes = params.task.getTomatoMinutes;
        this.restMinutes = params.task.getRestMinutes;
        // 根据任务模式设置重复次数：待办模式使用目标番茄数，长期模式使用每日目标番茄数
        this.repeatCount = params.task.getMode === 1 
          ? (params.task.getTargetTomatoCount || 1)
          : (params.task.getDailyTargetTomatoCount || 1);
        this.deadline = params.task.getDeadline;
      }
    })
  }
}
