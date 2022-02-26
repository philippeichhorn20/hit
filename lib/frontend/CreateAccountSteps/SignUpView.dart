

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/UserDataScreen.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/ThemesView.dart';

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController passwordControl = TextEditingController();
  TextEditingController usernameControl = TextEditingController();
  TextEditingController verifyEmailControl = TextEditingController();


  String loginResponse = "";
  String resetResponse = "";
  bool buttonIsLoading = false;

  bool setButtonLoading(bool enabled){
    setState(() {
      buttonIsLoading = enabled;
    });
  }

  void resetTheResponse(String s){
    setState(() {
      resetResponse = s;
    });
  }



  bool resetButtonIsLoading = false;

  bool resetButtonLoading(bool enabled){
    setState(() {
      resetButtonIsLoading = enabled;
    });
  }
  void updateLoginResponse(String s){
    setState(() {
      loginResponse = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
                height: 200,
                child: Image.asset("images/hitstorm_green.png", width: MediaQuery.of(context).size.width*0.6)),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: usernameControl,

                decoration: InputDecoration(
                    border: Styles.defaultTextInputBorder,
                    labelText: 'Email',
                    hintText: 'Enter valid email'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, bottom: 20, top: 20),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(

                obscureText: true,
                controller: passwordControl,
                decoration: InputDecoration(
                    border: Styles.defaultTextInputBorder,
                    labelText: 'Password',
                    hintText: 'Enter your password'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(loginResponse, style: Styles.SmallerTextGrey,textAlign: TextAlign.center,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20, top: 50),
              child: Container(
                width: MediaQuery.of(context).size.width *0.9,
                height: 50,   decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(500))),
                child: ElevatedButton(
                  onPressed: () async{
                    if(buttonIsLoading){
                      return null;
                    }
                    setButtonLoading(true);
                    dynamic loginResponse = await DatabaseRequests.logIn(usernameControl.text, passwordControl.text);
                    if(loginResponse == true){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => ThemesView()));
                    }else{
                      updateLoginResponse(loginResponse);
                    }
                    setButtonLoading(false);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),)
                  ),
                  child: buttonIsLoading ? Styles.LoadingAnimation: Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
            TextButton(
                onPressed: (){
                  resetTheResponse("");
                  showDialog(context: context, builder: (context){
                    return StatefulBuilder(builder: (context, setState){
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        title: Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          child: TextField(
                            controller: usernameControl,
                            decoration: InputDecoration(
                                border: Styles.defaultTextInputBorder,
                                labelText: 'Email',
                                hintText: 'Enter valid email'),
                          ),
                        ),
                        content: Text(resetResponse == "" ? "We will send you an email to reset the password":resetResponse, style: Styles.SmallerTextGrey,),
                        actions: [
                          if(!buttonIsLoading)
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          TextButton(
                            style: TextButton.styleFrom(

                                backgroundColor: Colors.red
                            ),
                            child: resetButtonIsLoading? Styles.LoadingAnimation : Text(Dictionary.text("Reset"), style: TextStyle(color: Colors.white),),
                            onPressed: ()async{
                              if(resetButtonIsLoading){
                                return null;
                              }
                              resetButtonLoading(true);

                              String response = await DatabaseRequests.resetPassword(usernameControl.text);
                              print(response);
                              setState((){
                                resetTheResponse(response);
                              });
                              if(response == ""){
                                Navigator.pop(context);
                              }

                              resetButtonLoading(false);
                            },

                          )
                        ],
                      );
                    });
                  });
                },

                child: Text('Reset Password')),
            TextButton(
                onPressed: (){
                  Navigator.push(context, new CupertinoPageRoute(
                    builder: (context)=> new UserDataScreen(),
                  ));
                },

                child: Text('New User? Create Account'))
          ],
        ),
      ),
    );
  }
}