
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/ScreenNameGenerator.dart';
import 'package:hitstorm/backend/Theme.dart' as bT;
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/InformationView.dart';
import 'package:hitstorm/frontend/views/NewTopicView.dart';
import 'package:hitstorm/frontend/views/SearchView.dart';
import 'package:hitstorm/main.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';


class Overview extends StatefulWidget {
  bT.Theme t;
  Overview({Key key, @required this.t}) : super(key: key);
  Set<Topic> topics = new Set<Topic>();

  @override
  _OverviewState createState() {
    return _OverviewState();
  }
}

class _OverviewState extends State<Overview> {


  Future<bool> getNewTopics(Topic lastTopic)async{

    if(widget.t.type == bT.ThemeTypes.MY_TOPICS){
      List<Topic> topics;
      topics = await DatabaseRequests.getMyTopicsInfoView(widget.topics.length);
      setState(() {
        widget.topics.addAll(topics);
      });
      return !(topics.length < 7);
    }
    if(lastTopic == null){
      widget.topics.clear();
    }
    List<Topic> topics;
    topics = await DatabaseRequests.getHottestTopicsOfTheme(lastTopic, widget.t);
    print(widget.topics.length);

    setState(() {
      widget.topics.addAll(topics);
    });
    return !(topics.length < 10);
  }

  bool firstStart = true;

  String loadingMoreString = "load more";

  void setLoadingMoreString(String s){
    setState(() {
      loadingMoreString = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(firstStart){
          getNewTopics(null);
          DatabaseRequests.retrieveDynamicLink(NavigationService.navigatorKey.currentContext);
          firstStart = false;
        }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white, size: 38,),
        onPressed: (){
          Navigator.push(context, new CupertinoPageRoute(
            builder: (context)=> new NewTopicView(),
          ));
        },
      ),
      appBar: AppBar(
        toolbarHeight: 75,
        leading: widget.t.type != bT.ThemeTypes.OVERALL_TOP ? TextButton.icon(icon: Icon(Icons.arrow_back_ios, size: 30, color: Colors.black54,), onPressed: (){
          Navigator.pop(context);
        },
        label: SizedBox(),
        ):TextButton(
          onPressed: (){
            Navigator.push(context, new CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context)=> new InformationView(),
            ));
          },
          child: Icon(Icons.info_outline, size: 30, color: Colors.black54,),
        ),
        actions: [
          if(widget.t == null || widget.t.type == bT.ThemeTypes.OVERALL_TOP)
          TextButton.icon(
            label: SizedBox(),
              onPressed: (){
                Navigator.push(context, new CupertinoPageRoute(
                  builder: (context)=> new SearchView(),
                ));
              },
            icon: Icon(Icons.search, color: Colors.black54, size: 32,),
              ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
            child: Container(
              color: Colors.green,
              height: 1.5,
            ),
            preferredSize: Size.fromHeight(1.5)),
        title: widget.t == null? Image.asset("images/hitstorm_green.png", height: 30,): Text(widget.t.name,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.black
        ),),
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: ()async{
            loadingMoreString = "load more";
            return await getNewTopics(null);
          },
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          color: Colors.green,
          strokeWidth: 2,
          backgroundColor: Colors.grey.shade100,
          edgeOffset: 10,
          displacement: 30,
          child:  widget.topics.length > 0 ?
            SingleChildScrollView(
              child: LazyLoadScrollView(
                isLoading: true,
                  scrollOffset: 1000, // Pixels from the bottom that should trigger a callback
                  onEndOfPage: () async {
                await getNewTopics(widget.topics.last);
                },
                child: ListView.builder(
                physics:NeverScrollableScrollPhysics(),

                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.topics.length+1,
                itemBuilder: (context, i){
                  if(i == widget.topics.length ){
                    return TextButton(onPressed: ()async{
                      if(loadingMoreString == "loading more..." || loadingMoreString == "no more results"){
                        return null;
                      }
                      setLoadingMoreString("loading more...");
                      if(await getNewTopics(widget.topics.last)){
                        setLoadingMoreString("load more");
                      }else{
                        setLoadingMoreString("no more results");
                      }

                    },
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                          foregroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),

                        ),
                        child: Text(Dictionary.text(loadingMoreString), style: TextStyle(color: Colors.black54),));
                  }
                  return widget.topics.toList()[i].listViewTopic(context, setState);
                },
              ),
          ),
            ) :
          Container(
            child: SingleChildScrollView(
              physics:AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 90.0, bottom: 5000),
                child: Center(
                  child: Text(
                    Dictionary.text("refresh to load")
                        , style: Styles.SmallTextDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}

