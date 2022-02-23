import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
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
    this.pseudonym = DatabaseRequests.username?? "anonym";
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
        print("liked");
      DatabaseRequests.db.rawUpdate(
          "INSERT OR REPLACE INTO Comments(commentId, postId, liked) VALUES(?, ?, 1);",
        [this.docRef.id, this.post.id]
      );
    }else{
        print("unliked");
        DatabaseRequests.db.rawUpdate(
            "INSERT OR REPLACE INTO Comments(commentId, postId, liked) VALUES(?, ?, 0);",
            [this.docRef.id, this.post.id]
        ).onError((error, stackTrace) {
          print("error");
        });
    }
    }
  }

  //datetime to String

}