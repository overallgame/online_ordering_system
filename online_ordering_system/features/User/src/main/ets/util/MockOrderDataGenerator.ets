import { Order, OrderItem, OrderStatus, PaymentStatus, PaymentMethod, OrderType, Dish, SpiceLevel } from 'common';

/**
 * 模拟订单数据生成器
 * 用于在服务器没有数据时提供测试数据
 */
export class MockOrderDataGenerator {
  
  /**
   * 生成模拟订单列表
   */
  static generateMockOrders(): Order[] {
    const orders: Order[] = [];
    
    // 生成不同状态的订单
    orders.push(MockOrderDataGenerator.createMockOrder('ORDER001', OrderStatus.PENDING, PaymentStatus.PENDING, '宫保鸡丁', 25.00, '2024-01-15 10:30:00'));
    orders.push(MockOrderDataGenerator.createMockOrder('ORDER002', OrderStatus.CONFIRMED, PaymentStatus.PAID, '麻婆豆腐', 18.00, '2024-01-14 19:20:00'));
    orders.push(MockOrderDataGenerator.createMockOrder('ORDER003', OrderStatus.PREPARING, PaymentStatus.PAID, '红烧肉', 35.00, '2024-01-14 18:45:00'));
    orders.push(MockOrderDataGenerator.createMockOrder('ORDER004', OrderStatus.READY, PaymentStatus.PAID, '糖醋里脊', 28.00, '2024-01-14 17:30:00'));
    orders.push(MockOrderDataGenerator.createMockOrder('ORDER005', OrderStatus.COMPLETED, PaymentStatus.PAID, '鱼香肉丝', 22.00, '2024-01-13 20:15:00'));
    orders.push(MockOrderDataGenerator.createMockOrder('ORDER006', OrderStatus.CANCELLED, PaymentStatus.PENDING, '回锅肉', 30.00, '2024-01-13 16:20:00'));
    
    // 生成套餐订单
    orders.push(MockOrderDataGenerator.createMockComboOrder('ORDER007', OrderStatus.COMPLETED, PaymentStatus.PAID, '经典双人套餐', 88.00, '2024-01-12 19:00:00'));
    
    // 生成多菜品订单
    orders.push(MockOrderDataGenerator.createMockMultiDishOrder('ORDER008', OrderStatus.PREPARING, PaymentStatus.PAID, '2024-01-12 18:30:00'));
    
    // 生成外卖订单
    orders.push(MockOrderDataGenerator.createMockDeliveryOrder('ORDER009', OrderStatus.READY, PaymentStatus.PAID, '水煮鱼', 45.00, '2024-01-11 21:00:00'));
    
    // 生成更多多菜品订单
    orders.push(MockOrderDataGenerator.createMockMultiDishOrder('ORDER010', OrderStatus.COMPLETED, PaymentStatus.PAID, '2024-01-10 19:30:00'));
    orders.push(MockOrderDataGenerator.createMockMultiDishOrder('ORDER011', OrderStatus.CONFIRMED, PaymentStatus.PAID, '2024-01-09 18:15:00'));
    
    // 生成大型多菜品订单
    orders.push(MockOrderDataGenerator.createMockLargeOrder('ORDER012', OrderStatus.PREPARING, PaymentStatus.PAID, '2024-01-08 20:00:00'));
    
    return orders;
  }
  
