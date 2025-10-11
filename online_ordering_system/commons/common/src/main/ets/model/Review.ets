export class Review {
  reviewId: string = '';
  orderId: string = '';
  userId: string = '';
  restaurantId: string = '';
  rating: number = 5;
  tasteRating: number = 5;
  serviceRating: number = 5;
  content: string = '';
  images: string[] = [];
  createTime: number = 0;
  likes: number = 0;
}

export class ReviewSummary {
  averageRating: number = 0;
  totalReviews: number = 0;
  ratingDistribution: number[] = [0, 0, 0, 0, 0];
}