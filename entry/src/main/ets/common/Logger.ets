/**
 * 日志工具类
 * 提供统一的日志输出格式
 */
export class Logger {
  private static readonly TAG: string = 'TomatoClock';

  /**
   * 输出调试日志
   */
  static debug(message: string, ...args: Object[]): void {
    console.debug(`[${Logger.TAG}] [DEBUG] ${message}`, ...args);
  }

  /**
   * 输出信息日志
   */
  static info(message: string, ...args: Object[]): void {
    console.info(`[${Logger.TAG}] [INFO] ${message}`, ...args);
  }

  /**
   * 输出警告日志
   */
  static warn(message: string, ...args: Object[]): void {
    console.warn(`[${Logger.TAG}] [WARN] ${message}`, ...args);
  }

  /**
   * 输出错误日志
   */
  static error(message: string, error?: Error): void {
    console.error(`[${Logger.TAG}] [ERROR] ${message}`, error);
  }
}
