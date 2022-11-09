import 'package:flutter/material.dart';
import 'package:guyde/LoginPage/LoginPage.dart';
import 'package:guyde/LoginPage/SignUpPage.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
            ),
            Row(
              children: [

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(

                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                            ),
                        ),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 * 0.8,
                      height: 40,
                      child:  const Center(
                        child: Text("Sign Up", style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.black
                        ),),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white, width: 2))),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 * 0.8,
                      height: 40,
                      child:  const Center(
                        child: Text("Login", style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          color: Colors.white
                        ),),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
