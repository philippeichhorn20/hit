import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/Topic.dart';

class Comment{

  String pseudonym;
  String text;
  String date;
  int likes;
  Tendency tendency;
  String id;
  DocumentReference post;

  DocumentReference docRef;
  bool liked = false;
  bool mine;
  bool deleted = false;


  Comment.fromDatabase(this.pseudonym, this.text, this.likes, this.date, String tendency, this.post){
    this.tendency = Topic.toTendency(tendency);
  }

  Comment.newComment(this.text, String tendency, this.pseudonym, this.post){
    this.tendency = Topic.toTendency(tendency);
    this.likes = 0;
    this.date = DateTime.now().toString();
    this.pseudonym = DatabaseRequests.auth.currentUser.displayName;
    this.mine = true;
  }


  Future<void> getIfCommentLiked()async{
    bool liked = false;
    List<Map<String, dynamic>> result = await DatabaseRequests.db.rawQuery("SELECT liked FROM Comments WHERE commentId = ?", [this.docRef.id]);
    if(result.isNotEmpty){
      liked = result.first.values.first == 0 ? false : true;
      print(result.first.values.first);
    }else{
      liked = false;
    }
    this.liked = liked;
  }


  Comment.testComment(){
    this.text = "This is a very long test comment that we are having here";
    this.tendency = Tendency.DOWNVOTE;
    this.date = DateTime.now().toString();
    this.likes = 100;
    this.pseudonym = "IAmABigFatNerd101";
  }


  void report(){
    DatabaseRequests.reportComment(this);
  }

  Map<String, dynamic> toMap(){
    return {
      "text" :text,
      "likes":likes,
      "username": pseudonym,
      "date": date,
      "post": post,
      "tendency" : tendency.toString(),
      "author": DatabaseRequests.auth.currentUser.uid
    };
  }

  static Comment fromMap(Map<dynamic, dynamic> map, DocumentReference documentReference, DocumentReference postRef){
    Comment c = Comment.fromDatabase(map.remove("username"), map.remove("text"), map.remove("likes"), map.remove("date"), map.remove("tendency"), postRef);
    c.docRef = documentReference;
    if(map.remove("author") == DatabaseRequests.auth.currentUser.uid){
      c.mine = true;
    }else{
     c.mine = false;
    }
    c.getIfCommentLiked();
    return c;
  }

  void like(){
    if(liked){
      likes--;

    }else{
      likes++;
    }
    liked = !liked;
    databaseCommentLike(liked);
  }

  void databaseCommentLike(bool isPositive)async{
    if(await DatabaseRequests.likeComment(this, isPositive)){
      if(isPositive){
      DatabaseRequests.db.rawUpdate(
          "INSERT OR REPLACE INTO Comments(commentId, postId, liked) VALUES(?, ?, 1);",
        [this.docRef.id, this.post.id]
      );
    }else{
        DatabaseRequests.db.rawUpdate(
            "INSERT OR REPLACE INTO Comments(commentId, postId, liked) VALUES(?, ?, 0);",
            [this.docRef.id, this.post.id]
        ).onError((error, stackTrace) {
          print("error");
        });
    }
    }
  }


  @override
  bool operator ==(Object other) {
    if(other.runtimeType != Comment){
      return false;
    }else if((other as Comment).docRef == this.docRef){
      return true;
    }
    return false;
  }

  @override
  int get hashCode => this.docRef.hashCode;


  Widget getCommentListTile(BuildContext context, Function dropComment, Function setState, int index){
    if(this.deleted){
      return SizedBox();
    }
    return Column(
      children: [
        Divider(),
        ListTile(
          trailing: TextButton.icon(
              onPressed: () async {
                bool result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(20))),
                        title: this.mine ? Text(Dictionary.text("Delete this Comment?")) : Text(Dictionary.text("Report this Comment")),
                        actions: [
                          TextButton(
                            child: Text(Dictionary.text('Cancel')),
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
                                this.mine? "Delete": "Report",
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                              onPressed: () async {
                                bool success = true;
                                if(this.mine) {
                                  success =
                                  await DatabaseRequests
                                      .deleteComment(this);
                                }else{
                                  await DatabaseRequests
                                      .reportComment(this);
                                }
                                if (success) {
                                  Navigator.pop(context);
                                  dropComment(index);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          )
                        ],
                      );
                    });
                if (result == true && this.mine) {
                  Navigator.pop(context);
                }

              },
              icon: Icon(Icons.more_vert, color: Colors.black26,),
              label: SizedBox()),
          title: Text(this.text,
              maxLines: 5,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              )),

          subtitle: Row(
            children: [
              Text("by ${this.pseudonym}", style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w400,
                fontSize: 11
              ),),
              Expanded(child: SizedBox()),
              TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                  ),
                  onPressed: () {
                    setState(() {
                      this.like();
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        "${this.likes.toString()}  ",
                        style: TextStyle(
                            color: this.liked ? Colors.red : Colors.black54,
                            fontWeight: FontWeight.w700),
                      ),
                      Icon(this.liked ? Icons.favorite: Icons.favorite_border, color: this.liked ? Colors.red: Colors.black54,size: 18,)
                    ],
                  )),
            ],
          ),
        ),
      ],
    );

  }
  //datetime to String

}