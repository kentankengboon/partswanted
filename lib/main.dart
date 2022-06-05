
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partswanted/register.dart';
import 'package:partswanted/services/auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

import 'editgroup.dart';
import 'editstall.dart';
import 'formgroup.dart';
import 'main_group.dart';
import 'main_menu.dart';

import 'chart.dart';

/*
import 'package:flutter/cupertino.dart';
/// Global variables
/// * [GlobalKey<NavigatorState>]
class GlobalVariable {

  /// This global key is used in material app for navigation through firebase notifications.
  /// [navState] usage can be found in [notification_notifier.dart] file.
  static final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();
}
*/


//////////////////////////////////////  this is an empty page //////////////////////////////////
///////////////////////// upon activating it just right away divert to other place ///////////////
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Main());
}

class Main extends StatelessWidget {
  //Firebase.initializeApp();
  // This widget is the root of your application.
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      //navigatorKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Parts Wanted'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {




  User user = FirebaseAuth.instance.currentUser;

/*
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
*/
  @override
  void initState() {
    super.initState();
    //print ("...................at main");

/*  //// no use one doesn't get activated here. so shut it down
    _fcm.requestNotificationPermissions(); // actually like this works for KW iphone liao

    _fcm.configure(onResume: (Map<String, dynamic> message) async {
      //// !!! dont print, because it will cause problem for IOS if not the correct syntax
      //print ("inside onResume");
      //print ("notification msg >>>>>>>>" + message.values.toString());
      //print ("notification msg :::::::::" + message['groupId'].toString());
      print ("notification msg :::::::::" + message['data']['stall'].toString());
      //print ("notification msg :::::::::" + message['data'].toString());
      //print ("notification msg :::::::::" + message['data']['food'].toString()); // looks like wrong
      //print ("notification msg :::::::::" + message['data']['place'].toString());
      //print ("notification msg :::::::::" + message['qty'].toString()); // this on iphone works
      //print ("notification msg :::::::::" + message['data']['remark'].toString());
      print ("notification msg :::::::::" + message['data']['image'].toString());
      //print ("notification msg :::::::::" + message['data']['index'].toString());
      //print ("notification msg ::::::::: body: " + message['notification']['body'].toString());
/*
      String groupIdNotify = message['groupId'].toString();
      String indexNotify = message['index'].toString();
      String stallIdNotify = message['stallId'].toString();
      String imageNotify = message['image'].toString();
      String stallNotify = message['stall'].toString();
      String foodNotify = message['food'].toString();
      String placeNotify = message['place'].toString();
      String qtyNotify = message['qty'].toString();
      String remarkNotify = message['remark'].toString();
*/
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

        print ("at Android :" + foodNotify);
        print ("at Android :" + imageNotify);
      }


      // this one and below one more looks like all can. all serve the same purposes.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall(
        //Navigator.of(GlobalVariable.navState.currentContext).push(MaterialPageRoute(builder: (context) => EditStall(
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

/*
   // As said above, this also work, but I think StackoverFlow said this usually iused when you do not have a BuildContext yet.
   // I do this to try the IOS notification navigation to screen thing
      navigatorKey.currentState.pushReplacement(
          MaterialPageRoute(builder: (_) => EditStall(
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
*/
    });
*/



  }

  go(){
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));}
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Chart()));
    }
  }



  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_){
      // Add Your Code here. // if not I keep getting like state triggered without widget issue or something???
      // after this WidgetsFlutterBinding.ensureInitialized();
      // and await Firebase.initializeApp(); are inserted above
      go();
    });
    return Center(child: Text ("coming up...",
      style: TextStyle(
        decoration: TextDecoration.none,
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),));
  }
}