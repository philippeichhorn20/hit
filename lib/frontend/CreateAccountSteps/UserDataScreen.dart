import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/ThemesView.dart';

class UserDataScreen extends StatefulWidget {
  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool hasAcceptedTerms = false;
  bool passwordValid = false;
  bool buttonIsLoading = false;

  bool setButtonLoading(bool enabled){
    setState(() {
      buttonIsLoading = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: formkey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            leading: TextButton.icon(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back_ios, color: Colors.black54,), label: SizedBox()),
          ),
          body: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height*0.05,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20, bottom: 20, top: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: TextFormField(
                      onChanged: (s){
                        setState(() {
                          usernameController;
                        });
                      },
                      autocorrect: false,
                      controller: usernameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny("\t"),
                        FilteringTextInputFormatter.deny(" "),
                      ],
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2.0),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.black26,
                                width: 0.5),
                          ),

                          hintText: 'username',
                          hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                      ),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey
                      ),
                    ),
                  ),
                ),
              ),Positioned(

                top: MediaQuery.of(context).size.height*0.2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20, bottom: 20, top: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: TextFormField(
                      onChanged: (s){
                        setState(() {
                          emailController;
                        });
                      },
                      autocorrect: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: emailController,
                      validator: (s){return mailIsValid(s);},

                      inputFormatters: [
                        FilteringTextInputFormatter.deny("\t"),
                        FilteringTextInputFormatter.deny(" "),
                      ],
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2.0),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.black26,
                                width: 0.5),
                          ),

                          hintText: 'email',
                          hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                      ),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height*0.35,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20, bottom: 20, top: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: TextFormField(
                      onChanged: (s){
                        setState(() {
                          passwordController;
                        });
                      },
                      autocorrect: false,
                      controller: passwordController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 1,
                      validator: (s){return passwordIsValid(s);},
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny("\t"),
                        FilteringTextInputFormatter.deny(" "),
                      ],
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2.0),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.black26,
                                width: 0.5),
                          ),
                          hintText: 'password',
                          hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                      ),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height*0.55,
                  child: Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        Text("I accept the terms of service", style: TextStyle(color: Colors.black54, fontSize: 18, ),),
                        Switch(value: hasAcceptedTerms, onChanged: (bool){
                          setState(() {
                            hasAcceptedTerms = bool;
                          });
                        })
                      ],
                    ),
                  )),
              Positioned(
                top: MediaQuery.of(context).size.height *0.75,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: passwordValid && hasAcceptedTerms ? Colors.orange:Colors.black26, borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () async{
                        if(buttonIsLoading){
                          return null;
                        }
                        setButtonLoading(true);
                        if(!passwordValid || !hasAcceptedTerms){
                          return null;
                        }else{
                          String response = await DatabaseRequests.createAccount(emailController.text, passwordController.text, usernameController.text);
                          if(response == "" || response == null){
                            Navigator.push(
                                context, MaterialPageRoute(builder: (_) => ThemesView()));
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(response, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                              duration: const Duration(milliseconds: 3000),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, // Inner padding for SnackBar content.
                                vertical: 30
                              ),
                              backgroundColor: Colors.green,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),));
                          }
                        }
                        setButtonLoading(false);
                      },
                      child: buttonIsLoading ? Styles.LoadingAnimation: Text(
                        'Get Started',
                        style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
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
  
  
  static String mailIsValid(String email){
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(!emailValid){
    return "Please enter a valid email";
    }
  }
  
   String passwordIsValid(String password){
    String answer;
    if(password.length < 8){
      passwordValid = false;
      answer = "Password must have at least 8 Characters";
    }else if(!password.contains(RegExp("[0-9]"))){
      passwordValid = false;
      answer = "Password must have at least one Number";
    }else if(!password.contains(RegExp("[a-zA-Z]"))){
      passwordValid = false;
      answer = "Password must have at least one Character";
    }else{
      passwordValid = true;
    }
      passwordValid = passwordValid;
    return answer;
  }
}
