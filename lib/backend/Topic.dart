import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:hitstorm/backend/Comment.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/frontend/Styles.dart';
import 'package:hitstorm/frontend/views/TopicView.dart';

class Topic {
  DocumentReference postRef;

  String name;
  String intro;

  String theme;

  int upvotes;
  int neutrals;
  int downvote;
  Tendency tendency;
  DateTime date = DateTime.now();

  bool mine;
  bool isAd = false;

  List<Comment> comments = [];

  Topic.test() {
    this.name = "TestTopic";
    this.intro =
        "This test was created as mock data and therer rvuhfri4bherrv4jrv4obrv4obrv32r3bjv  rt4o r t ot4 ojt4 t t rl";
    this.upvotes = 10;
    this.downvote = 5;
    this.tendency = Tendency.NO_TENDENCY;
    this.neutrals = 9;
  }

  Topic.createTopic(String name, String intro, this.theme) {
    this.name = name;
    this.intro = intro;
    this.upvotes = 0;
    this.downvote = 0;
    this.tendency = Tendency.NO_TENDENCY;
    this.neutrals = 0;
    this.mine = true;
  }

  Topic.isAd(){
    isAd = true;
  }

  String getDownvotes() {
    if (downvote < 1000) {
      return "$downvote";
    } else if (downvote < 100000) {
      return "${(downvote / 1000).toStringAsFixed(1)}K";
    } else if (downvote < 1000000) {
      return "${(downvote / 1000).toStringAsFixed(0)}K";
    } else {
      return "${(downvote / 1000000).toStringAsFixed(1)}Mio";
    }
  }

  String getUpvotes() {
    return "$upvotes";
  }

  String getNeutrals() {
    return "$neutrals";
  }

  int votesTotal() {
    if (getUpvote() + getNeutral() + getDownvote() <= 0) {
      return 3;
    } else {
      return getUpvote() + getNeutral() + getDownvote();
    }
  }

  int getDownvote() {
    if (this.downvote < 0) {
      return 1;
    } else {
      return downvote;
    }
  }

  int getUpvote() {
    if (this.upvotes < 0) {
      return 1;
    } else {
      return upvotes;
    }
  }

  int getNeutral() {
    if (this.neutrals < 0) {
      return 1;
    } else {
      return neutrals;
    }
  }

  void vote(Tendency tend) {
    HapticFeedback.selectionClick();
    if (this.tendency == tend) {
      tend = Tendency.NO_TENDENCY;
    }
    DatabaseRequests.db.rawUpdate("UPDATE Topics SET tendency = ? where id = ?",
        [tend.toString(), this.postRef.id]);
    if (tend == this.tendency) {
      changeTendencyCount(Tendency.NO_TENDENCY);
      this.tendency = Tendency.NO_TENDENCY;
    } else if (this.tendency == null) {
      //no tendencys so far
      this.tendency = tendency;
      switch (this.tendency) {
        case Tendency.DOWNVOTE:
          upvotes++;
          break;
        case Tendency.UPVOTE:
          downvote++;
          break;
        case Tendency.NEUTRAL:
          upvotes++;
          break;
      }
      DatabaseRequests.increment(this.tendency, this, true);
    } else {
      //change of tendency
      this.changeTendencyCount(tend);
      this.tendency = tend;
    }
  }

  void changeTendencyCount(Tendency tend) {
    //automatically adds or subtracts 1 from the overall count,
    // depending on wheather it was liked before or not

    if (this.tendency == Tendency.UPVOTE) {
      DatabaseRequests.increment(this.tendency, this, false);
      this.upvotes--;
    } else if (tend == Tendency.UPVOTE) {
      DatabaseRequests.increment(tend, this, true);
      this.upvotes++;
    }
    if (this.tendency == Tendency.DOWNVOTE) {
      DatabaseRequests.increment(this.tendency, this, false);
      this.downvote--;
    } else if (tend == Tendency.DOWNVOTE) {
      DatabaseRequests.increment(tend, this, true);
      this.downvote++;
    }
    if (this.tendency == Tendency.NEUTRAL) {
      DatabaseRequests.increment(this.tendency, this, false);
      this.neutrals--;
    } else if (tend == Tendency.NEUTRAL) {
      DatabaseRequests.increment(tend, this, true);
      this.neutrals++;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "topic": name,
      "intro": intro,
      "upvotes": upvotes,
      "neutrals": neutrals,
      "downvotes": downvote,
      "theme": theme,
      "date": DateTime.now().millisecondsSinceEpoch,
      "rating": (DateTime.now().millisecondsSinceEpoch ~/
          1000 ~/
          60 ~/
          60 ~/
          12 *
          100),
      "author": DatabaseRequests.auth.currentUser.uid
    };
  }

