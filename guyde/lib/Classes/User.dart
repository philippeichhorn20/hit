

import 'package:flutter/material.dart';
import 'package:guyde/Classes/Settings.dart';
import 'package:guyde/Functions/OtherParseFunctions.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class User{

  String name = "";
  ParseUser parseUser = ParseUser.forQuery(); // todo: feels fishiy
  bool isFollowing = false;
  bool amFollowing = false;
  int connectionDistance = 3;
  String id = "YMzUDiaY9r";
  bool isMe = false;

  User.test(){
    name = "PhilippEichhorn";

  }

  void switchAmFollowing (){
    amFollowing = !amFollowing;
  }

  User.fromMap(Map<String,dynamic> map){
    name = map.remove("username");
    id = map.remove("objectId");
    if(Settings.thisUser != null && id == Settings.thisUser!.objectId){
      isMe = true;
    }
  }

  @override
  bool operator ==(Object other) {
    if(other.runtimeType == runtimeType){
      print("true");
      return id == (other as User).id;
    }
    print("false");
    return false;
  }


  @override
  int get hashCode => id.hashCode;


  @override
  String toString() {
    // TODO: implement toString
    return "This users username is $name and the id is $id";
  }


  Widget toListTile(BuildContext context, Function setState){
    return Container(
      decoration:  BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)
          )
      ),
      child: ListTile(
        title:  Text(name, style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20
        ),),
        trailing: IconButton(onPressed: (){
          //todo database
          OtherParseFunctions.follow(id);
          setState(() {
            switchAmFollowing();
          });
        }, icon: amFollowing ? Icon(Icons.person, color: Colors.black12, size: 30,):
        Icon(Icons.person_add, color: Colors.black,size: 30,) ),
      ),
    );
  }



}