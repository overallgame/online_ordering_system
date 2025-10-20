import { MockOrderDataGenerator } from '../util/MockOrderDataGenerator';
import { OrderStatus,Order } from 'common';

/**
 * 模拟订单数据测试类
 */
export class MockOrderDataTest {
  
  /**
   * 测试生成模拟订单数据
   */
  static testGenerateMockOrders(): void {
    console.log('=== 开始测试模拟订单数据生成 ===');
    
    // 生成所有模拟订单
    const orders = MockOrderDataGenerator.generateMockOrders();
    
    console.log(`生成了 ${orders.length} 个模拟订单`);
    
    // 验证订单数据
    orders.forEach((order: Order, index: number) => {
      console.log(`订单 ${index + 1}:`);
      console.log(`  - 订单ID: ${order.orderId}`);
      console.log(`  - 状态: ${order.status}`);
      console.log(`  - 支付状态: ${order.paymentStatus}`);
      console.log(`  - 订单类型: ${order.orderType}`);
      console.log(`  - 总金额: ¥${order.finalAmount}`);
      console.log(`  - 菜品数量: ${order.items.length}`);
      if (order.items.length > 0) {
        console.log(`  - 主菜品: ${order.items[0].dish?.name || '未知'}`);
      }
      console.log(`  - 创建时间: ${new Date(order.createTime).toLocaleString()}`);
      console.log('---');
    });
    
    // 验证不同状态的订单
    const statusCounts: Record<string, number> = {};
    orders.forEach(order => {
      statusCounts[order.status] = (statusCounts[order.status] || 0) + 1;
    });
    
    console.log('订单状态分布:');
    Object.entries(statusCounts).forEach((entry: [string, number]) => {
      const status = entry[0];
      const count = entry[1];
      console.log(`  ${status}: ${count} 个`);
    });
    
    console.log('=== 模拟订单数据生成测试完成 ===');
  }
  
  /**
   * 测试按状态筛选生成订单
   */
  static testGenerateOrdersByStatus(): void {
    console.log('=== 开始测试按状态筛选生成订单 ===');
    
    const statuses = [
      OrderStatus.PENDING,
      OrderStatus.CONFIRMED,
      OrderStatus.ACCEPTED,
      OrderStatus.DELIVERING,
      OrderStatus.COMPLETED,
      OrderStatus.CANCELLED
    ];
    
    statuses.forEach(status => {
      const orders = MockOrderDataGenerator.generateMockOrdersByStatus(status);
      console.log(`${status} 状态订单: ${orders.length} 个`);
    });
    
    console.log('=== 按状态筛选生成订单测试完成 ===');
  }
  
  /**
   * 测试按数量生成订单
   */
  static testGenerateOrdersByCount(): void {
    console.log('=== 开始测试按数量生成订单 ===');
    
    const counts = [3, 5, 10, 15];
    
    counts.forEach(count => {
      const orders = MockOrderDataGenerator.generateMockOrdersByCount(count);
      console.log(`请求 ${count} 个订单，实际生成 ${orders.length} 个`);
    });
    
    console.log('=== 按数量生成订单测试完成 ===');
  }
  
  /**
   * 运行所有测试
   */
  static runAllTests(): void {
    console.log('开始运行模拟订单数据测试...');
    
    MockOrderDataTest.testGenerateMockOrders();
    MockOrderDataTest.testGenerateOrdersByStatus();
    MockOrderDataTest.testGenerateOrdersByCount();
    
    console.log('模拟订单数据测试完成！');
  }
}
