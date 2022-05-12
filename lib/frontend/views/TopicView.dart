
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/Comment.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/Theme.dart' as bT;
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/Overview.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

class TopicView extends StatefulWidget {
  Topic topic;
  bT.Theme themeFrom;

  TopicView({Key key, @required this.topic, @required this.themeFrom}) : super(key: key);

  @override
  _TopicViewState createState() => _TopicViewState();
}

class _TopicViewState extends State<TopicView> {
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];

  Future<void> getLatestComments(Comment lastComment) async {
    comments.addAll(await DatabaseRequests.getHottestCommentsOfTopic(
        widget.topic, lastComment));
    setState(() {
      comments = comments;
    });
  }

  bool commentButtonIsLoading = false;

  bool setCommentButtonLoading(bool enabled){
    setState(() {
      commentButtonIsLoading = enabled;
    });
  }


  Future<bool> updateTopic()async{
    Topic t = await DatabaseRequests.getSingleTopic(widget.topic.postRef.id);
    setState(() {
      widget.topic = t;
    });
  }

  void dropComment(int x){
    setState(() {
      comments.elementAt(x).deleted = true;
    });
  }

   void setMainState(){
    setState(() {

    });
  }

  void showErrorMessage(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: SizedBox(
        height: 50,
        child: Text(
          Dictionary.text(errorMessage),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20
          ),
        ),
      ),
      duration: const Duration(milliseconds: 3000),
      padding: const EdgeInsets.symmetric(
        horizontal: 50.0, // Inner padding for SnackBar content.
      ),
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
  }

  Future<bool> addComments(Comment c) async {
    bool successful = true;
    successful = await DatabaseRequests.commentTopic(this.widget.topic, c)
        .onError((error, stackTrace) {
      return successful;
    });
    if (successful) {
      setState(() {
        comments.insert(0, c);
      });
      commentController.clear();
      return true;
    } else {
      return false;
    }
  }

  Widget ReportSnackBar(Topic topic) {
    return SnackBar(
      content:  Text(Dictionary.text('Do you want to report this Post?')),
      action: SnackBarAction(
        label: 'Report',
        onPressed: () {
          topic.report();
        },
      ),
    );
  }





  bool firstStart = true;

  @override
  Widget build(BuildContext context) {
    if (firstStart) {
      getLatestComments(null);
      firstStart = false;
    }

    return Container(
      child: Scaffold(
        body: LazyLoadScrollView(
          onEndOfPage: () {
            if(comments.length > 0){
              return getLatestComments(comments.last);
            }else{
              return null;
            }
          },
          child: RefreshIndicator(
            onRefresh: () async{
              await updateTopic ();
            },
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            color: Colors.green,
            strokeWidth: 2,
            backgroundColor: Colors.grey.shade100,
            edgeOffset: 10,
            displacement: 30,
            child: Container(
              height: MediaQuery.of(context).size.height,

              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back_ios, size: 30, color: Colors.black54,),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .70,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Text(
                                widget.topic.name,
                               // overflow: TextOverflow.ellipsis,
                                style:Styles.TextDark,
                              ),
                            ),
                          ),

                          Expanded(child: SizedBox()),
                           TextButton.icon(
                                  onPressed: () async {
                                      bool result = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(20))),
                                              title: Text(widget.topic.mine? Dictionary.text("Delete this Post?"): Dictionary.text("Report this Post?")),
                                              actions: [
                                                TextButton(
                                                  child:  Text(Dictionary.text('Cancel')),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                        backgroundColor:
                                                        Colors.red),
                                                    child: Text(
                                                      Dictionary.text(widget.topic.mine?"Delete": "Report"),
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    onPressed: () async {
                                                      bool success;
                                                      if(widget.topic.mine){
                                                        success =
                                                        await DatabaseRequests
                                                            .deletePost(
                                                            widget.topic);
                                                      }else{
                                                        success =
                                                        await DatabaseRequests
                                                            .reportTopic(
                                                            widget.topic);
                                                      }
                                                      if (success && widget.topic.mine) {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    Overview(t: bT.Theme.topTheme())),
                                                              (Route<dynamic> route) => false,);
                                                      } else {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                )
                                              ],
                                            );
                                          });
                                      if (result == true) {
                                        Navigator.pop(context);
                                      }
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: Icon(Icons.more_vert, color: Colors.black26,),
                                  label: SizedBox()),

                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        child: Text(
                          widget.topic.intro ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54),
                        ),
                      ),
                    ),
                    VotingBoard(topic: widget.topic),
                    Container(
                      padding: EdgeInsets.only(left:15, right: 15),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Text(
                          " ${widget.topic.theme} · "
                          "${Styles.dateAsString(widget.topic.date)}",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                        ),),),
                    Container(
                      child: OutlinedButton(
                        autofocus: false,
                        style: ElevatedButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(width: 3),
                              borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width *.8,
                          child: Center(
                            child: Text(Dictionary.text("share"), style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                              fontSize: 17
                            ),),
                          ),
                        ),
                        onPressed: ()async{
                          Share.share((await DatabaseRequests.createDynamicLink(widget.topic.postRef.id)).toString());
                        },
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: commentController,
                              cursorColor: Colors.black87,
                              decoration: InputDecoration(
                                focusColor: Colors.transparent,
                                focusedBorder: InputBorder.none,
                                hintText: "Comments"
                              ),
                            ),
                          ),
                        ),

                        Container(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: TextButton.icon(

                                onPressed: () async {
                                  setCommentButtonLoading(true);
                                  if (profanityCheck()) {
                                    showProfanitySnackbar(Dictionary.text("Profane language has been detected"));
                                    setCommentButtonLoading(false);
                                    return false;
                                  }
                                  if (commentController.text.isNotEmpty) {
                                    Comment c = Comment.newComment(
                                        commentController.text,
                                        widget.topic.tendency.toString(),
                                        DatabaseRequests.auth.currentUser.displayName,
                                        widget.topic.postRef);
                                    if (await addComments(c)) {
                                    }else{
                                      showProfanitySnackbar(Dictionary.text("There has been an error, please try again later"));
                                    }
                                  }
                                  setCommentButtonLoading(false);
                                },
                                style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
                                icon:  commentButtonIsLoading ? Expanded(child: Container(child: Styles.LoadingAnimation)): Icon(Icons.send,color: Colors.grey,),
                                label:SizedBox()),
                          ),
                        )
                      ],
                    ),
                    RefreshIndicator(
                      onRefresh: () {
                        return getLatestComments(null);
                      },
                      triggerMode: RefreshIndicatorTriggerMode.anywhere,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, i) {
                          Comment c = comments[i];
                          if(c.deleted){
                            return SizedBox();
                          }
                          return c.getCommentListTile(context, dropComment, setState, i);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool profanityCheck() {
    String badString = commentController.text;
    return DatabaseRequests.filter.hasProfanity(badString);
  }

  void showProfanitySnackbar(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(Dictionary.text(s)),
      backgroundColor: Colors.red,
    ));
  }
}



