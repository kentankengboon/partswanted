
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partswanted/pictures.dart';
import 'package:toast/toast.dart';
import 'food.dart';
import 'package:flutter/scheduler.dart';

class EditStall extends StatefulWidget {
  final theIndex;
  final theStallId; //refer to this case's ID
  final theStall; //whatModel
  final theFood; //whatPN
  final thePlace; //whatUse
  final theQty; //whatQty
  final theRemark; // remark
  //final theAddress;
  final theImage; //image
  final theGroupId; //refer to groupID
  EditStall({this.theIndex, this.theStallId, this.theImage, this.theStall, this.theFood, this.thePlace, this.theQty, this.theRemark, this.theGroupId});

  @override
  _EditStallState createState() => _EditStallState(groupId: theGroupId, stallId: theStallId, index: theIndex, stall: theStall, food: theFood, place: thePlace, qty: theQty, remark: theRemark, image: theImage);
}

class _EditStallState extends State<EditStall> {
  int index;
  String stallId;
  String stall;
  String food;
  String place;
  String qty;
  String remark;
  String address;
  String image;
  String groupId;
  bool buttonTapped = false;
  //String justText = "click here";
  int x=1;
  String imageNew;
  String oldMsgList;
  String newMsgLog;
  String userId;
  String userName;
  int settingDone;
  //String myEmail;
  String whoUploadId;
  //Key key;

  ScrollController _scrollController = new ScrollController(
    //initialScrollOffset: 0.0,
    //keepScrollOffset: true,
  );

  _EditStallState({this.stallId, this.groupId, this.index, this.stall, this.food, this.place, this.qty, this.remark, this.image});

  //TextEditingController inputWhere = new TextEditingController();
  //TextEditingController inputWhere;
  //TextEditingController inputWhatStall;
  //TextEditingController inputWhatFood;
  //TextEditingController inputWhatQty;
  //TextEditingController inputRemark;
  //TextEditingController inputAddress;
  //TextEditingController inputChatMsg;



  TextEditingController inputChatMsg = new TextEditingController();

