import { TimerMode } from './TimerMode';

/**
 * 计时器视图模型
 * 管理计时器状态和持久化
 */
@Observed
export class TimerViewModel {
  /**
   * 计时器模式（专注/休息）
   */
  @Track mode: TimerMode = TimerMode.WORKING;

  /**
   * 当前计时秒数
   */
  @Track remainingSeconds: number = 25 * 60;

  /**
   * 总时长（秒）
   */
  @Track totalSeconds: number = 25 * 60;

  /**
   * 是否正在计时
   */
  @Track isRunning: boolean = false;

  /**
   * 是否暂停
   */
  @Track isPaused: boolean = false;

  /**
   * 当前关联的任务ID
   */
  @Track taskId: number = 0;

  /**
   * 计算进度百分比（0-100）
   */
  get progress(): number {
    if (this.totalSeconds === 0) {
      return 0;
    }
    return Math.round(((this.totalSeconds - this.remainingSeconds) / this.totalSeconds) * 100);
  }

  /**
   * 格式化时间为 MM:SS
   */
  get formattedTime(): string {
    const minutes = Math.floor(this.remainingSeconds / 60);
    const seconds = this.remainingSeconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }

  /**
   * 转换为持久化对象
   */
  toPersist(): Record<string, Object> {
    return {
      "mode": this.mode,
      "remainingSeconds": this.remainingSeconds,
      "totalSeconds": this.totalSeconds,
      "isRunning": this.isRunning,
      "isPaused": this.isPaused,
      "taskId": this.taskId
    };
  }

  /**
   * 从持久化对象恢复
   */
  static fromPersist(data: Record<string, Object>): TimerViewModel {
    const vm = new TimerViewModel();
    vm.mode = (data['mode'] as TimerMode) || TimerMode.WORKING;
    vm.remainingSeconds = (data['remainingSeconds'] as number) || 25 * 60;
    vm.totalSeconds = (data['totalSeconds'] as number) || 25 * 60;
    vm.isRunning = (data['isRunning'] as boolean) || false;
    vm.isPaused = (data['isPaused'] as boolean) || false;
    vm.taskId = (data['taskId'] as number) || 0;
    return vm;
  }

  /**
   * 开始计时
   */
  start(): void {
    this.isRunning = true;
    this.isPaused = false;
  }

  /**
   * 暂停计时
   */
  pause(): void {
    this.isPaused = true;
  }

  /**
   * 恢复计时
   */
  resume(): void {
    this.isPaused = false;
  }

  /**
   * 停止计时
   */
  stop(): void {
    this.isRunning = false;
    this.isPaused = false;
  }

  /**
   * 切换模式（专注↔休息）
   */
  toggleMode(): void {
    this.mode = this.mode === TimerMode.WORKING ? TimerMode.RESTING : TimerMode.WORKING;
  }

  /**
   * 设置任务时长（分钟）
   */
  setDuration(minutes: number): void {
    this.totalSeconds = minutes * 60;
    this.remainingSeconds = this.totalSeconds;
  }
}
