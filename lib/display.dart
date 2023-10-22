import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geodesy/geodesy.dart';
import 'package:latlong2/latlong.dart';

import 'mapscreen.dart';


class Display extends StatelessWidget {
  final Map<String,dynamic> data;
  final double yourLatitude;
  final double yourLongitude;
  Display({Key? key, required this.data, required this.yourLatitude, required this.yourLongitude}) : super(key: key);
  late AssetsAudioPlayer player = AssetsAudioPlayer.newPlayer();
  @override
  Widget build(BuildContext context) {
    final LatLng myLocation = LatLng(data['latitude'], data['longitude']);
    final LatLng otherLocation = LatLng(yourLatitude, yourLongitude);
    final Geodesy geodesy = Geodesy();
    num distance = geodesy.distanceBetweenTwoGeoPoints(myLocation, otherLocation);
    distance = double.parse(distance.toStringAsFixed(2));
    print('codeddddddddddddddddddddddddd');
    print(data['code']);
    Map<int,String> m={0:'police',1:'medical'};
    playaud();
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency occurred'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Expanded(
          child: Column(
            children: [
              Center(
                  child:Text(
                  "Emergency ${m[data['code']]} assistance required by:\n ${data['phone']}",
                  )
              ),
              ElevatedButton(style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),onPressed: stopaud, child: Text('Stop Ringing')),
      Container(
          child:
            MapScreen(firstlat: yourLatitude, firstlong: yourLongitude, secondlat: data['latitude'], secondlong: data['longitude']),
      ),
              //green colored box with text distance and make it rounded
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Distance: $distance meters",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> playaud() async {
    player.open(
      Audio("assets/audio/emergency.mp3"),
      autoStart: true,
    );
  }
  Future<void> stopaud() async {
    player.stop();
  }
}