  static Topic fromMap(
      Map<String, dynamic> map, DocumentReference documentReference) {
    Iterable it = map.entries;
    Topic t = new Topic.createTopic(
        map.remove("topic"), map.remove("intro"), map.remove("theme"));
    t.upvotes = map.remove("upvotes");
    t.downvote = map.remove("downvotes");
    t.neutrals = map.remove("neutrals");

    t.postRef = documentReference;
    if (map.containsKey("date")) {
      t.date = DateTime.fromMillisecondsSinceEpoch(map.remove("date"));
    }
    if (map.remove("author") == DatabaseRequests.auth.currentUser.uid) {
      t.mine = true;
    } else {
      t.mine = false;
    }
    t.sqliteCheck();
    return t;
  }

  void report() {
    DatabaseRequests.reportTopic(this);
  }

  void sqliteCheck() async {
    List<Map<String, dynamic>> result = await DatabaseRequests.db.rawQuery(
        "SELECT tendency FROM Topics WHERE id = ?", [this.postRef.id]);
    if (result.isNotEmpty) {
      this.tendency = Topic.toTendency(result.first.values.first);
    } else {
      this.tendency = Tendency.NO_TENDENCY;
      await DatabaseRequests.db.rawInsert(
          "INSERT INTO Topics (id, tendency) VALUES (?,?)",
          [this.postRef.id, Tendency.NO_TENDENCY.toString()]);
    }
  }

  static Tendency toTendency(String s) {
    switch (s) {
      case "Tendency.NEUTRAL":
        return Tendency.NEUTRAL;
        break;
      case "Tendency.DOWNVOTE":
        return Tendency.DOWNVOTE;
        break;
      case "Tendency.UPVOTE":
        return Tendency.UPVOTE;
        break;
      case "Tendency.NO_TENDENCY":
        return Tendency.NO_TENDENCY;
        break;
      default:
        return Tendency.NO_TENDENCY;
    }
  }

  @override
  bool operator ==(Object other) {
    Topic topic = other;
    return this.postRef == topic.postRef;
  }

  int _hashCode;

  @override
  int get hashCode {
    if (_hashCode == null) {
      _hashCode = this.postRef.hashCode;
    }
    return _hashCode;
  }

  Widget listViewTopic(BuildContext context, Function setState) {
    return TextButton(
      onPressed: () {
        Navigator.push(
            context,
            new CupertinoPageRoute(
              builder: (context) => new TopicView(
                topic: this,
              ),
            )).then((value) => setState(() {}));
      },
      style: ButtonStyle(
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.transparent),
        padding:
            MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(top: 10)),
      ),
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 8),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  this.name,
                  style: Styles.SmallTextDark,
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  this.intro,
                  maxLines: 3,
                  style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
              Divider(
                indent: 10,
                endIndent: 10,
              ),
              StatefulBuilder(builder: (context, setState) {
                return SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            setState(() {
                              this.vote(Tendency.UPVOTE);
                            });
                          },
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          icon: Icon(
                            Icons.arrow_circle_up,
                            color: this.tendency != Tendency.UPVOTE
                                ? Colors.grey
                                : Colors.green,
                          ),
                          label: Text(Styles.numberAsStrings(this.getUpvote()), style: Styles.SmallerTextGrey,)),
                      TextButton.icon(
                          onPressed: () {
                            setState(() {
                              this.vote(Tendency.NEUTRAL);
                            });
                          },
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),

                          ),
                          icon: Icon(
                            Icons.do_not_disturb_on,
                            color: this.tendency != Tendency.NEUTRAL
                                ? Colors.grey
                                : Colors.amberAccent,
                          ),

                          label: Text(Styles.numberAsStrings(this.getNeutral()), style: Styles.SmallerTextGrey,)),
                      TextButton.icon(
                          onPressed: () {
                            setState(() {
                              this.vote(Tendency.DOWNVOTE);
                            });
                          },
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          icon: Icon(
                            Icons.arrow_circle_down,
                            color: this.tendency != Tendency.DOWNVOTE
                                ? Colors.grey
                                : Colors.red,

                          ),
                          label: Text(Styles.numberAsStrings(this.getDownvote()), style: Styles.SmallerTextGrey,)),
                    ],
                  ),
                );
              }),
              Divider(
                color: Colors.black54,
              )
            ],
          )),
    );
  }
}

enum Tendency {
  UPVOTE,
  DOWNVOTE,
  NEUTRAL,
  NO_TENDENCY,
}
