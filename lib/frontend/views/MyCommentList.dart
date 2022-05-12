import 'package:flutter/material.dart';
import 'package:hitstorm/backend/Comment.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MyCommentList extends StatefulWidget {
  @override
  _MyCommentListState createState() => _MyCommentListState();
}

class _MyCommentListState extends State<MyCommentList> {


  String loadingMoreString = "load more";

  void setLoadingMoreString(String s){
    setState(() {
      loadingMoreString = s;
    });
  }

  Set<Comment> comments = new Set<Comment>();

  Future<bool> getNewComments(bool reload)async{
    if(reload){
      comments.clear();
    }
    List<Comment> commentsLocal;
    commentsLocal = await DatabaseRequests.getMyCommentsInfoView(comments.length);

    setState(() {
      comments.addAll(commentsLocal);
    });
    return !(commentsLocal.length < 10);
  }

  void dropComment(int index){
    setState(() {
      comments.elementAt(index).deleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(Dictionary.text("My Comments"),
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Colors.black
            ),),
          bottom: PreferredSize(
              child: Container(
                color: Colors.green,
                height: 1.5,
              ),
              preferredSize: Size.fromHeight(1.5)),
        ),
        body: Container(
          child: RefreshIndicator(
            onRefresh: ()async{
              loadingMoreString = "load more";
              return await getNewComments(true);
            },
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            color: Colors.green,
            strokeWidth: 2,
            backgroundColor: Colors.grey.shade100,
            edgeOffset: 10,
            displacement: 30,
            child:  comments.length > 0 ?
            SingleChildScrollView(
              child: LazyLoadScrollView(
                isLoading: true,
                scrollOffset: 1000, // Pixels from the bottom that should trigger a callback
                onEndOfPage: () async {
                  await getNewComments(false);
                },
                child: ListView.builder(
                  physics:NeverScrollableScrollPhysics(),

                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: comments.length+1,
                  itemBuilder: (context, i){
                    if(i == comments.length ){
                      return TextButton(onPressed: ()async{
                        if(loadingMoreString == "loading more..." || loadingMoreString == "no more results"){
                          return null;
                        }
                        setLoadingMoreString("loading more...");
                        if(await getNewComments(false)){
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
                    return comments.toList()[i].getCommentListTile(context, dropComment,  setState, i);
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
        ),
      ),
    );
  }
}
