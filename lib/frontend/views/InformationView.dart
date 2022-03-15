
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/SignUpView.dart';
import 'package:hitstorm/frontend/Styles.dart';

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

  bool deleteButtonIsLoading = false;

  bool setDeleteButtonLoading(bool enabled){
    setState(() {
      deleteButtonIsLoading = enabled;
    });
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
              fontSize: 30
          ),),
          foregroundColor: Colors.black45,
        ),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.deny("\t"),
                    FilteringTextInputFormatter.deny(" "),
                  ],
                  controller: usernameControl,
                  onSubmitted: (s){
                    DatabaseRequests.auth.currentUser.updateDisplayName(s);
                  },
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 25
                  ),
                  decoration: InputDecoration(
                      border: Styles.defaultTextInputBorder,
                      helperText: "enter to confirm changes",
                      hintText: 'username'),
                ),
              ),
              ExpansionPanelList(
                children: [
                  ExpansionPanel (
                    canTapOnHeader: false,
                    headerBuilder: (c, boolX){
                      return TextButton(
                          onPressed: (){
                            DatabaseRequests.getMyTopics(0);
                            setState(() {
                              isExpanded1 = !isExpanded1;
                            });
                          },
                          child: Text(Dictionary.text("Who we are"), style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 20
                          ),));
                    },
                    isExpanded: isExpanded1,
                    body: ListTile(

                      title:
                      const Text('To delete this panel, tap the trash can icon', style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38,
                          fontWeight: FontWeight.w700
                      )),
                    ),
                  ),
                  ExpansionPanel (
                    canTapOnHeader: false,
                    headerBuilder: (c, boolX){
                      return TextButton(
                          onPressed: (){
                            setState(() {
                              isExpanded2 = !isExpanded2;
                            });
                          },
                          child: Text(Dictionary.text("Imprint"), style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 20
                          ),));
                    },
                    isExpanded: isExpanded2,
                    body: ListTile(
                      title:
                       Text(Dictionary.text('To delete this panel, tap the trash can icon'), style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38,
                          fontWeight: FontWeight.w700
                      )),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Dictionary.text("Imprint"), style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                    ),
                  ),
                  onPressed: (){
                    return null;
                  },
                ),
              ),
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
              Container(
                alignment: Alignment.centerLeft,
                child: TextButton(

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Dictionary.text("Delete my Account"),
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
                        title: Text(Dictionary.text("Do you want to delete this account?")),
                        content: Text(errorMessage),
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
                              if(success){
                                Navigator.pushAndRemoveUntil(context, new CupertinoPageRoute(
                                  builder: (context)=> new SignUpView(),
                                ), (Route<dynamic> route) => false,);
                              }
                              setDeleteButtonLoading(false);
                            },

                          )
                        ],
                      );
                    });

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
