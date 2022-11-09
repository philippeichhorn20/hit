import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/Classes/Review.dart';
import 'package:guyde/HomePage.dart';
import 'package:guyde/NewPlace/ReviewTextPage.dart';


class SimpleReviewPage extends StatefulWidget {
  final Institution? institution;
  const SimpleReviewPage({Key? key, @required this.institution}): super(key:key);

  @override
  _SimpleReviewPageState createState() => _SimpleReviewPageState();
}

class _SimpleReviewPageState extends State<SimpleReviewPage> {
  bool upvoteSelected = false;
  bool downvoteSelected = false;

  Future<void> moveOn(BuildContext context, bool recommend)async{
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewTextPage(review: Review.simpleRatings(recommend, widget.institution!)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
       body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        upvoteSelected = true;
                        downvoteSelected = false;
                      });
                      moveOn(context, true);
                    },
                    label: SizedBox(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white12),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(

                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: upvoteSelected ? BorderSide(
                            color: Colors.green,
                            width: 6,
                          ): BorderSide.none
                        ),
                      ),
                    ),
                    icon: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child:  const Center(
                        child: Icon(Icons.arrow_circle_up_rounded, color: Colors.green,size: 100,),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04,),

                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        upvoteSelected = false;
                        downvoteSelected = true;
                      });
                      moveOn(context, true);
                    },
                    label: SizedBox(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white12),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(

                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: downvoteSelected ? BorderSide(
                              color: Colors.red,
                              width: 6,
                            ): BorderSide.none
                        ),
                      ),
                    ),
                    icon: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child:  const Center(
                        child: Icon(Icons.close_rounded, color: Colors.red,size: 100,),
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
