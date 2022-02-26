import 'dart:async';


import 'package:hitstorm/backend/Comment.dart';
import 'package:hitstorm/backend/Theme.dart';
import 'package:hitstorm/backend/Topic.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseRequests{
  static Database db;
  static   List<Topic> hottestTopics = [];
  static String pseudonym = "anonym";
  static String username;
  static String password;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static CollectionReference postRef = firestore.collection('Posts');
  static CollectionReference themeRef = firestore.collection('Themes');
  static CollectionReference userRef = firestore.collection('Users');
  static FirebaseAuth auth = FirebaseAuth.instance;
  static Theme theme;
  static String lastLogin;
  static String thisLoginTimeStamp;
  static List<Theme> themes;
  static ProfanityFilter filter;


  static Future<bool> init()async{
   // topicRef = database.reference().child("topics");

   print("initialising");
   filter =  new ProfanityFilter.filterAdditionally(badWords);
    thisLoginTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    db = await openDatabase("hitstorm.db", version: 1,
        onCreate: (Database db, i) async {
          await db.execute(
              'CREATE TABLE MyComments (id TEXT PRIMARY KEY)');
          await db.execute(
              'CREATE TABLE MyTopics (id TEXT PRIMARY KEY)');
          await db.execute(
              'CREATE TABLE Comments (commentId TEXT, postId TEXT, liked BOOLEAN, PRIMARY KEY (commentId, postId))');
          await db.execute(
              'CREATE TABLE Topics (id TEXT PRIMARY KEY, tendency TEXT)');
          await db.execute(
              'CREATE TABLE Variables (name Text PRIMARY KEY, value TEXT)'
          );


        },

);


    if(auth.currentUser != null){
      var sqlResult = await db.rawQuery("SELECT value FROM Variables WHERE name = 'lastLogin'");
      if(sqlResult.length > 0){
        print(sqlResult);
        lastLogin = sqlResult[0].values.first?? 0;
      }
      await db.execute(
          'INSERT OR REPLACE INTO Variables (name, value) VALUES ("lastLogin", $thisLoginTimeStamp)');
      DocumentSnapshot snap = await userRef.doc(auth.currentUser.uid).get();
      Map<String, dynamic> data = snap.data();
      String lastLoginDB = data.remove("lastLogin");
      if(data != null && data.length > 0 && lastLoginDB != lastLogin){
        getHistory();
      }
      userRef.doc(auth.currentUser.uid)
          .update({"lastLogin": thisLoginTimeStamp});

      username = auth.currentUser.displayName ?? "Anonym";
    }else{

    }
    themes = await getHottestThemes("");
  }

  //todo: test!!!!
  static Future<bool> getHistory() async{
    print("getting history");
    DocumentSnapshot snap = await userRef.doc(auth.currentUser.uid)
        .get();
      List<dynamic> posts = snap.get("Posts");
      await db.execute(
          'DELETE from MyTopics');

      await Future.forEach(posts, (element) async {
        await db.execute(
            'insert into MyTopics (id) values (?)', [element]);
      });


    try {
      List<dynamic> comments = snap.get("Comments");
      await db.execute(
          'DELETE from MyComments');
      await Future.forEach(comments, (element) async {
        await db.execute(
            'insert into MyComments (id) values (?)', [element]);
      });
    }on FirebaseException catch(e){

    }

  }


  static Future<String> createAccount(String email, String password1, String username)async{
    try {
      await auth.createUserWithEmailAndPassword(
          email: email,
          password: password1,
      );
      await auth.currentUser.updateDisplayName(username);
      userRef.doc(auth.currentUser.uid)
          .set({"lastLogin": lastLogin, "Posts": [], "Comments": []});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      }else if(e.code == "invalid-email"){
        print(e.code);
        return ('Please enter a valid email');
      }
      return "Error, please try again";
    } catch (e) {
      print(e);
    }
    if (auth.currentUser != null){
      return "";
    }
  }

  static Future<dynamic> logIn(String email, String password1)async{
    if(email == null || email.length < 5){
      return "Please enter a valid email adress";
    }else if(password1 == null || password1.length < 8){

      return "Please enter a valid password";
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password1
      );

      getHistory();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    }on Exception catch(e){
      print(e);
      return "Please try again later";
    }
    return true;
  }


  static Future<void> logOut()async {
    await db.execute("DELETE FROM MyComments;");
    await db.execute("DELETE FROM MyTopics;");
    await db.execute("DELETE FROM Variables");
    await db.execute("DELETE FROM MyComments;");
    await db.execute("DELETE FROM Topics;");

    await auth.signOut();
  }

  static Future<Topic> createTopic(Topic topic)async{
    try {
      await FirebaseFirestore.instance.runTransaction((transaction)async{
        topic.postRef = await postRef.add(
            topic.toMap());
        userRef.doc(auth.currentUser.uid)
        .update({'Posts': FieldValue.arrayUnion([topic.postRef.id])});
      });
    }catch (e) {
      return null;
    }
    db.execute("INSERT INTO MyTopics (id) VALUES (?)", [topic.postRef.id]);
    return topic;
  }


  static Future<bool> createTheme(Theme theme)async{
    try {
      theme.docRef = await themeRef.add(theme.toMap());
    }catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> reportTopic(Topic topic)async{
    await postRef.doc(topic.postRef.id).update({"reportings": FieldValue.increment(1) });
  }


  static Future<bool> commentTopic(Topic topic, Comment comment)async{
    bool success = true;
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async{
       comment.docRef = await topic.postRef.collection("Comments").add(comment.toMap());
       userRef.doc(auth.currentUser.uid)
           .update({'Comments': FieldValue.arrayUnion([comment.post.id])});
     }).onError((error, stackTrace) {
        success = false;
     });
    }catch(e){
      return false;
    }
    return success;
  }

  static Future<bool> increment(Tendency tend, Topic topic, bool positive)async{
    String s;
    bool isSuccessful = true;
    switch(tend){
      case Tendency.UPVOTE:
        s = "upvotes";
        break;
      case Tendency.DOWNVOTE:
        s = "downvotes";
        break;
      case Tendency.NEUTRAL:
        s = "neutrals";
        break;
    }
    if(s != null){
      await postRef.doc(topic.postRef.id).update({s: positive? FieldValue.increment(1):FieldValue.increment(-1) }).onError((error, stackTrace) {
        isSuccessful = false;
      });

    }
    return isSuccessful;

  }

  static Future<List<Topic>> getHottestTopics()async{
    QuerySnapshot querySnapshot = await postRef
    .orderBy("rating")
    .limit(20)
        .get();
    List<Topic> topics = [];


     querySnapshot.docs.forEach((element) {
      Topic t = Topic.fromMap(element.data() as Map<String, dynamic>,element.reference);
      topics.add(t);
    });

    return topics;

    /*
    int i = DatabaseRequests.hottestTopics.length;
    if(i >= hottestTopics.length ){
      Map<String, dynamic> param = {"skip": 0};
     // DataSnapshot snap = await topicRef.orderByChild("upvotes").limitToFirst(getExtension?10: i+10).once();
      List<dynamic> result;
      List<Topic> topics = [];
      result.forEach((entry)async {
        Topic t = await Topic.fromMap(entry, entry.remove("objectId"));
        topics.add(t);
      });
      hottestTopics = topics;
    }
    */

  }



  static Future<List<Topic>> getHottestTopicsOfTheme(Topic lastTopic, Theme theme)async{
    List<Topic> topics = [];
    QuerySnapshot querySnapshot;
    if(lastTopic == null) {
       querySnapshot = await postRef
           .orderBy("rating",descending: true)
           .where("theme", isEqualTo: theme.name)
          .limit(10)
          .get();
    }else{
      querySnapshot = await postRef
          .where("theme", isEqualTo: theme.name)
          .limit(10)
          .startAtDocument(await lastTopic.postRef.get())
          .get();
    }

    querySnapshot.docs.forEach((element) {
      Topic t = Topic.fromMap(element.data() as Map<String, dynamic>,element.reference);
      topics.add(t);
    });
    return topics;

    /*
    int i = DatabaseRequests.hottestTopics.length;
    if(i >= hottestTopics.length ){
      Map<String, dynamic> param = {"skip": 0};
     // DataSnapshot snap = await topicRef.orderByChild("upvotes").limitToFirst(getExtension?10: i+10).once();
      List<dynamic> result;
      List<Topic> topics = [];
      result.forEach((entry)async {
        Topic t = await Topic.fromMap(entry, entry.remove("objectId"));
        topics.add(t);
      });
      hottestTopics = topics;
    }
    */
  }


  static Future<bool> likeComment(Comment comment, bool isPositive)async{
    bool noError = true;
    await comment.docRef.update({"likes": isPositive? FieldValue.increment(1): FieldValue.increment(-1)}).onError((error, stackTrace) {
      noError = false;
    });
    return noError;
  }

  static Future<void> reportComment(Comment c)async{
    await c.docRef.update({"reportings": FieldValue.increment(1) });
  }

  static Future<List<Comment>> getHottestCommentsOfTopic(Topic topic, Comment lastComment)async{
    QuerySnapshot querySnapshot;
    if(lastComment == null){
      querySnapshot = await topic.postRef.collection("Comments").orderBy("likes", descending: true).limitToLast(10)
          .get();
    }else{
       querySnapshot = await topic.postRef.collection("Comments").orderBy("likes", descending: true).limitToLast(10)
          .startAfterDocument(await lastComment.post.get())
          .get();
    }

      List<Comment> comments = [];
    querySnapshot.docs.forEach((entry)async {
          Map element = entry.data();
          Comment c = Comment.fromMap(element, entry.reference, topic.postRef);
          comments.add(c);
        });

    return comments;
  }

  static Future<List<Topic>> getMyTopics(int offset,)async {
    List<Topic> topics = [];

    List<Map<String, dynamic>> results1 = await db.query("MyTopics", limit: 3, offset: offset);
    List<Map<String, dynamic>> results3 = await db.query("Topics", limit: 3, offset: offset);
    List<String> postIDs = [];


    results1.forEach((element) {
      postIDs.add(element.values.first);
    });

    results3.forEach((element) {
      postIDs.add(element.values.first);
    });

    await Future.forEach(postIDs, (element) async {
      DocumentSnapshot snap = await postRef.doc(element).get();
    //  print(snap.data() as Map<String, dynamic>);
      if(snap.data() != null) {
        topics.add(
            Topic.fromMap(snap.data() as Map<String, dynamic>, snap.reference));
      }
    });
    return topics;
    /*
    if(results.length < 10){
      results.addAll(await db.query("Topics", limit: 15-results.length, columns: ["id"] ));
    }
    if(results.length < 10) {
      results.addAll(await db.query("Comments", limit: 15-results.length, columns: ["postId"] ));
    }

     */


    }

    static Future<String> resetPassword(String email)async {
    String feedback = "";
    try {
      await auth.sendPasswordResetEmail(email: email);
    }on FirebaseAuthException catch(e){
      feedback = e.message;
    }on Exception catch (e){
      feedback = "Please try again later";
    }
    return feedback;
    }

    static Future<List<Topic>> getSearchedTopics(String regex)async{
      if(regex.length == 0){
      return await getMyTopics(0);
      }

      List<Topic> topics = [];

      try {
        QuerySnapshot querySnapshot1 = await postRef
          .where('topic', isGreaterThanOrEqualTo: regex)
           .where('topic', isLessThan: regex +'\uf8ff')
         //   .orderBy("rating")
          .limit(5)
          .get();


     Future.forEach(querySnapshot1.docs,(element) {

       Topic t =  Topic.fromMap(element.data() as Map<String, dynamic>,element.reference);
      topics.add(t);
    });
      } on Exception catch (e) {
        print(e);
      }
    QuerySnapshot querySnapshot2 = await postRef
        .where('intro', isGreaterThanOrEqualTo: regex)
        .where('intro', isLessThan: regex +'\uf8ff')
       // .orderBy("rating")
        .limit(5)
        .get();

     Future.forEach(querySnapshot2.docs,(element) {
      Topic t = Topic.fromMap(element.data() as Map<String, dynamic>,element.reference);
      topics.add(t);
    });
    return topics.toSet().toList();
  }


  static Future<bool> deleteUser()async{
    bool success = true;
      userRef.doc(auth.currentUser.uid).delete().onError((error, stackTrace) {
        success = false;
      });
    await DatabaseRequests.auth.currentUser.delete().onError((error, stackTrace) {
      success = false;
    });
    return success;
  }

  static Future<bool> deletePost(Topic topic)async{
    bool success = true;
    FirebaseFirestore.instance.runTransaction((transaction)async{
      await topic.postRef.delete().onError((error, stackTrace) {
        success = false;
      });
      userRef.doc(auth.currentUser.uid)
          .update({'Posts': FieldValue.arrayRemove([topic.postRef])});
    }).onError((error, stackTrace) {
      success = false;
    });

    return success;
  }

  static Future<bool> deleteComment(Comment comment)async{
    bool success = true;
    FirebaseFirestore.instance.runTransaction((transaction) async{
      await comment.docRef.delete();
      userRef.doc(auth.currentUser.uid)
          .update({'Comments': FieldValue.arrayRemove([comment.docRef])});
    }).onError((error, stackTrace) {
      success = false;
    });
    return success;
  }



  static Future<List<Comment>> getCommentsTest(String id)async{
    List<Comment> comments = [];
    for(int x = 0; x < 5; x++){
      comments.add(Comment.testComment());
    }
    return comments;
  }


  static Future<List<Theme>> getHottestThemes(String regex)async{
    QuerySnapshot querySnapshot = await themeRef
        .limit(15)
        .get();
    List<Theme> themes = [];
    themes.add(Theme.topTheme());
    querySnapshot.docs.forEach((element)async {
      Theme t = Theme.fromMap(element.data() as Map<String, dynamic>, element.reference);
      themes.add(t);
    });
    return themes;
  }


  static List<String> badWords = [
    "analritter",
    "arsch",
    "arschficker",
        "arschlecker",
        "arschloch",
        "bimbo",
        "bratze",
        "bumsen",
        "bonze",
        "fick",
        "ficken",
        "flittchen",
        "fotze",
        "fratze",
        "hackfresse",
        "hurensohn",
        "hure",
        "kackbratze",
        "kacke",
        "kacken",
        "kackwurst",
        "kampflesbe",
        "kanake",
        "neger",
        "nigger",
        "nutte",
        "onanieren",
        "penis",
        "pimmel",
        "pissen",
        "pisser",
        "poppen",
        "rosette",
        "schabracke",
        "schlampe",
        "scheiße",
        "scheisser",
        "schiesser",
        "schwanzlutscher",
        "schwuchtel",
        "tittchen",
        "titten",
        "vögeln",
        "vollpfosten",
        "wichse",
        "wichsen",
        "wichser",
  ];
}