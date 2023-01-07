

import 'package:guyde/Classes/Institution.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

class LocationRequests{


  static Future<Place> getLocationsFromCoordinates(double lat,lang)async{
    Place location = await Nominatim.reverseSearch(lat: lat,lon: lang,);
    print(location.address);
    return location;
  }

  static Future<List<Place>> getLocationsFromText(String text)async{
    List<Place> locations = await Nominatim.searchByName(limit: 5, query: text, addressDetails: true,);
    print(locations.first.displayName);
    return locations;
  }


  static Future<Place> testGetLocationsFromCoordinates()async{
    Place location = await Nominatim.reverseSearch(lat: 49.842761,lon: 9.173020,);
    print(location.address);
    return location;
  }
}