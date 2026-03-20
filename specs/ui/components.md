# 组件设计

> 版本：v1.0
> 创建日期：2026-03-18
> 状态：需求确认中

---

## 8.1 概述

本文档定义应用中可复用的UI组件，确保设计一致性和代码复用。

---

## 8.2 任务卡片组件 (ToDoListItem)

### 8.2.1 组件定义
```typescript
@Component
struct ToDoListItem {
  @Prop toDoListItem: ToDoListClass;
  onTaskClick: () => void = () => {};
  onStartClick: () => void = () => {};
}
```

### 8.2.2 组件结构
```
┌─────────────────────────────┐
│ 任务名称    [类型标签]       │
│ 截止日期/剩余天数 (计划模式) │
├─────────────────────────────┤
│ 番茄时长: XX分钟             │
│ 休息时长: XX分钟             │
│ 已完成: X/Y个番茄            │
├─────────────────────────────┤
│      [ 开始专注 ]           │
└─────────────────────────────┘
```

### 8.2.3 样式规范
| 属性 | 值 |
|------|-----|
| 宽度 | 96% |
| 高度 | auto |
| 圆角 | 8vp |
| 背景色 | Color.White |
| 阴影 | radius: 4, offsetY: 2 |
| 卡片间距 | 上下 4vp |

### 8.2.4 交互行为
- **点击卡片**：触发 `onTaskClick()`，进入编辑页
- **点击开始按钮**：触发 `onStartClick()`，进入计时器页
- **长按**：进入拖拽模式

---

## 8.3 按钮组件

### 8.3.1 主按钮 (PrimaryButton)
```typescript
@Builder
function PrimaryButton(label: string, onClick: () => void) {
  Button(label)
    .width('40%')
    .height('40vp')
    .fontSize('16vp')
    .backgroundColor($r("app.color.color_theme"))
    .fontColor(Color.White)
    .onClick(onClick);
}
```

**用途**：主要操作，如"开始专注"、"保存"等

### 8.3.2 次要按钮 (SecondaryButton)
```typescript
@Builder
function SecondaryButton(label: string, onClick: () => void) {
  Button(label)
    .width('40%')
    .height('40vp')
    .fontSize('16vp')
    .backgroundColor(Color.White)
    .fontColor($r("app.color.color_theme"))
    .border({ width: 1, color: $r("app.color.color_theme") })
    .onClick(onClick);
}
```

**用途**：次要操作，如"取消"、"跳过"等

### 8.3.3 文字按钮 (TextButton)
```typescript
@Builder
function TextButton(label: string, onClick: () => void) {
  Button(label)
    .type(ButtonType.Normal)
    .backgroundColor(Color.Transparent)
    .fontColor($r("app.color.color_theme"))
    .onClick(onClick);
}
```

**用途**：导航操作，如"返回"、"编辑"等

---

## 8.4 输入框组件

### 8.4.1 标准输入框 (TextInput)
```typescript
@Extend(TextInput)
function standardInput() {
  .height('40vp')
  .width('100%')
  .backgroundColor(Color.White)
  .borderRadius('4vp')
  .padding({ left: '12vp', right: '12vp' })
}
```

### 8.4.2 带标题的输入框 (LabeledInput)
```typescript
@Component
struct LabeledInput {
  @Prop label: string;
  @Prop placeholder: string;
  @Prop value: string;
  @Prop required: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.label)
          .fontSize('14fp')
          .fontColor(Color.Black)
        if (this.required) {
          Text('*')
            .fontSize('14fp')
            .fontColor(Color.Red)
        }
      }
      .width('100%')
      .margin({ bottom: '8vp' })

      TextInput({ placeholder: this.placeholder, text: this.value })
        .standardInput()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
```

---

## 8.5 标签组件

### 8.5.1 任务类型标签 (TaskTypeTag)
```typescript
@Component
struct TaskTypeTag {
  @Prop taskType: number; // 1=待办, 2=计划

  getTagColor(): Resource {
    return this.taskType === 1
      ? $r("app.color.color_todo_tag")
      : $r("app.color.color_plan_tag");
  }

  getTagText(): string {
    return this.taskType === 1 ? "待办" : "计划";
  }

  build() {
    Text(this.getTagText())
      .fontSize('12fp')
      .fontColor(Color.White)
      .backgroundColor(this.getTagColor())
      .padding({ left: '8vp', right: '8vp', top: '4vp', bottom: '4vp' })
      .borderRadius('4vp')
  }
}
```

