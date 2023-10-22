import 'dart:typed_data';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
class Advertisement {
  static Future<void> advert(Uint8List data) async {
    final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
    print(data);
    int counter = data[2];
    if (counter <= 25) {
      final advertiseSettings = AdvertiseSettings(
          advertiseMode: AdvertiseMode.advertiseModeLowLatency,
          txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
      //payload is all but first byte of data
      List<int> payload = [];
      for (int i = 2; i < data.length; i++) {
        payload.add(data[i]);
      }
      Uint8List payl = Uint8List.fromList(payload);
      payload[0] = counter + 1;
      final AdvertiseData advertiseData = AdvertiseData(
        serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
        manufacturerId: 1,
        manufacturerData: payl,
      );
      print(payload);
      await blePeripheral.start(
          advertiseData: advertiseData, advertiseSettings: advertiseSettings);
      await Future.delayed(Duration(seconds: 2)).then((value) =>
          blePeripheral.stop());
    }
  }

 static List<int> CreatePayload(Map<String, dynamic>userData, int counter, int code,
      int check) {
    List<int> send = [];
    send.add(counter);
    if (check == 0) {
      send.add(check);
      send.add(code);
      String t = userData['phone'].toString();
      for (int i = 0; i < 10; i += 2) {
        int f = int.parse(t.substring(i, i + 2));
        send.add(f);
      }
    }
    else {
      int latn = 0,
          longn = 0;
      if (userData['latitude'] < 0) latn = 1;
      if (userData['longitude'] < 0) longn = 1;
      print('hiiiiiiiiiiiiiiiiiiiiiii');
      send.add(check);
      String k = latn.toString() + longn.toString();
      send.add(int.parse(k));
      String f = userData['latitude'].toString();
      int i = 0;
      while (f[i] != '.') {
        i++;
      }
      i++;
      send.add(int.parse(f.substring(0, i - 1)));
      int j = i,
          cnt = 0;
      print(f);
      if (f.length - i < 4) {
        while (f.length - i != 4) {
          f += '0';
        }
      }
      while ((j - i) < 4 && j < f.length) {
        send.add(int.parse(f.substring(j, j + 2)));
        j += 2;
        cnt++;
      }
      if (cnt != 2) {
        while (cnt != 2) {
          send.add(0);
          cnt++;
        }
      }
      f = userData['longitude'].toString();
      i = 0;
      while (f[i] != '.') {
        i++;
      }
      i++;
      send.add(int.parse(f.substring(0, i - 1)));
      print(f);
      if (f.length - i < 4) {
        while (f.length - i != 4) {
          f += '0';
        }
      }
      j = i;
      cnt = 0;
      while ((j - i) < 4 && j < f.length) {
        send.add(int.parse(f.substring(j, j + 2)));
        j += 2;
        cnt++;
      }
      if (cnt != 2) {
        while (cnt != 2) {
          send.add(0);
          cnt++;
        }
      }
    }
    print(send);
    return send;
  }

  static Future<void> advertise(send) async {
    final FlutterBlePeripheral bleP = FlutterBlePeripheral();
    final advertiseSettings = AdvertiseSettings(
        advertiseMode: AdvertiseMode.advertiseModeLowLatency,
        txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
    Uint8List payload = send;
    print(payload);
    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
      manufacturerId: 1,
      manufacturerData: payload,
    );
    try {
      await bleP.start(
          advertiseData: advertiseData, advertiseSettings: advertiseSettings);
    }
    catch (e) {
      print(e);
    }
  }
}