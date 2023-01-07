

import 'package:flutter/material.dart';
import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/Classes/Settings.dart';
import 'package:guyde/Classes/User.dart';

class Review{
  int overall_rating = 0;
  int price_rating = 0;
  int value_rating = 0;
  int insta_rating = 0;
  int international_rating = 0;
  int social_rating = 0;
  User author = User.test();
  Institution institution = Institution.plain();
  String text = "";
  String id = "";
  bool recommend = false;
  DateTime createdAt = DateTime.now();




  Review.ratingsOnly(this.overall_rating,this.price_rating,this.value_rating,
      this.insta_rating,this.international_rating,this.social_rating, );

  Review.simpleRatings(this.recommend, this.institution);

  void recommendIt(bool vote){
    recommend = vote;
  }

  Review.fromMap(Map<String,dynamic> map){
    institution = Institution.fromMap(map.remove("place_id"));
    id = map.remove("objectId");
    recommend = map.remove("recommendation");
    author = User.fromMap(map.remove("author"));
    text = map.remove("text");
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return id == (other as Review).id;
  }
  void setText(String text){
    this.text = text;
  }


  Widget toListTile(BuildContext context){
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
          color: author.isMe? Colors.white30:Colors.white10,
          border: Border.all(
              color:Colors.transparent,
              width: .7
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)
          )
      ),
      child: ListTile(
        title: Text(text),
        subtitle: Text(author.name),
      ),
    );

  }
}