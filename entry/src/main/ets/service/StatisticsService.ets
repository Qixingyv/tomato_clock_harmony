import { Logger } from '../common/Logger';
import { DateUtils } from '../common/DateUtils';
import { TaskService } from './TaskService';
import { ToDoListClass } from '../viewmodel/ToDoListClass';
import { TaskMode } from '../viewmodel/TaskMode';
import { TaskStatus } from '../viewmodel/TaskStatus';
import {
  StatisticsData,
  StatisticsPeriod,
  DailyData,
  TaskRankingItem
} from '../viewmodel/StatisticsModels';
import { TaskConstant } from '../common/constants/TaskConstant';

/**
 * 统计服务类
 * 提供统计数据计算和分析功能
 */
export class StatisticsService {

  private constructor() {} // 防止实例化

  // ==================== 今日统计 ====================

  /**
   * 获取今日统计数据
   */
  static getTodayStatistics(): StatisticsData {
    const today = DateUtils.getToday();
    const endDate = new Date(today);
    endDate.setHours(23, 59, 59, 999);

    return StatisticsService.calculateStatistics(today, endDate, 'today');
  }

  // ==================== 本周统计 ====================

  /**
   * 获取本周统计数据
   * 从本周一到当前时间
   */
  static getWeekStatistics(): StatisticsData {
    const startDate = DateUtils.getWeekStart();
    const endDate = new Date();
    endDate.setHours(23, 59, 59, 999);

    return StatisticsService.calculateStatistics(startDate, endDate, 'week');
  }

  /**
   * 获取指定周的统计数据
   * @param weekStart 周一日期
   */
  static getWeekStatisticsFor(weekStart: Date): StatisticsData {
    const startDate = new Date(weekStart);
    startDate.setHours(0, 0, 0, 0);

    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + 6);
    endDate.setHours(23, 59, 59, 999);

