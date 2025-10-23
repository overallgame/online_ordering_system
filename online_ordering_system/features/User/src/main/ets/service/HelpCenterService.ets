import { HelpCategory, HelpItem } from '../pages/HelpCenterPage';

/**
 * 帮助中心服务类
 */
export class HelpCenterService {
  private static instance: HelpCenterService;
  private helpData: HelpCategory[] = [];

  public static getInstance(): HelpCenterService {
    if (!HelpCenterService.instance) {
      HelpCenterService.instance = new HelpCenterService();
    }
    return HelpCenterService.instance;
  }

  /**
   * 获取帮助数据
   */
  getHelpData(): HelpCategory[] {
    return this.getMockHelpData();
  }

  /**
   * 搜索帮助内容
   */
  searchHelpData(keyword: string): HelpCategory[] {
    const allData = this.getHelpData();
    const filtered = allData.map(category => {
      const filteredItems = category.items.filter(item => 
        item.title.toLowerCase().includes(keyword.toLowerCase()) ||
        (item.description && item.description.toLowerCase().includes(keyword.toLowerCase()))
      );
      
      const filteredCategory: HelpCategory = {
        title: category.title,
        items: filteredItems
      };
      return filteredCategory;
    }).filter(category => category.items.length > 0);

    return filtered;
  }

  /**
   * 获取帮助项目详情
   */
  getHelpItemDetail(itemId: string): HelpItem | null {
    const allData = this.getHelpData();
    
    for (const category of allData) {
      const item = category.items.find(item => item.id === itemId);
      if (item) {
        return item;
      }
    }
    
    return null;
  }

  /**
   * 提交反馈
   */
  submitFeedback(itemId: string, isHelpful: boolean, comment?: string): boolean {
    // 本地记录反馈，不需要网络请求
    console.log(`反馈记录: ${itemId}, 有帮助: ${isHelpful}, 评论: ${comment}`);
    return true;
  }

  /**
   * 获取模拟帮助数据
   */
  private getMockHelpData(): HelpCategory[] {
    return [
      {
        title: '常见问题',
        items: [
          {
            id: 'faq_1',
            title: '如何下单？',
            description: '了解下单流程和注意事项',
            type: 'page',
            content: '下单步骤：\n1. 浏览餐厅和菜品\n2. 选择心仪的菜品加入购物车\n3. 确认订单信息\n4. 选择支付方式\n5. 提交订单等待配送'
          },
          {
            id: 'faq_2',
            title: '如何支付？',
            description: '支持的支付方式和支付流程',
            type: 'page',
            content: '支付方式：\n• 微信支付\n• 支付宝\n• 银行卡\n• 现金支付（货到付款）\n\n支付流程：\n1. 选择支付方式\n2. 确认支付金额\n3. 完成支付\n4. 等待订单确认'
          },
          {
            id: 'faq_3',
            title: '配送时间多长？',
            description: '了解配送时间和配送范围',
            type: 'page',
            content: '配送时间：\n• 工作日：30-60分钟\n• 周末：45-75分钟\n• 节假日：60-90分钟\n\n配送范围：\n• 市区内免费配送\n• 郊区需额外配送费\n• 偏远地区暂不支持配送'
          },
          {
            id: 'faq_4',
            title: '如何取消订单？',
            description: '订单取消规则和操作步骤',
            type: 'page',
            content: '取消规则：\n• 未支付：随时可取消\n• 已支付未接单：可申请退款\n• 已接单：联系商家协商\n• 已配送：不可取消\n\n操作步骤：\n1. 进入"我的订单"\n2. 找到要取消的订单\n3. 点击"取消订单"\n4. 选择取消原因\n5. 确认取消'
          }
        ]
      },
      {
        title: '账户管理',
        items: [
          {
            id: 'account_1',
            title: '如何注册账户？',
            description: '新用户注册流程',
            type: 'page',
            content: '注册步骤：\n1. 点击"注册"按钮\n2. 输入手机号码\n3. 获取并输入验证码\n4. 设置登录密码\n5. 完善个人信息\n6. 完成注册'
          },
          {
            id: 'account_2',
            title: '忘记密码怎么办？',
            description: '密码找回方法',
            type: 'page',
            content: '找回密码：\n1. 点击"忘记密码"\n2. 输入注册手机号\n3. 获取验证码\n4. 设置新密码\n5. 确认新密码\n6. 完成重置'
          },
          {
            id: 'account_3',
            title: '如何修改个人信息？',
            description: '个人信息修改指南',
            type: 'page',
            content: '修改步骤：\n1. 进入"个人中心"\n2. 点击"个人信息"\n3. 点击"编辑"\n4. 修改需要的信息\n5. 点击"保存"\n6. 完成修改'
          }
        ]
      },
      {
        title: '订单相关',
        items: [
          {
            id: 'order_1',
            title: '如何查看订单状态？',
            description: '订单状态查询方法',
            type: 'page',
            content: '查看方法：\n1. 进入"我的订单"\n2. 查看订单列表\n3. 点击具体订单\n4. 查看订单详情\n\n订单状态：\n• 待支付\n• 已支付\n• 已接单\n• 配送中\n• 已完成\n• 已取消'
          },
          {
            id: 'order_2',
            title: '如何申请退款？',
            description: '退款申请流程',
            type: 'page',
            content: '申请退款：\n1. 进入"我的订单"\n2. 找到要退款的订单\n3. 点击"申请退款"\n4. 选择退款原因\n5. 填写退款说明\n6. 提交申请\n7. 等待审核结果'
          },
          {
            id: 'order_3',
            title: '订单超时未送达怎么办？',
            description: '超时处理方案',
            type: 'page',
            content: '处理方案：\n1. 联系商家确认配送情况\n2. 如确实超时，可申请补偿\n3. 联系客服处理\n4. 根据情况给予优惠券补偿\n5. 严重超时可申请退款'
          }
        ]
      },
      {
        title: '联系客服',
        items: [
          {
            id: 'contact_1',
            title: '在线客服',
            description: '7x24小时在线客服',
            type: 'contact'
          },
          {
            id: 'contact_2',
            title: '客服电话',
            description: '400-123-4567',
            type: 'contact'
          },
          {
            id: 'contact_3',
            title: '意见反馈',
            description: '提交您的宝贵意见',
            type: 'page',
            content: '反馈渠道：\n• 应用内意见反馈\n• 客服电话\n• 官方邮箱\n• 微信公众号\n\n反馈内容：\n• 使用体验\n• 功能建议\n• 问题报告\n• 其他意见'
          }
        ]
      }
    ];
  }
}
