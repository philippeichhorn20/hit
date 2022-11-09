import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/Functions/OtherParseFunctions.dart';
import 'package:guyde/NewPlace/NewInstitutionPage.dart';
import 'package:guyde/NewPlace/ReviewPage.dart';
import 'package:guyde/NewPlace/SimpleReviewPage.dart';

class FindPlacePage extends StatefulWidget {
  @override
  _FindPlacePageState createState() => _FindPlacePageState();
}

class _FindPlacePageState extends State<FindPlacePage> {
  TextEditingController locationText = TextEditingController();
  Position? currentPosition;



  Future<List<Institution>> getInstitutions()async{
    if(currentPosition == null&&false){
      return [];
    }else{
      print("hey");
      return OtherParseFunctions.getAllSpotsNearMe(51, 0, 100);
      //return OtherParseFunctions.getAllSpotsNearMe(currentPosition!.longitude, currentPosition!.latitude, 30);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title:  Container(
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
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if(snapshot.data != null && snapshot.connectionState == ConnectionState.done){
              return ListView.builder(itemBuilder: (context, index){

                if(index == 0){
                  return ListTile(title: Text("Add new Place"),
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NewInstitutionPage(),
                      ),
                    );
                  },);
                }else {
                  return snapshot.data![index-1].toSimpleWidget(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SimpleReviewPage(institution: snapshot.data![index-1]),
                      ),
                    );
                  }, context);
                }
              },
              itemCount: (snapshot.data??[]).length+1,);
            }else if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: Text("Loaoding..."),);
            }else{
              return Center(child: Text("Fuck..."),);
            }
          },
          future: getInstitutions(),
        ),
      ),
    );
  }
}
