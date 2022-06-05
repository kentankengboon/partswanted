
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partswanted/register.dart';
import 'package:partswanted/requestors.dart';
import 'package:partswanted/securespace.dart';
import 'package:partswanted/services/auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'editgroup.dart';
import 'editstall.dart';
import 'food.dart';
import 'formgroup.dart';
import 'main.dart';
import 'main_menu.dart';


import 'package:partswanted/testsite.dart';

class MainGroup extends StatefulWidget {

  final theSpecialChnPassword; // added for YQ
  MainGroup({this.theSpecialChnPassword});// added for YQ

  @override
  //_MainGroupState createState() => _MainGroupState();
  _MainGroupState createState() => _MainGroupState(specialChnPassword: theSpecialChnPassword); // changed to this for YQ
}

class _MainGroupState extends State<MainGroup> {

  _MainGroupState({this.specialChnPassword});// added for YQ
  String specialChnPassword;// added for YQ
  String userId;
  String myEmail;
  int getPicDone=1;
  int docLength;



  FirebaseMessaging _fcm = FirebaseMessaging();
  //final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator"); // this is to try the IOS notification navigation thing

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
  @override
  void initState() {
    super.initState();
    //print ("...................at main_group");
    //print("special password:      " + specialChnPassword);

    //if (specialChnPassword == "tebieguandao"){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: "req@gmail.com", theSpecialChnPassword: specialChnPassword)));} // added for YQ
//else { // this else is only for YQ, if not just do below, no need else
    if (specialChnPassword != "tebieguandao") { //added for YQ
      _fcm.requestNotificationPermissions(); // actually like this works for KW iphone liao
      _fcm.configure(onResume: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          groupIdNotify = message['groupId'].toString();
          indexNotify = message['index'].toString();
          stallIdNotify = message['stallId'].toString();
          imageNotify = message['image'].toString();
          stallNotify = message['stall'].toString();
          foodNotify = message['food'].toString();
          placeNotify = message['place'].toString();
          qtyNotify = message['qty'].toString();
          remarkNotify = message['remark'].toString();
          jobRefNoNotify =
              message['jobRefNo'].toString(); // added for unIssuedPo purpose
          notifyToEditStall();
          //print ("index notify at main a string:" + indexNotify);

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
          jobRefNoNotify =
              message['jobRefNo'].toString(); // added for unIssuedPo purpose
          notifyToEditStall();
          //print ("at Android :" + foodNotify);
          //print ("index notify at main_group: " + indexNotify);
          //print ("groupIdNotify at main_group: " + groupIdNotify);
        }
      });

