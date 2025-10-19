import { AddressBook } from '../model/AddressBook';
import { AddressBookResponse } from '../model/AddressApiModels';

/**
 * 地址数据转换器
 */
export class AddressConverter {
  
  /**
   * 将API响应数据转换为AddressBook模型
   * @param response API响应数据
   * @returns AddressBook模型
   */
  static fromApiResponse(response: AddressBookResponse): AddressBook {
    const addressBook = new AddressBook();
    addressBook.id = response.id;
    addressBook.userId = response.userId;
    addressBook.consignee = response.consignee;
    addressBook.phone = response.phone;
    addressBook.sex = response.sex;
    addressBook.provinceCode = response.provinceCode;
    addressBook.provinceName = response.provinceName;
    addressBook.cityCode = response.cityCode;
    addressBook.cityName = response.cityName;
    addressBook.districtCode = response.districtCode;
    addressBook.districtName = response.districtName;
    addressBook.detail = response.detail;
    addressBook.label = response.label;
    addressBook.isDefault = response.isDefault;
    return addressBook;
  }

  /**
   * 验证地址数据是否有效
   * @param addressBook 地址数据
   * @returns 是否有效
   */
  static validateAddress(addressBook: AddressBook): boolean {
    return !!(
      addressBook.consignee &&
      addressBook.phone &&
      addressBook.provinceName &&
      addressBook.cityName &&
      addressBook.districtName &&
      addressBook.detail
    );
  }

  /**
   * 格式化地址显示
   * @param addressBook 地址数据
   * @returns 格式化后的地址字符串
   */
  static formatAddressDisplay(addressBook: AddressBook): string {
    if (!AddressConverter.validateAddress(addressBook)) {
      return '请设置收货地址';
    }
    
    return `${addressBook.provinceName}${addressBook.cityName}${addressBook.districtName}${addressBook.detail}`;
  }

  /**
   * 格式化联系人显示
   * @param addressBook 地址数据
   * @returns 格式化后的联系人字符串
   */
  static formatContactDisplay(addressBook: AddressBook): string {
    if (!addressBook.consignee) {
      return '用户';
    }
    
    return `${addressBook.consignee} ${addressBook.phone || ''}`.trim();
  }
}
