import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/NewTopicView.dart';
import 'package:hitstorm/frontend/views/SearchView.dart';

class Top25View extends StatefulWidget {
  @override
  _Top25ViewState createState() => _Top25ViewState();
}

class _Top25ViewState extends State<Top25View> {
  List<Topic> topicSet = [];


  @override
  Widget build(BuildContext context) {


    return Container(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton.icon(
              label: SizedBox(),
              onPressed: (){
                Navigator.push(context, new CupertinoPageRoute(
                  builder: (context)=> new SearchView(),
                ));
              },
              icon: Icon(Icons.search, color: Colors.white, size: 32,),
            ),
          ],
          title: Text("Top 20", style: Styles.SmallText),
          backgroundColor: Colors.green,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(Icons.add, color: Colors.white, size: 38,),
          onPressed: (){
            Navigator.push(context, new CupertinoPageRoute(
              builder: (context)=> new NewTopicView(),
            ));
          },
        ),
        body: RefreshIndicator(
          color: Colors.orange,
          strokeWidth: 5,
          backgroundColor: Colors.blue,
          displacement: 30,
          onRefresh: ()async{
            topicSet = await DatabaseRequests.getHottestTopics();
            setState(() {
              topicSet = topicSet.toSet().toList();
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: ListView.builder(itemBuilder: (context, index){
              return Container(child: Column(
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text("\t\t\t #${index+1}", style: Styles.SmallerTextGrey,)),
                  Divider(),
                  topicSet.toList()[index].listViewTopic(context, setState)
                ],
              ),);
            },

            itemCount: topicSet.length,
            ),
          ),
        ),
      ),
    );
  }
}
