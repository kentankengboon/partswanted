

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:partswanted/pictures.dart';
import 'package:partswanted/po_records.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:toast/toast.dart';

import 'addstall.dart';
import 'chart.dart';
import 'editstall.dart';
import 'main_group.dart';
import 'main_menu.dart';
import 'notification.dart';
//import 'addstall.dart';
//import 'editstall.dart';

class Food extends StatefulWidget {
  final thePageTitle;
  final theGroupId;
  final theStallIndex;
  final thePreviousSort;
  final theSpecialChnPassword; //added for YQ
  //final theCustomerIs;
  //final theChartingFor;
  //final theUserStatus;
  Food({this.thePageTitle, this.theGroupId, this.theStallIndex, this.thePreviousSort, this.theSpecialChnPassword}); //added the SpecialPasswrod for YQ
  //Food({this.thePageTitle, this.theGroupId, this.theStallIndex, this.thePreviousSort, this.theSpecialChnPassword, this.theCustomerIs, this.theChartingFor}); //added the SpecialPasswrod for YQ

  @override
  _FoodState createState() => _FoodState(pageTitle: thePageTitle, groupId: theGroupId, stallIndex: theStallIndex, previousSort: thePreviousSort, specialChnPassword: theSpecialChnPassword);//added the SpecialPasswrod for YQ
  //_FoodState createState() => _FoodState(pageTitle: thePageTitle, groupId: theGroupId, stallIndex: theStallIndex, previousSort: thePreviousSort, specialChnPassword: theSpecialChnPassword, customerIs: theCustomerIs, chartingFor: theChartingFor);//added the SpecialPasswrod for YQ
}

class _FoodState extends State<Food> {
  //int connected;
  String groupId;
  String previousSort;
  int stallIndex;
  int docLength;
  String specialChnPassword; //added for YQ
  String customerPick;
  //String customerIs;
  String chartingFor;
  //String addNew = "";
  //final userStatus;
  _FoodState({this.pageTitle, this.groupId, this.stallIndex, this.previousSort, this.specialChnPassword}); // added specialPasswrod for YQ
  //_FoodState({this.pageTitle, this.groupId, this.stallIndex, this.previousSort, this.specialChnPassword, this.customerIs, this.chartingFor}); // added specialPasswrod for YQ

// todo: added with mobile cannot go to the last white PN
// todo: also -2 seems to have null problem?
// todo: how to red the PN when add new, or does it already? no right, red is only when gotmail rigth? done for webentry
  Future _getStall;
  AutoScrollController controller;
  final scrollDirection = Axis.vertical;
  //var controller = IndexedScrollController();

  //int stallIndex;
  String userId;
  String myEmail;
  String pageTitle;
  String userStatus;
  //List gotMail = []; // using this has unlimited growing list length, but I dont know how to assign the initial value to avoid null issue
  List <int> gotMail = List.filled(1000, 0, growable: true); //with this I can assign initial value od 0 to the List to avoid null issue. but it can growable to 100 I think
  List <int> multipleParts = List.filled(1000, 0, growable: true);
  //List multipleParts = [];
  //List stallIdOrder = List.filled(100, 0, growable: true);
  List stallIdOrder = [];


  //var partMore = List.generate(200, (i) => List(5), growable: false);
  //var morePart = new List.generate(200, (_) => new List(5));



  int stateSet=0;
  int gotMailChk=0;



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
  String userName = "";
  String previousChoice;
  String jobRefNoNotify; // added for unIssuedPo purpose


  void initState(){
    //print (".............at food init");
    super.initState();
//print("here at init:");
    //print ("...................at food");
    //print ("stallIndex at food: " + stallIndex.toString());
//if(customerIs != null){print("customerIs: " + customerIs);}
//if(chartingFor != null){print("chartingfor: " + chartingFor);}


    ///// if (customerIs == "Lenovo" && chartingFor == "toQuote"){customerPick = customerIs; getToQuote();} //// put where????

    if (specialChnPassword == "tebieguandao"){userId = "IWvhdoNgkCdXltByrveXP2lvypE2"; myEmail = "req@gmail.com";userStatus = "Rlogic";}else { //"If" added for YQ
      User user = FirebaseAuth.instance.currentUser;
      userId = FirebaseAuth.instance.currentUser.uid;
      userId = user.uid;
      //userId = "IWvhdoNgkCdXltByrveXP2lvypE2"; //changed for YQ
      myEmail = user.email;

      //myEmail = "req@gmail.com"; // changed for YQ
      //print("userid:   " + userId);
      //print("useremail: " + myEmail);

    getUserStatus();
//IWvhdoNgkCdXltByrveXP2lvypE2
    }
// secret check
    if (groupId == "ken@r-logic.comAll about B2C" ) {
      if ( userId != "5HQjvArqxmZh5Cnwd7huTalo2bh1"){
        //if ( userId != "oHbW3mrxT8VlvenzLUd4YKQjGXX2"){
        //if (userId != "94b7TA43zVZiAD7rrBTMNXOvfUj2")
        if (userId != "5ksQrdScGtRMNibBC9chqXnqbyF2")
        {groupId = "req@gmail.com";}
      }
    }

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



/*
    Notifications notice = Notifications();
    //print (notice.groupIdNotify);

    if (notice.resuming == 1){
      print ("resuming:   " + notice.resuming.toString());
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall(
    //Navigator.of(GlobalVariable.navState.currentContext).push(MaterialPageRoute(builder: (context) => EditStall(
    theGroupId: notice.groupIdNotify,
    //theIndex: notice.indexNotify, // can't passed index as integer over to here from notification, so shut it down
    theStallId: notice.stallIdNotify,
    theImage: notice.imageNotify,
    theStall: notice.stallNotify,
    theFood: notice.foodNotify,
    thePlace: notice.placeNotify,
    theQty: notice.qtyNotify,
    theRemark: notice.remarkNotify,
    )));
    } else {}
*/

    FirebaseFirestore.instance
        .collection("users")
        .doc(myEmail)
        .get()
        .then((value) async {
      if (value.data()['userStatus'] != null){
        if (value['userStatus'] == "Rlogic") {
          userStatus = "Rlogic";}
        else {
          if (value['userStatus'] == "SuperUser") {
            userStatus = "SuperUser";
            //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: myEmail)));
          } else {
            userStatus = "Requestor";
          }
        }
      }else{userStatus = "Requestor";}
    });
    //whatPartGotMail();
    if(pageTitle ==null) {pageTitle = "by Date";} // change to "by Date" from original's "All parts"
    //userId = FirebaseAuth.instance.currentUser.uid; //no need. shut down when doing YQ thing
    if (pageTitle == "by Date"){_getStall = getStall();}
    if (pageTitle == "Archived"){_getStall = getArchive();}
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: scrollDirection);
    //print ("userStatus:  " + userStatus);
    //setState(() {});
//print ("previous;  " + previousSort.toString());
    if (previousSort == null){previousSort = "";} // this is just for conditional testing later in the code
    if (previousSort != "") {overflowSelected("");}

/*
    FirebaseFirestore.instance.collection(groupId)
        .get().then((value){
          print (value.size);
          for (int m=0; m< value.size; m++){
            gotMail.add(0);
          }
      });
*/
    //conditionCode();
  }

