import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Theme.dart' as backendTheme;
import 'package:hitstorm/frontend/views/Overview.dart';
import 'package:hitstorm/frontend/views/Top25View.dart';

import 'InformationView.dart';
import 'NewTopicView.dart';
import 'SearchView.dart';

class ThemesView extends StatefulWidget {

  @override
  _ThemesViewState createState() => _ThemesViewState();
}

class _ThemesViewState extends State<ThemesView> {
  List<backendTheme.Theme> themes = DatabaseRequests.themes;



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amberAccent,
          child: Text("🕵️", style: TextStyle(
              fontSize: 30
          ),),
          onPressed: (){
            Navigator.push(context, new CupertinoPageRoute(
              builder: (context)=> new NewTopicView(),
            ));
          },
        ),
        appBar: AppBar(
          leading: TextButton(
            onPressed: (){
              Navigator.push(context, new CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context)=> new InformationView(),
              ));
            },
            child: Icon(Icons.info_outline, size: 30, color: Colors.white30,),
          ),
          actions: [
            TextButton.icon(
              label: SizedBox(),
              onPressed: (){
                Navigator.push(context, new CupertinoPageRoute(
                  builder: (context)=> new SearchView(),
                ));
              },
              icon: Text("🔎", style: TextStyle(
                fontSize: 30,
              ),),
            ),
          ],
          backgroundColor: Colors.green,
          elevation: 0,
          title: Text("Themes 🔥",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Colors.black
            ),),

        ),
        body: GridView.builder(
            itemCount: themes.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20),
            itemBuilder: (conext, i){
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: (){

                    if(i == 0){
                      Navigator.push(context, new CupertinoPageRoute(
                        builder: (context)=> new Top25View(),
                      ));
                    }else{
                    Navigator.push(context, new CupertinoPageRoute(
                        builder: (context)=> new Overview(t:themes[i]),
                    ));
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side:BorderSide(
                        width:  1,
                        style: BorderStyle.solid,
                        color:Colors.grey,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(themes[i].emoji,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w600,
                          ),),
                        Text(
                          themes[i].name,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
