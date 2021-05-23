
import 'package:flutter/material.dart';
import 'package:partswanted/food.dart';
import 'package:toast/toast.dart';

class MainMenu extends StatefulWidget {
  final theGroupId;
  MainMenu({this.theGroupId});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {


  @override
  Widget build(BuildContext context) {
    String groupId = widget.theGroupId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.black,
        title: (Text ("Main Menu")),
      ),

      // here, I set up a simple 2-picture UI (getparts and events) as subgroups
      // but you can go ahead and list only those subgroup that the users was invited to
      // by doing the same like in the main.dart
      // where the respective subgroup eligible to user was stated in firestore collection: users\my email\Group\groupname\[data]
      // this [data] can be logged to firestore through invitation by anyone who longpressed the subgroup icon below (just like the main.dart)
      // but bare in mind in doing so, you created 2 level of member-groupings, one at main one at this main-menu
      // or perhaps forget the main? let all users be at main? hmm...maybe this is better...

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(height: 200,
              child: Row(
                  children: [
                    Column(
                      children: [
                        Expanded(flex: 5,
                          child: Container(
                            //color: Colors.white,
                              child: GestureDetector(onTap: () {Toast.show("work in progress", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);},
                                child: Image.asset("assets/getparts.jpg",
                                  //fit: BoxFit.fitHeight,
                                  //width: 300, height: 100,
                                ),
                              )),
                        ),
                        //SizedBox(height: 10),
                        Expanded(flex: 1,child: Text("events",style: TextStyle(color: Colors.white))),
                      ],
                    ),
                    SizedBox(width: 5),

                    Flexible(
                      child: Column(
                        children: [
                          Expanded(flex: 5,
                            child: Container(
                                color: Colors.white,
                                child: GestureDetector (onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId)));
                                },
                                    child: Image.asset("assets/parts.png",
                                      //fit: BoxFit.fitWidth,
                                      //width: 300, height: 191
                                    ))
                              //child: Image.asset("assets/family2.png")),
                            ),
                          ),
                          //SizedBox(height: 10),
                          Expanded(flex: 1,child: Text("get parts",style: TextStyle(color: Colors.white))),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ],
      ),



    );


  }

}