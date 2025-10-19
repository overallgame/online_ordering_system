/**
 * API响应基础类
 */
export class ApiResponse<T> {
  code: number = 0;
  msg: string | null = null;
  data: T | null = null;

  constructor(data?: Partial<ApiResponse<T>>) {
    if (data) {
      this.code = data.code ?? this.code;
      this.msg = data.msg ?? this.msg;
      this.data = data.data ?? this.data
    }
  }

  /**
   * 判断请求是否成功
   */
  isSuccess(): boolean {
    return this.code === 1;
  }

  /**
   * 获取错误信息
   */
  getErrorMessage(): string {
    return this.msg || '请求失败';
  }
}

/**
 * 地址API响应数据
 */
export class AddressBookResponse {
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

  constructor(data?: Partial<AddressBookResponse>) {
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
}
