/**
 * 任务数据模型类
 * 用于表示和管理番茄钟任务的所有属性和行为
 * 支持两种任务模式：待办模式（一次性任务）和长期模式（每日重复任务）
 */
export class ToDoListClass {

  /** 任务唯一标识符 */
  private id: number = 0;
  /** 所属用户ID，用于区分不同用户的任务 */
  private user_id: number = 0;
  /** 任务名称，用户自定义的任务标题 */
  private name: string = '';
  /** 任务类型：1=待办模式（一次性任务），2=长期模式（每日重复任务） */
  private mode: number = 0;
  /** 单个番茄钟的时长（单位：分钟），默认25分钟 */
  private tomato_minutes: number = 25;
  /** 休息时长（单位：分钟），默认5分钟 */
  private rest_minutes: number = 5;
  /** 待办模式：目标总番茄数，完成该数量后任务完成 */
  private target_tomato_count: number | null = null;
  /** 长期模式：每日目标番茄数，每天需要完成的番茄钟数量 */
  private daily_target_tomato_count: number | null = null;
  /** 历史累计完成番茄数，记录任务创建以来完成的所有番茄钟总数 */
  private finished_tomato_count: number = 0;
  /** 今日已完成番茄数（仅长期模式使用），每天重置为0 */
  private today_finished_count: number = 0;
  /** 截止日期（仅长期任务有值），任务的目标完成日期 */
  private deadline: Date | null = null;
  /** 最后一次重置"今日计数"的日期，用于判断是否需要重置今日计数 */
  private last_reset_date: Date | null = null;
  /** 任务状态：1=进行中，2=已完成，3=已取消/归档，4=已过期 */
  private status: number = 1;
  /** 任务创建时间 */
  private created_at: Date = new Date();
  /** 任务最后更新时间 */
  private updated_at: Date = new Date();

  /**
   * 构造函数
   * @param id 任务ID，默认为0（新建任务时使用）
   * @param user_id 用户ID，默认为0
   * @param name 任务名称，默认为空字符串
   * @param mode 任务模式，默认为1（待办模式）
   * @param tomato_minutes 番茄时长，默认25分钟
   * @param rest_minutes 休息时长，默认5分钟
   * @param target_tomato_count 待办模式的目标番茄数，默认为null
   * @param daily_target_tomato_count 长期模式的每日目标番茄数，默认为null
   * @param finished_tomato_count 已完成番茄数，默认为0
   * @param today_finished_count 今日已完成番茄数，默认为0
   * @param deadline 截止日期，默认为null
   * @param last_reset_date 最后重置日期，默认为null
   * @param status 任务状态，默认为1（进行中）
   * @param created_at 创建时间，默认为当前时间
   * @param updated_at 更新时间，默认为当前时间
   */
  constructor(
    id: number = 0,
    user_id: number = 0,
    name: string = '',
    mode: number = 1,
    tomato_minutes: number = 25,
    rest_minutes: number = 5,
    target_tomato_count: number | null = null,
    daily_target_tomato_count: number | null = null,
    finished_tomato_count: number = 0,
    today_finished_count: number = 0,
    deadline: Date | null = null,
    last_reset_date: Date | null = null,
    status: number = 1,
    created_at: Date = new Date(),
    updated_at: Date = new Date()
  ) {
    this.id = id;
    this.user_id = user_id;
    this.name = name;
    this.mode = mode;
    this.tomato_minutes = tomato_minutes;
    this.rest_minutes = rest_minutes;
    this.target_tomato_count = target_tomato_count;
    this.daily_target_tomato_count = daily_target_tomato_count;
    this.finished_tomato_count = finished_tomato_count;
    this.today_finished_count = today_finished_count;
    this.deadline = deadline;
    this.last_reset_date = last_reset_date;
    this.status = status;
    this.created_at = created_at;
    this.updated_at = updated_at;
  }

  // ==================== Getter方法 ====================
  
  /** 获取任务ID */
  get getId(): number {
    return this.id;
  }

  /** 获取用户ID */
  get getUserId(): number {
    return this.user_id;
  }

  /** 获取任务名称 */
  get getName(): string {
    return this.name;
  }

  /** 获取任务模式（1=待办模式，2=长期模式） */
  get getMode(): number {
    return this.mode;
  }

