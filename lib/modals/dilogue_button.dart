class DilogueButton {
  String name;
  Function func;
  bool isDestructive;
  bool isDefault;

  DilogueButton({
    this.name = 'Ok',
    this.func = no,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

no() {}