      User user = FirebaseAuth.instance.currentUser;
      //print ("user: " + user.toString());
      userId = FirebaseAuth.instance.currentUser.uid;
      //print (specialChnPassword);
      //if (specialChnPassword != "tebieguandao") {userId = FirebaseAuth.instance.currentUser.uid;} // changed for YQ
      if (user == null) {
        //if (user == null && specialChnPassword != "tebieguandao") { //added for YQ
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Register()), (
            Route<dynamic>route) => false);
      }
      else {
        userId = user.uid;
        myEmail = user.email;

        FirebaseFirestore.instance.collection("users").doc(myEmail).get().then((
            value) {
          userName = value['name'];
        });
        setState(() {});
      }
    }
    //}
  }

  notifyToEditStall(){
    // this ken@r-logic.comAll about B2C group IS THE SECRET GROUP. so if notify groupID not from this group (that means for other groupID one, then no issue, go chat space.
    // if it is about this secret groupID, then cannot go in, unless userId is verified.
    if (groupIdNotify != "ken@r-logic.comAll about B2C" || userId == "5HQjvArqxmZh5Cnwd7huTalo2bh1" || userId == "5ksQrdScGtRMNibBC9chqXnqbyF2") { // this if is for secret space purpose only
      // this one and below one more looks like all can. all serve the same purposes.
      int indexNotifyInt = int.parse(indexNotify); //but wait, this like not working, render failure to navigate to editstall // can't pass index as integer over to here from notification, so must pass String and convert to int
      // use var instead?
      //print ("index notify at main a string _ 2:" + indexNotify);
      //print ("xxx    " + indexNotifyInt.toString());
      //Toast.show("Going editStall:  " + groupIdNotify + " - " + indexNotify.toString(), context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
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


  getPermission()async{
    //Toast.show("GM 1111", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
    await Permission.storage.request();
    //await Permission.camera.request();
    //if (await Permission.camera.request().isGranted) {Toast.show("Camera permission granted", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
    //else {Toast.show("No camera access permitted", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
    //if (await Permission.storage.request().isGranted) {Toast.show("File access permission granted", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
    //else {Toast.show("No file access permitted", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}

  }

  //var imageUrl  = List.filled(20, "");
  //var groupName = List.filled (20, "");//List (20);
  //var groupId = List.filled(20, "");//List (20);
  List imageUrl  = [];
  List groupName = [];
  List groupId = [];

  int copied;
  String userStatus ="-";

  getUserStatus()async{
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myEmail)
        .get()
        .then((value) async {
      if (value.data()['userStatus'] != null){
        if (value['userStatus'] != "SuperUser"){
          userStatus = "DoesntMatter";
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: myEmail)));
        } else{userStatus = "SuperUser";}
      }else{userStatus = "DoesntMatter";}
    });
    //print ("prinet here:   " + superUser);
  }

  Future getGroup() async {
    QuerySnapshot qn = await FirebaseFirestore.instance.collection("users").doc(myEmail).collection("Group").get();
    docLength = qn.docs.length;
    //print ("herrrrr");
    //print ("doclength " + docLength.toString());
    int x;
    for (x=0; x< docLength ; x++) {
      //if (qn.docs[x]['image'] != ""){
      imageUrl.add(await qn.docs[x]['image']);
      //print ("x: " + x.toString() + "     imageUrl" + imageUrl[x]);
      //}
      groupName.add(await qn.docs[x]['groupName']);
      groupId.add(await qn.docs[x]['groupId']);
      //print ("x: " + x.toString() + "     groupId:  " + groupId[x]);
    }
    if (getPicDone !=3 ) {
      if (mounted) setState(() {});
      getPicDone++;
    } else{}
    return qn.docs;
  }



  @override
  Widget build(BuildContext context) {

    if (specialChnPassword == "tebieguandao") //added for YQ
    {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) =>
                Food(theGroupId: "req@gmail.com",
                    theSpecialChnPassword: specialChnPassword)));
      });
      return Container();
    } // added for YQ


    else { //added for YQ
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      AuthMethods authmethods = new AuthMethods();

      getUserStatus();
      getGroup();
      //getPermission(); // shut it down, looks like not what needed to solve image picker permssion issue
//print ("superUser?  " + superUser);


      //return new MaterialApp( // this was written in to try the IOS notification navigation.
      // to remove, change the home: at Scaffold to return and remove a ) for this MaterialApp at bottom
      // and delete away the debugShowCheckedModeBanner: false, and navigatorKey: navigatorKey here
      //debugShowCheckedModeBanner: false,
      //navigatorKey: navigatorKey,
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: (Text("Welcome " + userName + "!",
              style: TextStyle(color: Colors.white),)),
            centerTitle: true,
            backgroundColor: Colors.black,
            actions: [
              userStatus == "SuperUser" ?
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => FormGroup(theMyEmail: myEmail)));
                  },

                  onLongPress: () {
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => secureSpace(theGroupId: "ken@r-logic.comAll about B2C")));
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SecureSpace()));
                  },


                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.add),
                  )) : Text(""),

              GestureDetector(
                  onTap: () {
                    authmethods.signOut();
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Register()), (
                        Route<
                            dynamic>route) => false); // remove all page excpet to the latest
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                    child:
                    //Icon (Icons.exit_to_app),
                    Text("logout"),
                  )
              )


              // below for testing supplier entry ////////////////////////
              // delete this section when testing done
              ,
              GestureDetector(
                  onTap: () {
                    //authmethods.signOut();
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TestSite(theSupplier: "GLOBAL TECHNOLOGY" ))); // remove all page excpet to the latest
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                    child:
                    //Icon (Icons.exit_to_app),
                    Text("supplier"),
                  )
              )
              ////////////////////////////////////////////////////////

            ]),

        body:
/*
      userStatus != "SuperUser"?

      userStatus == "-" ? Text (""):
      Column(
        children: [
          SizedBox(height: 30),
          Text(myEmail, style: TextStyle(fontSize: 20, color: Colors.white)),
          SizedBox(height: 30),
          GestureDetector(onTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId[0])));
          },
            child: Image.asset("assets/parts.png",
              fit: BoxFit.fitWidth,
              width: 400, height: 200,
            ),
          ),
          Text ("", style: TextStyle(fontSize: 12, color: Colors.white))
        ],)
          :
*/

        Container(
            child:
            FutureBuilder(
                future: getGroup(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text("Loading...",
                          style: TextStyle(color: Colors.black, fontSize: 10)),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: docLength,
                        itemBuilder: (_, index) {
                          //print ("here 00000");
                          return ListTile(
                            title: GestureDetector(onTap: () {
                              //print ("is here1111111111111111");
                              if (groupId[index] != null) {
                                // actually no need the if condition here bcos if not SuperUser, he can't come here, right?
                                //print ("is here");
                                userStatus == "SuperUser" ?


                                // secret check, but comment out groupId[index] == "ken@r-logic...." and :Toast to remove the secret check
                                groupId[index] == "ken@r-logic.comAll about B2C"
                                    ?

                                //(userId == "oHbW3mrxT8VlvenzLUd4YKQjGXX2" || userId == "94b7TA43zVZiAD7rrBTMNXOvfUj2") ?
                                //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainMenu(theGroupId: groupId[index])))
                                //  :Toast.show("Work in progress", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP)
                                Toast.show("Work in progress", context,
                                    duration: Toast.LENGTH_LONG,
                                    gravity: Toast.TOP)

                                    : Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) =>
                                        MainMenu(theGroupId: groupId[index])))


                                    : groupId[index] ==
                                    "ken@r-logic.comAll about B2C" ? Toast.show(
                                    "Please pick a group", context,
                                    duration: Toast.LENGTH_LONG,
                                    gravity: Toast.TOP) :

                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) =>
                                        Food(theGroupId: groupId[index])));
                                //if (index==0){ Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenu(theGroupId: groupId[index])));}
                                //if (index==1){Navigator.push(context, MaterialPageRoute(builder: (context) => Requestors()));}
                                //if (index!=0){Navigator.push(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId[index],)));}
                              }
                              else {
                                Toast.show("No Family here", context,
                                    duration: Toast.LENGTH_LONG,
                                    gravity: Toast.BOTTOM);
                              } /////// need to pass the groupId over to MainMenu
                            },
                              onLongPress: () {
                                // cannot use pushReplacement because after editGroup, it has to pop back here
                                if (userStatus == "SuperUser") {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          EditGroup(
                                              theGroupName: groupName[index],
                                              theGroupId: groupId[index],
                                              theImageUrl: imageUrl[index])));
                                }
                                else {}
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: ClipRRect(
                                  child:
                                  imageUrl[index] == "" ?

                                  groupId[index] == "req@gmail.com" ?
                                  Image.asset("assets/parts.png",
                                    fit: BoxFit.fitWidth,
                                    width: 400, height: 100,
                                  )
                                      : Center(child: Text(groupName[index],
                                    style: TextStyle(color: Colors.blue),))


                                      : Image.network(imageUrl[index],
                                    width: 500,
                                    height: 100,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                          );
                        });
                  }
                })),


      );
//);
    }
  }
}
