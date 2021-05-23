
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

  @override
  Widget build(BuildContext context) {
    TextEditingController inputWhere = new TextEditingController();
    TextEditingController inputWhatStall = new TextEditingController();
    TextEditingController inputWhatFood = new TextEditingController();
    TextEditingController inputWhatQty = new TextEditingController();
    TextEditingController inputRemark = new TextEditingController();

    File theImage = widget.croppedImage;
    groupId = widget.theGroupId;


    String userId;
    String stallId;
    double latitudeData;
    double longitudeData;
    int rating = 1;
    bool buttonTapped = false;

    //File croppedImage;
    //final picker = ImagePicker();


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

      stallId = userId + DateTime.now().toString(); // todo: stallID with model number
      StorageReference firebaseStorageRef =
      //FirebaseStorage.instance.ref().child(userId);
      FirebaseStorage.instance.ref().child(stallId);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(theImage);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      var downloadUrl = await taskSnapshot.ref.getDownloadURL();

      firebaseStorageRef = FirebaseStorage.instance.ref().child(stallId + "0");
      uploadTask = firebaseStorageRef.putFile(theImage);
      taskSnapshot = await uploadTask.onComplete;
      var downloadUrl0 = await taskSnapshot.ref.getDownloadURL();

/*
      final geoposition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitudeData = geoposition.latitude;
      longitudeData = geoposition.longitude;
      final coordinates = new Coordinates(latitudeData, longitudeData);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      String addr2 = addresses.first.addressLine;
*/
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      Map<String, String> userMap = {

        "image": downloadUrl,
        "whoupload": userName,
        "whatUse": inputWhere.text,
        "whatModel": inputWhatStall.text,
        "whatPN": inputWhatFood.text,
        "whatQty": inputWhatQty.text,
        //"address" : addr2,
        //"rating" : rating.toString(),
        "remark": inputRemark.text,
        //result = DateTime.Now.Date.ToString("yyyy.MM.dd | HH:mm:ss | ")
        "whenAsk": formattedDate,
        "whouploadId": userId,
        "archive" : formattedDate,
        //"whenAsk": DateTime.now().toString("yyyy.MM.dd | HH:mm:ss | ")
      };

      await Firestore.instance
          .collection(groupId)
          .document(stallId)
          .setData(userMap);

      await Firestore.instance
          .collection(groupId)
          .document(stallId)
          .updateData({"rating": rating});

      await Firestore.instance
          .collection(groupId)
          .document(stallId).collection("pictures").document(stallId + "0")
          .setData({"image": downloadUrl0});

      await Firestore.instance
          .collection(groupId)
          .document(stallId).collection("messages").document("messages")
          .setData({"messages": "request starts on " + formattedDate});

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: groupId,)));

      //Firestore.instance
      //    .collection(groupId)
      //    .document(stallId)
      //    .setData({'image': downloadUrl});
      //setState(() {userImageUrl = downloadUrl; Navigator.push(context, MaterialPageRoute(builder: (context) => Users()));});

    }


    //File croppedImage;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: (Text("Add Stall")),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 300,
                  width: 400,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.file(theImage, fit: BoxFit.fill)),
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

            SizedBox(height: 20),

            Row(
              children: [
                //SizedBox(width: 15),

                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20,0,0,0),
                    child: GestureDetector(
                      onTap: (){Toast.show("He likes it too !!!", context,
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
                    child: FlatButton(
                      //child: TextButton(
                      onPressed: () {if (buttonTapped == false) {uploadStallInfo();}},
                      //style: TextButton.styleFrom(primary: Colors.blue,),
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
