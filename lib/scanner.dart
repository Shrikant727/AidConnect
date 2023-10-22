import 'dart:typed_data';
import 'package:flutter/material.dart';

int getphone(Uint8List data){
  String t="";
  for(int i=5;i<data.length;i++){
    t+=data[i].toString();
  }
  return int.parse(t);
}
int gettype(Uint8List data){
  return data[4];
}
double getlat(Uint8List data){
  int flag=data[4];
  String lat=data[5].toString();
  lat+='.';
  int i=6;
  while(i!=8){
    if(data[i]==0)lat+='00';
    else if(data[i]<10)lat+='0'+data[i].toString();
    else lat+=data[i].toString();
    i++;
  }
  if(flag>=10)lat='-'+lat;
  return double.parse(lat);
}
double getlon(Uint8List data){
  int flag=data[4];
  String lon=data[8].toString();
  lon+='.';
  int i=9;
  while(i!=11){
    if(data[i]==0)lon+='00';
    else if(data[i]<10)lon+='0'+data[i].toString();
    else lon+=data[i].toString();
    i++;
  }
  if(flag==1||flag==11)lon='-'+lon;
  return double.parse(lon);
}