  /**
   * 创建单个菜品订单
   */
  private static createMockOrder(
    orderId: string, 
    status: OrderStatus, 
    paymentStatus: PaymentStatus, 
    dishName: string, 
    price: number, 
    orderTime: string
  ): Order {
    const order = new Order();
    order.orderId = orderId;
    order.userId = '100';
    order.restaurantId = '1';
    order.status = status;
    order.paymentStatus = paymentStatus;
    order.paymentMethod = PaymentMethod.WECHAT;
    order.orderType = OrderType.DINE_IN;
    order.createTime = MockOrderDataGenerator.parseTimeString(orderTime);
    order.updateTime = order.createTime;
    order.totalAmount = price;
    order.finalAmount = price;
    order.discountAmount = 0;
    order.deliveryAddress = '北京市朝阳区三里屯街道';
    order.customerNote = '请尽快制作';
    
    // 创建订单项
    const orderItem = new OrderItem();
    orderItem.itemId = `${orderId}_1`;
    orderItem.quantity = 1;
    orderItem.unitPrice = price;
    orderItem.totalPrice = price;
    orderItem.note = '微辣';
    
    // 创建菜品
    const dish = new Dish();
    dish.dishId = `${orderId}_dish_1`;
    dish.name = dishName;
    dish.price = price;
    dish.image = MockOrderDataGenerator.getRandomDishImage();
    dish.description = `${dishName}，经典川菜，口感鲜美`;
    dish.category = '川菜';
    dish.isAvailable = true;
    dish.stock = 100;
    dish.tags = ['热销', '推荐'] as string[];
    dish.preparationTime = 15;
    dish.rating = 4.5;
    dish.reviewCount = 128;
    dish.spiceLevel = MockOrderDataGenerator.getRandomSpiceLevel();
    
    orderItem.dish = dish;
    order.items = [orderItem];
    
    return order;
  }
  
  /**
   * 创建套餐订单
   */
  private static createMockComboOrder(
    orderId: string, 
    status: OrderStatus, 
    paymentStatus: PaymentStatus, 
    comboName: string, 
    price: number, 
    orderTime: string
  ): Order {
    const order = new Order();
    order.orderId = orderId;
    order.userId = '100';
    order.restaurantId = '1';
    order.status = status;
    order.paymentStatus = paymentStatus;
    order.paymentMethod = PaymentMethod.ALIPAY;
    order.orderType = OrderType.DINE_IN;
    order.createTime = MockOrderDataGenerator.parseTimeString(orderTime);
    order.updateTime = order.createTime;
    order.totalAmount = price;
    order.finalAmount = price;
    order.discountAmount = 0;
    order.deliveryAddress = '北京市朝阳区三里屯街道';
    order.customerNote = '套餐很实惠';
    
    // 创建套餐订单项
    const orderItem = new OrderItem();
    orderItem.itemId = `${orderId}_combo_1`;
    orderItem.quantity = 1;
    orderItem.unitPrice = price;
    orderItem.totalPrice = price;
    orderItem.note = '经典套餐';
    
    // 创建套餐菜品（模拟）
    const dish = new Dish();
    dish.dishId = `${orderId}_combo_dish`;
    dish.name = comboName;
    dish.price = price;
    dish.image = MockOrderDataGenerator.getRandomComboImage();
    dish.description = `${comboName}，包含2个主菜+1个汤+2份米饭`;
    dish.category = '套餐';
    dish.isAvailable = true;
    dish.stock = 50;
    dish.tags = ['套餐', '实惠'] as string[];
    dish.preparationTime = 20;
    dish.rating = 4.3;
    dish.reviewCount = 89;
    
    orderItem.dish = dish;
    order.items = [orderItem];
    
    return order;
  }
  
