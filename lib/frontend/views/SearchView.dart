import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/Topic.dart';
import 'package:hitstorm/frontend/views/Overview.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController searchConntroller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios, size: 30, color: Colors.black54,),
          ),
          bottom: PreferredSize(
              child: Container(
                color: Colors.green,
                height: 1.5,
              ),
              preferredSize: Size.fromHeight(1.5)),
          backgroundColor: Colors.white,
          toolbarHeight: 75,
          title: SizedBox(
            height: 50,
            child: TextField(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              cursorColor: Colors.black12,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30.0),
                  ),
                  borderSide: BorderSide.none,
                ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey.shade200,
        filled: true,
        hintText: 'Search',
        hintStyle: TextStyle(fontSize: 18,)
    ),
              onChanged: (text){
                setState(() {
                  searchConntroller;
                });
              },
              controller: searchConntroller,
            ),
          ),
        ),
        body: FutureBuilder(
                future: DatabaseRequests.getSearchedTopics(searchConntroller.text),
                builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot){


                  if (snapshot.hasData && snapshot.data.toSet().length + DatabaseRequests.themes.length == 0){
                    return Center(
                      child: Text(Dictionary.text("No results found")),
                    );
                  }

                  if(snapshot.connectionState == ConnectionState.done){
                    if(searchConntroller.text.length == 0){
                      return Padding(
                        padding: const EdgeInsets.only(bottom:8.0),
                        child: ListView.builder(
                        //   physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                            itemCount: ((!snapshot.hasData || snapshot.data == null) ? 0:snapshot.data.toSet().length) + DatabaseRequests.themes.length+1,
                            itemBuilder: (context, i){
                              if(snapshot.hasData && snapshot.data != null && i < snapshot.data.toSet().length){
                                Topic t = snapshot.data.toSet().elementAt(i);
                                return t.listViewTopic(context, setState);
                              }else if(((!snapshot.hasData || snapshot.data == null)? 0 : snapshot.data.toSet().length) == i){
                                return Column(
                                  children: [
                                    Container(
                                      color: Colors.grey.shade300,
                                        padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                                        margin: EdgeInsets.only( top: 10, bottom: 10),

                                        alignment: Alignment.centerLeft,
                                        child: Text(Dictionary.text("Groups: "),
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black54),
                                        )
                                    ),

                                  ],
                                );
                            }else{
                                var theme = DatabaseRequests.themes[i-((!snapshot.hasData || snapshot.data == null )? 0: snapshot.data.toSet().length)-1];
                                return theme.toWidget(context);
                              }

                            }
                        ),
                      );
                    }else{
                      return ListView.builder(
                          itemCount: snapshot.data.toSet().length,
                          itemBuilder: (context, i){
                            Topic t = snapshot.data.toSet().elementAt(i);
                            return t.listViewTopic(context, setState);
                          }
                      );
                    }
                  }
                  return Container(
                    child: Center(
                       child: CircularProgressIndicator(
                      backgroundColor: Colors.green,
                    ),
                    ),
                  );
                },
              ),



      ),
    );
  }
}
