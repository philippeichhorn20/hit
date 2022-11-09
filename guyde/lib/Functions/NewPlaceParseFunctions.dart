import 'package:guyde/Classes/Institution.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class NewPlaceParseFunctions{




  static Future<bool> addNewPlace(Institution institution)async{

    //await institution.imageParseFile.save();


    final ParseCloudFunction function = ParseCloudFunction('newPlace');
    final ParseResponse parseResponse = await function.execute(parameters: {
      "name":institution.name,
      "location": institution.point,
      "description": institution.description,
      "type": institution.type.index,
   //   "image": institution.imageParseFile,

    });
    if (parseResponse.success) {
      institution.id = parseResponse.result;
      print(parseResponse.result);
      print(parseResponse.results);
    }else{
      print(parseResponse.error?.message);
    }

    return parseResponse.success;
  }

}