  /** 获取番茄时长（分钟） */
  get getTomatoMinutes(): number {
    return this.tomato_minutes;
  }

  /** 获取休息时长（分钟） */
  get getRestMinutes(): number {
    return this.rest_minutes;
  }

  /** 获取待办模式的目标番茄数 */
  get getTargetTomatoCount(): number | null {
    return this.target_tomato_count;
  }

  /** 获取长期模式的每日目标番茄数 */
  get getDailyTargetTomatoCount(): number | null {
    return this.daily_target_tomato_count;
  }

  /** 获取历史累计完成番茄数 */
  get getFinishedTomatoCount(): number {
    return this.finished_tomato_count;
  }

  /** 获取今日已完成番茄数（仅长期模式有效） */
  get getTodayFinishedCount(): number {
    return this.today_finished_count;
  }

  /** 获取截止日期 */
  get getDeadline(): Date | null {
    return this.deadline;
  }

  /** 获取最后重置日期 */
  get getLastResetDate(): Date | null {
    return this.last_reset_date;
  }

  /** 获取任务状态 */
  get getStatus(): number {
    return this.status;
  }

  /** 获取创建时间 */
  get getCreatedAt(): Date {
    return this.created_at;
  }

  /** 获取更新时间 */
  get getUpdatedAt(): Date {
    return this.updated_at;
  }

  // ==================== 兼容旧接口的方法（为了不破坏现有代码） ====================
  
  /** 获取任务名称（兼容旧接口） */
  get getTaskName(): string {
    return this.name;
  }

  /** 获取任务类型（兼容旧接口） */
  get getTaskType(): number {
    return this.mode;
  }

  /**
   * 获取总目标番茄数
   * 待办模式返回目标总番茄数，长期模式返回每日目标番茄数
   * @returns 目标番茄数，如果为null则返回0
   */
  get getTotalTomatoNum(): number {
    return this.mode === 1 ? (this.target_tomato_count || 0) : (this.daily_target_tomato_count || 0);
  }

  /** 获取番茄时长（兼容旧接口） */
  get getTomatoDuration(): number {
    return this.tomato_minutes;
  }

  /** 获取休息时长（兼容旧接口） */
  get getRestDuration(): number {
    return this.rest_minutes;
  }

  /**
   * 获取已完成番茄数
   * 待办模式返回总完成数，长期模式返回今日完成数
   * @returns 已完成番茄数
   */
  get getCompletedTomatoNum(): number {
    return this.mode === 1 ? this.finished_tomato_count : this.today_finished_count;
  }

  /** 获取任务状态（兼容旧接口） */
  get getState(): number {
    return this.status;
  }

  /** 获取创建时间（兼容旧接口） */
  get getCreateTime(): Date {
    return this.created_at;
  }

  /** 获取更新时间（兼容旧接口） */
  get getUpdateTime(): Date {
    return this.updated_at;
  }

  // ==================== 业务方法 ====================
  
  /**
   * 计算剩余天数（仅长期模式有效）
   * 计算从今天到截止日期的剩余天数
   * @returns 剩余天数，如果不是长期模式或没有截止日期则返回0
   */
  getRemainingDays(): number {
    if (this.mode !== 2 || !this.deadline) {
      return 0;
    }
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const deadline = new Date(this.deadline);
    deadline.setHours(0, 0, 0, 0);
    const diffTime = deadline.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return Math.max(0, diffDays);
  }

  /**
   * 增加已完成番茄个数
   * 根据任务模式自动更新相应的完成数：
   * - 待办模式：增加总完成数（不超过目标数）
   * - 长期模式：同时增加今日完成数和总完成数
   * 更新后会自动更新updated_at时间戳
   */
  incrementCompletedTomatoNum(): void {
    if (this.mode === 1) {
      // 待办模式：增加总完成数
      if (this.target_tomato_count && this.finished_tomato_count < this.target_tomato_count) {
        this.finished_tomato_count++;
        this.updated_at = new Date();
      }
    } else {
      // 长期模式：增加今日完成数和总完成数
      this.today_finished_count++;
      this.finished_tomato_count++;
      this.updated_at = new Date();
    }
  }

