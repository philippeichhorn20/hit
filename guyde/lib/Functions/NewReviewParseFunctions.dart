



import 'package:guyde/Classes/Review.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class NewReviewParseFunctions{

  static Future<bool> addNewReview(Review review)async{


    final ParseCloudFunction function = ParseCloudFunction('newReview');
    final ParseResponse parseResponse = await function.execute(parameters: {
      "insta_rating":review.insta_rating,
      "insta_rating":review.international_rating,
      "insta_rating":review.overall_rating,
      "insta_rating":review.social_rating,
      "insta_rating":review.value_rating,
      "insta_rating":review.price_rating,
      "text":review.text,
      "place_id": review.institution.id,

    });
    if (parseResponse.success) {
      review.id = parseResponse.result;
      print(parseResponse.result);
    }else{
      print(parseResponse.error?.message);
    }

    return parseResponse.success;
  }

  static Future<bool> addNewSimpleReview(Review review)async{


    final ParseCloudFunction function = ParseCloudFunction('addNewSimpleReview');
    final ParseResponse parseResponse = await function.execute(parameters: {
      "recommendation":review.recommend,
      "text":review.text,
      "place_id": review.institution.id,
    });
    if (parseResponse.success) {
      print(parseResponse.results);

      review.id = parseResponse.result;
    }else{
      print(parseResponse.error?.message);
    }

    return parseResponse.success;
  }

}