
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Operations.dart';
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/TopicView.dart';
import 'package:hitstorm/main.dart';


class NewTopicView extends StatefulWidget {
  @override
  _NewTopicViewState createState() => _NewTopicViewState();
}

class _NewTopicViewState extends State<NewTopicView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController introController = TextEditingController();
  TextEditingController instaController = TextEditingController();
  TextEditingController twitterController = TextEditingController();

  int themeIndex;
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
        appBar: AppBar(
          title: Text( "Add a new topic", style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w700,
            fontSize: 25
          ),),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 25,
            color: Colors.black45,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [

                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, left:20, top: 20),
                    child: SizedBox(
                      child: TextFormField(
                        onChanged: (s){
                          setState(() {
                            nameController;
                          });
                        },
                        controller: nameController,
                        maxLines: 1,
                        maxLength: 50,
                        decoration: InputDecoration(

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7)),
                              borderSide: BorderSide(
                                  color: Colors.orange,
                                  width: 2.0),
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7)),
                              borderSide: BorderSide(
                                  color: Colors.black26,
                                  width: 0.5),
                            ),
                            hintText: 'Topic',
                            hintStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,)
                        ),
                        style: Styles.SmallTextDark,
                      ),
                    ),
                  ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0, left: 20, bottom: 10, top: 20),
                child: TextFormField(
                  onChanged: (s){
                    setState(() {
                      introController;
                    });
                  },
                  controller: introController,
                  maxLines: null,
                  maxLength: 400,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,

                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0),
              ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        borderSide: BorderSide(
                            color: Colors.black26,
                            width: 0.5),
                      ),

                      hintMaxLines: 3,
                      hintText: 'Give a short intro. \n\nDo not target people.',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                  ),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey
                  ),
                ),
              ),
              Wrap(
                children: [...generateChips()],
              ),
              SizedBox(height:40),

              TextButton(onPressed: ()async{
                if(buttonIsLoading){
                  return null;
                }
                setButtonLoading(true);
                if(profanityCheck()){
                  showProfanitySnackbar("Profane language has been detected");
                  setButtonLoading(false);
                  return true;
                }
                if(introController.text.isNotEmpty && nameController.text.isNotEmpty &&  themeIndex != null){
                  Topic t;
                  setState(() {
                    t = Operations.newTopic(nameController.text, introController.text, DatabaseRequests.themes[themeIndex].name);
                  });
                  t = await DatabaseRequests.createTopic(t);
                  if(t == null){
                    showProfanitySnackbar("Unsuccessful");
                  }
                  showNewPostSnapbar(t);
                  Navigator.pop(context);
                  setButtonLoading(false);
                }else{
                  setButtonLoading(false);
                  return null;
                }
              },
                  style: ElevatedButton.styleFrom(
                    primary: introController.text.isNotEmpty && nameController.text.isNotEmpty && themeIndex != null? Colors.orange: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      side:BorderSide(
                        color: Colors.transparent,

                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text("share",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w700
                      ),),
                  )),


            ],
          ),
        ),
      ),
    );
  }


  generateChips(){
    List<Widget> chips = [];
    for(int x = 1; x < DatabaseRequests.themes.length; x++){
      chips.add(_buildThemeChip(x));
    }
    return chips;
  }

  Widget _buildThemeChip(int index){
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ChoiceChip(
        label: Text(DatabaseRequests.themes[index].name),
        avatar: Text(DatabaseRequests.themes[index].emoji),
        selected: themeIndex == index,
        selectedColor: Colors.red,
        onSelected: (bool selected) {
            setState(() {
              themeIndex = selected ? index : null;
            });
        },
        backgroundColor: Colors.black26,
        labelStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }


  bool profanityCheck(){

    String badString = introController.text + " " + nameController.text;
    return DatabaseRequests.filter.hasProfanity(badString);
  }

  void showProfanitySnackbar(String s){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s),
      backgroundColor: Colors.red,));
  }

  void showNewPostSnapbar(Topic topic){
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext).showSnackBar(SnackBar(content: Text("Check out the new Post"),
      action: SnackBarAction(label: "open",
          textColor: Colors.white,
          onPressed: (){
        Navigator.push(NavigationService.navigatorKey.currentContext, new CupertinoPageRoute(
          builder: (context)=> new TopicView(topic: topic),
        ));
      }),
      backgroundColor: Colors.green,));
  }
}
