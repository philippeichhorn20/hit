import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/Dictionary.dart';
import 'package:hitstorm/backend/Topic.dart';

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
          backgroundColor: Colors.green,
          toolbarHeight: 75,
          title: TextField(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            cursorColor: Colors.black12,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(50.0),
                ),
                borderSide: BorderSide.none,
              ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(50.0),
                  ),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white30,
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
        body: FutureBuilder(
          future: DatabaseRequests.getSearchedTopics(searchConntroller.text),
          builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot){
            if (snapshot.hasError){
              return Center(
                child: Text(Dictionary.text("Sorry, we have a problem")),
              );
            }

            if (snapshot.hasData && snapshot.data.length == 0){

              return Center(
                child: Text(Dictionary.text("No results found")),
              );
            }

            if(snapshot.connectionState == ConnectionState.done){

              return ListView.builder(
                  itemCount: snapshot.data.toSet().length,
                  itemBuilder: (context, i){
                    Topic t = snapshot.data.toSet().elementAt(i);
                    return t.listViewTopic(context, setState);
                  }
              );
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