/*
    conditionCode(){ // todone: can this be done at various state of data entry? Or leave it here as a total re-run
      String cus;
      String arc;
      int stg;
      String condCust;
      String condStage;
      FirebaseFirestore.instance.collection(groupId)
          .get().then((result) {
        if (result.docs.length > 0) {
          result.docs.forEach((part) {
            cus = ""; arc =""; stg=0;
            //print ("moreParts: " + part["whatPN"]);
            if (part.data()['since'] != null) {
              if (part["since"] == "archived") {arc = "ARC";} else {arc = "ARN";}
            }else {arc = "ARN";}
            if (part.data()['customer'] != null) {
              if (part["customer"] == ""){cus = "XXX";}
              if (part["customer"] == "Harvey Norman"){cus = "HVN";}
              if (part["customer"] == "Courts"){cus = "COU";}
              if (part["customer"] == "Asus"){cus = "ASU";}
              if (part["customer"] == "B2C"){cus = "B2C";}
            }
              condCust = cus + arc;

            if (part.data()['stage'] != null) {
              stg = part["stage"];
            }
              condStage = stg.toString() + arc;

            //stageCode = "AAA";
            if (cus != "" && arc !=""){
              //FirebaseFirestore.instance.collection(groupId).doc(part.id).update({"condCode": condCust});
              FirebaseFirestore.instance.collection(groupId).doc(part.id).update({"condCode": [ condCust, condStage ]});
              //FirebaseFirestore.instance.collection(groupId).doc(part.id).update({"condCode": FieldValue.delete()});
              //FirebaseFirestore.instance.collection(groupId).doc(part.id).update({condCode: FieldValue.delete()});
            }
/*
            if (part.data()['whenAsk'] != null) {
              String timeString = part['whenAsk'];
              String yyyy = timeString.substring(0, 4);
              String mm = timeString.substring(5, 7);
              String dd = timeString.substring(8, 10);
              print("yyyy:" + yyyy + " mm:" + mm + " dd:" + dd);
              print (part['whenAsk']);

              print(DateTime.parse(yyyy + mm + dd));
              if(arc == "ARN"){FirebaseFirestore.instance.collection(groupId).doc(part.id).update({"since": DateTime.parse(yyyy + mm + dd)});}
            }
*/
            //////// below here is for registrating the number of morePart so that I can show the PN at food without running into null issue
            // todone: this can really be done at data entry source, and better do that, or not? (Done at webentry addMorePart)
            int morePartLength=0;
            FirebaseFirestore.instance.collection(groupId).doc(part.id).collection("moreParts").get()
            .then((moreValue) {
              morePartLength = moreValue.docs.length;
              FirebaseFirestore.instance.collection(groupId)
                  .doc(part.id)
                  .update({"morePartQty": morePartLength});});
            /////////////////////////

          });
        }
      });
    }
