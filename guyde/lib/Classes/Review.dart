

import 'package:flutter/material.dart';
import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/Classes/User.dart';

class Review{
  int overall_rating = 0;
  int price_rating = 0;
  int value_rating = 0;
  int insta_rating = 0;
  int international_rating = 0;
  int social_rating = 0;
  User user = User.test();
  Institution institution = Institution.plain();
  String text = "";
  String id = "";
  bool recommend = false;
  int numberRecommend = 0;
  int numberVotes = 0;


  Review.ratingsOnly(this.overall_rating,this.price_rating,this.value_rating,
      this.insta_rating,this.international_rating,this.social_rating, );

  Review.simpleRatings(this.recommend, this.institution);

  void recommendIt(bool vote){
    recommend = vote;
  }


  void setText(String text){
    this.text = text;
  }
}