  /**
   * 创建多菜品订单
   */
  private static createMockMultiDishOrder(
    orderId: string, 
    status: OrderStatus, 
    paymentStatus: PaymentStatus, 
    orderTime: string
  ): Order {
    const order = new Order();
    order.orderId = orderId;
    order.userId = '100';
    order.restaurantId = '1';
    order.status = status;
    order.paymentStatus = paymentStatus;
    order.paymentMethod = PaymentMethod.WECHAT;
    order.orderType = OrderType.DINE_IN;
    order.createTime = MockOrderDataGenerator.parseTimeString(orderTime);
    order.updateTime = order.createTime;
    order.deliveryAddress = '北京市朝阳区三里屯街道';
    order.customerNote = '多放点辣椒';
    
    // 创建多个订单项
    interface DishInfo {
      name: string;
      price: number;
      quantity: number;
    }
    
    const dishes: DishInfo[] = [
      { name: '宫保鸡丁', price: 25.00, quantity: 1 },
      { name: '麻婆豆腐', price: 18.00, quantity: 1 },
      { name: '米饭', price: 3.00, quantity: 2 }
    ];
    
    let totalAmount = 0;
    order.items = dishes.map((dish: DishInfo, index: number) => {
      const orderItem = new OrderItem();
      orderItem.itemId = `${orderId}_${index + 1}`;
      orderItem.quantity = dish.quantity;
      orderItem.unitPrice = dish.price;
      orderItem.totalPrice = dish.price * dish.quantity;
      orderItem.note = index === 0 ? '微辣' : '';
      
      const dishObj = new Dish();
      dishObj.dishId = `${orderId}_dish_${index + 1}`;
      dishObj.name = dish.name;
      dishObj.price = dish.price;
      dishObj.image = MockOrderDataGenerator.getRandomDishImage();
      dishObj.description = `${dish.name}，经典菜品`;
      dishObj.category = dish.name === '米饭' ? '主食' : '川菜';
      dishObj.isAvailable = true;
      dishObj.stock = 100;
      dishObj.tags = dish.name === '米饭' ? ['主食'] as string[] : ['热销'] as string[];
      dishObj.preparationTime = dish.name === '米饭' ? 5 : 15;
      dishObj.rating = 4.2;
      dishObj.reviewCount = 95;
      
      orderItem.dish = dishObj;
      totalAmount += orderItem.totalPrice;
      
      return orderItem;
    });
    
    order.totalAmount = totalAmount;
    order.finalAmount = totalAmount;
    order.discountAmount = 0;
    
    return order;
  }
  
  /**
   * 创建外卖订单
   */
  private static createMockDeliveryOrder(
    orderId: string, 
    status: OrderStatus, 
    paymentStatus: PaymentStatus, 
    dishName: string, 
    price: number, 
    orderTime: string
  ): Order {
    const order = new Order();
    order.orderId = orderId;
    order.userId = '100';
    order.restaurantId = '1';
    order.status = status;
    order.paymentStatus = paymentStatus;
    order.paymentMethod = PaymentMethod.WECHAT;
    order.orderType = OrderType.DELIVERY;
    order.createTime = MockOrderDataGenerator.parseTimeString(orderTime);
    order.updateTime = order.createTime;
    order.totalAmount = price + 5; // 包含配送费
    order.finalAmount = price + 5;
    order.discountAmount = 0;
    order.deliveryAddress = '北京市朝阳区三里屯街道123号';
    order.customerNote = '请送到门口，谢谢';
    order.estimatedDeliveryTime = order.createTime + 30 * 60 * 1000; // 30分钟后
    
    // 创建订单项
    const orderItem = new OrderItem();
    orderItem.itemId = `${orderId}_1`;
    orderItem.quantity = 1;
    orderItem.unitPrice = price;
    orderItem.totalPrice = price;
    orderItem.note = '中辣';
    
    // 创建菜品
    const dish = new Dish();
    dish.dishId = `${orderId}_dish_1`;
    dish.name = dishName;
    dish.price = price;
    dish.image = MockOrderDataGenerator.getRandomDishImage();
    dish.description = `${dishName}，外卖热销菜品`;
    dish.category = '川菜';
    dish.isAvailable = true;
    dish.stock = 100;
    dish.tags = ['外卖', '热销'] as string[];
    dish.preparationTime = 20;
    dish.rating = 4.6;
    dish.reviewCount = 156;
    dish.spiceLevel = MockOrderDataGenerator.getRandomSpiceLevel();
    
    orderItem.dish = dish;
    order.items = [orderItem];
    
    return order;
  }
  
