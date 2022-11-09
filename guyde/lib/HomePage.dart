import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/Classes/Review.dart';
import 'package:guyde/FriendsPage.dart';
import 'package:guyde/Functions/NewPlaceParseFunctions.dart';
import 'package:guyde/Functions/NewReviewParseFunctions.dart';
import 'package:guyde/NewPlace/FindPlacePage.dart';
import 'package:guyde/NewPlace/NewInstitutionPage.dart';
import 'package:guyde/Functions/OtherParseFunctions.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController locationText = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          elevation: 0.5,
          leading: Padding(
            padding: const EdgeInsets.only(left:10.0),
            child: IconButton(onPressed: ()async{
              NewPlaceParseFunctions.addNewPlace(Institution.plain());
            //  Position currentPosition = await Geolocator.getCurrentPosition();
              //  print(currentPosition.longitude);

           //   List<Placemark> placemarks = await placemarkFromCoordinates(currentPosition.longitude, currentPosition.latitude);
            //  print(placemarks.first.name);
            }, icon: Icon(Icons.location_on, color: Colors.white,size: 40,), ),
          ),
          title: Container(
            decoration:  BoxDecoration(
              color: Colors.white12,
              border: Border.all(
                color: Colors.transparent,
              ),
                borderRadius: BorderRadius.all(Radius.circular(20)
              )
            ),
            child: Padding(
              padding: const EdgeInsets.only(left:14.0,right: 10),
              child: TextField(
                cursorColor: Colors.white,
                 controller: locationText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),

                decoration: const InputDecoration(
                focusColor: Colors.transparent,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,

                ),
              ),
            ),
          ),
          actions: [
            IconButton(onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FriendsPage(),
                ),
              );
            }, icon: Icon(Icons.person, color: Colors.white,size: 40,))
          ],
        ),
        body: FutureBuilder<List<Institution>>(
          future:  OtherParseFunctions.getSpotsOfFriendsReviews(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: Text("Loading..."));
            }
            if(snapshot.connectionState == ConnectionState.none){
              return Center(child: Text("Error..."));
            }
            return ListView.builder(itemBuilder: (context, index){
              if(snapshot.data != null){
                return snapshot.data![index].toWidget((){}, context);
              }
              return Icon(Icons.question_mark);
            },
            itemCount: (snapshot.data??[]).length);
          }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FindPlacePage(),
              ),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
