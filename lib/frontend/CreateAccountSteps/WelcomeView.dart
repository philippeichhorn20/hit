import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/ScreenNameGenerator.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/Overview.dart';
import 'package:hitstorm/backend/Theme.dart' as bT;


class WelcomeView extends StatefulWidget {
  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {

  bool buttonIsLoading = false;

  bool setButtonLoading(bool enabled){
    setState(() {
      buttonIsLoading = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height*0.05,
              left: MediaQuery.of(context).size.width*(1-0.6) /2,
              child: Container(
                child: Center(
                  child: SizedBox(
                      height: 200,
                      child: Image.asset("images/hitstorm_green.png", width: MediaQuery.of(context).size.width*0.6)
                  ),
                ),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height*0.7,
                left:  MediaQuery.of(context).size.width*(1-0.9) /2,
                child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                onPressed: (){
                  DatabaseRequests.goToLegals();
                },
                child: Container(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(Dictionary.text("By clicking 'I Agree' you agree with our Terms and Conditions. Click here to see them."),style: TextStyle(color: Colors.black45),),
                )),

                style: ElevatedButton.styleFrom(
                  primary: Colors.black12,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // <-- Radius
                  ),
                ),
              )
            )),
            Positioned(
              top: MediaQuery.of(context).size.height*0.8,
              child: Padding(
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
                      dynamic loginResponse = await DatabaseRequests.logInAnonymously();
                      await DatabaseRequests.auth.currentUser.updateDisplayName(ScreenNameGenerator.generateUsername());
                      if(loginResponse == true){
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (_) => Overview(t: bT.Theme.topTheme())));
                      }
                      setButtonLoading(false);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),)
                    ),
                    child: buttonIsLoading ? Styles.LoadingAnimation: Text(
                      Dictionary.text('I Agree'),
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
