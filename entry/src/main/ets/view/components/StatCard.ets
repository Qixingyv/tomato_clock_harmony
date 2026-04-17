/**
 * StatCard 统计卡片组件
 * 用于展示统计数据的卡片组件
 */
@Component
export struct StatCard {
  @Prop title: string = '';
  @Prop value: string = '0';
  @Prop unit: string = '';

  build() {
    Column() {
      // 标题
      Text(this.title)
        .fontSize(14)
        .fontColor($r('app.color.color_text_tertiary'))
        .margin({ bottom: 8 })

      // 数值和单位
      Row() {
        Text(this.value)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.color_theme'))

        if (this.unit) {
          Text(this.unit)
            .fontSize(14)
            .fontColor($r('app.color.color_text_secondary'))
            .margin({ left: 4 })
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }
}
