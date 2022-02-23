

import 'package:cloud_firestore/cloud_firestore.dart';

class Theme{

  String name = "test";
  String emoji = "🔥";
  DocumentReference docRef;


  static Theme fromMap(Map<String, dynamic> map, DocumentReference docRef){
    Theme t = new Theme(map.remove("name"), map.remove("emoji"), docRef);
    return t;
  }

  Theme(this.name, this.emoji, this.docRef);

  Theme.topTheme(){
    name = "Top 25";
    emoji = "🔥";
  }

  Map<String, dynamic> toMap(){
    return
      {
        "name": name,
        "emoji":emoji,
        "votes":0,
        "topics": 0
      }
      ;
  }
}