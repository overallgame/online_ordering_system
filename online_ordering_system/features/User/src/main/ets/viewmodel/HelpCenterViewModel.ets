import { HelpCategory, HelpItem } from '../pages/HelpCenterPage';
import { HelpCenterService } from '../service/HelpCenterService';

/**
 * 帮助中心ViewModel - 处理帮助中心相关的业务逻辑
 */
@Observed
export class HelpCenterViewModel {
  // 帮助数据
  helpCategories: HelpCategory[] = [];
  filteredHelpItems: HelpCategory[] = [];
  isLoading: boolean = false;
  searchText: string = '';
  // 帮助中心服务
  private helpCenterService: HelpCenterService = HelpCenterService.getInstance();

  constructor() {
    // 在构造函数中直接加载数据
    this.loadHelpData();
  }

  /**
   * 加载帮助数据
   */
  loadHelpData(): void {
    this.isLoading = true;
    
    try {
      this.helpCategories = this.helpCenterService.getHelpData();
      this.filteredHelpItems = [...this.helpCategories];
    } catch (error) {
      console.error('加载帮助数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 搜索帮助内容
   */
  searchHelpItems(searchText: string): void {
    this.searchText = searchText;
    
    if (!searchText || searchText.trim() === '') {
      this.filteredHelpItems = [...this.helpCategories];
      return;
    }

    try {
      this.filteredHelpItems = this.helpCenterService.searchHelpData(searchText);
    } catch (error) {
      console.error('搜索帮助内容失败:', error);
      this.filteredHelpItems = [];
    }
  }

  /**
   * 获取帮助项目详情
   */
  getHelpItemById(itemId: string): HelpItem | null {
    return this.helpCenterService.getHelpItemDetail(itemId);
  }

  /**
   * 获取热门问题
   */
  getPopularQuestions(): HelpItem[] {
    const popularIds = ['faq_1', 'faq_2', 'faq_4', 'order_1'];
    const popularItems: HelpItem[] = [];
    
    for (const category of this.helpCategories) {
      for (const item of category.items) {
        if (popularIds.includes(item.id)) {
          popularItems.push(item);
        }
      }
    }
    
    return popularItems;
  }

  /**
   * 记录帮助项目点击
   */
  recordHelpItemClick(itemId: string): void {
    // 这里可以添加统计逻辑
    console.log(`Help item clicked: ${itemId}`);
  }
}
