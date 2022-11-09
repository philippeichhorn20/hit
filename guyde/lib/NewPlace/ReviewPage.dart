import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:guyde/HomePage.dart';
import 'package:guyde/NewPlace/ReviewTextPage.dart';
import '../Classes/Review.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double overallRating = 0;
  double priceRating = 0;
  double valueRating = 0;
  double socialRating = 0;
  double instaRating = 0;
  double internationalRating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
children: [
  const SizedBox(height: 50,),
  const Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("How was the Price?", style: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),),
  ),
  Center(
    child: RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      glow: false,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
            Icons.attach_money,
            color: Colors.amber,

      ),
      onRatingUpdate: (rating) {
            priceRating = rating;
      },
    ),
  ),
  const SizedBox(height: 20,),
  const Divider(),

  const Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("How was the Value?", style: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),),
  ),
  Center(
    child: RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      glow: false,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,

      ),
      onRatingUpdate: (rating) {
            valueRating = rating;
      },
    ),
  ),
  const SizedBox(height: 20,),
  const Divider(),

  const Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("Was it a Social Place?", style: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),),
  ),
  Center(
    child: RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      glow: false,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,

      ),
      onRatingUpdate: (rating) {
            socialRating = rating;
      },
    ),
  ),
  const SizedBox(height: 20,),
  const Divider(),

  const Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("Was it international?", style: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),),
  ),
  Center(
    child: RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      glow: false,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,

      ),
      onRatingUpdate: (rating) {
            internationalRating = rating;
      },
    ),
  ),
  const SizedBox(height: 20,),
  const Divider(),

  const Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("Was it Instagrammable?", style: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),),
  ),
  Center(
    child: RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      glow: false,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,

      ),
      onRatingUpdate: (rating) {
            instaRating = rating;
      },
    ),
  ),
  const SizedBox(height: 20,),
  const Divider(),

  const Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("How many Stars was it overall?", style: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),),
  ),
  Center(
    child: RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      glow: false,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,

      ),
      onRatingUpdate: (rating) {
            overallRating = rating;
      },
    ),
  ),
  const SizedBox(height: 20,),
  const Divider(),

  TextButton(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReviewTextPage(review: Review.ratingsOnly(overallRating.toInt(), priceRating.toInt(), valueRating.toInt(), instaRating.toInt(), internationalRating.toInt(), socialRating.toInt())),
        ),
      );
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.white),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(

            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(90.0),
            ),
      ),
    ),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 40,
      child:  const Center(
            child: Text("Next", style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.black
            ),),
      ),
    ),
  ),
],
            ),
            Padding(
              padding: const EdgeInsets.only(left:8.0, top: 40),
              child: Container(
                decoration: const BoxDecoration(
                    color:  Colors.white,
                    shape: BoxShape.circle
                ),
                child: IconButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },

                  icon: Icon(Icons.close, color: Colors.black,),
                ),
              ),
            ),
          ],

        ),

      ),
    );
  }
}
