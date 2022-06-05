
////////////////  not used ////////////

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partswanted/register.dart';
import 'package:partswanted/services/auth.dart';
import 'package:toast/toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'editgroup.dart';
import 'editstall.dart';
import 'formgroup.dart';
import 'main.dart';
import 'main_menu.dart';

class Requestors extends StatefulWidget {

  @override
  _RequestorsState createState() => _RequestorsState();
}

class _RequestorsState extends State<Requestors> {


  String userId;
  String myEmail;
  int getPicDone=1;
  int docLength;

  FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _fcm.requestNotificationPermissions();
    _fcm.configure(onResume: (Map<String, dynamic> message) async {

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
        theStallDocId: stallIdNotify,
        theImage: imageNotify, //image
        theStall: stallNotify, //whatModel
        theFood: foodNotify, //whatPN
        thePlace: placeNotify, //whatUse
        theQty: qtyNotify, //
        theRemark: remarkNotify, //remark
      )));
    });


    User user = FirebaseAuth.instance.currentUser;
    userId = FirebaseAuth.instance.currentUser.uid;
    if (user == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Register()));
    }
    else{
      userId = user.uid;
      myEmail = user.email;
      setState((){});
    }
  }

  var imageUrl  = List.filled(20, "");
  var groupName = List.filled (20, "");//List (20);
  var groupId = List.filled(20, "");//List (20);
  int copied;

  Future getGroup() async {

    QuerySnapshot qn = await FirebaseFirestore.instance.collection("users").doc(myEmail).collection("Group").get();
    docLength = qn.docs.length;
    int x;
    for (x=0; x< docLength ; x++) {
      imageUrl[x] = await qn.docs[x]['image'];
      groupName [x] = await qn.docs[x]['groupName'];
      groupId [x] = await qn.docs[x]['groupId'];
    }

    if (getPicDone !=3 ) {
      setState(() {});
      getPicDone++;
    } else{}
    return qn.docs;
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    AuthMethods authmethods = new AuthMethods();

    getGroup();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: (Text("Requestors", style: TextStyle(color: Colors.white),)),
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
                              child: Text ("supplier see all buyers. buyer go straight to food widget", style:
                              TextStyle(fontSize: 13, color: Colors.white) )


/*
                              child: ClipRRect(
                                child:
                                imageUrl[index] == "" ? Center(child: Text("image null")) :
                                Image.network(imageUrl[index],
                                  width: 500, height: 350,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
*/

                            ),
                          ),
                        );
                      }
                    });
              })),
    );
  }

}