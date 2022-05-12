
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:hitstorm/backend/Theme.dart' as bT;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/ScreenNameGenerator.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/SignUpView.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/WelcomeView.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/MyCommentList.dart';
import 'package:hitstorm/frontend/views/Overview.dart';

class InformationView extends StatefulWidget {
  @override
  _InformationViewState createState() => _InformationViewState();
}

class _InformationViewState extends State<InformationView> {
  bool isExpanded1 = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;
  bool isExpanded4 = false;
  bool isExpanded5 = false;
  String errorMessage = "";
  TextEditingController usernameControl = TextEditingController(text: DatabaseRequests.auth.currentUser.displayName);

  TextEditingController feedbackControl = TextEditingController();

  bool screenNameIsUpdating = false;

  bool deleteButtonIsLoading = false;

  String screenNameErrorText = "Enter to save changes";

  bool setDeleteButtonLoading(bool enabled){
    setState(() {
      deleteButtonIsLoading = enabled;
    });
  }

  bool feedbackSent = false;

  bool setFeedBackSent(bool b){
    setState(() {
      feedbackSent = b;
    });
  }

  bool setScreennameErrorText(String b){
    setState(() {
      screenNameErrorText = b;
    });
  }

  String username = DatabaseRequests.auth.currentUser.displayName;

  Widget screenNameUpdateResponse = Icon(Icons.rotate_left, color: Colors.red,);

  Future<bool> randomizeUsername()async {
    screenNameIsUpdating = true;
    String newName = ScreenNameGenerator.generateUsername();
    setState(() {
      username = newName;
      screenNameUpdateResponse = SizedBox(child: Styles.LoadingAnimation, height: 20, width: 20,);
    });

    try{
      await DatabaseRequests.auth.currentUser.updateDisplayName(newName).timeout(Duration(seconds: 1));
    }catch(e){
    }


    screenNameIsUpdating = false;
    setState(() {
      username = DatabaseRequests.auth.currentUser.displayName;
      if(DatabaseRequests.auth.currentUser.displayName == newName){
        screenNameUpdateResponse = Icon(Icons.check, color: Colors.green,);
      }else{
        screenNameUpdateResponse = Icon(Icons.warning, color: Colors.red,);

      }
      return false;
    });
    return  DatabaseRequests.auth.currentUser.displayName == newName;
  }



  Future<bool> updateScreenName(String s)async{
    screenNameIsUpdating = true;
    bool success = true;
    await DatabaseRequests.auth.currentUser.updateDisplayName(s);
    screenNameIsUpdating = false;
    return DatabaseRequests.auth.currentUser.displayName == s;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          leading: TextButton.icon(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey,), label: SizedBox()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(Dictionary.text("Information"), style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 25,
          ),),
          foregroundColor: Colors.black45,
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if(false)
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      border: Border.all(color: Colors.blueAccent, width: 3)

          ),
                    child: ListTile(
                      subtitle: Text("Username", style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11
                      ),),
                      title: Text(username, style: TextStyle(
                        color: Colors.black54,
                        fontSize: 25,
                        fontWeight: FontWeight.w600
                      ),),
                      trailing: TextButton.icon(onPressed: (){
                         randomizeUsername();
                      }, icon: screenNameUpdateResponse,
                        label: SizedBox(),
                      ),

                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny("\t"),
                      FilteringTextInputFormatter.deny(" "),
                    ],

                    controller: usernameControl,
                    onSubmitted: (s)async{
                      setScreennameErrorText("Loading...");

                      if(await updateScreenName(s)){
                        setScreennameErrorText("Your screenname has successfully been updated!");
                      }else{
                        setScreennameErrorText("Error, please try again!");
                      }
                    },
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 25
                    ),
                    decoration: InputDecoration(
                      errorText: screenNameErrorText,
                        errorBorder: Styles.defaultTextInputBorder,
                        errorStyle: TextStyle(
                          color: Colors.black
                        ),
                        border: Styles.defaultTextInputBorder,
                        helperText: "enter to confirm changes",
                        hintText: 'username'),
                  ),
                ),

                SizedBox(height: 40,),
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Dictionary.text("Legal"), style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      ),
                    ),
                    onPressed: (){
                      DatabaseRequests.goToLegals();
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Dictionary.text("Licenses"), style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      ),
                    ),
                    onPressed: (){
                      return showLicensePage(context: context, applicationIcon: SizedBox(), applicationName: "hitstorm", applicationVersion: "1.0");
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Dictionary.text("My Topics"), style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      ),
                    ),
                    onPressed: (){
                      Navigator.push(context, new CupertinoPageRoute(
                        builder: (context)=> new Overview(t: bT.Theme.myTopicsTheme()),
                      ));
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Dictionary.text("My Comments"), style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      ),
                    ),
                    onPressed: (){
                      Navigator.push(context, new CupertinoPageRoute(
                        builder: (context)=> new MyCommentList(),
                      ));
                    },
                  ),
                ),



                /*
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Dictionary.text("Log Out"), style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      ),
                    ),
                    onPressed: ()async{
                      setDeleteButtonLoading(true);
                      await DatabaseRequests.logOut();
                        Navigator.pushAndRemoveUntil(
                            context, MaterialPageRoute(builder: (_) => SignUpView()), (Route<dynamic> route) => false,);
                        setDeleteButtonLoading(false);
                    },
                  ),
                ),
                */

                Container(
                  alignment: Alignment.centerLeft,
                  child: TextButton(

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Dictionary.text("Delete Account"),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      ),
                    ),
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          title: Text(Dictionary.text("Do you want to delete your account?")),
                          contentTextStyle: TextStyle(
                            color: Colors.black54
                          ),
                          content: Text(errorMessage == ""? Dictionary.text("Your Comments and Posts need to be deleted seperately and before this step in order to remove all your personal data from the platform"):errorMessage),
                          actions: [
                            if(!deleteButtonIsLoading)
                              TextButton(
                              child:  Text(Dictionary.text('Cancel')),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(

                                backgroundColor: Colors.red
                              ),
                              child: deleteButtonIsLoading? Styles.LoadingAnimation : Text(Dictionary.text("Delete"), style: TextStyle(color: Colors.white),),
                              onPressed: ()async{
                                if(deleteButtonIsLoading){
                                  return null;
                                }
                                setDeleteButtonLoading(true);

                                bool success = await DatabaseRequests.deleteUser();
                                setDeleteButtonLoading(false);
                              },

                            ),
                          ],
                        );
                      });

                    },
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(
                        Radius.circular(20.0) //                 <--- border radius here
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          controller: feedbackControl,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600
                          ),
                          maxLines: null,

                          decoration: InputDecoration(
                              hintMaxLines: 3,
                              hintText: Dictionary.text(!feedbackSent ? "Give us your feedback here!": "We received your text!"),
                              hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width *0.6,
                        height: 33,
                        child: TextButton(
                          child: Text(!feedbackSent ? "Send": "Thank You", style: TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500
                          ),),
                          onPressed: (){
                            if(feedbackControl.text == null || feedbackControl.text.isEmpty|| feedbackSent){

                            }else{
                              DatabaseRequests.sendFeedback(feedbackControl.text);
                              feedbackControl.clear();
                              setFeedBackSent(true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
