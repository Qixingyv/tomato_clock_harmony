import { TaskMode } from './TaskMode';

/**
 * 统计周期类型
 */
export type StatisticsPeriod = 'today' | 'week' | 'month';

/**
 * 统计数据接口
 */
export interface StatisticsData {
  period: StatisticsPeriod;
  startDate: Date;
  endDate: Date;
  completedTomatoes: number;
  focusMinutes: number;
  completedTasks: number;
  totalTasks: number;
  completionRate: number;
  dailyData: DailyData[];
  taskRanking: TaskRankingItem[];
}

/**
 * 每日统计数据
 */
export interface DailyData {
  date: Date;
  completedTomatoes: number;
  focusMinutes: number;
}

/**
 * 任务排名项
 */
export interface TaskRankingItem {
  taskId: number;
  taskName: string;
  taskMode: TaskMode;
  completedTomatoes: number;
  totalCompletedTomatoes: number;
}
