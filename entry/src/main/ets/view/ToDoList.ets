import {ToDoListClass} from "../viewmodel/ToDoListClass"
import DateUtils from "../common/DateUtils"
import {TaskType} from "../viewmodel/TaskType"


@Entry
@Component
export struct ToDoList {

  private toDoListArray: Array<ToDoListClass> = [
    new ToDoListClass(1, 1,'学习高数第三章', 1, 8, 25, 5,new Date(),0,1,new Date(),new Date()),
    new ToDoListClass(1, 1,'开发番茄钟', 1, 8, 25, 5,new Date(),0,1,new Date(),new Date()),
    new ToDoListClass(1, 1,'学习高数第4章', 1, 8, 25, 5,new Date(),0,1,new Date(),new Date()),
    new ToDoListClass(1, 1,'学习英语', 1, 8, 25, 5,new Date(),0,1,new Date(),new Date()),

    new ToDoListClass(1, 1,'学习英语', 2, 8, 25, 5,new Date(),0,1,new Date(),new Date()),
    new ToDoListClass(1, 1,'学习英语', 2, 8, 25, 5,new Date(),0,1,new Date(),new Date()),
    new ToDoListClass(1, 1,'学习英语', 2, 8, 25, 5,new Date(),0,1,new Date(),new Date()),
  ];

  @State currentMenu: TaskType = TaskType.Todo;



  build() {
    Column() {

      // 标题
      Row(){
        Text("任务列表")
          .fontSize('24vp')
          .fontColor(Color.White)
          .fontFamily("Harmony Sans SC")
      }
      .width('100%')
      .backgroundColor($r("app.color.color_theme"))
      .justifyContent(FlexAlign.Center)
      .height('5%')


      // 待办事项 长期目标
      Row(){
        Button(){
          Text("待办模式")
            .fontSize('16vp')
        }
        .onClick(() => {
          this.currentMenu = TaskType.Todo;
        }
        )
        Button(){
          Text("长期目标")
            .fontSize('16vp')
        }
        .onClick( () => {
          this.currentMenu = TaskType.Plan;
        })
      }
      .width('100%')
      .height('8%')

      // 任务栏展示
      List(){
        ForEach(
          this.toDoListArray,
          (item: ToDoListClass) => {
            if(item.getTaskType === this.currentMenu)
            {
              ListItem(){
                ToDoListItem({toDoListItem: item})
              }
              .margin({top: '4vp',bottom: '4vp'})
            }
          }
        )
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .height('80%')

    }
    .width('100%')
    .height('100%')
  }

}


@Component
struct ToDoListItem {

  @Prop
  private toDoListItem: ToDoListClass;

  @Prop
  private currentMenu: number;

  build() {
    Column(){

      // 任务名称
      Row(){
        Text(this.toDoListItem.getTaskName)
          .fontSize('16vp')
          .fontWeight(700)

        Button("开始")
          .width('20%')
          .backgroundColor($r("app.color.color_theme"))

      }
      .margin({top: '8vp',left: '16vp'})
      .width('100%')
      .layoutWeight(7)

      Column() {

        // 一个番茄时间
        Row() {
          Text($r("app.string.string_tomato_duration"))
            .toDoListContent()
          Text(this.toDoListItem.getTomatoDuration.toString())
            .toDoListContent()
          Text($r("app.string.string_minute"))
            .toDoListContent()
        }
        .todoListRow()

        // 已完成番茄个数
        Row(){
          Text($r("app.string.string_completed_tomato_count"))
            .toDoListContent()
          Text(this.toDoListItem.getCompletedTomatoNum.toString() + '/' + this.toDoListItem.getTotalTomatoNum.toString())
            .toDoListContent()
        }
        .todoListRow()

        // 截至日期
        if(this.toDoListItem.getTaskType === 2)
        {
          Row() {
            Text($r("app.string.string_deadline_duration"))
              .toDoListContent()
            Text(DateUtils.formatDate(this.toDoListItem.getDeadline))
              .toDoListContent()
          }
          .todoListRow()
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({left: '16vp',top: '4vp'})
      .layoutWeight(13)
    }
    .height('80vp')
    .width('96%')
    .borderRadius('8vp')
    .shadow({
      radius: 4,
      color: $r('app.color.color_unselected'),
      offsetY: 2
    })
  }
}

@Extend(Text)
function toDoListContent() {
  .fontSize('14vp')
  .fontColor($r("app.color.color_todo_list_content"))
  .letterSpacing('1vp')
  .textAlign(TextAlign.Start)
}

@Extend(Row)
function todoListRow(){
  .margin({bottom: '0vp',top: '0vp',left: '0vp',right: '0vp'})
}