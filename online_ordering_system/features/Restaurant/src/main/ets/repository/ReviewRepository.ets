import { Result, ok, err } from '../util/Result';

export interface ReviewsPage {
  items: Array<DishReview>;
  hasMore: boolean;
}

export class DishReview {
  reviewId: string = '';
  orderId: string = '';
  userId: string = '';
  userName: string = '';
  userAvatar?: string;
  restaurantId: string = '';
  rating: number = 5;
  tasteRating: number = 5;
  serviceRating: number = 5;
  content: string = '';
  images: string[] = [];
  createTime: number = 0;
  likes: number = 0;
}

export class ReviewRepository {
  async fetchDishReviews(dishId: string, page: number = 1, pageSize: number = 10): Promise<Result<ReviewsPage>> {
    try {
      console.log(`Loading reviews for dish: ${dishId}`);
      const all: Array<DishReview> = [
        {
          reviewId: '1',
          orderId: 'order001',
          userId: 'user001',
          userName: '美食爱好者',
          userAvatar: 'common/images/avatar1.png',
          restaurantId: 'rest001',
          rating: 5,
          tasteRating: 5,
          serviceRating: 5,
          content: '非常好吃！味道正宗，分量足，服务态度也很好，下次还会再来！',
          images: ['common/images/review1.png', 'common/images/review2.png'],
          createTime: Date.now() - 86400000,
          likes: 12
        },
        {
          reviewId: '2',
          orderId: 'order002',
          userId: 'user002',
          userName: '吃货小王',
          userAvatar: 'common/images/avatar2.png',
          restaurantId: 'rest001',
          rating: 4,
          tasteRating: 4,
          serviceRating: 5,
          content: '口味不错，就是稍微有点辣，不过整体还是很满意的。',
          images: ['common/images/review3.png'],
          createTime: Date.now() - 172800000,
          likes: 8
        },
        {
          reviewId: '3',
          orderId: 'order003',
          userId: 'user003',
          userName: '美味探索家',
          userAvatar: 'common/images/avatar3.png',
          restaurantId: 'rest001',
          rating: 5,
          tasteRating: 5,
          serviceRating: 4,
          content: '这道菜真的太好吃了！麻辣鲜香，回味无穷，强烈推荐！',
          images: [],
          createTime: Date.now() - 259200000,
          likes: 15
        },
        {
          reviewId: '4',
          orderId: 'order004',
          userId: 'user004',
          userName: '吃遍天下',
          userAvatar: 'common/images/avatar4.png',
          restaurantId: 'rest001',
          rating: 4,
          tasteRating: 4,
          serviceRating: 4,
          content: '味道可以，性价比挺高的，配送速度也快。',
          images: ['common/images/review4.png'],
          createTime: Date.now() - 345600000,
          likes: 6
        },
        {
          reviewId: '5',
          orderId: 'order005',
          userId: 'user005',
          userName: '资深吃货',
          userAvatar: 'common/images/avatar5.png',
          restaurantId: 'rest001',
          rating: 5,
          tasteRating: 5,
          serviceRating: 5,
          content: '超级棒！这是我吃过最好吃的一次，食材新鲜，火候掌握得恰到好处！',
          images: ['common/images/review5.png', 'common/images/review6.png'],
          createTime: Date.now() - 432000000,
          likes: 20
        }
      ];
      
      const start = (page - 1) * pageSize;
      const end = start + pageSize;
      const items: Array<DishReview> = all.slice(start, end);
      const hasMore: boolean = end < all.length;
      const pageData: ReviewsPage = { items: items, hasMore: hasMore };
      return ok<ReviewsPage>(pageData);
    } catch (e) {
      return err('加载评论失败');
    }
  }
}
