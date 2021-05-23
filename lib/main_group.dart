
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partswanted/register.dart';
import 'package:partswanted/services/auth.dart';
import 'package:toast/toast.dart';

import 'editgroup.dart';
import 'editstall.dart';
import 'formgroup.dart';
import 'main_menu.dart';

class MainGroup extends StatefulWidget {

  @override
  _MainGroupState createState() => _MainGroupState();
}

class _MainGroupState extends State<MainGroup> {


  String userId;
  String myEmail;
  int getPicDone=1;
  int docLength;

  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    _fcm.configure(onResume: (Map<String, dynamic> message) async {
      //print ("notification msg >>>>>>>>" + message.values.toString());
      //print ("notification msg :::::::::" + message['data']['groupId'].toString());
      //print ("notification msg :::::::::" + message['data']['stall'].toString());
      //print ("notification msg :::::::::" + message['data']['stallId'].toString());
      //print ("notification msg :::::::::" + message['data']['food'].toString());
      //print ("notification msg :::::::::" + message['data']['place'].toString());
      //print ("notification msg :::::::::" + message['data']['qty'].toString());
      //print ("notification msg :::::::::" + message['data']['remark'].toString());
      //print ("notification msg :::::::::" + message['data']['image'].toString());
      //print ("notification msg :::::::::" + message['data']['index'].toString());

      String groupIdNotify = message['data']['groupId'].toString();
      String indexNotify = message['data']['index'].toString();
      String stallIdNotify = message['data']['stallId'].toString();
      String imageNotify = message['data']['image'].toString();
      String stallNotify = message['data']['stall'].toString();
      String foodNotify = message['data']['food'].toString();
      String placeNotify = message['data']['place'].toString();
      String qtyNotify = message['data']['qty'].toString();
      String remarkNotify = message['data']['remark'].toString();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall(
        theGroupId: groupIdNotify,
        //theIndex: indexNotify, // can't passed index as integer over to here from notification, so shut it down
        theStallId: stallIdNotify,
        theImage: imageNotify, //image
        theStall: stallNotify, //whatModel
        theFood: foodNotify, //whatPN
        thePlace: placeNotify, //whatUse
        theQty: qtyNotify, //
        theRemark: remarkNotify, //remark
      )));
    });

    if(Platform.isIOS) { //////////////_1
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    FirebaseAuth.instance.currentUser().then((user) {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Register()));
      }
      else{
        userId = user.uid;
        myEmail = user.email;
        setState((){});
      }
    });
  }

  var imageUrl  = List.filled(20, "");
  var groupName = List.filled (20, "");//List (20);
  var groupId = List.filled(20, "");//List (20);
  int copied;

  Future getGroup() async {

    QuerySnapshot qn = await Firestore.instance.collection("users").document(myEmail).collection("Group").getDocuments();
    docLength = qn.documents.length;
    int x;
    for (x=0; x< docLength ; x++) {
      imageUrl[x] = await qn.documents[x].data['image'];
      groupName [x] = await qn.documents[x].data['groupName'];
      groupId [x] = await qn.documents[x].data['groupId'];
    }

    if (getPicDone !=3 ) {
      setState(() {});
      getPicDone++;
    } else{}
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    AuthMethods authmethods = new AuthMethods();

    getGroup();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: (Text("Our Strategic Pillars", style: TextStyle(color: Colors.white),)),
          centerTitle: true,
          backgroundColor: Colors.black,
          actions: [
            GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FormGroup(theMyEmail: myEmail)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.add),
                )),

            GestureDetector (
                onTap: (){
                  authmethods.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon (
                      Icons.exit_to_app
                  ),
                )
            )
          ]),

      body:
      Container(
          child: FutureBuilder(
              future: getGroup(),
              builder: (_, snapshot) {

                return ListView.builder(
                    itemCount: docLength,
                    itemBuilder: (_, index) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Text("Loading..."),
                        );
                      } else {
                        return ListTile(
                          title: GestureDetector(onTap: () {
                            groupId[index] != null? Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenu(theGroupId: groupId[index]))) :
                            Toast.show("No Family here", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM); /////// need to pass the groupId over to MainMenu
                          },
                            onLongPress: (){Navigator.push(context, MaterialPageRoute(builder: (context) => EditGroup(theGroupName: groupName[index], theGroupId: groupId[index], theImageUrl: imageUrl[index])));},
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: ClipRRect(
                                child:
                                imageUrl[index] == "" ? Center(child: Text("image null")) :
                                Image.network(imageUrl[index],
                                  width: 500, height: 350,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                        );
                      }
                    });
              })),
    );
  }

}