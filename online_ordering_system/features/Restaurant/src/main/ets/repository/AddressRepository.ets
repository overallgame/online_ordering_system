import { AddressBook } from '../model/AddressBook';
import { ApiResponse, AddressBookResponse } from '../model/AddressApiModels';
import { AddressConverter } from '../util/AddressConverter';
import { ApiClient, ApiEndpoints } from 'common';

export class AddressRepository {
  private static instance: AddressRepository;
  private apiClient: ApiClient;

  private constructor() {
    this.apiClient = ApiClient.getInstance();
  }

  static getInstance(): AddressRepository {
    if (!AddressRepository.instance) {
      AddressRepository.instance = new AddressRepository();
    }
    return AddressRepository.instance;
  }

  async getDefaultAddress(): Promise<AddressBook | null> {
    try {
      const response = await this.apiClient.get<ApiResponse<AddressBookResponse>>(
        ApiEndpoints.ADDRESS_DEFAULT
      );
      if (response.success && response.data && response.data.data) {
        return AddressConverter.fromApiResponse(response.data.data);
      } else {
        console.error('获取默认地址失败:', response.error);
        return null;
      }
    } catch (error) {
      console.error('获取默认地址异常:', error);
      return null;
    }
  }
}
