import 'package:geolocator/geolocator.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Settings{

  static ParseUser? thisUser;
  static Position? position;

  void setUser(ParseUser user){
    thisUser = user;
  }
}