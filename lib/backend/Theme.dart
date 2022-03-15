

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/frontend/views/Overview.dart';

class Theme{

  String name = "test";
  String emoji = "🔥";
  DocumentReference docRef;
  int iconData = 61668;

  static Theme fromMap(Map<String, dynamic> map, DocumentReference docRef){
    Theme t = new Theme(map.remove("name"), map.remove("emoji"), docRef);
    t.iconData = map.remove("iconData");
    return t;
  }

  Theme(this.name, this.emoji, this.docRef);

  Theme.topTheme(){
    name = "Top 25";
    emoji = "🔥";
    iconData = iconData;
  }

  Map<String, dynamic> toMap(){
    return
      {
        "name": name,
        "emoji":emoji,
        "votes":0,
        "topics": 0,
        "iconData": iconData
      }
      ;
  }

  Widget toWidget(context){
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5, bottom:8),
      child: ElevatedButton(
        onPressed: (){
            Navigator.push(context, new CupertinoPageRoute(
              builder: (context)=> new Overview(t: this),
            ));

        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(60)),
            side:BorderSide(
              width:  2,
              style: BorderStyle.solid,
              color:Colors.grey.shade300,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Text(
                this.name,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}