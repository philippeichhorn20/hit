
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Theme.dart' as bT;
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/NewTopicView.dart';
import 'package:hitstorm/frontend/views/SearchView.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';


class Overview extends StatefulWidget {
  bT.Theme t;
  Overview({Key key, @required this.t}) : super(key: key);
  Set<Topic> topics = new Set<Topic>();


  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {

  Future<void> getNewTopics(Topic lastTopic)async{
    if(lastTopic == null){
      widget.topics.clear();
    }
    List<Topic> topics;
    topics = await DatabaseRequests.getHottestTopicsOfTheme(lastTopic, widget.t);
    setState(() {
      widget.topics.addAll(topics);
    });
  }

  bool firstStart = true;

  @override
  Widget build(BuildContext context) {

    if(firstStart){
      getNewTopics(null);
      firstStart = false;
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        child: Text("🕵️", style: TextStyle(
          fontSize: 30
        ),),
        onPressed: (){
          Navigator.push(context, new CupertinoPageRoute(
            builder: (context)=> new NewTopicView(),
          ));
        },
      ),
      appBar: AppBar(
        actions: [
          TextButton.icon(
            label: SizedBox(),
              onPressed: (){
                Navigator.push(context, new CupertinoPageRoute(
                  builder: (context)=> new SearchView(),
                ));
              },
              icon: Text("🔎", style: TextStyle(
                fontSize: 30,
              ),),
              ),
        ],
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text(widget.t.name+ " " +widget.t.emoji,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.black
        ),),

      ),
      body: RefreshIndicator(
        onRefresh: ()async{
          return await getNewTopics(null);
        },
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        color: Colors.orange,
        strokeWidth: 5,
        backgroundColor: Colors.blue,
        displacement: 30,
        child:  widget.topics.length > 0 ?
          LazyLoadScrollView(
            isLoading: true,
            onEndOfPage: () async {
            await getNewTopics(widget.topics.last);
            },
            child: ListView.builder(
            physics:AlwaysScrollableScrollPhysics(),

            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.topics.length,
            itemBuilder: (context, i){
              return widget.topics.toList()[i].listViewTopic(context, setState);
            },
          ),
        ) :
        SingleChildScrollView(
          physics:AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 90.0, bottom: 5000),
            child: Center(
              child: Text(
                "No Posts available"
                    , style: Styles.SmallTextDark,
              ),
            ),
          ),
        ),


      )
    );
  }
}

