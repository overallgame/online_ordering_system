import { Category } from 'common';

@Component
export struct CategoryTabsComponent {
  // 外部传入的参数
  @Prop categories: Category[] = [];
  @Link selectedCategory: Category | null;

  build() {
    Column() {
      if (this.categories.length === 0) {
        Text('暂无分类')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
          .height(48)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.White)
          .margin({ bottom: 8 })
      } else {
        Scroll() {
          Row() {
            ForEach(this.categories, (category: Category) => {
              Text(category.name)
                .fontSize(14)
                .fontWeight(this.selectedCategory?.id === category.id ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.selectedCategory?.id === category.id ? '#FF6B6B' : '#666666')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .backgroundColor(this.selectedCategory?.id === category.id ? '#FFF5F5' : Color.Transparent)
                .borderRadius(20)
                .margin({ right: 8 })
                .onClick(() => {
                  this.selectedCategory = category;
                })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(48)
        .backgroundColor(Color.White)
        .margin({ bottom: 8 })
      }
    }
  }
}
