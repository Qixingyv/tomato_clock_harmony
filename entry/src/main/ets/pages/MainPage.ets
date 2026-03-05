import { Profile } from '../view/Profile';
import { Statistics } from '../view/Statistics';
import { ToDoList } from '../view/ToDoList';

/**
 * MainPage组件的Builder函数
 * 用于在路由配置中创建MainPage实例
 */
@Builder
export function MainPageBuilder() {
  MainPage()
}

/**
 * 主页面组件
 * 包含底部Tab导航，用于在任务列表、统计和个人中心之间切换
 */
@Component
export struct MainPage {

  /** 当前选中的Tab索引，0=任务列表，1=统计，2=个人中心 */
  @State currentIndex: number = 0;

  /**
   * Tab栏构建器
   * 用于构建底部导航栏的每个Tab项
   * @param title Tab的标题文本
   * @param index Tab的索引位置
   * @param selectedImage Tab的图标资源
   * @returns 构建好的Tab项组件
   */
  @Builder
  tabBuilder(title: ResourceStr,index: number,selectedImage: Resource){
    Column(){
      // Tab图标，根据是否选中改变颜色
      Image(selectedImage)
        .width('24vp')
        .fillColor(index === this.currentIndex? $r('app.color.color_theme') : $r('app.color.color_unselected'))
        .margin({bottom: '4vp'})
      // Tab标题，根据是否选中改变颜色
      Text(title)
        .fontSize('12vp')
        .fontWeight(500)
        .fontColor(index === this.currentIndex? $r('app.color.color_theme') : $r('app.color.color_unselected'))
    }
    .width('100%')
    .height('56vp')

  }

  /**
   * 构建主页面UI
   * 包含底部Tab导航和三个Tab内容页面
   */
  build() {
    NavDestination() {
      // 底部Tab导航栏
      Tabs(
        { barPosition: BarPosition.End }
      ) {
        // Tab 1: 任务列表页面
        TabContent() {
          ToDoList()
        }
        .tabBar(this.tabBuilder($r("app.string.string_todo_list"), 0, $r("app.media.todo_list")))

        // Tab 2: 统计页面
        TabContent() {
          Statistics()
        }
        .tabBar(this.tabBuilder($r("app.string.string_statistics"), 1, $r("app.media.statistics")))

        // Tab 3: 个人中心页面
        TabContent() {
          Profile()
        }
        .tabBar(this.tabBuilder($r("app.string.string_profile"), 2, $r("app.media.profile")))

      }
      .height('100%')
      .width('100%')
      .barHeight('80vp')  // Tab栏高度
      .barMode(BarMode.Fixed)  // 固定模式，Tab栏不随内容滚动
      .onChange((index: number) => {
        // Tab切换时更新当前索引
        this.currentIndex = index;
      })

    }
    .hideBackButton(true)  // 隐藏返回按钮，因为这是主页面
  }
}