  TextEditingController inputWhere;
  TextEditingController inputWhatStall;
  TextEditingController inputWhatFood;
  TextEditingController inputWhatQty;
  TextEditingController inputRemark;




/*
  TextEditingController inputWhere = new TextEditingController(text: place);
  TextEditingController inputWhatStall = new TextEditingController(text: stall);
  TextEditingController  inputWhatFood = new TextEditingController(text: food);
  TextEditingController  inputWhatQty = new TextEditingController(text: qty);
  TextEditingController  inputRemark = new TextEditingController(text: remark);
  //inputAddress = new TextEditingController(text: address);
*/

  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) async{
      if (user != null) {
        userId = user.uid;
        //myEmail = user.email;
        var result = await Firestore.instance.collection("users").where(
            "userId", isEqualTo: userId).getDocuments();
        result.documents.forEach((record) {
          userName = record.data["name"];
        });
      }

/* //works.... in getting the index...but somehow created page tranefr problem. page go blank at Main, or was it the issue?
    if (index == null) { // for those that end up here from notification where index cannot be passed over
      var docSnap = await Firestore.instance.collection(groupId).getDocuments();
      int x = -1;
      docSnap.documents.forEach((result) {
        x++;
        if (result.documentID == stallId) {
          print("DocID >>>>>..................." + result.documentID);
          print("index >>>>>..................." + x.toString());
          index = x;
        }
      });
    }
*/
      inputWhere = new TextEditingController(text: place);
      inputWhatStall = new TextEditingController(text: stall);
      inputWhatFood = new TextEditingController(text: food);
      inputWhatQty = new TextEditingController(text: qty);
      inputRemark = new TextEditingController(text: remark);

    });

    Firestore.instance
        .collection(groupId)
        .document(stallId)
        .get()
        .then((value) async {
      if (value.data != null) {whoUploadId = value.data["whouploadId"];}
    });


    Firestore.instance
        .collection(groupId)
        .document(stallId).collection("messages").document("messages")
        .get()
        .then((value) async {
      if (value.data != null && settingDone !=1) {
        newMsgLog = value.data["messages"];
        setState(() {});
        settingDone=1;
      }else{}
    });
  }




  @override
  Widget build(BuildContext context) {

/*
    index = widget.theIndex;
    //stallId = widget.theStallId;
    stall = widget.theStall;
    food = widget.theFood;
    place = widget.thePlace;
    qty = widget.theQty;
    remark = widget.theRemark;
    //address = widget.theAddress;
    image = widget.theImage;
    //groupId = widget.theGroupId;
    //key = widget.key;
    //File croppedImage;
 */

    // if (index == null ){index = 0;} // for those that end up here from notification where index cannot be passed over


/*  work but shifted up to see if can solve the auto word disappear problem
    TextEditingController inputWhere = new TextEditingController(text: place);
    TextEditingController inputWhatStall = new TextEditingController(text: stall);
    TextEditingController  inputWhatFood = new TextEditingController(text: food);
    TextEditingController  inputWhatQty = new TextEditingController(text: qty);
    TextEditingController  inputRemark = new TextEditingController(text: remark);
    //inputAddress = new TextEditingController(text: address);
*/
    updateInfo() async {
      buttonTapped = true;
      //print ("place 1: " + place);
      if (inputWhere.text != ""){place = inputWhere.text;}
      if (inputWhatStall.text != ""){stall = inputWhatStall.text;}
      if (inputWhatFood.text != ""){food = inputWhatFood.text;}
      if (inputWhatQty.text != ""){qty = inputWhatQty.text;}
      if (inputRemark.text != ""){remark = inputRemark.text;}

      Map<String, String> userMap = {
        "whatUse": place, //whatUse
        "whatModel": stall, //whatModel
        "whatPN": food, //WhatPN
        "whatQty": qty, //whatQty
        //"address": inputAddress.text,
        "remark": remark,
      };

      await Firestore.instance.collection(groupId).document(stallId).updateData(userMap);
      Toast.show("Information uploaded", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }

    ok(){
      //Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId, theStallIndex: index)));
    }

    File croppedImage;
    final picker = ImagePicker();
    var pickedImage;
    var downloadUrl;
    Future captureImage(ImageSource source) async {
      //print ("+++++++++++++++");
      //imageCache.clear();
      //imageCache.clearLiveImages();
      pickedImage = await picker.getImage(source: source);
      //File compressedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 85);
      //print ("---------------------");
      //print ("here 111:::::::::::::::::: " + pickedImage.path);
      if (pickedImage.path == null ){} else {
        croppedImage = await ImageCropper.cropImage(
            sourcePath: pickedImage.path,
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
        //if (croppedImage != null ) {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddStall(croppedImage: croppedImage)));}

      }
      //print (image);
      StorageReference firebaseStorageRef =
      //FirebaseStorage.instance.ref().child(userId);
      FirebaseStorage.instance.ref().child(stallId);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(croppedImage);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
      //print ('url:::::::::::::: ' + downloadUrl.toString());

      await Firestore.instance.collection(groupId).document(stallId).updateData({"image": downloadUrl});
      imageNew = downloadUrl;
      //image = "https://firebasestorage.googleapis.com/v0/b/myclone-36401.appspot.com/o/kKTEfZynhZdxdKcK52MouEBv6bi12021-03-13%2008%3A17%3A11.086210?alt=media&token=8c5a7153-9a7d-459d-ad05-4140d79c31f6";
//print ("!!!!!!!!!!!!!!!" + imageNew);
//justText = "I know what" + imageNew;
      //imageCache.clear();
      //imageCache.clearLiveImages();
      setState(() {});
    }

    //trigger(){x++;print("in trigger: " + imageNew);justText = x.toString() + "  " + image;setState(() {});}


    Future getMsgList() async {
      await Firestore.instance
          .collection(groupId)
          .document(stallId).collection("messages").document("messages")
          .get()
          .then((value) {
        if (value.data != null) {
          if (value.data['messages'] != null) {
            newMsgLog = value.data['messages'];
          }
        }
      });
      if (mounted) setState(() {});
    }

    getMsgList();

    writeData() async{
      //print("entered writeDataaaaaaaaaaaaaaaaaaaaaaaaaaa");
      //Toast.show("Toast activated", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);


      await Firestore.instance
          .collection(groupId)
          .document(stallId).collection("messages").document("messages")
          .get()
          .then((value) async{

        if (value.data != null) {
          newMsgLog = value.data["messages"] + "\n" + userName + ": " + inputChatMsg.text;
          await Firestore.instance.collection(groupId).document(stallId).collection("messages").document("messages")
              .setData({"messages": newMsgLog});
          //print ("writtennnnnnnnnnnnn");
        }
        else {
          newMsgLog = userName + ": " + inputChatMsg.text;
          await Firestore.instance.collection(groupId).document(stallId).collection("messages").document("messages")
              .setData({"messages": newMsgLog});}

        //await Firestore.instance.collection(groupId).document(stallId).collection("messages").document("messages").setData({"messages": newMsgLog});
        setState(() {
          inputChatMsg.clear();
        });
        //inputChatMsg.clear();
      });

      // write to NotificationTrigger to trigger notification
      // but delete the existing triggering message first
      //Firestore.instance.collection("NotificationTrigger").getDocuments().then((snapshot) {
      //  for (DocumentSnapshot ds in snapshot.documents){
      //    ds.reference.delete();
      //  }
      //});

      Map<String, dynamic> triggerMap = {
        "groupId": groupId, //whatUse
        "stall": stall,
        "stallId": stallId,
        "food": food,
        "place": place,
        "qty": qty,
        "remark": remark,
        "image": image,
        "index": index,
      };
      await Firestore.instance.collection("NotificationTrigger").document()
          .setData(triggerMap);

    }

    //SchedulerBinding.instance.addPostFrameCallback((_) => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

//print ("userId:::::::: " + userId);
//    print ("creator Id :::::: " + whoUploadId);
    return Scaffold(
        resizeToAvoidBottomInset: true, // todo: open this up to avoid horizontal view overflow

        //backgroundColor: Colors.grey,
        appBar: AppBar(
          //automaticallyImplyLeading: true,

            title: (Text ("Edit and Chat")),
            //backgroundColor: Colors.grey,

            actions: [
              GestureDetector(
                  onTap: () { ok();},
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,12,20,10),
                    child: Text("ok", style: TextStyle(fontSize: 20),),
                  )),
            ]

        ),

        body:
        //Builder(builder: (context) => Container(
        //child:

        Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // image and info
              Container(
                height: 130,
                child: Row(
                  children: [
                    Expanded(flex:1,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Pictures(
                            theIndex: index,
                            theStallId: stallId,
                            theGroupId : groupId,
                            //theImage: snapshot.data[index].data['image'],
                            theStall :stall,
                            theFood: food,
                            //thePlace: snapshot.data[index].data['whatUse'],
                            //theRemark: snapshot.data[index].data['remark'],
                            //theAddress: snapshot.data[index].data['address'],
                          )));
                        },
                        onLongPress: () {if (userId == whoUploadId) captureImage(ImageSource.gallery);
                        },
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(8,8,10,0),
                            child: Container(
                              height: 120,
                              //width: 150,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: imageNew == null? Image.network(image, fit: BoxFit.fill): Image.network(imageNew, fit: BoxFit.fill)
                                //child: Image.file(croppedImage, fit: BoxFit.fill)
                              ),
                            )
                        ),
                      ),
                    ),

                    Expanded(flex: 2,
                      child: Column(
                        children: [
                          userId == whoUploadId?
                          Expanded(flex: 1,
                            child: TextField(
                              style:
                              TextStyle(fontStyle: FontStyle.italic, fontSize: 15, color: Colors.blue),
                              controller: inputWhere,
                              decoration: InputDecoration(
                              ),
                            ),
                          ):
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,20,8,0),
                            child: Align(alignment: Alignment.centerLeft,
                              child: Text(place,
                                  style:
                                  TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.blue)),
                            ),
                          ),

                          userId == whoUploadId?
                          Expanded(flex:1,
                            child: TextField(
                              style:
                              TextStyle(fontStyle: FontStyle.italic, fontSize: 15, color: Colors.blue),
                              controller: inputWhatStall, //this will insert the test into field for edit
                              decoration: InputDecoration(
                                //hintText: "the stall: " + stall, //without the controller, you can insert this hint, but then not editable
                                //hintStyle: TextStyle(
                                //    fontSize: 10,
                                //    color: Colors.grey[400],
                                //    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ):
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,5,8,0),
                            child: Align(alignment: Alignment.centerLeft,
                              child: Text(stall,
                                  //textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.blue)),
                            ),
                          ),

                          userId == whoUploadId?
                          Expanded(flex:1,
                            child:
                            TextField(
                              style:
                              TextStyle(fontStyle: FontStyle.italic, fontSize: 15, color: Colors.blue),
                              controller: inputWhatFood,
                              //keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                //hintText: "food: " + food,
                                //hintStyle: TextStyle(
                                //    fontSize: 10,
                                //    color: Colors.grey[400],
                                //    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ):
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,5,8,0),
                            child: Align(alignment: Alignment.centerLeft,
                              child: Text(food,
                                  //textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.blue)),
                            ),
                          ),

                          userId == whoUploadId?
                          Expanded(flex:1,
                            child: TextField(
                              style:
                              TextStyle(fontStyle: FontStyle.italic, fontSize: 15, color: Colors.blue),
                              controller: inputWhatQty,
                              decoration: InputDecoration(
                                //hintText: "qty: " + qty,
                                //hintStyle: TextStyle(
                                //    fontSize: 10,
                                //    color: Colors.grey[400],
                                //    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ):
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0,5,8,0),
                            child: Align(alignment: Alignment.centerLeft,
                              child: Text(qty,
                                  //textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.blue)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //remark
              Row(
                children: [
                  userId == whoUploadId?
                  Expanded (flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextField(
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                        controller: inputRemark,
                        keyboardType: TextInputType.multiline,
                        maxLength: null,
                        maxLines: null,
                        decoration: InputDecoration(
                          //hintText: remark,
                          //hintStyle: TextStyle(
                          //    fontSize: 15,
                          //    color: Colors.grey[400],
                          //    fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ):
                  Expanded(flex:1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20,8,8,0),
                      child: Align(alignment: Alignment.centerLeft,
                        child: Text(remark,
                            //textAlign: TextAlign.center,
                            style:
                            TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.blue)),
                      ),
                    ),
                  ),

                  userId == whoUploadId?
                  Expanded(flex: 1,
                    child: GestureDetector(
                        onTap: () {
                          userId == whoUploadId? updateInfo():
                          Toast.show("You have not update right", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
                          //Toast.show(imageUrl, context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                          ////////////////////////////////////////// wait need to at least validate email existed
                          //if (buttonTapped == false) {updateInfo();}
                          //setupFamilyGroup();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0,15,0,15),
                          child:  Icon(
                            Icons.upload,
                            color: Colors.blue,
                            size: 20.0,
                          ),
                        )),
                  ):
                  Text(""),


                ],
              ),


              // message scroll and input
              Expanded(flex: 1,
                child: Container(
                  //height: 500,
                  //constraints: BoxConstraints.expand(),
                  height: MediaQuery.of(context).size.height,
                  //height: double.infinity,
                  child: Column(
                    children: [
                      Expanded(flex:8,

                        child: Align(alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0,10,0,15),
                            child: SingleChildScrollView(
                              //controller: _scrollController,
                              reverse: true,
                              scrollDirection: Axis.vertical, //.horizontal
                              //padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                  child: newMsgLog != null
                                      ? Text(
                                    newMsgLog,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                      : Text(""),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),


                      //input message
                      Row(
                        children: [
                          Expanded(flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                              child: TextFormField(
                                style: TextStyle(color: Colors.blue),
                                controller: inputChatMsg,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "type your message here",
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[400],
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          ),

                          Expanded(flex: 1,
                            child: GestureDetector(
                                onTap: () {
                                  //print (inputChatMsg.text);
                                  inputChatMsg.text != ""?
                                  //print (inputChatMsg.text);
                                  writeData()
                                  //print ("testttttttttttttt");
                                      :print ("nulllllllllllll");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0,0,0,15),
                                  child:  Icon(
                                    Icons.send,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ])
      //))
    );
  }
}
