/**
 * Statistics 统计页面视图组件
 * 显示今日/本周/本月的统计数据
 */
import { StatisticsData, StatisticsPeriod, TaskRankingItem, DailyData } from '../viewmodel/StatisticsModels';
import { StatisticsService } from '../service/StatisticsService';
import { StatCard } from './components/StatCard';

@Component
export struct Statistics {
  @State private currentPeriod: StatisticsPeriod = 'today';
  @State private statistics: StatisticsData | null = null;

  aboutToAppear() {
    this.loadStatistics();
  }

  /**
   * 加载统计数据
   */
  private loadStatistics(): void {
    switch (this.currentPeriod) {
      case 'today':
        this.statistics = StatisticsService.getTodayStatistics();
        break;
      case 'week':
        this.statistics = StatisticsService.getWeekStatistics();
        break;
      case 'month':
        this.statistics = StatisticsService.getMonthStatistics();
        break;
    }
  }

  /**
   * 切换统计周期
   */
  private switchPeriod(period: StatisticsPeriod): void {
    this.currentPeriod = period;
    this.loadStatistics();
  }

  build() {
    Column() {
      // 标题
      Text('数据统计')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.color.color_theme'))
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 12 })

      // 时间维度切换
      Row() {
        this.TabButton('今日', this.currentPeriod === 'today', () => this.switchPeriod('today'))
        this.TabButton('本周', this.currentPeriod === 'week', () => this.switchPeriod('week'))
        this.TabButton('本月', this.currentPeriod === 'month', () => this.switchPeriod('month'))
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundColor(Color.White)

      // 统计卡片区域
      if (this.statistics) {
        Column() {
          // 完成番茄数和专注时长（横向排列）
          Row() {
            StatCard({
              title: '完成番茄数',
              value: this.statistics.completedTomatoes.toString(),
              unit: '个'
            })
              .layoutWeight(1)

            StatCard({
              title: '专注时长',
              value: (this.statistics.focusMinutes / 60).toFixed(1),
              unit: '小时'
            })
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 8, bottom: 8 })

          // 任务完成率
          StatCard({
            title: '任务完成率',
            value: this.statistics.completionRate.toFixed(0),
            unit: '%'
          })
            .width('100%')

          // 任务排行
          if (this.statistics.taskRanking.length > 0) {
            Column() {
              Text('任务排行')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.color_text_primary'))
                .width('100%')
                .padding({ left: 16, top: 16, bottom: 8 })

              List({ space: 8 }) {
                ForEach(this.statistics.taskRanking.slice(0, 5), (item: TaskRankingItem, index: number) => {
                  ListItem() {
                    Row() {
                      Text(`${index + 1}`)
                        .fontSize(14)
                        .fontColor($r('app.color.color_text_tertiary'))
                        .width(24)

                      Text(item.taskName)
                        .fontSize(14)
                        .fontColor($r('app.color.color_text_primary'))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)

                      Text(`${item.completedTomatoes}个`)
                        .fontSize(14)
                        .fontColor($r('app.color.color_theme'))
                    }
                    .width('100%')
                    .height(40)
                    .padding({ left: 16, right: 16 })
                    .backgroundColor($r('app.color.color_background_gray'))
                    .borderRadius(8)
                  }
                }, (item: TaskRankingItem, index: number) => `${item.taskId}-${index}`)
              }
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 16 })
            }
            .width('100%')
            .margin({ top: 8 })
            .backgroundColor(Color.White)
            .borderRadius(8)
          }

          // 每日数据趋势
          if (this.statistics.dailyData.length > 0) {
            Column() {
              Text('每日趋势')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.color_text_primary'))
                .width('100%')
                .padding({ left: 16, top: 16, bottom: 8 })

              List({ space: 0 }) {
                ForEach(this.statistics.dailyData.slice(-7), (item: DailyData) => {
                  ListItem() {
                    Row() {
                      Text(this.formatDate(item.date))
                        .fontSize(12)
                        .fontColor($r('app.color.color_text_tertiary'))
                        .width(80)

                      Column() {
                        Row() {
                          Text('完成')
                            .fontSize(12)
                            .fontColor($r('app.color.color_text_tertiary'))
                          Text(`${item.completedTomatoes}个`)
                            .fontSize(12)
                            .fontColor($r('app.color.color_text_secondary'))
                            .margin({ left: 8 })
                        }

                        Row() {
                          Text('专注')
                            .fontSize(12)
                            .fontColor($r('app.color.color_text_tertiary'))
                          Text(`${item.focusMinutes}分钟`)
                            .fontSize(12)
                            .fontColor($r('app.color.color_text_secondary'))
                            .margin({ left: 8 })
                        }
                        .margin({ top: 4 })
                      }
                      .layoutWeight(1)
                    }
                    .width('100%')
                    .height(50)
                    .padding({ left: 16, right: 16 })
                    .border({ width: { bottom: 1 }, color: $r('app.color.color_border_light') })
                  }
                }, (item: DailyData) => `${item.date.getTime()}`)
              }
              .width('100%')
            }
            .width('100%')
            .margin({ top: 8 })
            .backgroundColor(Color.White)
            .borderRadius(8)
          }
        }
        .width('100%')
        .padding(16)
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_background_gray'))
  }

  /**
   * Tab按钮Builder
   */
  @Builder
  TabButton(title: string, isSelected: boolean, onClick: () => void) {
    Text(title)
      .fontSize(14)
      .fontColor(isSelected ? $r('app.color.color_theme') : $r('app.color.color_text_secondary'))
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(isSelected ? $r('app.color.color_tab_selected_bg') : 'transparent')
      .borderRadius(16)
      .onClick(onClick)
  }

  /**
   * 格式化日期
   */
  private formatDate(date: Date): string {
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    const weekday = weekdays[date.getDay()];
    return `${month}/${day} 周${weekday}`;
  }
}
