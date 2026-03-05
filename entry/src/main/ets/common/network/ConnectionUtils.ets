// import http from '@ohos.net.http';
// import { ToDoListClass } from '../../viewmodel/ToDoListClass';
//
// export class ConnectionUtils {
//   // 基础API地址（需要根据实际后端地址修改）
//   private static readonly BASE_URL: string = 'https://your-api-domain.com/api';
//
//   /**
//    * 获取任务列表
//    * @param userId 用户ID
//    * @returns 任务列表
//    */
//   static async getTaskList(userId: number): Promise<Array<ToDoListClass>> {
//     return new Promise((resolve, reject) => {
//       let httpRequest = http.createHttp();
//       httpRequest.request(
//         `${this.BASE_URL}/tasks?user_id=${userId}`,
//         {
//           method: http.RequestMethod.GET,
//           header: {
//             'Content-Type': 'application/json'
//           }
//         },
//         (err, data) => {
//           httpRequest.destroy();
//           if (err) {
//             console.error('获取任务列表失败:', JSON.stringify(err));
//             reject(err);
//             return;
//           }
//           if (data.responseCode === 200) {
//             try {
//               const result = JSON.parse(data.result.toString());
//               const taskList: Array<ToDoListClass> = result.data.map((item: any) => {
//                 return this.mapToToDoListClass(item);
//               });
//               resolve(taskList);
//             } catch (parseError) {
//               console.error('解析任务列表失败:', JSON.stringify(parseError));
//               reject(parseError);
//             }
//           } else {
//             reject(new Error(`HTTP错误: ${data.responseCode}`));
//           }
//         }
//       );
//     });
//   }
//
//   /**
//    * 创建任务
//    * @param task 任务对象
//    * @returns 创建的任务
//    */
//   static async createTask(task: ToDoListClass): Promise<ToDoListClass> {
//     return new Promise((resolve, reject) => {
//       let httpRequest = http.createHttp();
//       httpRequest.request(
//         `${this.BASE_URL}/tasks`,
//         {
//           method: http.RequestMethod.POST,
//           header: {
//             'Content-Type': 'application/json'
//           },
//           extraData: this.mapToApiFormat(task)
//         },
//         (err, data) => {
//           httpRequest.destroy();
//           if (err) {
//             console.error('创建任务失败:', JSON.stringify(err));
//             reject(err);
//             return;
//           }
//           if (data.responseCode === 200 || data.responseCode === 201) {
//             try {
//               const result = JSON.parse(data.result.toString());
//               resolve(this.mapToToDoListClass(result.data));
//             } catch (parseError) {
//               console.error('解析创建任务结果失败:', JSON.stringify(parseError));
//               reject(parseError);
//             }
//           } else {
//             reject(new Error(`HTTP错误: ${data.responseCode}`));
//           }
//         }
//       );
//     });
//   }
//
//   /**
//    * 更新任务
//    * @param task 任务对象
//    * @returns 更新后的任务
//    */
//   static async updateTask(task: ToDoListClass): Promise<ToDoListClass> {
//     return new Promise((resolve, reject) => {
//       let httpRequest = http.createHttp();
//       httpRequest.request(
//         `${this.BASE_URL}/tasks/${task.getId}`,
//         {
//           method: http.RequestMethod.PUT,
//           header: {
//             'Content-Type': 'application/json'
//           },
//           extraData: this.mapToApiFormat(task)
//         },
//         (err, data) => {
//           httpRequest.destroy();
//           if (err) {
//             console.error('更新任务失败:', JSON.stringify(err));
//             reject(err);
//             return;
//           }
//           if (data.responseCode === 200) {
//             try {
//               const result = JSON.parse(data.result.toString());
//               resolve(this.mapToToDoListClass(result.data));
//             } catch (parseError) {
//               console.error('解析更新任务结果失败:', JSON.stringify(parseError));
//               reject(parseError);
//             }
//           } else {
//             reject(new Error(`HTTP错误: ${data.responseCode}`));
//           }
//         }
//       );
//     });
//   }
//
//   /**
//    * 删除任务（逻辑删除）
//    * @param taskIds 任务ID数组
//    * @returns 是否成功
//    */
//   static async deleteTasks(taskIds: Array<number>): Promise<boolean> {
//     return new Promise((resolve, reject) => {
//       let httpRequest = http.createHttp();
//       httpRequest.request(
//         `${this.BASE_URL}/tasks/batch`,
//         {
//           method: http.RequestMethod.DELETE,
//           header: {
//             'Content-Type': 'application/json'
//           },
//           extraData: {
//             ids: taskIds,
//             status: 3 // 3=已取消/归档
//           }
//         },
//         (err, data) => {
//           httpRequest.destroy();
//           if (err) {
//             console.error('删除任务失败:', JSON.stringify(err));
//             reject(err);
//             return;
//           }
//           if (data.responseCode === 200 || data.responseCode === 204) {
//             resolve(true);
//           } else {
//             reject(new Error(`HTTP错误: ${data.responseCode}`));
//           }
//         }
//       );
//     });
//   }
//
//   /**
//    * 将API返回的数据映射为ToDoListClass对象
//    */
//   private static mapToToDoListClass(item: any): ToDoListClass {
//     return new ToDoListClass(
//       item.id || 0,
//       item.user_id || 0,
//       item.name || '',
//       item.mode || 1,
//       item.tomato_minutes || 25,
//       item.rest_minutes || 5,
//       item.target_tomato_count || null,
//       item.daily_target_tomato_count || null,
//       item.finished_tomato_count || 0,
//       item.today_finished_count || 0,
//       item.deadline ? new Date(item.deadline) : null,
//       item.last_reset_date ? new Date(item.last_reset_date) : null,
//       item.status || 1,
//       item.created_at ? new Date(item.created_at) : new Date(),
//       item.updated_at ? new Date(item.updated_at) : new Date()
//     );
//   }
//
//   /**
//    * 将ToDoListClass对象映射为API格式
//    */
//   private static mapToApiFormat(task: ToDoListClass): any {
//     return {
//       user_id: task.getUserId,
//       name: task.getName,
//       mode: task.getMode,
//       tomato_minutes: task.getTomatoMinutes,
//       rest_minutes: task.getRestMinutes,
//       target_tomato_count: task.getTargetTomatoCount,
//       daily_target_tomato_count: task.getDailyTargetTomatoCount,
//       finished_tomato_count: task.getFinishedTomatoCount,
//       today_finished_count: task.getTodayFinishedCount,
//       deadline: task.getDeadline ? task.getDeadline.toISOString().split('T')[0] : null,
//       last_reset_date: task.getLastResetDate ? task.getLastResetDate.toISOString().split('T')[0] : null,
//       status: task.getStatus
//     };
//   }
// }