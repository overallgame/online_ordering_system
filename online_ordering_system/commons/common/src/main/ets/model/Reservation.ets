export class Reservation {
  reservationId: string = '';
  userId: string = '';
  restaurantId: string = '';
  reservationTime: number = 0;
  peopleCount: number = 2;
  tableType: string = '';
  contactName: string = '';
  contactPhone: string = '';
  status: ReservationStatus = ReservationStatus.PENDING;
  specialRequirements: string = '';
  createTime: number = 0;
}

export enum ReservationStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  CANCELLED = 'cancelled',
  COMPLETED = 'completed'
}