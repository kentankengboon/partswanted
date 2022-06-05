
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:image_cropper/image_cropper.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:geocoder/geocoder.dart';
//import 'package:location_permissions/location_permissions.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:permission/permission.dart';
import 'package:intl/intl.dart';

import 'food.dart';

class AddStall extends StatefulWidget {
  File croppedImage;
  final theGroupId;
  AddStall({Key key, this.croppedImage, this.theGroupId}) : super(key: key);

  @override
  _AddStallState createState() => _AddStallState();
}

class _AddStallState extends State<AddStall> {
  String groupId;
  String userName;
  String userEmail;


  @override
  Widget build(BuildContext context) {
    TextEditingController inputWhere = new TextEditingController();
    TextEditingController inputWhatStall = new TextEditingController();
    TextEditingController inputWhatFood = new TextEditingController();
    TextEditingController inputWhatQty = new TextEditingController();
    TextEditingController inputRemark = new TextEditingController();
    TextEditingController inputCustomer = new TextEditingController();
    TextEditingController inputTgtPrice = new TextEditingController();

    File theImage = widget.croppedImage;
    groupId = widget.theGroupId;


    String userId;
    String stallId;
    //String timeStamp;
    double latitudeData;
    double longitudeData;
    int rating = 1;
    bool buttonTapped = false;
    //  attempt //
    String dropdownValue;

    //File croppedImage;
    //final picker = ImagePicker();

    userId = FirebaseAuth.instance.currentUser.uid;
    if (userId != null) {
      FirebaseFirestore.instance.collection("users").where("userId", isEqualTo: userId).get().then((result){
        if (result.docs.isNotEmpty){
          //print ("here?>>>>>>>>>>>>>>.");
          result.docs.forEach((record) {userName = record["name"];userEmail = record["email"];});
          //print ("userName:::::::::: " + userName);
        }
      });


      //result.documents.forEach((record) { userName = record.data["name"];});
//print ("userName:::::::::: " + userName);
      //Toast.show("here: " + userName, context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      //Toast.show(" not found", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeamPage()));
    } else {
      //print (user.uid);
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
    }
/*
    FirebaseAuth.instance.currentUser().then((user) async{
      //setState(() {
      if (user != null) {
        userId = user.uid;
        var result = await Firestore.instance.collection("users") .where("userId", isEqualTo: userId) .getDocuments();
        result.documents.forEach((record) { userName = record.data["name"];
        });
        Toast.show("here: " + userName, context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeamPage()));
      } else {
        //print (user.uid);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
      }
      //});
    });
*/
    Future uploadStallInfo() async {
      //var image = await picker.getImage(source: source);
      //File compressedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 85);

      //if (image != null) {
      //  croppedImage = await ImageCropper.cropImage(
      //      sourcePath: image.path,
      //      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      //      compressQuality: 100,
      //      maxWidth: 500,
      //      maxHeight: 500,
      //      compressFormat: ImageCompressFormat.jpg,
      //      androidUiSettings: AndroidUiSettings(
      //        toolbarColor: Colors.blue,
      //        toolbarTitle: "Crop it",
      //      ));
      //setState(() {_image = cropped;flag=1;});
      //}

      //print ("tapped 1 ?" + buttonTapped.toString());

      buttonTapped = true;

      //print ("tapped 2 ?" + buttonTapped.toString());
      var downloadUrl;
      var downloadUrl0;
      DateTime now = DateTime.now();
      //stallId = userEmail + now.toString();
      String formattedDate = DateFormat('yyyy-MM-dd' + '  ' + 'HH:mm').format(now);
      String idDate = DateFormat('yyyyMMddHHmmss').format(now);
      stallId = idDate + userEmail;
//print ("stallIdnew: " + stallId);



      StorageReference firebaseStorageRef =
      //FirebaseStorage.instance.ref().child(userId);
      FirebaseStorage.instance.ref().child(stallId + "/" + userEmail + "/" +  stallId +"_0");
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(theImage);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();

      firebaseStorageRef = FirebaseStorage.instance.ref().child(stallId + "/" + userEmail + "/"  + stallId+"_1");
      uploadTask = firebaseStorageRef.putFile(theImage);
      taskSnapshot = await uploadTask.onComplete;
      downloadUrl0 = await taskSnapshot.ref.getDownloadURL();


/*
      final geoposition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitudeData = geoposition.latitude;
      longitudeData = geoposition.longitude;
      final coordinates = new Coordinates(latitudeData, longitudeData);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      String addr2 = addresses.first.addressLine;
*/


      Map<String, dynamic> userMap = {

        "image": downloadUrl,
        "whoupload": userEmail,
        "whatUse": inputWhere.text,
        "whatModel": inputWhatStall.text,
        "whatPN": inputWhatFood.text,
        "whatQty": inputWhatQty.text,
        //"address" : addr2,
        //"rating" : rating.toString(),
        "remark": inputRemark.text,
        //result = DateTime.Now.Date.ToString("yyyy.MM.dd | HH:mm:ss | ")
        "whenAsk": formattedDate,
        "whouploadId": userEmail,
        "since" : formattedDate,
        "customer": inputCustomer.text,
        "tgtPrice": inputTgtPrice.text,
        "stallId": stallId,
        "quotes": "",
        "poUploaded": "",
        "poStatus": ""
        //"msgIncoming" : 0 // <<<<<<<< no need liao, and go remove all msgIncoming at firestore bah
        // >>>>>>>>>> instead must have all members email and set up mail box state = 0 here
        //"whenAsk": DateTime.now().toString("yyyy.MM.dd | HH:mm:ss | ")
      };

      await FirebaseFirestore.instance
          .collection(groupId)
          .doc(stallId)
          .set(userMap);

      await FirebaseFirestore.instance
          .collection(groupId)
          .doc(stallId)
          .update({"rating": rating});

      await FirebaseFirestore.instance
          .collection(groupId)
          .doc(stallId).collection("pictures").doc(stallId + "0")
          .set({"image": downloadUrl0});

      await FirebaseFirestore.instance
          .collection(groupId)
          .doc(stallId).collection("messages").doc("messages")
          .set({"messages": "request starts on  " + formattedDate});

      await FirebaseFirestore.instance
          .collection(groupId)
          .doc(stallId).collection("messages").doc("messages")
          .update({"dateStamp": DateFormat.yMMMd().format(now)});
      await FirebaseFirestore.instance
          .collection(groupId)
          .doc(stallId).collection("messages").doc("messages")
          //.update({"timeStamp": DateFormat('hh:mm').format(DateTime.now())});
          .update({"timeStamp": now});

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId,)));

      //Firestore.instance
      //    .collection(groupId)
      //    .document(stallId)
      //    .setData({'image': downloadUrl});
      //setState(() {userImageUrl = downloadUrl; Navigator.push(context, MaterialPageRoute(builder: (context) => Users()));});

    }
    //File croppedImage;



    //    attempt  ///
    void overflowSelected(String choice) {
      //if (choice == OverflowBtn.courtsClick) {
        //Toast.show("Here ", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        inputCustomer.text = choice;

      //}
    }

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(

          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
              onPressed: () {
                //print ("userStatus:  " + userStatus);
                //Navigator.pop(context); //to fix routing issue, cannot use this else might show blank page if there isnt a previous widget standby in place. hence not working for Notification jumping to EditStall situation
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId,)));
              }),
          title: (Text("Add Part")),
        ),

        body: SingleChildScrollView(
          reverse: true,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 200,
                  width: 200,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.file(theImage, width: 200, height: 200,)), //fit: BoxFit.fill)),
                )),
            //SizedBox (height: 5),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                controller: inputWhere,
                decoration: InputDecoration(
                  hintText: "What use",
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),



            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                controller: inputWhatStall,
                decoration: InputDecoration(
                  hintText: "what Model",
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                controller: inputWhatFood,
                decoration: InputDecoration(
                  hintText: "what PN",
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                controller: inputWhatQty,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "what Qty",
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                controller: inputRemark,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "description",
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),

/*
//    attempt  ///
        DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
              setState(() {
              dropdownValue = newValue;
              });
              },
              items: <String>['One', 'Two', 'Free', 'Four']
                  .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
              );
              }).toList(),
              ),
*/




            Row(
              children: [
                Expanded(flex:7,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextField(
                      style:
                      TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                      controller: inputCustomer,
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "customer (if applicable)",
                        hintStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),

                //    attempt  ///
                Expanded(flex:1,
                  child: PopupMenuButton<String>(
                    onSelected: overflowSelected,
                    itemBuilder: (BuildContext context) {
                      return OverflowBtn.choices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ),

              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                controller: inputTgtPrice,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Tgt Price (if applicable)",
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),



            SizedBox(height: 20),

            Row(
              children: [
                //SizedBox(width: 15),

                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20,0,0,0),
                    child: GestureDetector(
                      onTap: (){Toast.show("Please click ok when done", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);},
                      child: Text(
                        "reserved button",
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 150,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        //primary: Colors.black,
                        backgroundColor: Colors.blue,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      onPressed: () {if (buttonTapped == false) {uploadStallInfo();}},
                      child: Text(
                        "ok",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ]),
        ));
  }
}

//    attempt  ///
class OverflowBtn{
  static const String courtsClick ='Courts';
  static const String harveyNormanClick ='Harvey Norman';
  static const String asusClick ='Asus';
  static const String b2cClick ='B2C';
  static const String archiveClick ='Archived';

  static const List <String> choices = <String> [
    courtsClick, harveyNormanClick , asusClick, b2cClick, archiveClick];

}