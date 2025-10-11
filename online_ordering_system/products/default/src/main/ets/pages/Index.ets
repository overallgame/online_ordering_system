import { BreakpointSystem } from 'utils';
import { BreakpointTypeEnum } from 'utils/src/main/ets/utils/BreakpointSystem';
import { drawing } from '@kit.ArkGraphics2D';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private tabsController: TabsController = new TabsController();
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToAppear() {
    this.breakpointSystem.register();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  @Builder
  tabBarBuilder(title: string, targetIndex: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .colorFilter(this.currentIndex === targetIndex ?
          {
            color: '#1890FF',
            mode: drawing.BlendMode.SRC_IN
          } :
          {
            color: '#666666',
            mode: drawing.BlendMode.SRC_IN
          })
      Text(title)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? '#1890FF' : '#666666')
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(8)
    .padding(8)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }

  build() {
    Tabs({
      barPosition: this.currentBreakpoint === BreakpointTypeEnum.LG ?
      BarPosition.Start :
      BarPosition.End,
      controller: this.tabsController
    }) {
      TabContent() {
        // 首页内容
      }.tabBar(this.tabBarBuilder("首页", 0, $r("app.media.home")))

      TabContent() {
        // 分类内容
      }.tabBar(this.tabBarBuilder("分类", 1, $r("app.media.category")))

      TabContent() {
        // 订单内容
      }.tabBar(this.tabBarBuilder("订单", 2, $r("app.media.order")))

      TabContent() {
        // 我的内容
      }.tabBar(this.tabBarBuilder("我", 3, $r("app.media.mine")))
    }
    .scrollable(false)
    .vertical(this.currentBreakpoint === BreakpointTypeEnum.LG ? true : false)
    .divider({
      strokeWidth: 0.5,
      color: '#E8E8E8'
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .barWidth(this.currentBreakpoint === BreakpointTypeEnum.LG ? 120 : '100%')
    .barHeight(this.currentBreakpoint === BreakpointTypeEnum.LG ? '100%' : 80)
    .width('100%')
    .height('100%')
  }
}