class VotingBoard extends StatefulWidget {
  Topic topic;

  VotingBoard({Key key, @required this.topic}) : super(key: key);

  @override
  _VotingBoardState createState() => _VotingBoardState();
}

class _VotingBoardState extends State<VotingBoard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              tendencyButton(Tendency.UPVOTE, widget.topic.getUpvotes(), Icons.arrow_upward_rounded,
                  Colors.green),
              tendencyButton(Tendency.NEUTRAL, widget.topic.getNeutrals(),
                  Icons.do_not_disturb_on, Colors.amberAccent),
              tendencyButton(Tendency.DOWNVOTE, widget.topic.getDownvotes(),
                  Icons.arrow_downward_rounded, Colors.red),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Container(
                height: 10,
                color: Colors.green,
                width: ((MediaQuery.of(context).size.width - 30) *
                    (widget.topic.votesTotal() == 0
                        ? 1
                        : widget.topic.getUpvote()) /
                    widget.topic.votesTotal()),
              ),
              Container(
                height: 10,
                color: Colors.amberAccent,
                width: ((MediaQuery.of(context).size.width - 30) *
                    (widget.topic.votesTotal() == 0
                        ? 1
                        : widget.topic.getNeutral()) /
                    widget.topic.votesTotal()),
              ),
              Container(
                height: 10,
                color: Colors.red,
                width: ((MediaQuery.of(context).size.width - 30) *
                    (widget.topic.votesTotal() == 0
                        ? 1
                        : widget.topic.getDownvote()) /
                    widget.topic.votesTotal()),
              ),
            ],
          ),
        ),
        Text("${widget.topic.getUpvotes()} upvotes · ${widget.topic.getNeutrals()} neutrals · ${widget.topic.getDownvote()} downvotes",
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),),
        SizedBox(height: 10,)
      ],
    );
  }

  Widget tendencyButton(
      Tendency tendency, String votes, IconData icon, Color color) {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
                setState(() {
                  widget.topic.vote(tendency);
                });
                return null;
            },
            style: ElevatedButton.styleFrom(
              elevation: 2,
              primary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                side: BorderSide(
                  width: widget.topic.tendency == tendency ? 4 : 1,
                  style: BorderStyle.solid,
                  color:
                      widget.topic.tendency == tendency ? color : Colors.grey,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Icon(icon, size: 35, color: Colors.black54,)
                ],
              ),
            ),
          ),
        ));
  }
}

