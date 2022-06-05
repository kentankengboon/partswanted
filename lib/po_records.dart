
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
import 'package:permission_handler/permission_handler.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:toast/toast.dart';

import 'addstall.dart';
import 'editstall.dart';
import 'main_group.dart';
import 'main_menu.dart';
import 'notification.dart';
//import 'addstall.dart';
//import 'editstall.dart';

class PoRecords extends StatefulWidget {

  String theGroupId;
  PoRecords({this.theGroupId});

  @override
  _PoRecordsState createState() => _PoRecordsState(groupId: theGroupId);
}

class _PoRecordsState extends State<PoRecords> {
  String groupId;
  int docLength;
  _PoRecordsState({this.groupId});

  void initState(){
    super.initState();
  }

  getPoRecords()async{
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).doc("UnIssuedPO").collection("UnIssuedPO").where("poUploaded", isEqualTo: "no").get();
    docLength = qn.docs.length;
    return qn.docs;
  }

  doneItem(docId)async{
    await FirebaseFirestore.instance.collection(groupId).doc("UnIssuedPO").collection("UnIssuedPO").doc(docId).update({"poUploaded": "yes"});
    if (mounted) {setState(() {});}
  }

  @override
  Widget build(BuildContext context) {
  getPoRecords();


  return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: (Text("PO to upload",style: TextStyle(color: Colors.white, fontSize: 20))),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () {
              //Navigator.pop(context);
              Navigator.pop(context);
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall()));
            }),


      ),

    body:
      Container(
          child:
          FutureBuilder(
              future: getPoRecords(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text("Loading...",style: TextStyle(color: Colors.white, fontSize: 10)),
                  );
                } else {

                return ListView.builder(
                    itemCount: docLength,
                    itemBuilder: (_, index) {
                    return
                      Slidable(
                        actionPane:  SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: ListTile(
                          title:

                          Column(
                            children: [
                            //Text(""),
                            //Text((index+1).toString(),style: TextStyle(color: Colors.white, fontSize: 10)),

                            snapshot.data[index].data()['jobRefNo'] != null && snapshot.data[index].data()['jobRefNo'] != ""?
                            Align(alignment: Alignment.topLeft, child: Text("job  : " + snapshot.data[index]['jobRefNo'],style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.bold))):
                              snapshot.data[index].data()['stallId'] != null?
                              Align(alignment: Alignment.topLeft, child: Text("job  : " + snapshot.data[index]['stallId'],style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.bold))):
                              null,

                              snapshot.data[index].data()['poNumber'] != null ?
                              Align(alignment: Alignment.topLeft, child: Text("PO No  : " + snapshot.data[index]['poNumber'],style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.bold))):
                              null,

                              if(snapshot.data[index].data()['partNo'] != null && snapshot.data[index].data()['partNo'] != "-")
                                Align(alignment: Alignment.topLeft, child:Text(
                                    "part No: " + snapshot.data[index]['partNo'] + '\n' +
                                    "price: " + snapshot.data[index]['price0'] + '\n' +
                                    "qty  : " + snapshot.data[index]['qty0'] + '\n' +
                                    "to   : " + snapshot.data[index]['vendor']
                                    ,style: TextStyle(color: Colors.white, fontSize: 15))),

                              if(snapshot.data[index].data()['partNo1'] != null && snapshot.data[index].data()['partNo1'] != "-")
                                Align(alignment: Alignment.topLeft, child:Text(
                                  '\n' + "part No: " + snapshot.data[index]['partNo1'] + '\n' +
                                      "price: " + snapshot.data[index]['price1'] + '\n' +
                                      "qty  : " + snapshot.data[index]['qtyMore1'] + '\n' +
                                      "to   : " + snapshot.data[index]['vendor']
                                    ,style: TextStyle(color: Colors.white, fontSize: 15))),

                              if(snapshot.data[index].data()['partNo2'] != null && snapshot.data[index].data()['partNo2'] != "-")
                                Align(alignment: Alignment.topLeft, child:Text(
                                    '\n' + "part No: " + snapshot.data[index]['partNo2'] + '\n' +
                                        "price: " + snapshot.data[index]['price2'] + '\n' +
                                        "qty  : " + snapshot.data[index]['qtyMore2'] + '\n' +
                                        "to   : " + snapshot.data[index]['vendor']
                                    ,style: TextStyle(color: Colors.white, fontSize: 15))),

                              if(snapshot.data[index].data()['partNo3'] != null && snapshot.data[index].data()['partNo3'] != "-")
                                Align(alignment: Alignment.topLeft, child:Text(
                                    '\n' + "part No: " + snapshot.data[index]['partNo3'] + '\n' +
                                        "price: " + snapshot.data[index]['price3'] + '\n' +
                                        "qty  : " + snapshot.data[index]['qtyMore3'] + '\n' +
                                        "to   : " + snapshot.data[index]['vendor']
                                    ,style: TextStyle(color: Colors.white, fontSize: 15))),

                              if(snapshot.data[index].data()['partNo4'] != null && snapshot.data[index].data()['partNo4'] != "-")
                                Align(alignment: Alignment.topLeft, child:Text(
                                    '\n' + "part No: " + snapshot.data[index]['partNo4'] + '\n' +
                                        "price: " + snapshot.data[index]['price4'] + '\n' +
                                        "qty  : " + snapshot.data[index]['qtyMore4'] + '\n' +
                                        "to   : " + snapshot.data[index]['vendor']
                                    ,style: TextStyle(color: Colors.white, fontSize: 15))),


                            //Align(alignment: Alignment.topLeft, child:Text("price: " + snapshot.data[index]['price0'],style: TextStyle(color: Colors.white, fontSize: 15))),
                            //Align(alignment: Alignment.topLeft, child:Text("qty  : " + snapshot.data[index]['qty0'],style: TextStyle(color: Colors.white, fontSize: 15))),
                            //Align(alignment: Alignment.topLeft, child:Text("to   : " + snapshot.data[index]['vendor'],style: TextStyle(color: Colors.white, fontSize: 15))),
                              Text(""),
                              Divider(color: Colors.grey),
                            ]),
                        ),

                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Done',
                            color: Colors.blue,
                            icon: Icons.archive,
                            onTap: (){
                              doneItem(snapshot.data[index].documentID);
                            },
                          ),
                        ],

                      );
                  });
                }
              }
          )
      )

  );

  }

}