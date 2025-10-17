import { OrderService } from '../service/OrderService';
import { OrderDataConverter, AdminOrderSearchResponse } from '../util/OrderDataConverter';

/**
 * 订单服务测试类
 */
export class OrderServiceTest {
  
  /**
   * 测试管理端订单搜索接口数据转换
   */
  static testAdminOrderSearchResponseConversion(): void {
    console.log('开始测试管理端订单搜索接口数据转换...');
    
    // 模拟管理端订单搜索接口响应数据
    const mockResponse: AdminOrderSearchResponse = {
      code: 1,
      msg: null,
      data: {
        total: 2,
        records: [
          {
            id: 1,
            number: 'ORDER001',
            status: 1,
            userId: 100,
            addressBookId: 1,
            orderTime: '2024-01-01 10:00:00',
            checkoutTime: '2024-01-01 10:05:00',
            payMethod: 1,
            payStatus: 1,
            amount: 50.00,
            remark: '测试订单1',
            userName: '张三',
            phone: '13800138000',
            address: '北京市朝阳区',
            consignee: '张三',
            cancelReason: '',
            rejectionReason: '',
            cancelTime: '',
            estimatedDeliveryTime: '2024-01-01 11:00:00',
            deliveryStatus: 0,
            deliveryTime: '',
            packAmount: 1,
            tablewareNumber: 2,
            tablewareStatus: 1,
            orderDetailList: [
              {
                id: 1,
                name: '宫保鸡丁',
                orderId: 1,
                dishId: 1,
                dishFlavor: '微辣',
                number: 1,
                amount: 25.00,
                image: 'dish1.jpg'
              },
              {
                id: 2,
                name: '米饭',
                orderId: 1,
                dishId: 2,
                dishFlavor: '',
                number: 1,
                amount: 25.00,
                image: 'dish2.jpg'
              }
            ]
          },
          {
            id: 2,
            number: 'ORDER002',
            status: 5,
            userId: 100,
            addressBookId: 1,
            orderTime: '2024-01-02 12:00:00',
            checkoutTime: '2024-01-02 12:05:00',
            payMethod: 2,
            payStatus: 1,
            amount: 80.00,
            remark: '测试订单2',
            userName: '张三',
            phone: '13800138000',
            address: '北京市朝阳区',
            consignee: '张三',
            cancelReason: '',
            rejectionReason: '',
            cancelTime: '',
            estimatedDeliveryTime: '2024-01-02 13:00:00',
            deliveryStatus: 1,
            deliveryTime: '2024-01-02 13:00:00',
            packAmount: 2,
            tablewareNumber: 4,
            tablewareStatus: 1,
            orderDetailList: [
              {
                id: 3,
                name: '红烧肉',
                orderId: 2,
                dishId: 3,
                dishFlavor: '正常',
                number: 1,
                amount: 40.00,
                image: 'dish3.jpg'
              },
              {
                id: 4,
                name: '汤',
                orderId: 2,
                dishId: 4,
                dishFlavor: '',
                number: 1,
                amount: 40.00,
                image: 'dish4.jpg'
              }
            ]
          }
        ]
      }
    };
    
    // 测试数据转换
    const orders = OrderDataConverter.convertAdminOrderSearchResponse(mockResponse);
    const total = OrderDataConverter.getTotalFromAdminResponse(mockResponse);
    
    console.log('转换后的订单数量:', orders.length);
    console.log('总订单数:', total);
    
    if (orders.length === 2 && total === 2) {
      console.log('✅ 管理端订单搜索接口数据转换测试通过');
    } else {
      console.log('❌ 管理端订单搜索接口数据转换测试失败');
    }
    
    // 测试订单状态转换
    if (orders.length > 0) {
      const firstOrder = orders[0];
      console.log('第一个订单状态:', firstOrder.status);
      console.log('第一个订单支付状态:', firstOrder.paymentStatus);
      console.log('第一个订单支付方式:', firstOrder.paymentMethod);
      console.log('第一个订单金额:', firstOrder.totalAmount);
      console.log('第一个订单创建时间:', OrderDataConverter.formatTime(firstOrder.createTime));
    }
  }
  
  /**
   * 测试订单服务获取用户全部订单
   */
  static async testGetUserAllOrders(): Promise<void> {
    console.log('开始测试获取用户全部订单...');
    
    const orderService = OrderService.getInstance();
    
    try {
      // 测试获取用户订单（这里会实际调用API，需要确保网络连接正常）
      const response = await orderService.getUserAllOrders(
        '100', // 用户ID
        1,     // 页码
        10,    // 每页数量
        undefined, // 状态筛选
        undefined, // 开始时间
        undefined  // 结束时间
      );
      
      if (response.success) {
        console.log('✅ 获取用户全部订单测试通过');
        console.log('订单数量:', response.data?.orders.length || 0);
        console.log('总订单数:', response.data?.total || 0);
      } else {
        console.log('❌ 获取用户全部订单测试失败:', response.error);
      }
    } catch (error) {
      console.log('❌ 获取用户全部订单测试异常:', error);
    }
  }
  
  /**
   * 运行所有测试
   */
  static async runAllTests(): Promise<void> {
    console.log('=== 开始运行订单服务测试 ===');
    
    // 测试数据转换
    OrderServiceTest.testAdminOrderSearchResponseConversion();
    
    // 测试API调用（需要网络连接）
    await OrderServiceTest.testGetUserAllOrders();
    
    console.log('=== 订单服务测试完成 ===');
  }
}
