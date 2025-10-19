export class ApiResponseT<T> {
  code: number = 0;
  msg: string | null = null;
  data: T | null = null;

  constructor(data?: Partial<ApiResponseT<T>>) {
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
