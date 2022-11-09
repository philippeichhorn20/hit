import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guyde/Classes/Institution.dart';
import 'package:guyde/LoginPage/Constants.dart';
import 'package:guyde/LoginPage/WelcomePage.dart';
import 'package:guyde/NewPlace/MapPage.dart';
import 'package:image_picker/image_picker.dart';


class NewInstitutionPage extends StatefulWidget {
  @override
  _NewInstitutionPageState createState() => _NewInstitutionPageState();
}

class _NewInstitutionPageState extends State<NewInstitutionPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  InstitutionTypes institutionType = InstitutionTypes.NOT_SELECTED;
  TextEditingController descriptionController = TextEditingController();

  var locationTypes = ["Current Location", "Selected Location"];
  var locationTypeSelection = Constants.hasLocationActivated ? 1:0;
 final ImagePicker picker = new ImagePicker();
  File image = File("");


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 100,),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    cursorColor: Colors.white,

                    controller: nameController,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white
                    ),
                    decoration: const InputDecoration(
                      focusColor: Colors.white,
                        hintStyle: TextStyle(color: Colors.white60,
                        fontWeight: FontWeight.w700,
                        fontSize: 30),
                        hintText: "name.",
                        fillColor: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (context)=> CupertinoActionSheet(
                        title: const Text("Choose a Resource"),
                        cancelButton: CupertinoActionSheetAction(
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () async{
                              XFile? xfile = await picker.pickImage(source: ImageSource.camera);
                              setState(() {
                                if(xfile != null) {
                                  image =File(xfile.path);
                                }
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Camera'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
                              setState(() {
                                if(xfile != null) {
                                  image = File(xfile.path);
                                }
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Gallery'),
                          ),
                        ],
                      )
                    );
                  },
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width*0.9,

                    decoration: BoxDecoration(
                      image:  DecorationImage(image: Image.file(image?? File("BS"),

                        ).image,
                        fit: BoxFit.cover,

                      ),

                      border: Border.all(
                    color: Colors.black,
                        width: 1,
                    ),
                      borderRadius: const BorderRadius.all(Radius.circular(40),

                      )

                    ),

                  ),
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: List<Widget>.generate(
                      InstitutionTypes.values.length-1,
                          (int index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ChoiceChip(
                            label: Text(InstitutionTypes.values.elementAt(index).name,style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700
                            ),),
                            selected: institutionType.name == InstitutionTypes.values.elementAt(index).name,
                            selectedColor: Colors.green,
                            backgroundColor: Colors.white,
                            onSelected: (bool selected) {
                              setState(() {
                                institutionType = selected ? InstitutionTypes.values.elementAt(index) : InstitutionTypes.NOT_SELECTED;
                              });
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    cursorColor: Colors.white,

                    controller: descriptionController,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white
                    ),
                    maxLines: 2,
                      maxLength: 60,
                    decoration: const InputDecoration(
                        focusColor: Colors.white,
                        hintStyle: TextStyle(color: Colors.white60,
                            fontWeight: FontWeight.w700,
                            fontSize: 30),
                        hintText: "description.",
                        fillColor: Colors.white),
                  ),
                ),
              ],
            ),


            Positioned(
              top: MediaQuery.of(context).size.height*0.9,
              right: MediaQuery.of(context).size.width*0.025,
              child: TextButton(
                onPressed: () {
                  if(nameController.text.isNotEmpty && institutionType != InstitutionTypes.NOT_SELECTED /*&&  image.path != ""*/) {
                    Institution institution = Institution.undefLoc(
                        nameController.text, institutionType, image);
                    institution.description = descriptionController.text;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MapPage(institution: institution,),
                      ),
                    );
                  }


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
                    child: Text("Add Location", style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Colors.black
                    ),),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:8.0, top: 40),
              child:  Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
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
      ),

    );
  }




}
