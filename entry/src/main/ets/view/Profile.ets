/**
 * Profile 个人中心视图组件
 */
import { User } from '../viewmodel/User';
import { LoginType } from '../viewmodel/LoginType';
import { AuthService } from '../service/AuthService';
import { GlobalNavStack } from '../common/GlobalNavStack';
import { ToastUtil } from '../common/ToastUtil';
import { Logger } from '../common/Logger';
import { promptAction } from '@kit.ArkUI';

@Component
export struct Profile {
  @State private user: User | null = null;
  @State private todayTomatoes: number = 0;
  @State private totalTomatoes: number = 0;

  async aboutToAppear() {
    await this.loadUserData();
    await this.loadStatistics();
  }

  /**
   * 加载用户数据
   */
  private async loadUserData(): Promise<void> {
    try {
      this.user = AuthService.getCurrentUser();
    } catch (error) {
      Logger.error('Failed to load user data', error as Error);
    }
  }

  /**
   * 加载统计数据
   */
  private async loadStatistics(): Promise<void> {
    // TODO: 从 StatisticsService 获取统计数据
    this.todayTomatoes = 0;
    this.totalTomatoes = 0;
  }

  /**
   * 退出登录
   */
  private async handleLogout(): Promise<void> {
    const result = await promptAction.showDialog({
      title: '确认退出登录？',
      message: '退出后需要重新登录才能使用',
      buttons: [
        { text: '取消', color: $r('app.color.color_text_tertiary') },
        { text: '确认', color: $r('app.color.color_warning') }
      ]
    });

    if (result.index === 1) {
      try {
        // 先退出登录（会触发状态变化通知）
        await AuthService.logout();

        // 清空导航栈，返回到Index页面的登录UI
        GlobalNavStack.clear();
      } catch (error) {
        Logger.error('Logout failed', error as Error);
        ToastUtil.showError('退出失败');
      }
    }
  }

  /**
   * 获取登录类型文字
   */
  private getLoginTypeText(type: LoginType): string {
    switch (type) {
      case LoginType.WECHAT:
        return '微信登录';
      case LoginType.HUAWEI:
        return '华为账号登录';
      case LoginType.GUEST:
        return '游客模式';
      default:
        return '未知';
    }
  }

  /**
   * 获取登录类型图标
   */
  private getLoginTypeIcon(type: LoginType): Resource {
    switch (type) {
      case LoginType.WECHAT:
        return $r('app.media.todo_list');
      case LoginType.HUAWEI:
        return $r('app.media.todo_list');
      default:
        return $r('app.media.todo_list');
    }
  }

  build() {
    Scroll() {
      Column() {
        // 用户信息卡片
        Column() {
          // 头像
          Image(this.user?.avatar || $r('app.media.todo_list'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .margin({ top: 32, bottom: 16 })
            .backgroundColor($r('app.color.color_background_gray'))

          // 昵称
          Text(this.user?.displayName || '番茄用户')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.color_text_primary'))
            .margin({ bottom: 8 })

          // 登录类型
          Row() {
            Image(this.getLoginTypeIcon(this.user?.loginType || LoginType.WECHAT))
              .width(16)
              .height(16)
              .margin({ right: 4 })

            Text(this.getLoginTypeText(this.user?.loginType || LoginType.WECHAT))
              .fontSize(14)
              .fontColor($r('app.color.color_text_tertiary'))
          }
          .margin({ bottom: 24 })
        }
        .width('100%')
        .backgroundColor(Color.White)

        // 统计卡片
        Column() {
          Row() {
            this.StatItem('今日完成', `${this.todayTomatoes}`, '个')
            this.StatItem('累计完成', `${this.totalTomatoes}`, '个')
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .margin({ top: 8 })

        // 菜单列表
        Column() {
          // 设置
          this.MenuItem('设置', $r('app.media.todo_list'), () => {
            ToastUtil.showToast('功能开发中');
          })

          this.MenuItem('关于', $r('app.media.todo_list'), () => {
            ToastUtil.showToast('番茄钟 v1.0.0');
          })

          // 意见反馈
          this.MenuItem('意见反馈', $r('app.media.todo_list'), () => {
            ToastUtil.showToast('功能开发中');
          })

          // 隐私政策
          this.MenuItem('隐私政策', $r('app.media.todo_list'), () => {
            ToastUtil.showToast('功能开发中');
          })

          // 用户协议
          this.MenuItem('用户协议', $r('app.media.todo_list'), () => {
            ToastUtil.showToast('功能开发中');
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .backgroundColor(Color.White)
        .margin({ top: 8 })

        // 退出登录按钮
        Button('退出登录')
          .width('90%')
          .height(48)
          .fontSize(16)
          .backgroundColor(Color.White)
          .fontColor($r('app.color.color_danger'))
          .border({ width: 1, color: $r('app.color.color_danger') })
          .borderRadius(8)
          .margin({ top: 24, bottom: 32 })
          .onClick(() => this.handleLogout())
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_background_gray'))
  }

  /**
   * 统计项Builder
   */
  @Builder
  StatItem(label: string, value: string, unit: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.color_theme'))
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.color_text_tertiary'))
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding(16)
  }

  /**
   * 菜单项Builder
   */
  @Builder
  MenuItem(title: string, icon: Resource, onClick: () => void) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor($r('app.color.color_text_secondary'))

      Text(title)
        .fontSize(16)
        .fontColor($r('app.color.color_text_primary'))
        .layoutWeight(1)
        .margin({ left: 12 })

      Text('>')
        .fontSize(16)
        .fontColor($r('app.color.color_text_hint'))
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(onClick)
  }
}