### 8.5.2 状态标签 (StatusTag)
```typescript
@Component
struct StatusTag {
  @Prop status: string;
  @Prop color: Resource;

  build() {
    Text(this.status)
      .fontSize('12fp')
      .fontColor(Color.White)
      .backgroundColor(this.color)
      .padding({ left: '8vp', right: '8vp', top: '4vp', bottom: '4vp' })
      .borderRadius('4vp')
  }
}
```

---

## 8.6 数据卡片组件 (StatCard)

### 8.6.1 组件定义
```typescript
@Component
struct StatCard {
  @Prop title: string;
  @Prop value: string;
  @Prop change: string = '';
  @Prop changePositive: boolean = true;

  build() {
    Column() {
      Text(this.title)
        .fontSize('14fp')
        .fontColor($r("app.color.color_unselected"))
        .margin({ bottom: '8vp' })

      Text(this.value)
        .fontSize('24fp')
        .fontWeight(600)
        .fontColor(Color.Black)
        .margin({ bottom: '4vp' })

      if (this.change) {
        Row() {
          Text(this.changePositive ? '↑' : '↓')
            .fontSize('12fp')
            .fontColor(this.changePositive ? Color.Green : Color.Red)
          Text(this.change)
            .fontSize('12fp')
            .fontColor(this.changePositive ? Color.Green : Color.Red)
        }
      }
    }
    .width('100%')
    .padding('16vp')
    .backgroundColor(Color.White)
    .borderRadius('8vp')
    .alignItems(HorizontalAlign.Center)
  }
}
```

**使用示例**：
```typescript
StatCard({
  title: '完成番茄数',
  value: '12 个',
  change: '+3',
  changePositive: true
})
```

---

## 8.7 弹窗组件

### 8.7.1 确认弹窗 (ConfirmDialog)
```typescript
@Component
struct ConfirmDialog {
  @Prop title: string;
  @Prop message: string;
  @Prop confirmText: string = '确认';
  @Prop cancelText: string = '取消';
  onConfirm: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      // 半透明遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .opacity(0.3)

      // 弹窗内容
      Column() {
        Text(this.title)
          .fontSize('18fp')
          .fontWeight(600)
          .margin({ bottom: '8vp' })

        Text(this.message)
          .fontSize('14fp')
          .margin({ bottom: '20vp' })

        Row() {
          Button(this.cancelText)
            .layoutWeight(1)
            .onClick(() => this.onCancel())

          Button(this.confirmText)
            .layoutWeight(1)
            .margin({ left: '10vp' })
            .onClick(() => this.onConfirm())
        }
        .width('100%')
      }
      .width('80%')
      .padding('20vp')
      .backgroundColor(Color.White)
      .borderRadius('12vp')
    }
  }
}
```

---

## 8.8 加载组件

### 8.8.1 加载中 (LoadingIndicator)
```typescript
@Component
struct LoadingIndicator {
  @Prop message: string = '加载中...';

  build() {
    Column() {
      LoadingProgress()
        .width('50vp')
        .height('50vp')

      Text(this.message)
        .fontSize('14fp')
        .fontColor($r("app.color.color_unselected"))
        .margin({ top: '16vp' })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 8.9 空状态组件 (EmptyState)

### 8.9.1 组件定义
```typescript
@Component
struct EmptyState {
  @Prop icon: Resource;
  @Prop title: string;
  @Prop message: string;
  @Prop actionText: string = '';
  onAction: () => void = () => {};

  build() {
    Column() {
      Image(this.icon)
        .width('80vp')
        .height('80vp')
        .opacity(0.5)
        .margin({ bottom: '16vp' })

      Text(this.title)
        .fontSize('18fp')
        .fontWeight(600)
        .fontColor($r("app.color.color_unselected"))
        .margin({ bottom: '8vp' })

      Text(this.message)
        .fontSize('14fp')
        .fontColor($r("app.color.color_unselected"))
        .margin({ bottom: '20vp' })

      if (this.actionText) {
        Button(this.actionText)
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

**使用场景**：
- 任务列表为空
- 统计数据为空
- 网络错误

---

## 8.10 组件扩展 (Extend)

### 8.10.1 文字扩展
```typescript
// 列表内容文字
@Extend(Text)
function listContentText() {
  .fontSize('14vp')
  .fontColor($r("app.color.color_todo_list_content"))
  .letterSpacing('1vp')
}

// 标题文字
@Extend(Text)
function titleText() {
  .fontSize('24vp')
  .fontColor(Color.White)
  .fontFamily("Harmony Sans SC")
}
```

### 8.10.2 行扩展
```typescript
// 标准行间距
@Extend(Row)
function standardRow() {
  .margin({ bottom: '4vp', top: '4vp' })
  .width('100%')
}
```

---

**相关文档：**
- [页面布局](./pages.md)
- [导航结构](./navigation.md)
