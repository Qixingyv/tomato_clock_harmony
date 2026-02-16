import { CountDownTimer } from '../view/CountDownTimer';
import { Profile } from '../view/Profile';
import { Statistics } from '../view/Statistics';
import { ToDoList } from '../view/ToDoList';

@Entry
@Component
struct Index {

  private tabsController: TabsController = new TabsController();
  @State currentIndex: number = 0;

  @Builder
  tabBuilder(title: ResourceStr,index: number,selectedImage: Resource){
    Column(){
      Image(selectedImage)
        .width('24vp')
        .fillColor(index === this.currentIndex? $r('app.color.color_theme') : $r('app.color.color_unselected'))
        .margin({bottom: '4vp'})
      Text(title)
        .fontSize('12vp')
        .fontWeight(500)
        .fontColor(index === this.currentIndex? $r('app.color.color_theme') : $r('app.color.color_unselected'))
    }
    .width('100%')
    .height('56vp')

  }

  build() {
    Tabs(
      {barPosition: BarPosition.End,controller: this.tabsController}
    ) {
      TabContent(){
        ToDoList({ tabsController: this.tabsController })
      }
      .tabBar(this.tabBuilder($r("app.string.string_todo_list"),0,$r("app.media.todo_list")))

      TabContent(){
        CountDownTimer()
      }
      .tabBar(this.tabBuilder($r("app.string.string_count_down_timer"),1,$r("app.media.count_down_timer")))

      TabContent(){
        Statistics()
      }
      .tabBar(this.tabBuilder($r("app.string.string_statistics"),2,$r("app.media.statistics")))

      TabContent(){
        Profile()
      }
      .tabBar(this.tabBuilder($r("app.string.string_profile"),3,$r("app.media.profile")))

    }
    .height('100%')
    .width('100%')
    .barHeight('80vp')
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })

  }
}