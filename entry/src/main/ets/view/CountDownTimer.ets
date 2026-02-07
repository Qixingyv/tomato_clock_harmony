import { TaskType } from "../viewmodel/TaskType"
import {ToDoListClass} from "../viewmodel/ToDoListClass"
import {TaskStatus} from "../viewmodel/TaskStatus"

// 暂停 继续 结束 跳过休息
@Entry
@Component
export struct CountDownTimer {

  // 番茄钟对象
  private toDoList: ToDoListClass = new ToDoListClass(1, 1,'学习高数第三章', 1, 8, 25, 5,new Date(),0,1,new Date(),new Date());

  // 剩余时间
  @State proGressValue: number = this.toDoList.getTomatoDuration;

  // 总时间
  private progressTotal: number = this.toDoList.getTomatoDuration;

  // 剩余番茄钟个数
  private totalTomatoNum: number = this.toDoList.getTotalTomatoNum;

  // 页面状态：0休息模式/1专注模式/2暂停，用来控制页面变化
  private status: number = 0;

  // 当前番茄钟状态
  private currentTomatoStatus: TaskStatus = TaskStatus.Working;

  build() {
    Column() {
      Row(){
        Text(this.toDoList.getTaskType.toString())
      }

      Stack(){
        Progress({value: this.proGressValue, total: this.progressTotal,type: ProgressType.Ring})
          .color($r("app.color.color_theme"))
          .style({ strokeWidth: 24})
          .width('80%')
        Column(){
          Text(this.proGressValue.toString())
          Text(this.status.toString())
        }
      }
      .width('100%')

      Row(){
        Text(this.toDoList.getTaskName.toString())
      }

      Row(){

        Button().onClick((event: ClickEvent) => {

        })
        Button().onClick((event: ClickEvent) => {
          
        })
      }
    }
    .width('100%')
    .height('100%')
  }

}