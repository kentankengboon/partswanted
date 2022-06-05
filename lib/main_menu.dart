import 'dart:io';
import 'package:flutter/material.dart';
import 'package:partswanted/food.dart';

import 'package:toast/toast.dart';

import 'editstall.dart';
import 'main_group.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainMenu extends StatefulWidget {
  final theGroupId;
  //final theUserStatus;
  MainMenu({this.theGroupId});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {


  FirebaseMessaging _fcm = FirebaseMessaging();
  String groupIdNotify;
  String indexNotify;
  String stallIdNotify;
  String imageNotify;
  String stallNotify;
  String foodNotify;
  String placeNotify;
  String qtyNotify;
  String remarkNotify;
  String jobRefNoNotify; // added for unIssuedPo purpose
  String userName = "";
  String userId;

  void initState(){
    //print ("at init   " + userStatus);
    super.initState();
    //print ("...................at main_menu");
    userId = FirebaseAuth.instance.currentUser.uid;
    _fcm.requestNotificationPermissions(); // actually like this works for KW iphone liao

    _fcm.configure(onResume: (Map<String, dynamic> message) async {

      if(Platform.isIOS) {
        groupIdNotify = message['groupId'].toString();
        indexNotify = message['index'].toString();
        stallIdNotify = message['stallId'].toString();
        imageNotify = message['image'].toString();
        stallNotify = message['stall'].toString();
        foodNotify = message['food'].toString();
        placeNotify = message['place'].toString();
        qtyNotify = message['qty'].toString();
        remarkNotify = message['remark'].toString();
        jobRefNoNotify = message['jobRefNo'].toString(); // added for unIssuedPo purpose
        notifyToEditStall();

      } else {
        groupIdNotify = message['data']['groupId'].toString();
        indexNotify = message['data']['index'].toString();
        stallIdNotify = message['data']['stallId'].toString();
        imageNotify = message['data']['image'].toString();
        stallNotify = message['data']['stall'].toString();
        foodNotify = message['data']['food'].toString();
        placeNotify = message['data']['place'].toString();
        qtyNotify = message['data']['qty'].toString();
        remarkNotify = message['data']['remark'].toString();
        jobRefNoNotify = message['jobRefNo'].toString(); // added for unIssuedPo purpose
        notifyToEditStall();
        //print ("at Android :" + foodNotify);
        //print ("at Android :" + imageNotify);
      }
    });
  }

  notifyToEditStall(){
    // this ken@r-logic.comAll about B2C group IS THE SECRET GROUP. so if notify groupID not from this group (that means for other groupID one, then no issue, go chat space.
    // if it is about this secret groupID, then cannot go in, unless userId is verified.
    if (groupIdNotify != "ken@r-logic.comAll about B2C" || userId == "5HQjvArqxmZh5Cnwd7huTalo2bh1" || userId == "5ksQrdScGtRMNibBC9chqXnqbyF2") { // this if is for secret space purpose only
      // this one and below one more looks like all can. all serve the same purposes.
      int indexNotifyInt = int.parse(indexNotify); // can't pass index as integer over to here from notification, so must pass String and convert to int
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall(
        //Navigator.of(GlobalVariable.navState.currentContext).push(MaterialPageRoute(builder: (context) => EditStall(
        theGroupId: groupIdNotify,
        theIndex: indexNotifyInt,
        theStallDocId: stallIdNotify,
        theImage: imageNotify, //image
        theStall: stallNotify, //whatModel
        theFood: foodNotify, //whatPN
        thePlace: placeNotify, //whatUse
        theQty: qtyNotify, //
        theRemark: remarkNotify, //remark
        theJobRefNo: jobRefNoNotify, // added for unIssuedPo purpose
      )));
    }
  }



  @override
  Widget build(BuildContext context) {
    String groupId = widget.theGroupId;
    //String userStatus = widget.theUserStatus;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));
              //Navigator.pop(context);
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
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId)));
                                  // to fix routing issue, cannot use this >> Navigator.push(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId)));
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