import { GlobalNavStack } from '../common/GlobalNavStack'
import { router } from '@kit.ArkUI'


@Entry
@Component
export struct Index {

  navPathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(GlobalNavStack) {
      Column() {

        // 图标及欢迎词
        Column() {
          Image($r("app.media.icon_foreground"))
            .width('100vp')

          Text("欢迎来到番茄钟")
        }
        .width('100%')

        // 账号密码输入区
        Column() {
          TextInput({ placeholder: $r("app.string.string_please_enter_username") })
            .textInputStyle()
          TextInput({ placeholder: $r("app.string.string_please_enter_password") })
            .textInputStyle()
        }
        .width('100%')

        // 注册登录按钮
        Row() {
          Button($r("app.string.string_login")).onClick((event: ClickEvent) => {
            GlobalNavStack.pushPathByName('MainPage',null);
          })
          Button($r("app.string.string_sign_up")).onClick((event: ClickEvent) => {
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Column() {
          Button("华为账号登录").onClick((event: ClickEvent) => {
          })
          Button("微信登录").onClick((event: ClickEvent) => {
          })
        }

      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

    }

  }
}

@Extend(TextInput)
function textInputStyle() {
  .width('70%')
  .margin('4vp')
}