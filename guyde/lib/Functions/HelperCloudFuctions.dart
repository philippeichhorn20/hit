



 import 'package:guyde/Classes/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class HelperCloudFunctions{

static List<User> resultsToUser(ParseResponse parseResponse){
  List<User> users = [];
  if (parseResponse.success) {
    List<dynamic> maps = parseResponse.result;
    maps.forEach((element) {
      if(element != null) {
        Map<String,dynamic>? userMap = element.remove("following_id");
        if(userMap == null){
          print("connection doesnt supply user");
        }else{
          users.add(User.fromMap(userMap));
        }
      }
    });
    }else{
 print(parseResponse.error?.message);
 }
 return users.toSet().toList();
}

}