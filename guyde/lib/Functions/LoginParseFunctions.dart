import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class LoginParseFunctions{


  static Future<bool> signUp(String username, String email, String password)async{
    ParseUser user = ParseUser.createUser(username.trim(),password.trim(),email.trim());
    var response = await user.signUp();
    if (response.success) user = response.result;
    return response.success;
  }


  static Future<bool> logIn( String username, String password)async{
    final user = ParseUser(username, password, null);

    var response = await user.login();

    return response.success;
  }
}