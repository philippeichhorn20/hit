import 'package:guyde/Classes/Settings.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginParseFunctions{


  static Future<bool> signUp(String username, String email, String password)async{
    ParseUser user = ParseUser.createUser(username.trim(),password.trim(),email.trim());
    var response = await user.signUp();
    if (response.success) user = response.result;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    await prefs.setString("password", password);
    return response.success;
  }


  static Future<bool> logIn( String username, String password)async{
    final user = ParseUser(username, password, null);

    var response = await user.login();
    if(response.success){
      Settings.thisUser = user;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("username", username);
      await prefs.setString("password", password);
    }

    return response.success;
  }
}