  /**
   * 创建大型多菜品订单
   */
  private static createMockLargeOrder(
    orderId: string, 
    status: OrderStatus, 
    paymentStatus: PaymentStatus, 
    orderTime: string
  ): Order {
    const order = new Order();
    order.orderId = orderId;
    order.userId = '100';
    order.restaurantId = '1';
    order.status = status;
    order.paymentStatus = paymentStatus;
    order.paymentMethod = PaymentMethod.WECHAT;
    order.orderType = OrderType.DINE_IN;
    order.createTime = MockOrderDataGenerator.parseTimeString(orderTime);
    order.updateTime = order.createTime;
    order.deliveryAddress = '北京市朝阳区三里屯街道';
    order.customerNote = '家庭聚餐，请尽快制作';
    
    // 创建多个订单项
    interface DishInfo {
      name: string;
      price: number;
      quantity: number;
      note?: string;
    }
    
    const dishes: DishInfo[] = [
      { name: '宫保鸡丁', price: 25.00, quantity: 2, note: '微辣' },
      { name: '麻婆豆腐', price: 18.00, quantity: 1, note: '中辣' },
      { name: '红烧肉', price: 35.00, quantity: 1, note: '少油' },
      { name: '糖醋里脊', price: 28.00, quantity: 1, note: '酸甜' },
      { name: '鱼香肉丝', price: 22.00, quantity: 1, note: '微辣' },
      { name: '米饭', price: 3.00, quantity: 4, note: '' },
      { name: '蛋花汤', price: 8.00, quantity: 1, note: '清淡' }
    ];
    
    let totalAmount = 0;
    order.items = dishes.map((dish: DishInfo, index: number) => {
      const orderItem = new OrderItem();
      orderItem.itemId = `${orderId}_${index + 1}`;
      orderItem.quantity = dish.quantity;
      orderItem.unitPrice = dish.price;
      orderItem.totalPrice = dish.price * dish.quantity;
      orderItem.note = dish.note || '';
      
      const dishObj = new Dish();
      dishObj.dishId = `${orderId}_dish_${index + 1}`;
      dishObj.name = dish.name;
      dishObj.price = dish.price;
      dishObj.image = MockOrderDataGenerator.getRandomDishImage();
      dishObj.description = `${dish.name}，经典菜品`;
      dishObj.category = dish.name === '米饭' ? '主食' : (dish.name === '蛋花汤' ? '汤品' : '川菜');
      dishObj.isAvailable = true;
      dishObj.stock = 100;
      dishObj.tags = dish.name === '米饭' ? ['主食'] : (dish.name === '蛋花汤' ? ['汤品'] : ['热销']);
      dishObj.preparationTime = dish.name === '米饭' ? 5 : (dish.name === '蛋花汤' ? 10 : 15);
      dishObj.rating = 4.2;
      dishObj.reviewCount = 95;
      
      orderItem.dish = dishObj;
      totalAmount += orderItem.totalPrice;
      
      return orderItem;
    });
    
    order.totalAmount = totalAmount;
    order.finalAmount = totalAmount;
    order.discountAmount = 0;
    
    return order;
  }
  
  /**
   * 解析时间字符串为时间戳
   */
  private static parseTimeString(timeStr: string): number {
    try {
      return new Date(timeStr).getTime();
    } catch (error) {
      console.warn('解析时间字符串失败:', timeStr, error);
      return Date.now();
    }
  }
  
  /**
   * 获取随机菜品图片
   */
  private static getRandomDishImage(): string {
    const images: string[] = [
      'dish1.jpg', 'dish2.jpg', 'dish3.jpg', 'dish4.jpg', 'dish5.jpg'
    ];
    return images[Math.floor(Math.random() * images.length)];
  }
  
  /**
   * 获取随机套餐图片
   */
  private static getRandomComboImage(): string {
    const images: string[] = [
      'combo1.jpg', 'combo2.jpg', 'combo3.jpg'
    ];
    return images[Math.floor(Math.random() * images.length)];
  }
  
  /**
   * 获取随机辣度
   */
  private static getRandomSpiceLevel(): SpiceLevel {
    const levels: SpiceLevel[] = [SpiceLevel.MILD, SpiceLevel.MEDIUM, SpiceLevel.SPICY];
    return levels[Math.floor(Math.random() * levels.length)];
  }
  
  /**
   * 生成指定数量的模拟订单
   */
  static generateMockOrdersByCount(count: number): Order[] {
    const allOrders = MockOrderDataGenerator.generateMockOrders();
    return allOrders.slice(0, Math.min(count, allOrders.length));
  }
  
  /**
   * 根据状态筛选生成模拟订单
   */
  static generateMockOrdersByStatus(status: OrderStatus): Order[] {
    const allOrders = MockOrderDataGenerator.generateMockOrders();
    return allOrders.filter(order => order.status === status);
  }
}
