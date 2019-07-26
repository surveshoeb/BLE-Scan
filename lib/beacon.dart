import 'package:flutter_ble/flutter_ble.dart';

class Beacon{
  String address;
  int rssi;
  BluetoothDevice device;
  AdvertisementData advertisementData;
  int timestamp;

  Beacon(this.address, this.rssi, this.device, this.advertisementData, this.timestamp);

  @override
  bool operator ==(Object other) =>
  identical(this, other) ||
  other is Beacon &&
  address == other.address;
}