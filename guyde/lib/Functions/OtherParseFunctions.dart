import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/Classes/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'HelperCloudFuctions.dart';

class OtherParseFunctions{



  static Future<bool> follow(String otherUserId)async{
    final ParseCloudFunction function = ParseCloudFunction('follow');
    final ParseResponse parseResponse = await function.execute(parameters: {
      "id":otherUserId,
    });
    if (parseResponse.success) {
      print("success");
      //  institution.id = parseResponse.result;
    }else{
      print(parseResponse.error?.message);
    }

    return parseResponse.success;

  }


  static Future<List<User>> getFriends()async{
    final ParseCloudFunction function = ParseCloudFunction('getFriends');
    final ParseResponse parseResponse = await function.execute();
    print(parseResponse.result.toString());
    return HelperCloudFunctions.resultsToUser(parseResponse);
  }

  static Future<List<User>> getFriendsOfFriends()async{
    print("hello");
    final ParseCloudFunction function = ParseCloudFunction('getFriendsOfFriends');
    final ParseResponse parseResponse = await function.execute();
    print(parseResponse.result.toString());
    return HelperCloudFunctions.resultsToUser(parseResponse);
  }


  static Future<List<User>> getListOfPeople()async{

    final ParseCloudFunction function = ParseCloudFunction('getPeople');
    final ParseResponse parseResponse = await function.execute();

    List<User> userList = [];



    parseResponse.result.forEach((element) {

      userList.add(User.fromMap(element));

    });
    return userList;

  }

  static  Future<List<Institution>> getSpotsOfFriendsReviews()async{

    final ParseCloudFunction function = ParseCloudFunction('getSpotsOfFriendsReviews');
    final ParseResponse parseResponse = await function.execute();
    print("reviews");
    print(parseResponse.result);
    List<Institution> list = [];
    (parseResponse.result as List<dynamic>).forEach((element) {
      print(element);
      list.add(Institution.fromMap((element as Map<String,dynamic>).remove("place_id")));
    });
    return list;

  }

  static  Future<List<Institution>> getAllSpotsNearMe(double lat, double lang, double radius)async{

    final ParseCloudFunction function = ParseCloudFunction('getAllSpotsNearMe');
    final ParseResponse parseResponse = await function.execute(parameters: {
      "lat":lat,
      "lang":lang,
      "radius":radius,
    });
    print("fr");
    print(parseResponse.result);
    print(parseResponse.results);

    List<Institution> list = [];
    (parseResponse.result as List<dynamic>).forEach((element) {
      print(element);
      list.add(Institution.fromMap(element));
    });
    return list;

  }




}