  /**
   * 设置已完成番茄个数
   * 根据任务模式设置相应的完成数，并进行合法性校验
   * @param num 要设置的完成数，必须大于等于0且不超过目标数
   */
  setCompletedTomatoNum(num: number): void {
    if (this.mode === 1) {
      // 待办模式：设置总完成数
      if (num >= 0 && this.target_tomato_count && num <= this.target_tomato_count) {
        this.finished_tomato_count = num;
        this.updated_at = new Date();
      }
    } else {
      // 长期模式：设置今日完成数
      if (num >= 0 && this.daily_target_tomato_count && num <= this.daily_target_tomato_count) {
        this.today_finished_count = num;
        this.updated_at = new Date();
      }
    }
  }

  /**
   * 重置今日计数（仅长期模式有效）
   * 如果今天是新的一天，将今日完成数重置为0，并更新最后重置日期
   * 用于长期模式每日自动重置计数
   */
  resetTodayCount(): void {
    if (this.mode === 2) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      // 如果今天还没有重置过，则重置今日计数
      if (!this.last_reset_date || this.last_reset_date.getTime() !== today.getTime()) {
        this.today_finished_count = 0;
        this.last_reset_date = today;
        this.updated_at = new Date();
      }
    }
  }

  // ==================== Setter方法 ====================

  /**
   * 设置任务名称
   */
  setName(name: string): void {
    this.name = name;
    this.updated_at = new Date();
  }

  /**
   * 设置番茄时长
   */
  setTomatoMinutes(minutes: number): void {
    this.tomato_minutes = minutes;
    this.updated_at = new Date();
  }

  /**
   * 设置休息时长
   */
  setRestMinutes(minutes: number): void {
    this.rest_minutes = minutes;
    this.updated_at = new Date();
  }

  /**
   * 设置目标番茄数（待办模式）
   */
  setTargetTomatoCount(count: number): void {
    this.target_tomato_count = count;
    this.updated_at = new Date();
  }

  /**
   * 设置每日目标番茄数（计划模式）
   */
  setDailyTargetTomatoCount(count: number): void {
    this.daily_target_tomato_count = count;
    this.updated_at = new Date();
  }

  /**
   * 设置截止日期（计划模式）
   */
  setDeadline(date: Date): void {
    this.deadline = date;
    this.updated_at = new Date();
  }

  /**
   * 设置任务状态
   */
  setStatus(status: number): void {
    this.status = status;
    this.updated_at = new Date();
  }

  // ==================== 序列化方法 ====================

  /**
   * 转换为JSON对象（用于存储）
   * Date对象转换为时间戳存储
   */
  toJson(): Record<string, Object | null> {
    return {
      'id': this.id,
      'user_id': this.user_id,
      'name': this.name,
      'mode': this.mode,
      'tomato_minutes': this.tomato_minutes,
      'rest_minutes': this.rest_minutes,
      'target_tomato_count': this.target_tomato_count,
      'daily_target_tomato_count': this.daily_target_tomato_count,
      'finished_tomato_count': this.finished_tomato_count,
      'today_finished_count': this.today_finished_count,
      'deadline': this.deadline ? this.deadline.getTime() : null,
      'last_reset_date': this.last_reset_date ? this.last_reset_date.getTime() : null,
      'status': this.status,
      'created_at': this.created_at.getTime(),
      'updated_at': this.updated_at.getTime()
    };
  }

  /**
   * 从JSON对象创建实例（用于从存储恢复）
   * 时间戳转换为Date对象
   */
  static fromJson(data: Record<string, Object>): ToDoListClass {
    return new ToDoListClass(
      (data['id'] as number) || 0,
      (data['user_id'] as number) || 0,
      (data['name'] as string) || '',
      (data['mode'] as number) || 1,
      (data['tomato_minutes'] as number) || 25,
      (data['rest_minutes'] as number) || 5,
      (data['target_tomato_count'] as number | null) || null,
      (data['daily_target_tomato_count'] as number | null) || null,
      (data['finished_tomato_count'] as number) || 0,
      (data['today_finished_count'] as number) || 0,
      (data['deadline'] as number | null) ? new Date(data['deadline'] as number) : null,
      (data['last_reset_date'] as number | null) ? new Date(data['last_reset_date'] as number) : null,
      (data['status'] as number) || 1,
      (data['created_at'] as number) ? new Date(data['created_at'] as number) : new Date(),
      (data['updated_at'] as number) ? new Date(data['updated_at'] as number) : new Date()
    );
  }

}