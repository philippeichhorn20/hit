import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/Theme.dart' as bT;
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/TopicView.dart';
class TopicLoadView extends StatefulWidget {
  String topicString;

  TopicLoadView({Key key, @required this.topicString}) : super(key: key);


  @override
  _TopicLoadViewState createState() => _TopicLoadViewState();
}

class _TopicLoadViewState extends State<TopicLoadView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: FutureBuilder(
          future: DatabaseRequests.getSingleTopic(widget.topicString),
          builder:  (BuildContext context, AsyncSnapshot<Topic> snapshot) {
            if(snapshot.hasData){
    return TopicView(topic: snapshot.data, themeFrom: bT.Theme.topTheme(),);
    }else if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: Styles.LoadingAnimation,
              );
            }else if(snapshot.hasError || snapshot.data == null){
              return Center(child: Text(Dictionary.text("Sorry, this topic no longer exists")),);
            }else{
              return Styles.LoadingAnimation;

            }
          },
        ),
      ),
    );
  }
}
