import { HelpCenterViewModel } from '../viewmodel/HelpCenterViewModel';
import { ToastComponent } from '../components/ToastComponent';
import { HelpDetailPage } from './HelpDetailPage';

/**
 * 帮助中心页面
 */
@Component
export struct HelpCenterPage {
  @State helpCenterViewModel: HelpCenterViewModel = new HelpCenterViewModel();
  @Consume('navStack') navStack: NavPathStack;
  @State searchText: string = '';
  @State isSearching: boolean = false;

  aboutToAppear() {
    this.loadHelpData();
  }

  loadHelpData() {
    this.helpCenterViewModel.loadHelpData();
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        
        // 搜索栏
        this.buildSearchBar()
        
        // 帮助内容
        this.buildHelpContent()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('帮助中心')
    .hideTitleBar(true)
  }

  @Builder
  buildTopBar() {
    Row() {
      Image($r('app.media.back'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.navStack.pop();
        })
      
      Text('帮助中心')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildSearchBar() {
    Row() {
      TextInput({ placeholder: '搜索帮助内容...' })
        .onChange((value: string) => {
          this.searchText = value;
          this.handleSearch();
        })
        .fontSize(16)
        .fontColor('#000000')
        .backgroundColor('#F8F8F8')
        .borderRadius(20)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .layoutWeight(1)
        .margin({ right: 12 })
      
      Image($r('app.media.more'))
        .width(20)
        .height(20)
        .fillColor('#666666')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildHelpContent() {
    if (this.helpCenterViewModel.isLoading) {
      this.buildLoadingView()
    } else if (this.helpCenterViewModel.filteredHelpItems.length === 0) {
      this.buildEmptyView()
    } else {
      Scroll() {
        Column() {
          ForEach(this.helpCenterViewModel.filteredHelpItems, (category: HelpCategory) => {
            this.buildHelpCategory(category)
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
    }
  }

  @Builder
  buildHelpCategory(category: HelpCategory) {
    Column() {
      // 分类标题
      Text(category.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12, top: 20 })
      
      // 帮助项目列表
      Column() {
        ForEach(category.items, (item: HelpItem, index: number) => {
          this.buildHelpItem(item, index === category.items.length - 1)
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildHelpItem(item: HelpItem, isLast: boolean) {
    Row() {
      Column() {
        Text(item.title)
          .fontSize(15)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 4 })
        
        if (item.description) {
          Text(item.description)
            .fontSize(13)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      Image($r('app.media.open'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .border({ 
      //bottom: isLast ? { width: 0 } : { width: 1, color: '#F0F0F0' }
    })
    .onClick(() => {
      this.handleHelpItemClick(item);
    })
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#4CAF50')
      
      Text('加载中...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  buildEmptyView() {
    Column() {
      Image($r('app.media.more'))
        .width(120)
        .height(120)
        .opacity(0.6)
      
      Text('暂无帮助内容')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
      
      Text('请稍后再试或联系客服')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }

  handleSearch() {
    this.isSearching = true;
    this.helpCenterViewModel.searchHelpItems(this.searchText);
    this.isSearching = false;
  }

  handleHelpItemClick(item: HelpItem) {
    if (item.type === 'page') {
      this.navStack.pushPath({name:"HelpDetailPage",param:{helpItem:item} as HelpPageParams});
    } else if (item.type === 'contact') {
      // 联系客服
      this.showToast('正在为您转接客服...');
    } else if (item.type === 'external') {
      // 打开外部链接
      this.showToast('正在打开链接...');
    }
  }

  showToast(message: string) {
    ToastComponent.getInstance().show(message);
  }
}

// 帮助分类接口
export interface HelpCategory {
  title: string;
  items: HelpItem[];
}

// 帮助项目接口
export interface HelpItem {
  id: string;
  title: string;
  description?: string;
  type: 'page' | 'contact' | 'external';
  content?: string;
  url?: string;
}
export interface HelpPageParams {
  helpItem: HelpItem;
}