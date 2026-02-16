import { TaskType } from "../viewmodel/TaskType"
import {ToDoListClass} from "../viewmodel/ToDoListClass"
import {TaskStatus} from "../viewmodel/TaskStatus"

@Component
export struct CountDownTimer {

  // 文本计时器控制器
  textTimerController: TextTimerController = new TextTimerController();

  // 番茄钟对象
  private toDoList: ToDoListClass = new ToDoListClass(1, 1,'学习高数第三章', 1, 8, 1, 5,new Date(),0,1,new Date(),new Date());

  // 文本倒计时样式
  private textTimerFormat: string = "mm:ss"

  // 剩余时间
  @State progressValue: number = this.toDoList.getTomatoDuration * 60 * 1000;

  // 总时间
  private progressTotal: number = this.toDoList.getTomatoDuration * 60 * 1000;



  // 当前番茄钟状态
  @State private currentTomatoStatus: TaskStatus = TaskStatus.Working;

  // 是否暂停
  @State private isPause: boolean = false;

  // // 剩余番茄钟个数
  // private totalTomatoNum: number = this.toDoList.getTotalTomatoNum;

  // 获取当前番茄钟模式
  getCurrentTaskType(taskType: TaskType): Resource {

    let result: Resource = $r("app.string.string_empty");

    if(taskType === TaskType.Todo) {
      result = $r("app.string.string_todo_mode")
    }
    else {
      result = $r("app.string.string_plan_mode")
    }

    return result;
  }

  // 获取页面当前状态
  getCurrentTaskStatus(taskStatus: TaskStatus,isPause: boolean): string {

    let result: string = "";

    if(taskStatus === TaskStatus.Working && isPause === false) {
      result = "专注模式";
    }
    else if (taskStatus === TaskStatus.Working && isPause === true) {
      result = "暂停";
    }

    return result;
  }

  // 根据页面状态，获取左侧按钮值
  getLeftButtonValue(currentTomatoStatus: TaskStatus,isPause: boolean): Resource {

    let leftButtonValue: Resource = $r("app.string.string_empty");

    if(this.currentTomatoStatus === TaskStatus.Working && this.isPause === false) {
      leftButtonValue = $r("app.string.string_pause");
    }
    else if (this.currentTomatoStatus === TaskStatus.Working && this.isPause === true) {
      leftButtonValue = $r("app.string.string_resume")
    }


    return leftButtonValue;
  }

  build() {
    Column() {

      // 任务类型
      Row(){
        Text(this.getCurrentTaskType(this.toDoList.getTaskType))
      }

      // 计时区域
      Stack(){

        // 环形区域
        Progress({value: this.progressValue, total: this.progressTotal,type: ProgressType.Ring})
          .color($r("app.color.color_theme"))
          .style({ strokeWidth: 24})
          .width('80%')

        // 信息展示
        Column(){

          // 文本计时器
          TextTimer({ isCountDown: true, count: this.progressTotal, controller: this.textTimerController })
            .format(this.textTimerFormat)
            .fontColor(Color.Black)
            .fontSize(50)
            .onTimer((utcTime: number, elapsedTime: number) => {
              this.progressValue -= 1000;
              console.log(`计时中: 已经过时间:${elapsedTime} 总时间 ${this.progressTotal/1000}`)
              if(elapsedTime === this.progressTotal/1000)
              {
                console.log("已结束");
              }
            })

          // 任务状态
          Text(this.getCurrentTaskStatus(this.currentTomatoStatus,this.isPause))
        }
      }
      .width('100%')

      // 任务名称
      Row(){
        Text(this.toDoList.getTaskName.toString())
      }

      // 按钮
      Row(){

        Button(this.getLeftButtonValue(this.currentTomatoStatus,this.isPause)).onClick((event: ClickEvent) => {
          if(this.currentTomatoStatus === TaskStatus.Working && this.isPause === false){
            this.textTimerController.pause();
            this.isPause = true;
          }
          else if (this.currentTomatoStatus === TaskStatus.Working && this.isPause === true) {
            this.textTimerController.start();
            this.isPause = false;
          }
        })
        Button($r("app.string.string_finish")).onClick((event: ClickEvent) => {
          
        })
      }
    }
    .width('100%')
    .height('100%')
  }

}