*/

  getUserStatus()async{
    //print ("getUserStatus");
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myEmail)
        .get()
        .then((value) async {
      if (value.data()['userStatus'] != null){
        userStatus = value['userStatus'];
      }
    });
    setState(() {});
    //print ("prinet here:   " + superUser);
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

  whatPartGotMail(currentSnap)async {
    //print ("whatPartGotMail");
    int stallCount=0;
    stallIdOrder.clear();
    //gotMail.clear();
    await currentSnap
        .get().then((value){
      value.docs.forEach((stallId) async{
        //stallIdOrder[stallCount] = stallId.id;
        stallIdOrder.insert(stallCount, stallId.id);
        //gotMail.insert(stallCount, 0);
        gotMail[stallCount] = 0;
        multipleParts[stallCount] = 0;
        stallCount ++;
        //gotMail.add(0);
        //multipleParts.add(0);

        await FirebaseFirestore.instance.collection(groupId).doc(stallId.id).collection('mailBox')
            .get().then((mailBox){
          if (mailBox.docs.length >0){
            //print ("stallIdOrder:  " + stallIdOrder.length.toString() + "      gotMail:  " + gotMail.length.toString() + "       stallCount:   " + stallCount.toString());

            mailBox.docs.forEach((email){
              if (email.id == myEmail){
                if (email['gotMail'] == 1){
                  for (int x=0; x< stallIdOrder.length; x++){
                    if (stallIdOrder[x] == stallId.id) {
                      gotMail[x] = 1; // todo: try: got to be the last one which is stallIdOrder-1 like below multiplsParts right?
                      //gotMail.insert(x, 1);
                    }
                  }
                  //if(mounted) {setState(() {});}  //shut down so that wont run build so many time, but ok?
                }
                if (email['gotMail'] == -1){
                  for (int x=0; x< stallIdOrder.length; x++){
                    if (stallIdOrder[x] == stallId.id) {
                      gotMail[x] = -1; // todo: try: got to be the last one which is stallIdOrder-1 like below multiplsParts right?
                      //gotMail.insert(x, 1);
                    }
                  }
                  //if(mounted) {setState(() {});} //shut down so that wont run build so many time, but ok?
                }
              }
            });//if(mounted) {setState(() {});}
          }else {}
        });

        await FirebaseFirestore.instance.collection(groupId).doc(stallId.id).collection('moreParts')
            .get().then((moreParts){
          if (moreParts.docs.length >0){
            //print ("stallIdOrder:  " + stallIdOrder.length.toString());

            for (int y=0; y< stallIdOrder.length; y++){
              if (stallIdOrder[y] == stallId.id) { multipleParts[y] = 1; // todo: try: got to be the last one which is stallIdOrder-1 like below multiplsParts right?
              }
            }
            //if(mounted){setState(() {});} //shut down so that wont run build so many time, but ok?
          }//if(mounted){setState(() {});}
        });if(mounted){setState(() {});} // works only then setstate here, but multiple build runs will happen
        //for (int x=0; x< stallIdOrder.length; x++){
        //print (x.toString() + ":" + stallIdOrder[x].toString() + ">>>>>>>" + gotMail[x].toString());
        //}

      });//if(mounted){setState(() {});}
    });//if(mounted){setState(() {});}
    if (stateSet < 2) {
      // if (mounted)setState(() {}); //shut down so that wont run build so many time, but ok?
      stateSet ++;
    } // if i do setstate here, it scroll again. but if I dont, it does not have the gotMail[x] status for red becos this is not fast enough,
    //unless the list view is slower which happens when items is a lot
    //print ("got mail? : " + gotMail.toString());
    gotMailChk=1;
    //if (mounted)setState(() {}); // added this while all above setstate was shut down, see if ok. on surface looks ok
  }

  getStall() async {
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("since", isNotEqualTo: "archived").orderBy("since", descending: true).get();

    /*
    ////////////////////////////////
    await FirebaseFirestore.instance.collection(groupId).where("since", isNotEqualTo: "archived").orderBy("since", descending: true).get()
        .then((value) {if (value.docs.length >0){
          print("docLength:    " + value.docs.length.toString());
          int i = -1;
          value.docs.forEach((part) async{
            //if(part.data()['whatPN'] !=null) {
              //i++;
              await FirebaseFirestore.instance.collection(groupId).doc(part.id)
                  .collection("moreParts").get()
                  .then((result) { i++;
                if (result.docs.length > 0) {
                  //i++;
                  int x = 0;
                  result.docs.forEach((morePart) {
                    if (morePart.data()['whatPN'] != null) {
                      x++;
                      partMore[i][x] = morePart['whatPN'];
                      print("i:   " + i.toString());
                      print("x:   " + x.toString());
                      print("partMore[i][x]:   " + partMore[i][x]);
                      //(value.docs[index].data()['quotes'] !=null)
                      //value.data()["poUploaded"] != null
                    }
                  });
                }
              });
            //}


          });

        }
        });
    ////////////////////////////////////
    */
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("since", isNotEqualTo: "archived").orderBy("since", descending: true);
    await whatPartGotMail(currentSnap); setState(() {}); // need setstate, else if no item to display for this sort, it wont refresh and will like no response.
    docLength = qn.size; // it will just remain as the current sorting state
    return qn.docs; // this return all the documents (an Array snapshot) in users collection
  }

  getArchive() async{
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("since", isEqualTo: "archived").get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("since", isEqualTo: "archived");
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  getLenovo() async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Courts").get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Lenovo").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo").get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Lenovo").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo");
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where('condCode', arrayContains: 'LNVARN').get(); //this is good one
    //var currentSnap = FirebaseFirestore.instance.collection(groupId).where('condCode', arrayContains: 'LNVARN'); //this is good one
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  getCourts() async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Courts").get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Courts").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo").get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Courts").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo");
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  getHarveyNorman() async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Harvey Norman").get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Harvey Norman").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo").get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Harvey Norman").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo");
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  getAsus() async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Asus").get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Asus").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo").get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "Asus").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo");
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  getB2C() async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "B2C").get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "B2C").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo").get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: "B2C").where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo");
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  sortByPn() async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).orderBy('whatPN').get();
    //FirebaseFirestore.FieldPath.documentID()
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).orderBy("whatPN").get();
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).orderBy("condCode"[1]).get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).orderBy('whatPN');
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  sortByJob() async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).orderBy('whatPN').get();
    //FirebaseFirestore.FieldPath.documentID()
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: customerPick).where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo").get();
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).orderBy("condCode"[1]).get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where("customer", isEqualTo: customerPick).where("jobIdNo", isNotEqualTo: "archived").orderBy("jobIdNo");
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    //print (customerPick);
    return qn.docs;
  }

  getToQuote()async {
    //print ("atToQuote: " + customerPick);
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("stage", isEqualTo: 1).get();
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where('condCode', arrayContains: '1ARN').get();
    //var currentSnap = FirebaseFirestore.instance.collection(groupId).where('condCode', arrayContains: '1ARN');
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '1ARN').get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '1ARN');
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    //print(customerPick);
    chartingFor = 'toQuote';
    writeDataForChart(docLength, customerPick, 'toQuote', 'latestQuoteDate', 'latestQuoteQty');
    return qn.docs;
  }

  getToPO()async {
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("stage", isEqualTo: 2).get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '2ARN').get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '2ARN');
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    chartingFor = 'toPo';
    writeDataForChart(docLength, customerPick, 'toPo', 'latestPoDate', 'latestPoQty');
    return qn.docs;
  }

  getToApprove()async {
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("stage", isEqualTo: 3).get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '3ARN').get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '3ARN');
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  getToShip()async{
    //QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where("stage", isEqualTo: 4).get();
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '4ARN').get();
    var currentSnap = FirebaseFirestore.instance.collection(groupId).where('customer', isEqualTo: customerPick).where('condCode', arrayContains: '4ARN');
    await whatPartGotMail(currentSnap);setState(() {});
    docLength = qn.size;
    return qn.docs;
  }

  writeDataForChart(docLength, customerPick, statusToCheck, fieldNameLatestDate, fieldNameLatestQty) async {
    var latestDate;
    //print ("Here " + statusToCheck + "  " + docLength.toString());
//print("customerPick: " + customerPick);
    FirebaseFirestore.instance.collection('charts').doc(customerPick).update({fieldNameLatestQty: docLength});
    //FirebaseFirestore.instance.collection('charts').doc(statusToCheck).update({"latestDate": DateTime.now()});


    await FirebaseFirestore.instance.collection('charts')
        .doc(customerPick)
        .get()
        .then((value) async {
      if (value.data()[fieldNameLatestDate] != null) {
        latestDate = value[fieldNameLatestDate];
        //print (latestDate);
        //print (DateTime.now());
        final difference = DateTime.now().difference(DateTime.parse(latestDate.toDate().toString())).inDays;
        //print ("difference :" + difference.toString());
        if (difference >0) {
          Map<String, dynamic> chtMap = {"date": DateFormat.yMMMd().format(DateTime.now()), "qty": docLength, "color": "0xff109618"};
          FirebaseFirestore.instance
              .collection('charts')
              .doc(customerPick).collection(statusToCheck).doc(DateTime.now().toString())
              .set(chtMap);

          //FirebaseFirestore.instance.collection('charts').doc(customerPick).update({"latestDate": DateTime.now()});
          FirebaseFirestore.instance.collection('charts').doc(customerPick).update({fieldNameLatestDate: DateTime(DateTime.now().year,DateTime.now().month, DateTime.now().day)});
        } // write new set of chart data and update the latestDate

        //if(DateTime.parse(latestDate.toDate().toString()).compareTo(DateTime.now()) < 0){print("yes  latest before now");}
      }

    });
  }

  var rate = List.filled(100,0);//List (100); //means users can only made changes to 100 stall rating at ome time without quiting the page
  var indexHolding = List.filled(100,-1); //List (100); //this is because this rating list store all the new changed rating for the stall that rating was changed
  // if exceed 100, then user can't changed the rating anymore. Well, but he just need to exit the page and come in again
  // then the new changed rating will be uploaded to firestore and all the list become empty for new changes again
  // cannot fille indexholding with 0 because 0 is a begining existing index, so cannot use that

  //List indexHolding = [];
  //List indexHolding = List.empty(growable: true);
  int rateCount=0;
  int indexCount=0;


  //int archiveIndex;
  archiveItem(docId, whoUpLoadId, customer, stage)async{
    // print ("yes here");
    //print (docId);
    //print (whoUpLoadId);
    //print ("stage: " + stage.toString());
    String custCode;
    if (await customer != null) {

      if (customer == "Harvey Norman"){custCode = "HVN";}
      else{if (customer == "Lenovo"){custCode = "LNV";}
      else{if (customer == "Courts"){custCode = "COU";}
      else{if (customer == "Asus"){custCode = "ASU";}
      else{if (customer == "BSC"){custCode = "BSC";}
      else{custCode = "XXX";}
      }
      }
      }
      }
    }


    if (userId == whoUpLoadId || myEmail == whoUpLoadId || myEmail == "ken@r-logic.com" || myEmail == "kenneth@r-logic.com"){
      await FirebaseFirestore.instance.collection(groupId).doc(docId).update({"since": "archived"});
      await FirebaseFirestore.instance.collection(groupId).doc(docId).update({"jobIdNo": "archived"});
      // todo: update condCode here
      FirebaseFirestore.instance.collection(groupId).doc(docId).update({"condCode": [ custCode+"ARC", stage.toString()+"ARC" ]});
      //_getStall = getStall();
      if(pageTitle == "by Date"){_getStall = getStall();setState(() {});}
      if(pageTitle == "By Job No."){_getStall = sortByJob();setState(() {});}
      if(pageTitle == "Lenovo"){_getStall = getLenovo();setState(() {});}
      if(pageTitle == "Courts"){_getStall = getCourts();setState(() {});}
      if(pageTitle == "Harvey Norman"){_getStall = getHarveyNorman();setState(() {});}
      if(pageTitle == "Asus"){_getStall = getAsus();setState(() {});}
      if(pageTitle == "B2C"){_getStall = getB2C();setState(() {});}
      if(pageTitle == "All Parts"){_getStall = sortByPn();setState(() {});}
      if(pageTitle == "To Quote"){_getStall = getToQuote();setState(() {});}
      if(pageTitle == "To PO"){_getStall = getToPO();setState(() {});}
      if(pageTitle == "To Approve"){_getStall = getToApprove();setState(() {});}
      if(pageTitle == "To Ship"){_getStall = getToShip();setState(() {});}

      //if (mounted)setState(() {});
    }
    else{
      Toast.show("You are not authorised", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  archiveToggle()async{
    //print ("ghererere");
    //if (previousSort == "") {stallIndex = -1; previousSort="";}
    stallIndex = -1;
    previousChoice="";
    if (pageTitle == "by Date"){ _getStall = getArchive(); pageTitle = "Archived";}
    else{ _getStall = getStall(); pageTitle = "by Date";}
    if (mounted)setState(() {});
  }

  void overflowSelected(String choice) {
    //print ("previous Sort: " + previousSort.toString());
    if (previousSort == "" ) {stallIndex = -1;} // stallIndex = -1 only for within page sorting play. but not when returning from editstall where we have to show the white highlighted items

    if (choice == OverflowBtn.lenovoClick || previousSort == "Lenovo") {
      customerPick = "Lenovo";
      _getStall = getLenovo(); pageTitle = "Lenovo"; previousChoice = "Lenovo"; previousSort = "";
      //print (pageTitle);
      //if (mounted)setState(() {});
    }

    if (choice == OverflowBtn.courtsClick || previousSort == "Courts") {
      customerPick = "Courts";
      _getStall = getCourts(); pageTitle = "Courts"; previousChoice = "Courts"; previousSort = "";
      //if (mounted)setState(() {});
    }

    if (choice == OverflowBtn.harveyNormanClick || previousSort == "Harvey Norman") {
      customerPick = "Harvey Norman";
      _getStall = getHarveyNorman(); pageTitle = "Harvey Norman";previousChoice = "Harvey Norman"; previousSort = "";
      //if (mounted)setState(() {});
    }

    if (choice == OverflowBtn.asusClick || previousSort == "Asus") {
      customerPick = "Asus";
      _getStall = getAsus(); pageTitle = "Asus";previousChoice = "Asus"; previousSort = "";
      //if (mounted)setState(() {});
    }

    if (choice == OverflowBtn.b2cClick || previousSort == "B2C") {
      customerPick = "B2C";
      _getStall = getB2C(); pageTitle = "B2C";previousChoice = "B2C"; previousSort = "";
      //if (mounted)setState(() {});
    }

    /*
    if (choice == OverflowBtn.archiveClick || previousSort == "Archived") {
      _getStall = getArchive(); pageTitle = "Archived";previousChoice = "Archived"; previousSort = "";
      if (mounted)setState(() {});
    }
    */


    if (choice == OverflowBtn.sortPnClick || previousSort == "sortByPn") {
      customerPick = null;
      _getStall = sortByPn(); pageTitle = "All Parts"; previousChoice = "sortByPn"; previousSort = "";
      //if (mounted)setState(() {});
    }

    if (choice == OverflowBtn.sortJobClick || previousSort == "sortByJob") {
      //customerPick = "";
      _getStall = sortByJob(); pageTitle = "By Job No."; previousChoice = "sortByJob"; previousSort = "";
      //if (mounted)setState(() {});
    }

    if (choice == OverflowBtn.toQuoteClick || previousSort == "toQuote") {
      _getStall = getToQuote(); pageTitle = "To Quote";previousChoice = "toQuote"; previousSort = "";
      //print (customerPick);
      //if (mounted)setState(() {});
    }
    if (choice == OverflowBtn.toPoClick || previousSort == "toPo") {
      _getStall = getToPO(); pageTitle = "To PO";previousChoice = "toPo"; previousSort = "";
      //if (mounted)setState(() {});
    }
    if (choice == OverflowBtn.toApproveClick || previousSort == "toApprove") {
      _getStall = getToApprove(); pageTitle = "To Approve";previousChoice = "toApprove"; previousSort = "";
      //if (mounted)setState(() {});
    }
    if (choice == OverflowBtn.toShipClick || previousSort == "toShip") {
      _getStall = getToShip(); pageTitle = "To Ship";previousChoice = "toShip"; previousSort = "";
      //if (mounted)setState(() {});
    }
  }

  poRecords(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => PoRecords(
      theGroupId: groupId,
    )));
  }

  int goToIndex;
  Future _scrollToIndex() async {
    //print ("at scroll:   " + stallIndex.toString());
    //print ("scroll to index:  " + goToIndex.toString());
    //goToIndex=0;
    if (stallIndex == null){goToIndex =0;}
    else{
      if (stallIndex > 0){goToIndex = stallIndex-1;}
      else{
        if (stallIndex == 0){goToIndex = stallIndex;}
        else{
          //if (stallIndex == -2){goToIndex = docLength-1;stallIndex = docLength-1;}//addNew = 'yes';
        }
      }
    }
    if (goToIndex == null) {goToIndex=0;}
    await controller.scrollToIndex(goToIndex, preferPosition: AutoScrollPosition.begin);
  }

/*
  copyJobNo() {
    int x=0;
    int y=0;
    FirebaseFirestore.instance.collection("req@gmail.com").get().then((value){
      value.docs.forEach((stallId) async {
        if (stallId.data()['jobRefNo'] != null) {
          String jobRefNo = stallId['jobRefNo'];
          var since = stallId['since'];
          String docId = stallId.id;
          if (since != 'archived') {
            x++;
            print ("x: " + x.toString() + "     " + docId + "    " + since.toString());
            FirebaseFirestore.instance.collection("req@gmail.com").doc(docId).update({"jobIdNo": jobRefNo});
          }
          else{
            x++;
            print ("x: " + x.toString() + "     " + docId + "    " + since.toString());
            FirebaseFirestore.instance.collection("req@gmail.com").doc(docId).update({"jobIdNo": "archived"});
          }
        }
        else{x++; print ("x: " + x.toString() + "     No Job Ref    " );}
      });
    });
  }
*/
  @override
  Widget build(BuildContext context) {

//copyJobNo();

    //print ("hererere");
    //print ("userStatus: " + userStatus.toString());
    // getUserStatus(); // todo: to open this? Status only access at Init stage. Does it affect the sensitive status identification?

    //if (gotMailChk ==0){whatPartGotMail ();}
    //print ("userstatus  " + userStatus);
    //String groupId = widget.theGroupId;
    //stallIndex = widget.theStallIndex;
    //print (stallIndex);
    //if (stallIndex == null) {stallIndex =0;}
    //String userId;
    String stallDocId;
    String stallIdNo;
    File croppedImage;
    int rating;
    //String stallId;
    int existed;

    Future forDebug() async{
      var image =  File ('/Users/kengboon/MyDocuments/MyClone/assets/food.jpg');
      croppedImage = await ImageCropper().cropImage(sourcePath: image.path);
      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddStall(croppedImage: image)));
    }

    final picker = ImagePicker();
    Future captureImage(ImageSource source) async {
      //Toast.show("1111", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      //Permission.camera.request();
      //Permission.storage.request();
      //if (await Permission.camera.request().isGranted) {
      //Toast.show("1111 Camera permission granted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      //} else{Toast.show("1111 Camera not permitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);}
      //if (await Permission.storage.request().isGranted) {

      var image = await picker.getImage(source: source);
      //Toast.show("2222", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      //File compressedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 85);
      if (image.path == null ){Toast.show("Image not found", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);}
      else {
        //Toast.show("3333", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
        croppedImage = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 500,
            maxHeight: 500,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.blue,
              toolbarTitle: "Crop it",
            ));
        //setState(() {_image = cropped;flag=1;});
        if (croppedImage != null ) {
          //Toast.show("4444", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddStall(croppedImage: croppedImage, theGroupId: groupId)));
        } else {Toast.show("Cropped image not found", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
      }

      //} else{Toast.show("File access not granted", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
      //}else{Toast.show("Camera access not granted", context, backgroundColor:Colors.blueGrey[800], textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}


    }


    Future getRating() async {
      await FirebaseFirestore.instance.collection("FoodStall").doc(stallDocId).get()
          .then((value) {
        rating = value['rating'];
        //return _rating;
      });
    }

    upClick (){
      if (rating <5) {rating ++;}
      FirebaseFirestore.instance.collection("FoodStall").doc(stallDocId).update({"rating": rating});
      //clicked = 1;
      setState(() {
      });
    }

    downClick () async {
      //if (rating>1) {rating --;}
      //await Firestore.instance.collection("FoodStall").document(stallDocId).updateData({"rating": rating});
      //clicked = 1;
      //setState(() {});
    }


    _scrollToIndex();

    Future checkStage(index)async{
      //print ("checkstage here...index is "   + index.toString());
      String stage = "";

/*
      await FirebaseFirestore.instance.collection(groupId).doc(index)
          .get().then((value){
            print ("index:   " + index.toString());
            if (value.data()['quotes'] != null){
              stage = "quoted";
              print ("stage:   " + stage);
              return stage;
            }
      });
*/
      await FirebaseFirestore.instance.collection(groupId)
          .get().then((value){
        //print ("index:   " + index.toString());
        if(value.docs[index].data()['quotes'] !=null) {
          //if (value.docs[index]['quotes'] != null) {
          stage = "quoted";
          //print("index:   " + index.toString());
          //print("stage:   " + stage);
          return stage;
        }
        //}
      });
    }

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
              onPressed: () {
                //print ("userStatus:  " + userStatus);
                //Navigator.pop(context); //to fix routing issue, cannot use this else might show blank page if there isnt a previous widget standby in place. hence not working for Notification jumping to EditStall situation
                if (specialChnPassword != "tebieguandao") { //added for YQ
                  userStatus == "SuperUser" ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainMenu(theGroupId: groupId)))
                      : Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));
                } //added for YQ
              }),
          //automaticallyImplyLeading: true,
          title: (Text(pageTitle + "   " + docLength.toString(),style: TextStyle(color: Colors.white, fontSize: 10))),
          backgroundColor: Colors.black,
          actions: [
            userStatus == "SuperUser" || userStatus == "Rlogic"?

            // turned off this poRecord thing and replace it with chart function right below. Not enough space there
            //GestureDetector(
            //    onTap: () {
            //      poRecords();
            //      //forDebug(); ///////////////////////////////////
            //    },
            //    child: Padding(
            //      padding: const EdgeInsets.only(right: 20.0),
            //      child: Icon(Icons.document_scanner),
            //    )):Text(""),

            GestureDetector(
                onTap: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => Chart(theGroupId: groupId)));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Chart(theGroupId: groupId, theCustomerPick: customerPick, theChartingFor: chartingFor)));
                  //forDebug(); ///////////////////////////////////
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.insert_chart),
                )):Text(""),




            GestureDetector(
                onTap: () {
                  archiveToggle();
                  //forDebug(); ///////////////////////////////////
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.folder_open),
                )),


            GestureDetector(
                onTap: () {
                  captureImage(ImageSource.camera);
                  //forDebug(); ///////////////////////////////////
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.add_a_photo),
                )),

            GestureDetector(
                onTap: () {
                  captureImage(ImageSource.gallery);
                  //forDebug(); ///////////////////////////////////
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.photo),
                )),

            userStatus == "SuperUser" || userStatus == "Rlogic"?
            PopupMenuButton<String>(
              onSelected: overflowSelected,
              itemBuilder: (BuildContext context) {
                return OverflowBtn.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ): Text("")
          ],
        ),

        body:
        Container(
          child: FutureBuilder(
            //future: getStall(),
              future: _getStall,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text("Loading...",style: TextStyle(color: Colors.white, fontSize: 15)),
                  );
                } else {
                  //if (customerIs == "Lenovo" && chartingFor == "toQuote"){customerPick = customerIs; getToQuote();}
                  //else {print("xxx");}
                  //SizedBox(height: 100);
                  return ListView.builder(
                    //return IndexedListView.builder(
                      scrollDirection: scrollDirection,
                      controller: controller,
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {


                        /*
                        //rating = snapshot.data[index].data['rating'];
                        rating = snapshot.data[index]['rating'];
                        for (int x = 0; x <= 99; x++) {
                          if (indexHolding[x] == index){rating = rate[x];}
                          // check if index is one of the indexx[count]
                          // if yes, then rating  =  rate [count]
                          // then goto next index (this auto by flutter)
                        }
                        //if (index == indexNo && rateDown==1) {rating--; rateDown =0;}
                        //if (index == indexNo && rateUp==1) {rating++; rateUp =0;}
                        */


                        // I shut down the AutoScrolling first. becos, though seems worked fine, but with that the red alert is not appearing
                        // to re-insert this AutoScrolling, just wrap add back this widget here above Slidable
                        // In fact this AutoScrolling Widget can be added in couple of other places below and will works as well too
                        //return AutoScrollTag(key: ValueKey(index), controller: controller, index: index,
                        return // todo: opening up the archived elimination here below will casue shcking scrolling issue
                          //snapshot.data[index].data()['since'] == "archived" && pageTitle != "Archived"?Text(""): // temp for PN sort only, else dont know how to sort the PN with non-archived item
                          AutoScrollTag(key: ValueKey(index), controller: controller, index: index,
                            child: Slidable(
                              //delegate: SlidableDrawerDelegate(),
                              actionPane:  SlidableDrawerActionPane(),
                              actionExtentRatio: pageTitle != "Archived" ? 0.25: 0,
                              child: Container(

                                child: ListTile(
                                  //key: ValueKey(index),
                                  //controller: controller,
                                  //index: index,
                                  title: GestureDetector(

                                    onTap: () {
                                      stallDocId = snapshot.data[index].documentID;
                                      snapshot.data[index].data()['stallId'] != null?
                                      stallIdNo = snapshot.data[index]['stallId']: stallIdNo = stallDocId;

                                      String jobRefNo="";
                                      snapshot.data[index].data()['jobRefNo'] != null?
                                      jobRefNo = snapshot.data[index]['jobRefNo']:jobRefNo = "";
                                      ////////////// if I put push instead of push replacement, then if I click ok, it will get back to Food
                                      ////////////// but this push action means this food page still there. so after click ok which navigate to Food
                                      //////////// then click back arrow, it will still remain at Food


                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall(
                                          thePageTitle: pageTitle,
                                          theIndex: index,
                                          theStallDocId: stallDocId,
                                          theStallIdNo: stallIdNo,
                                          theImage: snapshot.data[index]['image'], //image
                                          theStall: snapshot.data[index]['whatModel'], //whatstall
                                          theFood: snapshot.data[index]['whatPN'], //whatfood
                                          thePlace: snapshot.data[index]['whatUse'], //where
                                          theQty: snapshot.data[index]['whatQty'], //
                                          theRemark: snapshot.data[index]['remark'], //remark
                                          //theMultipleParts: multipleParts[index],
                                          //theAddress: snapshot.data[index].data['address'],
                                          theGroupId: groupId,
                                          thePreviousSort: previousChoice,
                                          theJobRefNo: jobRefNo
                                      )));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                      child:
                                      Column(
                                        children: [
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [


                                                    snapshot.data[index].data()['stage'] == 4?
                                                    //snapshot.data[index].data()['poStatus'] == "approved"?
                                                    Align(alignment: Alignment.topLeft,child: Text ("PO approved",style: TextStyle(color: Colors.lightGreenAccent, fontSize: 12))):

                                                    snapshot.data[index].data()['stage'] == 3?
                                                    //snapshot.data[index].data()['poUploaded'] != ""?
                                                    Align(alignment: Alignment.topLeft, child: Text ("pending approval",style: TextStyle(color: Colors.yellowAccent, fontSize: 12))):

                                                    snapshot.data[index].data()['stage'] == 2?
                                                    //snapshot.data[index].data()['quotes'] != ""?
                                                    Align(alignment: Alignment.topLeft, child: Text ("pending PO",style: TextStyle(color: Colors.orangeAccent, fontSize: 12)))
                                                        : Align(alignment: Alignment.topLeft, child: Text("pending quote",style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12))),
                                                    //SizedBox(height: 15),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      //child: snapshot.data[index].data['image'] != null ?
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          stallDocId = snapshot.data[index].documentID;
                                                          stallIdNo = snapshot.data[index]['stallId'];
                                                          //(done) here it goes to picrues, looks like must pass the userEmail to allow saving to Storage subfolder at pictures.dart
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Pictures(
                                                            theIndex: index,
                                                            theStallId: stallDocId,
                                                            theStallIdNo: stallIdNo,
                                                            theGroupId : groupId,
                                                            theImage: snapshot.data[index]['image'],
                                                            theStall :snapshot.data[index]['whatModel'],
                                                            theFood: snapshot.data[index]['whatPN'],
                                                            thePlace: snapshot.data[index]['whatUse'],
                                                            theRemark: snapshot.data[index]['remark'],
                                                            //theAddress: snapshot.data[index].data['address'],
                                                          )));
                                                        },

                                                        child:
                                                        Column(
                                                          children: [
                                                            //multipleParts[index] != 1?

                                                            /*
                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(0,40,0,70),
                                                            child: Align(alignment:Alignment.center,child: Text(snapshot.data[index]['whatModel'], textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 15))),
                                                          )
                                                          */

                                                            /* // forget about the ClipRRect pictures here, just use text
                                                          ClipRRect(
                                                              child: Image.network(
                                                                //snapshot.data[index].data['image'],
                                                                snapshot.data[index]['image'],
                                                                width: 250,
                                                                height: 120,
                                                                //fit: BoxFit.fill
                                                              ),
                                                              borderRadius:pepe

                                                              BorderRadius.circular(20))
                                                          */

                                                            Padding(
                                                                padding: const EdgeInsets.fromLTRB(0,20,0,3),
                                                                child:

                                                                snapshot.data[index].data()['stage'] == 4?
                                                                Align(alignment:Alignment.center,child: Text(snapshot.data[index]['whatPN'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightGreenAccent, fontSize: 15))):

                                                                snapshot.data[index].data()['stage'] == 3?
                                                                Align(alignment:Alignment.center,child: Text(snapshot.data[index]['whatPN'], textAlign: TextAlign.center,style: TextStyle(color: Colors.yellowAccent, fontSize: 15))):

                                                                snapshot.data[index].data()['stage'] == 2?
                                                                Align(alignment:Alignment.center,child: Text(snapshot.data[index]['whatPN'], textAlign: TextAlign.center,style: TextStyle(color: Colors.orangeAccent, fontSize: 15))):
                                                                Align(alignment:Alignment.center,child: Text(snapshot.data[index]['whatPN'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15)))
                                                            ),

                                                            multipleParts[index] == 1?
                                                            Padding(
                                                                padding: const EdgeInsets.fromLTRB(0,0,0,3),
                                                                child:
                                                                //Align(alignment:Alignment.center,child: Text(partMore[index][1], textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 20))),
                                                                Align(alignment:Alignment.center,

                                                                    child:

                                                                    Column(
                                                                      children: [
                                                                        snapshot.data[index]['morePartQty'] >= 1?
                                                                        //snapshot.data[index]['whatPN1'] !=null?

                                                                        //Text(snapshot.data[index]['whatPN1'] , textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 15))
                                                                        snapshot.data[index].data()['stage'] == 4?
                                                                        Text(snapshot.data[index]['whatPN1'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightGreenAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 3?
                                                                        Text(snapshot.data[index]['whatPN1'], textAlign: TextAlign.center,style: TextStyle(color: Colors.yellowAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 2?
                                                                        Text(snapshot.data[index]['whatPN1'], textAlign: TextAlign.center,style: TextStyle(color: Colors.orangeAccent, fontSize: 15)):
                                                                        Text(snapshot.data[index]['whatPN1'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15))



                                                                            :Text(""),

                                                                        snapshot.data[index]['morePartQty'] >= 2 ?
                                                                        //snapshot.data[index]['whatPN1'] !=null?
                                                                        //Text(snapshot.data[index]['whatPN2'] , textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 15))
                                                                        snapshot.data[index].data()['stage'] == 4?
                                                                        Text(snapshot.data[index]['whatPN2'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightGreenAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 3?
                                                                        Text(snapshot.data[index]['whatPN2'], textAlign: TextAlign.center,style: TextStyle(color: Colors.yellowAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 2?
                                                                        Text(snapshot.data[index]['whatPN2'], textAlign: TextAlign.center,style: TextStyle(color: Colors.orangeAccent, fontSize: 15)):
                                                                        Text(snapshot.data[index]['whatPN2'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15))


                                                                            :
                                                                        Text(""),

                                                                        snapshot.data[index]['morePartQty'] >= 3 ?
                                                                        //Text(snapshot.data[index]['whatPN3'] , textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 15))
                                                                        snapshot.data[index].data()['stage'] == 4?
                                                                        Text(snapshot.data[index]['whatPN3'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightGreenAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 3?
                                                                        Text(snapshot.data[index]['whatPN3'], textAlign: TextAlign.center,style: TextStyle(color: Colors.yellowAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 2?
                                                                        Text(snapshot.data[index]['whatPN3'], textAlign: TextAlign.center,style: TextStyle(color: Colors.orangeAccent, fontSize: 15)):
                                                                        Text(snapshot.data[index]['whatPN3'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15))



                                                                            :
                                                                        Text(""),

                                                                        snapshot.data[index]['morePartQty'] >= 4 ?
                                                                        //Text(snapshot.data[index]['whatPN4'] , textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 15))
                                                                        snapshot.data[index].data()['stage'] == 4?
                                                                        Text(snapshot.data[index]['whatPN4'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightGreenAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 3?
                                                                        Text(snapshot.data[index]['whatPN4'], textAlign: TextAlign.center,style: TextStyle(color: Colors.yellowAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 2?
                                                                        Text(snapshot.data[index]['whatPN4'], textAlign: TextAlign.center,style: TextStyle(color: Colors.orangeAccent, fontSize: 15)):
                                                                        Text(snapshot.data[index]['whatPN4'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15))



                                                                            :
                                                                        Text(""),

                                                                        snapshot.data[index]['morePartQty'] >= 5 ?
                                                                        //Text(snapshot.data[index]['whatPN5'] , textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 15))
                                                                        snapshot.data[index].data()['stage'] == 4?
                                                                        Text(snapshot.data[index]['whatPN5'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightGreenAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 3?
                                                                        Text(snapshot.data[index]['whatPN5'], textAlign: TextAlign.center,style: TextStyle(color: Colors.yellowAccent, fontSize: 15)):

                                                                        snapshot.data[index].data()['stage'] == 2?
                                                                        Text(snapshot.data[index]['whatPN5'], textAlign: TextAlign.center,style: TextStyle(color: Colors.orangeAccent, fontSize: 15)):
                                                                        Text(snapshot.data[index]['whatPN5'], textAlign: TextAlign.center,style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15))


                                                                            : Text(""),

                                                                      ],
                                                                    )


                                                                ))





                                                                : Text(""),
                                                          ],
                                                        ),

                                                      ),
                                                    ),

                                                    snapshot.data[index].data()['finalStatus'] != null && snapshot.data[index].data()['finalStatus'] != "" ?
                                                    Align(alignment: Alignment.topLeft, child:Text ("latest status",style: TextStyle(color: Colors.white, fontSize: 10)))
                                                        :Text(""),

                                                    //SizedBox(height:05),
                                                    snapshot.data[index].data()['finalStatus'] != null && snapshot.data[index].data()['finalStatus'] != "" ?
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0,5,0,0),
                                                      child: Align(alignment: Alignment.topLeft, child:Text (snapshot.data[index]['finalStatus'],style: TextStyle(color: Colors.white, fontSize:12))),
                                                    )
                                                        :Text("")
                                                    //Align(alignment: Alignment.topLeft, child:Text ("...",style: TextStyle(color: Colors.white, fontSize: 20)))

                                                    /* // forget about the start rating here
                                                  Container(width: 120,
                                                    child: Row(
                                                      children: [
                                                        //SizedBox(width: 3),

                                                        Expanded(
                                                          child: GestureDetector(onTap: () async {

                                                            if (indexCount < 100) {

                                                              stallDocId = snapshot.data[index].documentID;

                                                              for (int x = 0; x <= 99; x++) {

                                                                if(indexHolding[x] == index)
                                                                {existed =1; if (rate[x] >0) {rate[x] -- ; rating = rate[x];} else rating = 0;}
                                                              }

                                                              if (existed !=1){
                                                                rating = snapshot.data[index]['rating'];
                                                                rating --;
                                                                rate[indexCount] = rating;
                                                                //rateCount++;
                                                                indexHolding[indexCount] = index;
                                                                indexCount ++;}
                                                              else {existed = 0;}

                                                              await FirebaseFirestore.instance.collection(groupId).doc(stallDocId).update({"rating": rating});
                                                              if(mounted){setState(() {});}
                                                            }
                                                          },
                                                              child: Icon(Icons.keyboard_arrow_left, size: 20, color: Colors.blue)
                                                          ),
                                                        ),

                                                        Expanded(child: rating >= 1  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey)),
                                                        Expanded(child: rating >= 2  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey)),
                                                        Expanded(child: rating >= 3  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey)),
                                                        Expanded(child: rating >= 4  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey)),
                                                        Expanded(child: rating >= 5  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey)),

                                                        Expanded(
                                                          child: GestureDetector(onTap: () async {
                                                            if (indexCount < 100){
                                                              stallDocId = snapshot.data[index].documentID;
                                                              for (int x = 0; x <= 99; x++) {
                                                                if(indexHolding[x] == index)
                                                                {existed =1; if (rate[x]<5) {rate[x] ++ ;rating = rate[x];} else{rating = 5;} }
                                                              }

                                                              if (existed !=1){
                                                                rating = snapshot.data[index]['rating'];
                                                                rating ++;
                                                                rate[indexCount] = rating;
                                                                //rateCount++;
                                                                indexHolding[indexCount] = index;
                                                                indexCount ++;}
                                                              else {existed = 0;}

                                                              await FirebaseFirestore.instance.collection(groupId).doc(stallDocId).update({"rating": rating});
                                                              if(mounted){setState(() {});}
                                                            }
                                                          },
                                                              child: Icon(Icons.keyboard_arrow_right, size: 20, color: Colors.blue)),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                */

                                                  ],
                                                ),
                                              ),
                                              //SizedBox(height: 70),
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Align(alignment: Alignment.centerLeft),
                                                    Padding(
                                                        padding: const EdgeInsets.fromLTRB(
                                                            20, 0, 0, 0),
                                                        child:





                                                        stallIndex != null && index == stallIndex?

                                                        snapshot.data[index].data()['jobRefNo'] == null?  Text("-") :
                                                        Text(
                                                          snapshot.data[index]['jobRefNo'],
                                                          //snapshot.data[index]['stallId'].substring(0, 17), //textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )


                                                            :

                                                        // >>>>> here see send er name is who, if you are not sender, then red
                                                        //snapshot.data[index]['msgIncoming'] == 1 ?


                                                        //gotMail[index].isEmpty = true?
                                                        //gotMail[index] !=null?
                                                        gotMail[index] == -1?
                                                        //snapshot.data[index]['mailBox'].length == 1 ?
                                                        //snapshot.data.docId == stallGotMail[index]?

                                                        //addNew == 'yes?'?
                                                        snapshot.data[index].data()['jobRefNo'] == null?  Text("-") :
                                                        Text(
                                                          //snapshot.data[index].data['whatModel'],
                                                          snapshot.data[index]['jobRefNo']+ " (n)",
                                                          //snapshot.data[index]['stallId'].substring(0, 17) + " (new)",//textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )

                                                            :

                                                        gotMail[index] == 1?

                                                        snapshot.data[index].data()['jobRefNo'] == null?  Text("-") :
                                                        Text(
                                                          //snapshot.data[index].data['whatModel'],
                                                          snapshot.data[index]['jobRefNo'],
                                                          //snapshot.data[index]['stallId'].substring(0, 17) + " (mail)",//textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )

                                                            :
                                                        snapshot.data[index].data()['jobRefNo'] == null?  Text("-") :
                                                        Text(
                                                          //snapshot.data[index].data['whatModel'],
                                                          snapshot.data[index]['jobRefNo'],
                                                          //snapshot.data[index]['stallId'].substring(0, 17),//textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )






                                                      //: Text( // this is to cater for null gotMail[index], when gotMail method not done yet
                                                      //snapshot.data[index].data['whatModel'],
                                                      //  snapshot.data[index]['whatModel'],//textAlign: TextAlign.left,
                                                      //  style: TextStyle(
                                                      //    color: Colors.blue,
                                                      //    fontSize: 15,
                                                      //    fontWeight: FontWeight.bold,
                                                      //  ),
                                                      //)


                                                    ),



                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                      child:
                                                      snapshot.data[index].data()['whatModel'] == null? Text(""):
                                                      Text(
                                                        //snapshot.data[index].data['whatPN'],
                                                        snapshot.data[index]['whatModel'],//textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                      child:
                                                      snapshot.data[index].data()['tgtPrice'] == null || snapshot.data[index].data()['tgtPrice'] == "" ?

                                                      snapshot.data[index].data()['whatQty'] == null? Text(""):
                                                      Text(
                                                        //snapshot.data[index].data['whatQty'],
                                                        "Qty: " + snapshot.data[index]['whatQty'],//textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.blueGrey[500],
                                                          fontSize: 15,
                                                        ),
                                                      ):
                                                      Text(
                                                        //snapshot.data[index].data['whatQty'],
                                                        "Qty: " + snapshot.data[index]['whatQty'] + ".  Tgt price: " + snapshot.data[index]['tgtPrice'],//textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.blueGrey[500],
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),


                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                      // can do a row here to add customer?
                                                      child:
                                                      snapshot.data[index].data().containsKey('customer') ?
                                                      snapshot.data[index].data()['whatUse'] == null? Text(""):
                                                      Text(
                                                        snapshot.data[index]['whatUse'] + " - " + snapshot.data[index]['customer'],//textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 15,
                                                        ),
                                                      ):

                                                      snapshot.data[index].data()['whatUse'] == null? Text(""):
                                                      Text(
                                                        //snapshot.data[index].data['whatUse'],
                                                        snapshot.data[index]['whatUse'],//textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 15,
                                                        ),
                                                      ),


                                                    ),



                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                      child:
                                                      snapshot.data[index].data()['remark'] == null? Text(""):
                                                      Text(
                                                        //snapshot.data[index].data['remark'],
                                                        snapshot.data[index]['remark'],//textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.blueGrey[500],
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                      child:
                                                      snapshot.data[index].data()['whenAsk'] == null? Text(""):
                                                      Text(
                                                        //snapshot.data[index].data['whenAsk'],
                                                        snapshot.data[index]['whenAsk'],//textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),

                                                    /* // no need to present the stallID here liao
                                                  Padding(
                                                      padding: const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                      child:
                                                      snapshot.data[index].data()['stallId'] != null ?
                                                      Text(
                                                        snapshot.data[index]['stallId'] ,
                                                        style: TextStyle(
                                                          color: Colors.blueGrey[500],
                                                          fontSize: 15,
                                                        ),
                                                      )
                                                          : Text("")
                                                  ),
                                                  */
/*
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(
                                                        20, 0, 0, 0),
                                                    child: Text(
                                                      snapshot
                                                          .data[index].data['rating'].toString(),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
*/
/*
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(
                                                        20, 0, 0, 0),
                                                    child: Text('$rating'),
                                                  ),
                                                  //Text(DateTime.now().toString()),
*/

                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(color: Colors.grey),
                                        ],

                                      ),
                                    ),
                                  ),

                                ),
                              ),
                              actions: <Widget>[

                                IconSlideAction(
                                  caption: 'Archive',
                                  color: Colors.blue,
                                  icon: Icons.archive,
                                  onTap: (){
                                    archiveItem(snapshot.data[index].documentID, snapshot.data[index]["whouploadId"], snapshot.data[index]["customer"], snapshot.data[index]["stage"]);
                                  },
                                ),
                              ],
                            ),
                          );
                      });
                } ///////else
              }),
        )
    );
  }
}


class OverflowBtn{
  static const String lenovoClick ='Lenovo';
  static const String courtsClick ='Courts';
  static const String harveyNormanClick ='Harvey Norman';
  static const String asusClick ='Asus';
  static const String b2cClick ='B2C';
  //static const String archiveClick ='Archived';
  static const String sortPnClick ='All Parts';
  static const String sortJobClick ='Sort by Job';
  static const String toQuoteClick ='To Quote';
  static const String toPoClick ='To PO';
  static const String toApproveClick ='To Approve';
  static const String toShipClick ='To Ship';

  static const List <String> choices = <String> [
    lenovoClick, courtsClick, harveyNormanClick , asusClick, b2cClick, sortPnClick, sortJobClick, toQuoteClick,toPoClick,toApproveClick, toShipClick];

}
