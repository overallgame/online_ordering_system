export class Restaurant {
  restaurantId: string = '';
  name: string = '';
  address: string = '';
  phone: string = '';
  businessHours: BusinessHours = new BusinessHours();
  description?: string;
  images: Array<string> = [];
  rating: number = 0;
  reviewCount: number = 0;
  deliveryFee: number = 0;
  minOrderAmount: number = 0;
  isOpen: boolean = true;
}

export class BusinessHours {
  openingTime: string = '09:00';
  closingTime: string = '22:00';
  is24Hours: boolean = false;
  specialHours?: Array<SpecialHours>;
}

export class SpecialHours {
  date: string = ''; // YYYY-MM-DD
  openingTime: string = '';
  closingTime: string = '';
  reason?: string;
}