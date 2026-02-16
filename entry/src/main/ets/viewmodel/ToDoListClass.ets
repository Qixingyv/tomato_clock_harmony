export class ToDoListClass {

  // 任务id
  private id: number = 0;
  // 所属用户id
  private user_id: number = 0;
  // 任务名称
  private task_name: string = '';
  // 任务类型 1. 待办模式 2. 长期模式
  private task_type: number = 0;
  // 总共需要番茄个数
  private total_tomato_num: number = 0;
  // 单个番茄时长(分钟)
  private tomato_duration: number = 0;
  // 休息时长(分钟)
  private rest_duration: number = 0;
  // 截至日期
  private deadline: Date = new Date();
  // 已完成番茄个数
  private completed_tomato_num: number = 0;
  // 任务状态
  private state: number = 0;
  // 创建时间
  private create_time: Date = new Date();
  // 更新时间
  private update_time: Date = new Date();

  constructor(
    id: number,
    user_id: number,
    task_name: string,
    task_type: number,
    total_tomato_num: number,
    tomato_duration: number,
    rest_duration: number,
    deadline: Date,
    completed_tomato_num: number,
    state: number,
    create_time: Date,
    update_time: Date
  ) {
    this.id = id;
    this.user_id = user_id;
    this.task_name = task_name;
    this.task_type = task_type;
    this.total_tomato_num = total_tomato_num;
    this.tomato_duration = tomato_duration;
    this.rest_duration = rest_duration;
    this.deadline = deadline;
    this.completed_tomato_num = completed_tomato_num;
    this.state = state;
    this.create_time = create_time;
    this.update_time = update_time;
  }

  get getId(): number {
    return this.id;
  }

  get getUserId(): number {
    return this.user_id;
  }
  get getTaskName(): string {
    return this.task_name;
  }
  get getTaskType(): number {
    return this.task_type;
  }
  get getTotalTomatoNum(): number {
    return this.total_tomato_num;
  }
  get getTomatoDuration(): number {
    return this.tomato_duration;
  }
  get getRestDuration(): number {
    return this.rest_duration;
  }

  get getDeadline(): Date {
    return this.deadline;
  }

  get getCompletedTomatoNum(): number {
    return this.completed_tomato_num;
  }

  get getState(): number {
    return this.state;
  }

  get getCreateTime(): Date {
    return this.create_time;
  }

  get getUpdateTime(): Date {
    return this.update_time;
  }



}