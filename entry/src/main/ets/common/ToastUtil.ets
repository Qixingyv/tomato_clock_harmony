import promptAction from '@ohos.promptAction';

/**
 * 提示工具类
 * 提供统一的Toast提示功能
 */
export class ToastUtil {
  /**
   * 显示普通提示
   */
  static showToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  /**
   * 显示错误提示（时长3秒）
   */
  static showError(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 3000
    });
  }

  /**
   * 显示成功提示
   */
  static showSuccess(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}
