import 'package:flutter/material.dart';
import 'package:guyde/Classes/User.dart';
import 'package:guyde/Functions/OtherParseFunctions.dart';


class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin{
  List<User> userList = [User.test()];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2,initialIndex: 0);
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Stack(
          children: [


            TabBarView(
              controller: _tabController,

              children: [
                Padding(
                  padding: const EdgeInsets.only(top:60.0),

                  child: FutureBuilder<List<User>>(
                    future: OtherParseFunctions.getFriends(),
                    builder: (context, snapshot) {

                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: Text("Loading"));

                      }else if(snapshot.connectionState == ConnectionState.none||!snapshot.hasData ||snapshot.data == null || snapshot.data!.length == 0 ){
                        return Center(child: Text("shit"));
                      }



                      return ListView.builder(itemBuilder: (context, index){
                        User user = snapshot.data!.elementAt(index);
                        return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: user.toListTile(context, (){setState(() {});})
                        );
                      },
                        itemCount: snapshot.data!.length,
                      );
                    }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:60.0),
                  child: ListView.builder(itemBuilder: (context, index){
                    User user = userList[index];
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: user.toListTile(context, (){setState(() {});})
                    );
                  },
                    itemCount: userList.length,
                  ),
                ),
              ]
            ),
            Padding(
              padding: const EdgeInsets.only(left:30.0, top: 60),
              child: Container(
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
                    child:  Icon(Icons.arrow_back_ios, color: Colors.white,),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height*0.9,
              left: MediaQuery.of(context).size.width*0.3,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)
                    )
                ),
                child: Row(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: _tabController.index == 0 ? Colors.transparent :Colors.white,
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(20)
                            )
                        ),
                        child: TextButton(onPressed: (){
                          print("pressed");

                          setState(() {
                            _tabController.animateTo(1);
                          });                        },
                          child: Text("Following", style: TextStyle(
                              color: Colors.white, fontSize: 14
                          ),),

                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: _tabController.index == 1 ? Colors.transparent: Colors.white,
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(20)
                            )
                        ),
                        child: TextButton(onPressed: (){
                          print("pressed");

                          setState(() {
                            _tabController.animateTo(0);
                          });                        },
                          child: Text("Following", style: TextStyle(
                              color: Colors.white, fontSize:14
                          ),),

                        )
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
