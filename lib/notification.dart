
// //////////////////  NOT USED //////////////
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'editstall.dart';

class Notifications {

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
  int resuming;

  notifyAndNavigate() {
    _fcm.requestNotificationPermissions(); // actually like this works for KW iphone liao

    _fcm.configure(onResume: (Map<String, dynamic> message) async {
      resuming = 1;
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
        jobRefNoNotify = message['jobRefNo'].toString(); // added for unIssuedPo purpose
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
      }

/*
      // this one and below one more looks like all can. all serve the same purposes.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall(
            //Navigator.of(GlobalVariable.navState.currentContext).push(MaterialPageRoute(builder: (context) => EditStall(
            theGroupId: groupIdNotify,
            //theIndex: indexNotify, // can't passed index as integer over to here from notification, so shut it down
            theStallId: stallIdNotify,
            theImage: imageNotify,
            theStall: stallNotify,
            theFood: foodNotify,
            thePlace: placeNotify,
            theQty: qtyNotify,
            theRemark: remarkNotify,
          )));

*/

    });

    //return groupIdNotify;
  }



}