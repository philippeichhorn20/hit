import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:hitstorm/backend/Comment.dart';
import 'package:hitstorm/backend/Theme.dart';
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/WelcomeView.dart';
import 'package:hitstorm/frontend/TopicLoadView.dart';
import 'package:hitstorm/frontend/views/TopicView.dart';
import 'package:hitstorm/main.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DatabaseRequests {
  static Database db;
  static List<Topic> hottestTopics = [];
  static String pseudonym = "anonym";
  static String username;
  static String password;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static CollectionReference postRef = firestore.collection('Posts');
  static CollectionReference themeRef = firestore.collection('Themes');
  static CollectionReference userRef = firestore.collection('Users');
  static CollectionReference feedbackRef = firestore.collection('Feedback');
  static FirebaseAuth auth = FirebaseAuth.instance;
  static Theme theme;
  static String lastLogin;
  static String thisLoginTimeStamp;
  static List<Theme> themes;
  static ProfanityFilter filter;
  static bool databaseInitSuccessful = false;
  static FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  static String legalsLink =
      "https://docs.google.com/document/d/e/2PACX-1vRro4b3TF65zzSW6NC7dyIjmDNZ2T7mOTunS9-Pjv5PG1SC6XtkQ3bEtPs3s9Y4yFMbJIqRubu2qgcp/pub";

  static Future<bool> init() async {
    if (auth.currentUser != null && auth.currentUser.email != null) {
      await auth.signOut();
    }

    filter = new ProfanityFilter.filterAdditionally(badWords);
    db = await openDatabase(
      "hitstorm.db",
      version: 1,
      onCreate: (Database db, i) async {
        await db.execute('CREATE TABLE MyComments (id TEXT PRIMARY KEY)');
        await db.execute(
            'CREATE TABLE MyTopics (id TEXT PRIMARY KEY, time TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
        await db.execute(
            'CREATE TABLE Comments (commentId TEXT, postId TEXT, liked BOOLEAN, PRIMARY KEY (commentId, postId))');
        await db.execute(
            'CREATE TABLE Topics (id TEXT PRIMARY KEY, tendency TEXT, time TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
        await db.execute(
            'CREATE TABLE Variables (name Text PRIMARY KEY, value TEXT)');
        await deleteUser();
      },
    );
    themes = await getHottestThemes("");

    dynamicLinks.onLink(onSuccess: (dynamicLinkData) {
      print("link found");
      Navigator.of(NavigationService.navigatorKey.currentContext).push(CupertinoPageRoute(
          builder: (context) => TopicLoadView(topicString: dynamicLinkData.link.queryParameters['id'])));
      return null;
    });
    auth
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        Navigator.of(NavigationService.navigatorKey.currentContext).push(CupertinoPageRoute(
            builder: (context) => WelcomeView()));
      }
    });

  }

  static Future<bool> initWithDB() async {
    bool success = true;
    thisLoginTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    if (auth.currentUser != null) {
      var sqlResult = await db
          .rawQuery("SELECT value FROM Variables WHERE name = 'lastLogin'");
      if (sqlResult.length > 0) {
        lastLogin = sqlResult[0].values.first ?? 0;
      }
      await db.execute(
          'INSERT OR REPLACE INTO Variables (name, value) VALUES ("lastLogin", $thisLoginTimeStamp)');
      DocumentSnapshot snap = await userRef.doc(auth.currentUser.uid).get();
      if (!snap.exists) {
        success = false;
      }
      Map<String, dynamic> data = snap.data();
      if (data == null) {
        userRef
            .doc(auth.currentUser.uid)
            .set({"lastLogin": lastLogin, "Posts": [], "Comments": []});
      }
      String lastLoginDB = data.remove("lastLogin");
      if (data != null && data.length > 0 && lastLoginDB != lastLogin) {
        if (!await getHistory()) {
          success = false;
        }
      }
      userRef.doc(auth.currentUser.uid).update(
          {"lastLogin": thisLoginTimeStamp}).onError((error, stackTrace) {
        success = false;
      });

      username = auth.currentUser.displayName ?? "Anonym";
    } else {}
    return success;
  }

  //todo: test!!!!
  static Future<bool> getHistory() async {
    bool success = true;
    DocumentSnapshot snap = await userRef.doc(auth.currentUser.uid).get();
    if (!snap.exists) {
      success = false;
    }
    List<dynamic> posts = snap.get("Posts");
    await db.execute('DELETE from MyTopics');

    await Future.forEach(posts, (element) async {
      await db.execute('insert into MyTopics (id) values (?)', [element]);
    });
    try {
      List<dynamic> comments = snap.get("Comments");
      await db.execute('DELETE from MyComments');
      await Future.forEach(comments, (element) async {
        await db.execute('insert into MyComments (id) values (?)', [element]);
      });
    } on FirebaseException catch (e) {
      success = false;
    }
    return success;
  }

  static Future<String> createAccount(
      String email, String password1, String username) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password1,
      );
      await auth.currentUser.updateDisplayName(username);
      userRef
          .doc(auth.currentUser.uid)
          .set({"lastLogin": lastLogin, "Posts": [], "Comments": []});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      } else if (e.code == "invalid-email") {
        print(e.code);
        return ('Please enter a valid email');
      }
      return "Error, please try again";
    } catch (e) {
      print(e);
    }
    if (auth.currentUser != null) {
      return "";
    }
  }

  static Future<dynamic> logInAnonymously() async {
    try {
      await auth.signInAnonymously();
      await userRef
          .doc(auth.currentUser.uid)
          .set({"lastLogin": lastLogin, "Posts": [], "Comments": []});
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    } on Exception catch (e) {
      print(e);
      return "Please try again later";
    }
    return true;
  }

  static Future<dynamic> logIn(String email, String password1) async {
    if (email == null || email.length < 5) {
      return "Please enter a valid email adress";
    } else if (password1 == null || password1.length < 8) {
      return "Please enter a valid password";
    }
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password1);

      getHistory();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    } on Exception catch (e) {
      print(e);
      return "Please try again later";
    }
    return true;
  }

  static Future<void> logOut() async {
    await db.execute("DELETE FROM MyComments");
    await db.execute("DELETE FROM MyTopics");
    await db.execute("DELETE FROM Variables");
    await db.execute("DELETE FROM Comments");
    await db.execute("DELETE FROM Topics");
    await auth.signOut();
  }

  static Future<Topic> createTopic(Topic topic) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        topic.postRef = await postRef.add(topic.toMap());
        userRef.doc(auth.currentUser.uid).update({
          'Posts': FieldValue.arrayUnion([topic.postRef.id])
        });
      });
    } catch (e) {
      return null;
    }
    db.execute("INSERT INTO MyTopics (id) VALUES (?)", [topic.postRef.id]);
    return topic;
  }

  static Future<bool> createTheme(Theme theme) async {
    try {
      theme.docRef = await themeRef.add(theme.toMap());
    } catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> reportTopic(Topic topic) async {
    await postRef.doc(topic.postRef.id).update({
      "reportings": FieldValue.increment(1),
      "rating": FieldValue.increment(-100)
    });
    return true;
  }

  static Future<bool> commentTopic(Topic topic, Comment comment) async {
    bool success = true;
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        comment.docRef =
            await topic.postRef.collection("Comments").add(comment.toMap());
        userRef.doc(auth.currentUser.uid).update({
          'Comments': FieldValue.arrayUnion([comment.post.id])
        });
        await db.insert("MyComments", {"id": comment.docRef.path});
      }).onError((error, stackTrace) {
        success = false;
      });
    } catch (e) {
      return false;
    }
    return success;
  }

  static Future<bool> increment(
      Tendency tend, Topic topic, bool positive) async {
    String s;
    bool isSuccessful = true;
    switch (tend) {
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
    if (s != null) {
      await postRef.doc(topic.postRef.id).update({
        s: positive ? FieldValue.increment(1) : FieldValue.increment(-1)
      }).onError((error, stackTrace) {
        isSuccessful = false;
      });
    }
    return isSuccessful;
  }

  static Future<List<Topic>> getHottestTopics() async {
    getHottestThemes("");

    QuerySnapshot querySnapshot =
        await postRef.orderBy("rating").limit(20).get();
    List<Topic> topics = [];

    await Future.forEach(querySnapshot.docs, (element) async {
      Topic t = await Topic.fromMap(
          element.data() as Map<String, dynamic>, element.reference);
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

  static Future<List<Topic>> getHottestTopicsOfTheme(
      Topic lastTopic, Theme theme) async {
    List<Topic> topics = [];
    QuerySnapshot querySnapshot;
    if (lastTopic == null) {
      if (theme == null || theme.type == ThemeTypes.OVERALL_TOP) {
        querySnapshot =
            await postRef.orderBy("rating", descending: true).limit(10).get();
      } else {
        querySnapshot = await postRef
            .orderBy("rating", descending: true)
            .where("theme", isEqualTo: theme.name)
            .limit(10)
            .get();
      }
    } else {
      if (theme == null || theme.type == ThemeTypes.OVERALL_TOP) {
        querySnapshot = await postRef
            .orderBy("rating", descending: true)
            .limit(10)
            .startAfterDocument(await lastTopic.postRef.get())
            .get();
      } else {
        querySnapshot = await postRef
            .orderBy("rating", descending: true)
            .where("theme", isEqualTo: theme.name)
            .limit(10)
            .startAfterDocument(await lastTopic.postRef.get())
            .get();
      }
    }
    await Future.forEach(querySnapshot.docs, (element) async {
      Topic t = await Topic.fromMap(
          element.data() as Map<String, dynamic>, element.reference);
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

  static Future<void> sendFeedback(String s) async {
    await feedbackRef.add({"text": s, "date": DateTime.now()});
  }

  static Future<bool> likeComment(Comment comment, bool isPositive) async {
    bool noError = true;
    await comment.docRef.update({
      "likes": isPositive ? FieldValue.increment(1) : FieldValue.increment(-1)
    }).onError((error, stackTrace) {
      noError = false;
    });
    return noError;
  }

  static Future<void> reportComment(Comment c) async {
    await c.docRef.update({"reportings": FieldValue.increment(1)});
  }

  static Future<List<Comment>> getHottestCommentsOfTopic(
      Topic topic, Comment lastComment) async {
    QuerySnapshot querySnapshot;
    if (lastComment == null) {
      querySnapshot = await topic.postRef
          .collection("Comments")
          .orderBy("likes", descending: true)
          .limitToLast(10)
          .get();
    } else {
      querySnapshot = await topic.postRef
          .collection("Comments")
          .orderBy("likes", descending: true)
          .limitToLast(10)
          .startAfterDocument(await lastComment.docRef.get())
          .get();
    }

    List<Comment> comments = [];

    querySnapshot.docs.forEach((entry) async {
      Map element = entry.data();
      Comment c = Comment.fromMap(element, entry.reference, topic.postRef);
      comments.add(c);
    });

    return comments;
  }

  static Future<List<Topic>> getMyTopics(
    int offset,
  ) async {
    List<Topic> topics = [];

    List<Map<String, dynamic>> results1 = await db.query(
      "MyTopics",
      limit: 7,
      offset: offset,
      orderBy: "time DESC",
    );
    List<Map<String, dynamic>> results3 = await db.query("Topics",
        limit: 5,
        offset: offset,
        orderBy: "time DESC",
        where: "tendency != ?",
        whereArgs: [Tendency.NO_TENDENCY.toString()]);

    List<String> postIDs = [];

    results1.forEach((element) {
      postIDs.add(element.values.first);
    });

    results3.forEach((element) {
      postIDs.add(element.values.first);
    });

    await Future.forEach(postIDs, (element) async {
      DocumentSnapshot snap = await postRef.doc(element).get();
      if (snap.data() != null) {
        topics.add(await Topic.fromMap(
            snap.data() as Map<String, dynamic>, snap.reference));
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

  static Future<String> resetPassword(String email) async {
    String feedback = "";
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      feedback = e.message;
    } on Exception catch (e) {
      feedback = "Please try again later";
    }
    return feedback;
  }

  static Future<List<Topic>> getSearchedTopics(String regex) async {
    if (regex.length == 0) {
      return await getMyTopics(0);
    }

    List<Topic> topics = [];

    try {
      QuerySnapshot querySnapshot1 = await postRef
          .where('topic', isGreaterThanOrEqualTo: regex)
          .where('topic', isLessThan: regex + '\uf8ff')
          //   .orderBy("rating")
          .limit(5)
          .get();

      Future.forEach(querySnapshot1.docs, (element) async {
        Topic t = await Topic.fromMap(
            element.data() as Map<String, dynamic>, element.reference);
        topics.add(t);
      });
    } on Exception catch (e) {
      print(e);
    }
    QuerySnapshot querySnapshot2 = await postRef
        .where('intro', isGreaterThanOrEqualTo: regex)
        .where('intro', isLessThan: regex + '\uf8ff')
        // .orderBy("rating")
        .limit(5)
        .get();

    Future.forEach(querySnapshot2.docs, (element) async {
      Topic t = await Topic.fromMap(
          element.data() as Map<String, dynamic>, element.reference);
      topics.add(t);
    });
    return topics.toSet().toList();
  }

  static Future<bool> deleteUser() async {
    bool success = true;
    userRef.doc(auth.currentUser.uid).delete().onError((error, stackTrace) {
      success = false;
    });
    await DatabaseRequests.auth.currentUser
        .delete()
        .onError((error, stackTrace) {
      success = false;
    });
    await DatabaseRequests.auth.signOut();
    await db.execute("DELETE FROM MyComments");
    await db.execute("DELETE FROM MyTopics");
    await db.execute("DELETE FROM Variables");
    await db.execute("DELETE FROM Comments");
    await db.execute("DELETE FROM Topics");

    return success;
  }

  static Future<bool> deletePost(Topic topic) async {
    bool success = true;
    FirebaseFirestore.instance.runTransaction((transaction) async {
      await topic.postRef.delete().onError((error, stackTrace) {
        success = false;
      });
      userRef.doc(auth.currentUser.uid).update({
        'Posts': FieldValue.arrayRemove([topic.postRef])
      }).onError((error, stackTrace) {
        success = false;
      });
    }).onError((error, stackTrace) {
      success = false;
    });
    return success;
  }

  static Future<bool> deleteComment(Comment comment) async {
    bool success = true;
    FirebaseFirestore.instance.runTransaction((transaction) async {
      try {
        await comment.docRef.delete();
        int x = await db.delete("MyComments",
            where: "id = ?", whereArgs: [comment.docRef.path]);
      } catch (e) {
        print(e);
      }
      userRef.doc(auth.currentUser.uid).update({
        'Comments': FieldValue.arrayRemove([comment.docRef])
      });
    }).onError((error, stackTrace) {
      success = false;
    });
    return success;
  }

  static Future<List<Comment>> getCommentsTest(String id) async {
    List<Comment> comments = [];
    for (int x = 0; x < 5; x++) {
      comments.add(Comment.testComment());
    }
    return comments;
  }

  static Future<List<Theme>> getHottestThemes(String regex) async {
    // if(!databaseInitSuccessful){
    //   databaseInitSuccessful = await initWithDB();
    //  }

    if (themes == null || themes.length == 0) {
      QuerySnapshot querySnapshot = await themeRef.limit(20).get();
      List<Theme> themesLocal = [];
      querySnapshot.docs.forEach((element) async {
        Theme t = Theme.fromMap(
            element.data() as Map<String, dynamic>, element.reference);
        themesLocal.add(t);
      });
      themes = themesLocal;
    }
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

  static Future<bool> goToLegals() async {
    await launch(legalsLink);
  }

  //deep links:

  static Future<Uri> createDynamicLink(String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://hitstorm.page.link',
      link: Uri.parse('https://hitstorm.page.link.com/?id=$id'),
      googleAnalyticsParameters:
          GoogleAnalyticsParameters(source: "", medium: "", campaign: ""),
      androidParameters: AndroidParameters(
        packageName: 'com.hitstorm.hitstorm',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.hitstorm.hitstorm',
        appStoreId: "1612645231",
        minimumVersion: '1',
      ),
    );
    var dynamicUrl = await parameters.buildShortLink();

    return dynamicUrl.shortUrl;
  }

  static Future<bool> retrieveDynamicLink(BuildContext context) async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data == null) {
      return false;
    }

    final Uri deepLink = data.link;
    String id = deepLink.queryParameters['id'];
    if (deepLink != null) {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => TopicLoadView(topicString: id)));
    }
  }

  static Future<Topic> getSingleTopic(String id) async {
    DocumentSnapshot snap = await postRef.doc(id).get();
    if (snap.data() != null) {
      return await Topic.fromMap(
          snap.data() as Map<String, dynamic>, snap.reference);
    } else {
      return null;
    }
  }

  static Future<List<Topic>> getMyTopicsInfoView(
    int offset,
  ) async {
    List<Topic> topics = [];

    List<Map<String, dynamic>> results1 = await db.query(
      "MyTopics",
      limit: 7,
      offset: offset,
      orderBy: "time DESC",
    );

    List<String> postIDs = [];

    results1.forEach((element) {
      postIDs.add(element.values.first);
    });

    await Future.forEach(postIDs, (element) async {
      DocumentSnapshot snap = await postRef.doc(element).get();
      if (snap.data() != null) {
        topics.add(await Topic.fromMap(
            snap.data() as Map<String, dynamic>, snap.reference));
      }
    });
    return topics;
  }

  static Future<List<Comment>> getMyCommentsInfoView(
    int offset,
  ) async {
    List<Comment> comments = [];

    List<Map<String, dynamic>> results1 = await db.query(
      "MyComments",
      limit: 7,
      offset: offset,
    );

    List<String> postIDs = [];

    results1.forEach((element) {
      postIDs.add(element.values.first);
    });

    await Future.forEach(postIDs, (element) async {
      List<String> path = (element as String).split("/");
      DocumentSnapshot snap =
          await postRef.doc(path[1]).collection("Comments").doc(path[3]).get();
      if (snap.data() != null) {
        comments.add(Comment.fromMap(snap.data() as Map<String, dynamic>,
            snap.reference, snap.reference.parent.parent));
      }
    });
    return comments;
  }
}
