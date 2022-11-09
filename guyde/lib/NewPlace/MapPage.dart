import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/Functions/NewPlaceParseFunctions.dart';
import 'package:guyde/Functions/OtherParseFunctions.dart';
import 'package:guyde/NewPlace/ReviewPage.dart';
import 'package:guyde/NewPlace/SimpleReviewPage.dart';

import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final Institution? institution;
  const MapPage({Key? key, @required this.institution}): super(key:key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController mapController = MapController();
  List<Marker> markers = [];
  Widget markerLogo = Container(height: 20, width: 20,
    decoration: const  BoxDecoration(
    color: Colors.black,
    shape: BoxShape.circle,
  ),
  child:  Icon(Icons.location_searching, color: Colors.white,size:25 ,),
  );
  MapPosition pos = MapPosition();


  Future<void> findNewPlaces(MapPosition pos)async{
    print("oy");

    List<Institution> institutions = await OtherParseFunctions.getAllSpotsNearMe(pos.center!.latitude,
        pos.center!.latitude,
        1000000000);
    institutions.forEach((element) {
      print(element.toString());
      markers.add(Marker(point: LatLng(element.point.latitude,element.point.longitude),
          builder: (context){
        return Container(
          height: 100,
          width: 100,
          margin: EdgeInsets.all(40),
          color: Colors.black,
          child: Icon(InstitutionTypes.toIcon(element.type),size: 20,color: Colors.white,)
        );
          }));
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                  center: LatLng(51.509364, -0.128928),
                  zoom: 9.2,
                  controller: mapController,
                  keepAlive: true,

                  onPositionChanged: (position,what){
                   pos = position;
                  },
                  onMapCreated: ((mapController1) async{
                    Position location = await Geolocator.getCurrentPosition();
                    print("fuck");
                    print("here1");
                    LatLng positionOfUser = LatLng(location.latitude, location.longitude);
                    print("here2");
                    print(positionOfUser.latitude);
                    try {
                //      mapController1.move(positionOfUser, 10);
                    }catch(e){
                      print(e.toString());
                    }
                  }),
                  onTap: (tapPosition, latLang) {
                    if (markers.length == 0) {
                      markers.add(Marker(
                          point: latLang, builder: (context) => markerLogo ));
                    } else {
                      markers[0] = Marker(
                          point: latLang, builder: (context) => markerLogo);
                    }
                  }),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

                ),
                MarkerLayerOptions(markers: markers)
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.9,
              right: MediaQuery.of(context).size.width * 0.025,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: Container(height: MediaQuery.of(context).size.width*0.15, width: MediaQuery.of(context).size.width*0.15,
                      decoration: const  BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: TextButton.icon(onPressed: ()async{
                        findNewPlaces(pos);
                      },

                          icon:  Icon(Icons.location_on, color: Colors.white,size:30 ,), label: SizedBox()),
                    ),
                  ),

                  TextButton(
                    onPressed: ()async {
                      if(markers.length > 0) {
                        widget.institution!.setGeolocation(
                            markers[0].point.latitude,
                            markers[0].point.longitude);
                        await NewPlaceParseFunctions.addNewPlace(
                            widget.institution!);

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SimpleReviewPage(institution:widget.institution),
                          ),
                        );
                      }
                      },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(90.0),
                        ),
                      ),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 40,
                      child: const Center(
                        child: Text(
                          "Post Review",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ),
            Padding(
              padding: const EdgeInsets.only(left:8.0, top: 40),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle
                ),
                child: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },

                  icon: const Padding(
                    padding:  EdgeInsets.only(left: 8.0),
                    child:  Icon(Icons.arrow_back_ios, color: Colors.white,),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
