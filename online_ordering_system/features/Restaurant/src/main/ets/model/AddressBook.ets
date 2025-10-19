/**
 * 地址信息模型
 */
export class AddressBook {
  id: number = 0;
  userId: number = 0;
  consignee: string = '';
  phone: string = '';
  sex: string = '';
  provinceCode: string = '';
  provinceName: string = '';
  cityCode: string = '';
  cityName: string = '';
  districtCode: string = '';
  districtName: string = '';
  detail: string = '';
  label: string = '';
  isDefault: number = 0;

  constructor(data?: Partial<AddressBook>) {
    if (data) {
      this.id = data.id ?? this.id;
      this.userId = data.userId ?? this.userId;
      this.consignee = data.consignee ?? this.consignee;
      this.phone = data.phone ?? this.phone;
      this.sex = data.sex ?? this.sex;
      this.provinceCode = data.provinceCode ?? this.provinceCode;
      this.provinceName = data.provinceName ?? this.provinceName;
      this.cityCode = data.cityCode ?? this.cityCode;
      this.cityName = data.cityName ?? this.cityName;
      this.districtCode = data.districtCode ?? this.districtCode;
      this.districtName = data.districtName ?? this.districtName;
      this.detail = data.detail ?? this.detail;
      this.label = data.label ?? this.label;
      this.isDefault = data.isDefault ?? this.isDefault;
    }
  }

  /**
   * 获取完整地址字符串
   */
  getFullAddress(): string {
    return `${this.provinceName}${this.cityName}${this.districtName}${this.detail}`;
  }

  /**
   * 获取联系人信息
   */
  getContactInfo(): string {
    return `${this.consignee} ${this.phone}`;
  }

  /**
   * 是否为默认地址
   */
  isDefaultAddress(): boolean {
    return this.isDefault === 1;
  }
}
