@Component
export struct InfoItem {
  @Prop label: string = '';
  @Prop value: string = '';
  onChange?: ((value: string) => void )| null |undefined;
  @Prop isEditing: boolean = false;
  readonly :boolean=false;

  build() {
    Row() {
      // 左侧标签
      Text(this.label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)
        .textAlign(TextAlign.Start)

      // 右侧内容区（根据编辑状态切换）
      if (this.isEditing&&!this.readonly  && this.onChange) {
        TextInput({
          placeholder: `请输入${this.label}`,text:this.value=="未设置"? "" : this.value
        })
          .onChange(this.onChange)
          .fontSize(16)
          .fontColor('#000000')
          .backgroundColor('#F8F8F8')
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .layoutWeight(1)
      } else {
        Text(this.value)
          .fontSize(16)
          .fontColor('#000000')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .margin({right:20})
      }
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 16 })
  }
}