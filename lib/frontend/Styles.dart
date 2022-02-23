


import 'package:flutter/material.dart';

class Styles{

  static const TextStyle SmallText = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white
  );
  static const TextStyle SmallTextDark = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.black87
  );
  static const TextStyle TextDark = TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w700,
      color: Colors.black87
  );

  static const TextStyle SmallerTextGrey = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Colors.black54
  );

  static const CircularProgressIndicator LoadingAnimation = CircularProgressIndicator(
    backgroundColor: Colors.greenAccent,
  );


  static const OutlineInputBorder defaultTextInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(
        color: Colors.orange,
        width: 2.0),
  );


  static String numberAsStrings(int num){
    if(num < 1000){
      return "$num";
    }else if(num < 100000){
      return "${(num / 1000).toStringAsFixed(1)}K";
    }else if(num < 1000000){
      return "${(num / 1000).toStringAsFixed(0)}K";
    }else{
      return "${(num / 1000000).toStringAsFixed(1)}Mio";
    }
  }

  static String dateAsString(DateTime date){
    DateTimeRange range = DateTimeRange(start: date, end: DateTime.now());
    if(range.duration.inMinutes < 60){
      return "${range.duration.inMinutes} min";
    }else if(range.duration.inHours < 24){
      return "${range.duration.inHours} hours";
    }else if(range.duration.inDays < 14){
      return "${range.duration.inDays} days";
    }else if(range.duration.inDays < 7*8){
      return "${((range.duration.inDays)~/7).toInt()} weeks";
    }else if(range.duration.inDays < 7*50){
      return "${((range.duration.inDays)~/(7*4)).toInt()} months";
    }{
      return "${date.day}.${date.month}.${date.year}";
    }
  }

}