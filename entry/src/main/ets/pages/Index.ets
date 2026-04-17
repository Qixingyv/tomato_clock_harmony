/**
 * Index 登录页面
 * 支持微信和华为账号登录
 */
import { AuthService } from '../service/AuthService';
import { GlobalNavStack } from '../common/GlobalNavStack';
import { Logger } from '../common/Logger';
import { ToastUtil } from '../common/ToastUtil';
import { promptAction } from '@kit.ArkUI';

/**
 * Index页面Builder函数
 * 用于路由注册
 */
@Builder
export function IndexBuilder() {
  Index()
}

@Entry
@Component
export struct Index {
  @State private isLoading: boolean = false;
  @State private hasAutoLoginChecked: boolean = false;

  async aboutToAppear() {
    // 注册登录状态变化监听器
    AuthService.setAuthStateChangeListener((isLoggedIn: boolean) => {
      if (isLoggedIn) {
        // 用户已登录，跳转到主页
        this.navigateToMain();
      }
      // 如果已退出登录，不需要做任何事，因为已经在登录页了
    });

    // 检查自动登录
    const loggedIn = await this.checkAutoLogin();
    if (loggedIn) {
      this.navigateToMain();
    }
    this.hasAutoLoginChecked = true;
  }

  aboutToDisappear(): void {
    // 移除登录状态监听器
    AuthService.removeAuthStateChangeListener();
  }

  /**
   * 检查自动登录
   */
  private async checkAutoLogin(): Promise<boolean> {
    try {
      await AuthService.init();
      return AuthService.isLoggedIn();
    } catch (error) {
      Logger.error('Auto login check failed', error as Error);
      return false;
    }
  }

  /**
   * 跳转到主页
   */
  private navigateToMain(): void {
    GlobalNavStack.pushPathByName('MainPage', null);
  }

  /**
   * 微信登录
   */
  private async handleWechatLogin(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    try {
      // 拉起微信授权
      const code = await this.getWechatAuthCode();
      const result = await AuthService.loginWithWeChat(code);
      if (result) {
        this.navigateToMain();
      } else {
        ToastUtil.showError('登录失败');
      }
    } catch (error) {
      Logger.error('Wechat login failed', error as Error);
      ToastUtil.showError('登录失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 华为登录
   */
  private async handleHuaweiLogin(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    try {
      // 拉起华为授权
      const accessToken = await this.getHuaweiAccessToken();
      const result = await AuthService.loginWithHuawei(accessToken);
      if (result) {
        this.navigateToMain();
      } else {
        ToastUtil.showError('登录失败');
      }
    } catch (error) {
      Logger.error('Huawei login failed', error as Error);
      ToastUtil.showError('登录失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 游客模式登录
   */
  private async handleGuestLogin(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    try {
      const result = await AuthService.loginAsGuest();
      if (result) {
        this.navigateToMain();
      } else {
        ToastUtil.showError('登录失败');
      }
    } catch (error) {
      Logger.error('Guest login failed', error as Error);
      ToastUtil.showError('登录失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 获取微信授权码（模拟）
   */
  private async getWechatAuthCode(): Promise<string> {
    // TODO: 实际项目中调用微信SDK
    // const result = await wechatAuthProvider.getAuthCode();
    return 'mock_wechat_code';
  }

  /**
   * 获取华为访问令牌（模拟）
   */
  private async getHuaweiAccessToken(): Promise<string> {
    // TODO: 实际项目中调用华为Account Kit
    // const result = await accountAuthProvider.getAccessToken();
    return 'mock_huawei_token';
  }

  build() {
    Navigation(GlobalNavStack) {
      Column() {
        // Logo和标题
        Image($r('app.media.icon_foreground'))
          .width(120)
          .height(120)
          .margin({ top: 80, bottom: 20 })

        Text('番茄钟')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.color_theme'))
          .margin({ bottom: 8 })

        Text('专注当下，高效生活')
          .fontSize(14)
          .fontColor($r('app.color.color_text_tertiary'))
          .margin({ bottom: 60 })

        // 登录按钮区域
        Column() {
          // 游客模式
          Button('游客模式')
            .width('80%')
            .height(48)
            .fontSize(16)
            .backgroundColor($r('app.color.color_background_gray'))
            .fontColor($r('app.color.color_text_primary'))
            .margin({ bottom: 12 })
            .enabled(!this.isLoading && this.hasAutoLoginChecked)
            .onClick(() => this.handleGuestLogin())

          // 微信登录
          Button('微信一键登录')
            .width('80%')
            .height(48)
            .fontSize(16)
            .backgroundColor($r('app.color.color_wechat_green'))
            .fontColor(Color.White)
            .margin({ bottom: 12 })
            .enabled(!this.isLoading && this.hasAutoLoginChecked)
            .onClick(() => this.handleWechatLogin())

          // 华为登录
          Button('华为账号登录')
            .width('80%')
            .height(48)
            .fontSize(16)
            .backgroundColor($r('app.color.color_huawei_red'))
            .fontColor(Color.White)
            .margin({ bottom: 40 })
            .enabled(!this.isLoading && this.hasAutoLoginChecked)
            .onClick(() => this.handleHuaweiLogin())

          // 用户协议
          Text('登录即表示同意《用户协议》和《隐私政策》')
            .fontSize(12)
            .fontColor($r('app.color.color_text_tertiary'))

          // 加载指示器
          if (this.isLoading) {
            LoadingProgress()
              .width(24)
              .height(24)
              .color($r('app.color.color_theme'))
              .margin({ top: 16 })
          }
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .hideTitleBar(true)
  }
}
