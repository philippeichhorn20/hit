

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';

class Subcomment{

  String pseudonym;
  String text;
  String date;
  String id;

  DocumentReference reference;
  bool mine;
  bool deleted = false;


  Subcomment(this.text, this.date, this.reference, this.id, this.pseudonym){
    this.mine = this.id == DatabaseRequests.auth.currentUser.uid;
  }

  Subcomment.create(this.text){
    this.mine = true;
    this.pseudonym = DatabaseRequests.auth.currentUser.displayName;
    this.date = DateTime.now().toString();
    this.id = DatabaseRequests.auth.currentUser.uid;
  }

  static Subcomment fromMap(Map<String, dynamic> map, DocumentReference ref){
    return Subcomment(map.remove("text"), map.remove("date"), ref, map.remove("authorID"), map.remove("pseudonym"));
  }

  Map<String, dynamic> toMap(){
    return {
      "text": this.text,
      "date": this.date,
      "authorID": this.id,
      "pseudonym":this.pseudonym
    };
  }

  Widget getSubCommentListTile(BuildContext context, Function dropComment, Function setState, int index){
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
                                      .deletSubcomment(this);
                                }else{
                                  await DatabaseRequests
                                      .reportSubcomment(this);
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
            ],
          ),
        ),
      ],
    );

  }
}