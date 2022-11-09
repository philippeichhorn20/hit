import 'package:flutter/material.dart';
import 'package:guyde/Classes/Review.dart';
import 'package:guyde/Functions/NewReviewParseFunctions.dart';

class ReviewTextPage extends StatefulWidget {
  final Review? review;
  const ReviewTextPage({Key? key, @required this.review}): super(key:key);
  @override
  _ReviewTextPageState createState() => _ReviewTextPageState();
}

class _ReviewTextPageState extends State<ReviewTextPage> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  Stack(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: 200,),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                    ),
                    maxLines: 15,

                    cursorColor: Colors.white,
                    decoration: InputDecoration(

focusColor: Colors.white,
                        border: InputBorder.none,


                        //OutlineInputBorder(
                        //                          borderRadius: BorderRadius.circular(30.0),
                        //
                        //                        ),
                        //                        focusedBorder: OutlineInputBorder(
                        //                          borderRadius: BorderRadius.circular(30.0),
                        //
                        //                        ),
                        filled: false,
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        helperMaxLines: 10,
                        hintText: "Leave a short review of your experience here...",
                        fillColor: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height*.1,
            child: TextButton(
              onPressed: () async{
                widget.review!.setText(textEditingController.text);
                NewReviewParseFunctions.addNewReview(widget.review!);
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
                  child: Text("Post", style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),),
                ),
              ),
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
                  Navigator.pop(context);
                },

                icon: const Padding(
                  padding:  EdgeInsets.only(left: 8.0),
                  child:  Icon(Icons.arrow_back_ios, color: Colors.black,),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
