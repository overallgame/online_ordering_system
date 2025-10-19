import { AddressBook } from 'common/src/main/ets/model/AddressBook';
import { AddressRepository } from '../repository/AddressRepository';
import { DataState, idleState } from '../util/DataState';

export class AddressViewModel {
  private repository: AddressRepository;
  
  state: DataState<AddressBook | null> = idleState<AddressBook | null>(null);
  isRefreshing: boolean = false;

  constructor() {
    this.repository = AddressRepository.getInstance();
  }

  async loadDefaultAddress(): Promise<AddressBook | null> {
    try {
      const address = await this.repository.getDefaultAddress();
      
      if (address) {
        return address;
      } else {
        console.warn('AddressViewModel: 未找到默认地址');
        return null;
      }
    } catch (error) {
      console.error('AddressViewModel: 加载默认地址失败:', error);
      return null;
    }
  }
}
