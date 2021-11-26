class Reader {
  late String serialNumber;
  late String deviceName;

  Reader.fromJson(Map<String, String> data) {
    this.serialNumber = data['serialNumber']!;
    this.deviceName = data['deviceName']!;
  }
}