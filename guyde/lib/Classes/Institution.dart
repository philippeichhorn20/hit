import 'package:geolocator/geolocator.dart';
import 'package:guyde/Classes/Settings.dart';
import 'package:guyde/Functions/LocationRequests.dart';
import 'package:guyde/Settings/Constants.dart';
import 'package:guyde/UI/ReviewElements/Direction.dart';
import 'package:latlong2/latlong.dart';


import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:guyde/Classes/Review.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Institution{
  String name = "test name";
  ParseGeoPoint point = ParseGeoPoint(latitude: 0, longitude: 0);
  InstitutionTypes type = InstitutionTypes.NOT_SELECTED;
  String id = "6ITpyrDGuT";
  ParseFileBase imageParseFile =  ParseFile(File(""));
  int overall_rating = 3;
  int price_rating = 1;
  int value_rating = 2;
  int insta_rating = 0;
  int international_rating = 4;
  int social_rating = 5;
  int recommend_count = 13;
  int vote_count = 18;
  String description = "This is where a short introdtion from the original uathor will be placed";
  String location = "Schillerstr. 10, Kronberg - DE";
  Map<String, int> ratingMap = {"":0};
  int starSize = 15;
  Set<Review> reviews = Set();
  String imageUrl = "";

  Institution.fromApp(this.name, double long, double lat, this.type){
    this.point = ParseGeoPoint(latitude: lat, longitude: long);
  }
  Institution.undefLoc(this.name, this.type, File imageFile){
    Image(image: ResizeImage(FileImage(imageFile), height: 100, width: 300));
    
    imageParseFile = ParseFile(imageFile);
    
  }

  Institution.plain();

  void setGeolocation(var lat, long){
    point = ParseGeoPoint(latitude: lat, longitude: long);
  }

  int recomendCount(){
    recommend_count = 0;
    List<Review> list = reviews.toList();
    for(int i = 0; i< reviews.length; i++){
      if(list[i].recommend){
       recommend_count++;
      }
    }
    return recommend_count;
  }


  String getDistance(){
    return Direction.distanceToString( Geolocator.distanceBetween(this.point.latitude, this.point.longitude, Settings.position!.latitude, Settings.position!.longitude));
  }

  int voteCount(){
    vote_count = reviews.length;
return vote_count;
  }

  Institution.test(){
     name = "Harry Fish 'n Chips";
     point = ParseGeoPoint(latitude: 0, longitude: 0);
     type = InstitutionTypes.RESTAURANT;
     id = "0";
     imageParseFile =  ParseFile(File("_image_picker_DE6E2A69-3B26-4C17-91C9-ECDBE25089AB-3621-00001A30D586E66C.jpg"));
  }



  int ratingsToMap(){
    ratingMap = {
      "Overall": overall_rating,
      "Price": price_rating,
      "Value": value_rating,
      "Social": social_rating,
      "Instagrammable": insta_rating,
      "Internationality": international_rating,
    };
    return 6;
  }

  Institution.fromMap(Map<String,dynamic> map){
    name = map.remove("name")??name;
    description = map.remove("description")??description;
    Map<String,dynamic>? geoMap = map.remove("location");
    id = map.remove("objectId");
    if(geoMap != null){
      point.latitude = geoMap.remove("latitude")*1.0;
      point.longitude = geoMap.remove("longitude")*1.0;
    }
    imageUrl = (map.remove("image")as Map<String, dynamic>).remove("url")??name;
    type = InstitutionTypes.values.elementAt(map.remove("type")??0);
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return id == (other as Institution).id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;

  @override
  String toString(){
    return "$name is located at $location";
  }

  
  void setImage(Image image){
    
  }
  
  Widget toSimpleWidget(Function onPressed, BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 24.0),
      child: ListTile(

        title: Text(name, style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18

        ),),
        trailing: Icon(InstitutionTypes.toIcon(type),color: Colors.white54,),
        subtitle: Text(location,
        ),
        tileColor: Colors.white12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),

      ),
    );
  }

  Widget toWidget(Function onPressed, BuildContext context){

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextButton(
        onPressed: (){
          onPressed();
        },
        child: Container(
          width: MediaQuery.of(context).size.width*0.9,
          height: 303,
          decoration: BoxDecoration(
            color: Colors.white12,
              border: Border.all(
                color: Colors.transparent,
                width: 3
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20)
              )
          ),
          child: Column(
            children: [
            Row(
              children: [

                (imageUrl == "")?Icon(Icons.category):ClipRRect(
                  borderRadius: BorderRadius.circular(20.0, ),

                  child: Image.network(imageUrl,
                    width:MediaQuery.of(context).size.width*0.85,
                    height: 150,
                    fit: BoxFit.fitWidth,

                  ),
                ),


              ],
            ),
            Padding(
              padding: EdgeInsets.only(top:20, bottom: 10),
              child: Column(
                children: [
                  Text(this.name, style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,

                  )),
                  Padding(
                    padding: const EdgeInsets.only(top:13.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.zero,
                          child: Row(
                            children: [
                              Container(
                                height: 10,
                                width: (recomendCount()/voteCount())*150,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    border: Border.all(
                                      color: Colors.green,
                                    ),

                                    borderRadius: const BorderRadius.only(bottomLeft:Radius.circular(200),
                                        topLeft:Radius.circular(200)
                                    )
                                ),
                              ),
                              Container(
                                height: 10,
                                width: (1-(recomendCount()/voteCount()))*150,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                    border: Border.all(
                                      color: Colors.red,
                                    ),

                                    borderRadius: const BorderRadius.only(bottomRight:Radius.circular(200),
                                        topRight:Radius.circular(200)
                                    )
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("  "+((recomendCount()/(voteCount()== 0? voteCount():1))*100).toInt().toString()+"%", style: const TextStyle(
                            color: Colors.white30,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                        ),
                      ],

                    ),
                  ),
                ],
              ),
            ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(type.name.toUpperCase().substring(0,1)+type.name.toLowerCase().substring(1)+
                      " • "+
                      getDistance()+ " away",
                    style: Constants.smallText,
                  ),


                ],
              )
          ],
          ),
        ),
      ),
    );
  }

  Marker toMarker(BuildContext context, Function onPressed){
    return Marker(point: LatLng(point.latitude,point.longitude),
        height: 105,
        width: 105,
        builder: (context){
      return TextButton.icon(
          onPressed: (){
            onPressed();
          },
          icon: Container(

        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white),

        child: CircularPercentIndicator(radius:40,
            lineWidth:7,
            percent: .7,//recomendCount()/voteCount(),
            backgroundColor: Colors.black12,
            progressColor: Colors.black45,
            center: Icon(InstitutionTypes.toIcon(type,), size: 40, color: Colors.black,)),
      ),
          label: const SizedBox());
    });
  }
}


enum InstitutionTypes{
  HOSTEL, HOTEL, RESTAURANT, BAR, CAFE, ATTRACTION, REGION, SPOT, NOT_SELECTED;


   static IconData toIcon(InstitutionTypes type){
    switch (type){
      case InstitutionTypes.HOSTEL:
        return Icons.hotel;
      case InstitutionTypes.HOTEL:
        return Icons.hotel;
      case InstitutionTypes.RESTAURANT:
        return Icons.restaurant_menu;
      case InstitutionTypes.CAFE:
        return Icons.local_cafe;
      case InstitutionTypes.ATTRACTION:
        return Icons.local_attraction;
      case InstitutionTypes.BAR:
        return Icons.bar_chart_outlined;
      case InstitutionTypes.REGION:
        return Icons.landscape;
        case InstitutionTypes.SPOT:
      return Icons.location_on;
      case InstitutionTypes.NOT_SELECTED:
        return Icons.question_mark;

    }
  }


}