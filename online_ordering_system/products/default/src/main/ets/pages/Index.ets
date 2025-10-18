import { BreakpointSystem } from 'utils';
import { BreakpointTypeEnum } from 'utils/src/main/ets/utils/BreakpointSystem';
import { drawing } from '@kit.ArkGraphics2D';
import { UserPage } from 'user';
import { AuthStateService } from '../service/AuthStateService';
import { LoginPage, RegisterPage } from 'authentication';
import { HomePage } from 'restaurant';
import { AppDataManager } from 'common';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Index {
  @State isLogin: boolean = false;
  @State currentIndex: number = 0;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @Provide('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  private authStateService: AuthStateService = AuthStateService.getInstance();
  private appDataManager: AppDataManager = AppDataManager.getInstance();

  aboutToAppear() {
    this.breakpointSystem.register();
    this.initializeApp();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  private async initializeApp(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const initSuccess = await this.appDataManager.initialize(context);
      
      if (initSuccess) {
        console.log('AppDataManager initialized successfully');
        await this.checkAuthStatus();
      } else {
        console.error('Failed to initialize AppDataManager');
        this.isLogin = false;
        this.mainPathStack.pushPathByName('login', null);
      }
    } catch (error) {
      console.error('App initialization error:', error);
      this.isLogin = false;
      this.mainPathStack.pushPathByName('login', null);
    }
  }

  private async checkAuthStatus(): Promise<void> {
    try {
      const loginStatus = await this.authStateService.checkLoginStatus();
      if (!loginStatus) {
        this.isLogin = false;
        this.mainPathStack.pushPathByName('login', null);
      } else {
        this.isLogin = true;
      }
    } catch (error) {
      console.error('Check auth status error:', error);
      this.isLogin = false;
      this.mainPathStack.pushPathByName('login', null);
    }
  }

  build() {
    Navigation(this.mainPathStack) {
      Column() {
        this.buildMainContent();
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }
    .navDestination(this.mainRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }

  @Builder
  mainRouter(name: string, _param?: Object) {
    if (name === 'login') {
      LoginPage()
    } else if (name === 'register') {
      RegisterPage()
    } else {
      this.buildMainContent()
    }
  }

  @Builder
  buildMainContent() {
    Tabs({
      barPosition: this.currentBreakpoint === BreakpointTypeEnum.LG ?
      BarPosition.Start :
      BarPosition.End,
      controller: this.tabsController
    }) {
      TabContent() {
        HomePage()
      }.tabBar(this.tabBarBuilder("首页", 0, $r("app.media.home"), $r("app.media.home_active")))

      TabContent() {
        // 订单内容
      }.tabBar(this.tabBarBuilder("订单", 1, $r("app.media.order"), $r("app.media.order_active")))

      TabContent() {
        UserPage()
      }.tabBar(this.tabBarBuilder("我", 2, $r("app.media.mine"), $r("app.media.mine_active")))
    }
    .scrollable(false)
    .vertical(this.currentBreakpoint === BreakpointTypeEnum.LG ? true : false)
    .divider({ strokeWidth: 0.5, color: '#E8E8E8' })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .barWidth(this.currentBreakpoint === BreakpointTypeEnum.LG ? 120 : '100%')
    .barHeight(this.currentBreakpoint === BreakpointTypeEnum.LG ? '100%' : 80)
    .width('100%')
    .height('100%')
  }

  @Builder
  tabBarBuilder(title: string, targetIndex: number, icon: Resource, activeIcon: Resource) {
    Column() {
      Image(this.currentIndex == targetIndex ? activeIcon : icon)
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
}