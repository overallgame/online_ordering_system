import { OrderService } from '../service/OrderService';
import { OrderDataConverter, AdminOrderSearchResponse, HistoryOrderResponse } from '../util/OrderDataConverter';

/**
 * 订单服务测试类
 */
export class OrderServiceTest {
  /**
   * 测试历史订单接口数据转换
   */
  static testHistoryOrderResponseConversion(): void {
    console.log('开始测试历史订单接口数据转换...');
    
    // 模拟历史订单接口响应数据
    const mockResponse: HistoryOrderResponse = {
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
              }
            ]
          }
        ]
      }
    };
    
    // 测试数据转换
    const orders = OrderDataConverter.convertHistoryOrderList(mockResponse.data);
    
    console.log('转换后的订单数量:', orders.length);
    console.log('总订单数:', mockResponse.data.total);
    
    if (orders.length === 2 && mockResponse.data.total === 2) {
      console.log('✅ 历史订单接口数据转换测试通过');
    } else {
      console.log('❌ 历史订单接口数据转换测试失败');
    }
  }

  /**
   * 测试订单服务获取历史订单
   */
  static async testGetHistoryOrders(): Promise<void> {
    console.log('开始测试获取历史订单...');
    
    const orderService = OrderService.getInstance();
    
    try {
      // 测试获取历史订单（这里会实际调用API，需要确保网络连接正常）
      const response = await orderService.getHistoryOrders(
        1,     // 页码
        10,    // 每页数量
        1 // 状态筛选
      );
      
      if (response.success) {
        console.log('✅ 获取历史订单测试通过');
        console.log('订单数量:', response.data?.orders.length || 0);
        console.log('总订单数:', response.data?.total || 0);
      } else {
        console.log('❌ 获取历史订单测试失败:', response.error);
      }
    } catch (error) {
      console.log('❌ 获取历史订单测试异常:', error);
    }
  }
  
  /**
   * 运行所有测试
   */
  static async runAllTests(): Promise<void> {
    console.log('=== 开始运行订单服务测试 ===');
    
    // 测试数据转换
    OrderServiceTest.testHistoryOrderResponseConversion();
    
    // 测试API调用（需要网络连接）
    await OrderServiceTest.testGetHistoryOrders();
    
    console.log('=== 订单服务测试完成 ===');
  }
}
