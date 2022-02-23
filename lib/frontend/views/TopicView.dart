
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/Comment.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/ThemesView.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class TopicView extends StatefulWidget {
  Topic topic;

  TopicView({Key key, @required this.topic}) : super(key: key);

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
      comments;
    });
  }

  bool commentButtonIsLoading = false;

  bool setCommentButtonLoading(bool enabled){
    setState(() {
      commentButtonIsLoading = enabled;
    });
  }

  void deleteComment(Comment c){
    setState(() {
      comments.remove(c);
    });
  }

   void setMainState(){
    setState(() {

    });
  }

  void showErrorMessage(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        errorMessage,
      ),
      duration: const Duration(milliseconds: 3000),
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0, // Inner padding for SnackBar content.
      ),
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
  }

  Future<bool> addComments(Comment c) async {
    bool successful = true;
    await DatabaseRequests.commentTopic(this.widget.topic, c)
        .onError((error, stackTrace) {
      successful = false;
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
      content: const Text('Do you want to report this Post?'),
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
        body: RefreshIndicator(
          onRefresh: () {
            return getLatestComments(null);
          },
          child: LazyLoadScrollView(
            onEndOfPage: () {
              if(comments.length > 0){
                return getLatestComments(comments.last);
              }else{
                return null;
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .1,
                          child: IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              color: Colors.black54,
                              onPressed: () {
                                Navigator.pop(context,);
                              }),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .65,
                          child: Text(
                            widget.topic.name,
                           // overflow: TextOverflow.ellipsis,
                            style:Styles.TextDark,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                         TextButton.icon(
                                onPressed: () async {
                                  int result = await showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        MediaQuery.of(context).size.width,
                                        10,
                                        10,
                                        10),
                                    items: [
                                      if (!widget.topic.mine)
                                        PopupMenuItem(
                                          value: 1,
                                          child: Text('report'),
                                        ),
                                      if (widget.topic.mine)
                                        PopupMenuItem(
                                          value: 2,
                                          child: Text('delete'),
                                        ),
                                    ],
                                    initialValue: 0,
                                  );
                                  if (result == 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        ReportSnackBar(widget.topic));
                                  } else if (result == 2) {
                                    bool result = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            title: Text("Delete this Post?"),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
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
                                                    "Delete",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: () async {
                                                    bool success =
                                                    await DatabaseRequests
                                                        .deletePost(
                                                        widget.topic);
                                                    if (success) {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ThemesView()));
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
                                  }
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(Icons.more_vert),
                                label: SizedBox()),

                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      child: Text(
                        widget.topic.intro ?? "",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ),
                  Divider(),
                  VotingBoard(topic: widget.topic),
                  Container(
                    padding: EdgeInsets.only(left:15, right: 15),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(
                        " ${widget.topic.theme} · "
                        "${Styles.dateAsString(widget.topic.date)} ago",
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 12,
                      ),),),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: commentController,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                        child: TextButton.icon(
                            onPressed: () async {
                              setCommentButtonLoading(true);
                              if (profanityCheck()) {
                                showProfanitySnackbar("Profane language has been detected");
                                setCommentButtonLoading(false);
                                return false;
                              }
                              if (commentController.text.isNotEmpty) {
                                Comment c = Comment.newComment(
                                    commentController.text,
                                    widget.topic.tendency.toString(),
                                    DatabaseRequests.pseudonym,
                                    widget.topic.postRef);
                                if (await addComments(c)) {
                                  showErrorMessage("added your comment");
                                }else{
                                  showProfanitySnackbar("There has been an error, please try again later");
                                }
                              }
                              await Future.delayed(Duration(seconds: 1));
                              setCommentButtonLoading(false);
                            },
                            icon:  commentButtonIsLoading ? Expanded(child: Styles.LoadingAnimation): Icon(Icons.send),
                            label:SizedBox()),
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
                        return CommentView(comment: c);
                      },
                    ),
                  )
                ],
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
      content: Text(s),
      backgroundColor: Colors.red,
    ));
  }
}

class CommentView extends StatefulWidget {
  Comment comment;

  CommentView({Key key, @required this.comment}) : super(key: key);

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  bool expanded = false;

  void dropComment(){
    setState(() {
      widget.comment.deleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Comment c = widget.comment;

    if(c.deleted){
      return SizedBox();
    }
    return Column(
      children: [
        Divider(),
        ListTile(
          trailing: SizedBox(
            width: MediaQuery.of(context).size.width * .15,
            child: TextButton.icon(
                onPressed: () async {
                  int result = await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.5, 0, 0),
                    items: [
                      if (!c.mine)
                        PopupMenuItem(
                          value: 1,
                          child: Text('report'),
                        ),
                      if (c.mine)
                        PopupMenuItem(
                          value: 2,
                          child: Text('delete'),
                        ),
                    ],
                    initialValue: 0,
                  );
                  if (result == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        ReportSnackBar(c));
                  } else if (result == 2) {
                    bool result = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20))),
                            title: Text("Delete this Comment?"),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
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
                                    "Delete",
                                    style: TextStyle(
                                        color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    bool success =
                                    await DatabaseRequests
                                        .deleteComment(c);
                                    if (success) {
                                      Navigator.pop(context);
                                      dropComment();
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
                  }
                },
                icon: Icon(Icons.more_vert),
                label: SizedBox()),
          ),
          title: Text(c.text,
              maxLines: expanded ? null : 5,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              )),

          subtitle: Row(
            children: [
              Text("by ${c.pseudonym}"),
              Expanded(child: SizedBox()),
              TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent),
                  ),
                  onPressed: () {
                    setState(() {
                      c.like();
                    });
                  },
                  child: Text(
                    "${c.likes.toString()} 🔥",
                    style: TextStyle(
                        color: c.liked ? Colors.red : Colors.blueGrey,
                        fontWeight: FontWeight.w700),
                  )),
            ],
          ),
        ),
      ],
    );

  }
  Widget ReportSnackBar(Comment comment) {
    return SnackBar(
      content: const Text('Do you want to report this Post?'),
      action: SnackBarAction(
        label: 'Report',
        onPressed: () {
          comment.report();
        },
      ),
    );
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
        Divider(),
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
              if (widget.topic.tendency.index != 4) {
                setState(() {
                  widget.topic.vote(tendency);
                });
              } else {
                return null;
              }
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

/* FutureBuilder(
                    future: getLatestComments(),
                    builder: (context, AsyncSnapshot<List<Comment>> snapshot){
                      if(snapshot.connectionState != ConnectionState.done){
                        return CircularProgressIndicator();
                      }
                      if(snapshot.hasData && snapshot.data.length > 0){
                        return RefreshIndicator(
                          onRefresh: (){
                            return getLatestComments();
                          },
                          triggerMode: RefreshIndicatorTriggerMode.anywhere,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, i){
                              Comment c = snapshot.data[i];
                              return CommentView(comment: c);
                            },
                          ),
                        );
                      }
                      return TextButton(child: Text("no comments yet"),
                      onPressed: (){
                        return getLatestComments();
                      },);
                    })

 */
