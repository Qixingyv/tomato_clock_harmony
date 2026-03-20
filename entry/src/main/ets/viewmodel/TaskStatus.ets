/**
 * 任务状态枚举
 * 定义任务的生命周期状态
 */
export enum TaskStatus {
  WORKING = 1,    // 进行中（通用）
  COMPLETED = 2,  // 已完成（通用）
  EXPIRED = 4,    // 已过期（计划模式专属）
  CANCELLED = 5   // 已取消（通用）
}