    return StatisticsService.calculateStatistics(startDate, endDate, 'week');
  }

  // ==================== 本月统计 ====================

  /**
   * 获取本月统计数据
   * 从本月1号到当前时间
   */
  static getMonthStatistics(): StatisticsData {
    const startDate = DateUtils.getMonthStart();
    const endDate = new Date();
    endDate.setHours(23, 59, 59, 999);

    return StatisticsService.calculateStatistics(startDate, endDate, 'month');
  }

  /**
   * 获取指定月的统计数据
   * @param year 年份
   * @param month 月份（1-12）
   */
  static getMonthStatisticsFor(year: number, month: number): StatisticsData {
    const startDate = new Date(year, month - 1, 1);
    startDate.setHours(0, 0, 0, 0);

    const endDate = new Date(year, month, 0);
    endDate.setHours(23, 59, 59, 999);

    return StatisticsService.calculateStatistics(startDate, endDate, 'month');
  }

  // ==================== 自定义时间段统计 ====================

  /**
   * 获取自定义时间段的统计数据
   * @param startDate 开始日期
   * @param endDate 结束日期
   * @param period 统计周期类型
   */
  static getCustomStatistics(
    startDate: Date,
    endDate: Date,
    period: StatisticsPeriod = 'today'
  ): StatisticsData {
    const start = new Date(startDate);
    start.setHours(0, 0, 0, 0);

    const end = new Date(endDate);
    end.setHours(23, 59, 59, 999);

    return StatisticsService.calculateStatistics(start, end, period);
  }

  // ==================== 核心计算逻辑 ====================

  /**
   * 计算指定时间段的统计数据
   * @param startDate 开始日期
   * @param endDate 结束日期
   * @param period 统计周期类型
   */
  private static calculateStatistics(
    startDate: Date,
    endDate: Date,
    period: StatisticsPeriod
  ): StatisticsData {
    const allTasks = TaskService.getAllTasks();

    // 过滤在时间段内有活动的任务
    const activeTasks = allTasks.filter(task => {
      const createdAt = task.getCreatedAt;
      return createdAt <= endDate;
    });

    // 计算完成的番茄数和专注分钟数
    let completedTomatoes = 0;
    let focusMinutes = 0;
    const taskCompletionMap = new Map<number, number>();

    for (const task of activeTasks) {
      if (task.getMode === TaskMode.PLAN) {
        // 计划任务：统计期间内的完成数需要通过历史记录计算
        // 由于当前数据模型限制，我们使用总完成数作为近似值
        const totalCompleted = task.getFinishedTomatoCount;
        completedTomatoes += totalCompleted;
        focusMinutes += totalCompleted * task.getTomatoMinutes;
        taskCompletionMap.set(task.getId, totalCompleted);
      } else {
        // 待办任务：统计总完成数
        const totalCompleted = task.getFinishedTomatoCount;
        completedTomatoes += totalCompleted;
        focusMinutes += totalCompleted * task.getTomatoMinutes;
        taskCompletionMap.set(task.getId, totalCompleted);
      }
    }

    // 计算完成任务数
    const completedTasks = activeTasks.filter(t => t.getStatus === TaskStatus.COMPLETED).length;

    // 计算完成率
    const totalTasks = activeTasks.length;
    const completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    // 生成每日数据
    const dailyData = StatisticsService.generateDailyData(startDate, endDate, activeTasks);

    // 生成任务排名
    const taskRanking = StatisticsService.generateTaskRanking(activeTasks);

    return {
      period,
      startDate,
      endDate,
      completedTomatoes,
      focusMinutes,
      completedTasks,
      totalTasks,
      completionRate: Math.round(completionRate * 10) / 10,
      dailyData,
      taskRanking
    };
  }

  /**
   * 生成每日统计数据
   * @param startDate 开始日期
   * @param endDate 结束日期
   * @param tasks 任务列表
   */
  private static generateDailyData(
    startDate: Date,
    endDate: Date,
    tasks: ToDoListClass[]
  ): DailyData[] {
    const dailyData: DailyData[] = [];
    const currentDate = new Date(startDate);

    while (currentDate <= endDate) {
      const dayDate = new Date(currentDate);
      let dayTomatoes = 0;
      let dayMinutes = 0;

      for (const task of tasks) {
        if (task.getMode === TaskMode.PLAN) {
          // 计划任务：如果任务的最后重置日期在当天之前，说明当天可能有完成
          // 这是一个简化的计算方式
          const lastReset = task.getLastResetDate;
          if (lastReset && lastReset <= dayDate) {
            dayTomatoes += task.getTodayFinishedCount;
            dayMinutes += task.getTodayFinishedCount * task.getTomatoMinutes;
          }
        }
      }

      // 对于待办任务，由于没有每日记录，我们平均分配
      // 这是一个简化的处理方式
      const todoTasks = tasks.filter(t => t.getMode === TaskMode.TODO && t.getStatus === TaskStatus.COMPLETED);
      const daysDiff = Math.max(1, DateUtils.diffDays(startDate, endDate) + 1);
      for (const task of todoTasks) {
        const avgTomatoes = task.getFinishedTomatoCount / daysDiff;
        dayTomatoes += Math.round(avgTomatoes * 10) / 10;
        dayMinutes += Math.round(avgTomatoes * task.getTomatoMinutes * 10) / 10;
      }

      dailyData.push({
        date: dayDate,
        completedTomatoes: Math.round(dayTomatoes),
        focusMinutes: Math.round(dayMinutes)
      });

      currentDate.setDate(currentDate.getDate() + 1);
    }

    return dailyData;
  }

  /**
   * 生成任务排名（前10名）
   * @param tasks 任务列表
   */
  private static generateTaskRanking(tasks: ToDoListClass[]): TaskRankingItem[] {
    const ranking: TaskRankingItem[] = tasks.map((task): TaskRankingItem => {
      return {
        taskId: task.getId,
        taskName: task.getName,
        taskMode: task.getMode as TaskMode,
        completedTomatoes: task.getMode === TaskMode.PLAN ?
          task.getTodayFinishedCount : task.getFinishedTomatoCount,
        totalCompletedTomatoes: task.getFinishedTomatoCount
      };
    });

    // 按完成数排序
    ranking.sort((a, b) => b.completedTomatoes - a.completedTomatoes);

    // 返回前10名
    return ranking.slice(0, 10);
  }

  // ==================== 快捷统计方法 ====================

  /**
   * 获取今日完成番茄数
   */
  static getTodayCompletedTomatoes(): number {
    return TaskService.getTodayCompletedTomatoes();
  }

  /**
   * 获取今日专注分钟数
   */
  static getTodayFocusMinutes(): number {
    const tomatoes = StatisticsService.getTodayCompletedTomatoes();
    const tasks = TaskService.getActiveTasks();
    if (tasks.length === 0) {
      return tomatoes * TaskConstant.DEFAULT_TOMATO_MINUTES;
    }
    // 使用第一个活跃任务的番茄时长作为平均值
    return tomatoes * tasks[0].getTomatoMinutes;
  }

  /**
   * 获取本周完成番茄数
   */
  static getWeekCompletedTomatoes(): number {
    const stats = StatisticsService.getWeekStatistics();
    return stats.completedTomatoes;
  }

  /**
   * 获取本月完成番茄数
   */
  static getMonthCompletedTomatoes(): number {
    const stats = StatisticsService.getMonthStatistics();
    return stats.completedTomatoes;
  }

  /**
   * 获取总完成番茄数（所有时间）
   */
  static getTotalCompletedTomatoes(): number {
    return TaskService.getTotalCompletedTomatoes();
  }

  /**
   * 获取平均每日完成番茄数（本月）
   */
  static getAverageDailyTomatoes(): number {
    const stats = StatisticsService.getMonthStatistics();
    const days = Math.max(1, DateUtils.diffDays(stats.startDate, stats.endDate) + 1);
    return Math.round((stats.completedTomatoes / days) * 10) / 10;
  }

  /**
   * 获取连续打卡天数
   * 简化版本：检查今天和昨天是否有完成记录
   */
  static getContinuousDays(): number {
    const today = DateUtils.getToday();
    const yesterday = DateUtils.addDays(today, -1);

    let days = 0;
    let checkDate = today;

    while (true) {
      const dayStats = StatisticsService.getCustomStatistics(checkDate, checkDate, 'today');
      if (dayStats.completedTomatoes > 0) {
        days++;
        checkDate = DateUtils.addDays(checkDate, -1);
      } else {
        break;
      }

      // 最多检查365天
      if (days > 365) {
        break;
      }
    }

    return days;
  }
}
