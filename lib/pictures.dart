
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:expenses/viewpicture.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:partswanted/viewpicture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:network_to_file_image/network_to_file_image.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:http/http.dart' as http;
//import 'dart:math';

class Pictures extends StatefulWidget {
  final theIndex;
  final theStallId;
  final theStallIdNo;
  final theStall;
  final theFood;
  final thePlace;
  final theRemark;
  final theAddress;
  final theImage;
  final theGroupId;
  Pictures({this.theIndex, this.theStallId, this.theStallIdNo, this.theImage, this.theStall, this.theFood, this.thePlace, this.theRemark, this.theAddress, this.theGroupId});

  @override
  _PicturesState createState() => _PicturesState(stallIdNo: theStallIdNo);
}

class _PicturesState extends State<Pictures> {



  int index;
  String stallId;
  String stallIdNo;
  String stall;
  String food;
  String place;
  String remark;
  String address;
  String image;
  String groupId;
  //List breakupMsg = [];
  List imageUrl = [];
  //var imageUrl = List (20);
  //List imageUrl = List.empty(growable:true);
  //List imageUrl = List.filled(20, "dd");
  //var imageUrl = [];

  int docLength;
  int docLengthMore;
  //int getPicDone;
  int picIndex;
  //int docStart=0;
  //int addOrDel=0;
  int triggered=0;
  String myEmail;

  _PicturesState({this.stallIdNo});

  void initState() {
    super.initState();

    //User user = FirebaseAuth.instance.currentUser;
    //userId = FirebaseAuth.instance.currentUser.uid;
    myEmail = FirebaseAuth.instance.currentUser.email;
  }

  getPictures() async {
    if (triggered !=1) {
    QuerySnapshot qn = await FirebaseFirestore.instance.collection(groupId).doc(stallId).collection("pictures").get();
    docLength = qn.docs.length;
    int x;
    for (x=0; x< docLength ; x++) {
      imageUrl.add(await qn.docs[x]['image']);
    }

    QuerySnapshot qnMore = await FirebaseFirestore.instance.collection(groupId).doc(stallId).collection("morePictures").get();
    docLengthMore = qnMore.docs.length;
    int y;
    for (y=0; y< docLengthMore ; y++) {
      imageUrl.add(await qnMore.docs[y]['image']);
    }


    setState(() {triggered = 1;});

    //print (stallId);
  }

  }



  File croppedImage;
  final picker = ImagePicker();
  var pickedImage;
  var downloadUrl;
  String pictureId;
  String picAdded = "N";

  Future captureImage(ImageSource source) async {
    pickedImage = await picker.getImage(source: source);
    if (pickedImage.path == null ){} else {
      croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 800,
          maxHeight: 800,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue,
            toolbarTitle: "Crop it",
          ));
    }

    pictureId = myEmail + DateTime.now().toString();

    StorageReference firebaseStorageRef =
    //FirebaseStorage.instance.ref().child(pictureId); /// put to folder email > stallId > email + DateTime.noe().toString()_add
    FirebaseStorage.instance.ref().child(stallIdNo + "/" + myEmail + "/" +  pictureId);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(croppedImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    downloadUrl = await taskSnapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection(groupId).doc(stallId).collection("pictures").doc(pictureId).set({"image": downloadUrl});
    //docStart = docLength;
    docLength ++;
    imageUrl.add(downloadUrl);
    picAdded = "Y";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    //index = widget.theIndex;
    stallId = widget.theStallId;
    stall = widget.theStall;
    food = widget.theFood;
    //place = widget.thePlace;
    //remark = widget.theRemark;
    //address = widget.theAddress;
    //image = widget.theImage;
    groupId = widget.theGroupId;

    getPictures();

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(

          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
              onPressed: () {
                //picAdded == "Y" ?
                Navigator.pop(context, picAdded);
                    //: Navigator.pop(context);
              }),

          title: (Text("Pictures")),
          backgroundColor: Colors.black,
          actions: [
            GestureDetector(
                onTap: () {captureImage(ImageSource.camera);},
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.add_a_photo),
                )),

            GestureDetector(
                onTap: () {
                  captureImage(ImageSource.gallery);},
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.photo),
                ))
          ],
        ),

        body:
        Column(
          children: [
            SizedBox(height:10),
            Text (stall, textAlign: TextAlign.center, style: TextStyle(color: Colors.white,)),
            Text (food, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            Divider(color: Colors.grey),
            Expanded(
              flex: 30,
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(5),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: imageUrl.map((imageUrl) => buildCard((context), imageUrl)).toList(),
              ),
            ),
          ],
        )
    );
  }

  removePic(urlClicked) async {
    //QuerySnapshot qn = await Firestore.instance.collection("FoodStall").document(stallId).collection("pictures").getDocuments();
    //print("here: " + urlClicked);
    FirebaseFirestore.instance
        .collection(groupId).doc(stallId).collection("pictures").where("image", isEqualTo: urlClicked) .get()
        .then((value) {
      value.docs.forEach((result) async{
        result.reference.delete();
        //await FirebaseFirestore.instance.collection(groupId).doc(stallId).collection("pictures").doc(result.documentID).delete();
        //print(result.documentID);
      }); });

    StorageReference firebaseStorageRef = await FirebaseStorage.instance.getReferenceFromUrl(urlClicked);
    await firebaseStorageRef.delete();
    imageUrl.remove(urlClicked);
    //getPicDone = 0;
    setState(() {});
  }

  Widget buildCard(BuildContext context, String imageUrl) => FocusedMenuHolder(
    menuWidth: 80,
    menuItems: [
      FocusedMenuItem(title: Text('ok'), onPressed: (){
        //Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPicture(theImageUrl: imageUrl)));
      }),
      FocusedMenuItem(
          title: Text('Del', style: TextStyle(color: Colors.white)),
          trailingIcon: Icon(Icons.delete, color: Colors.white,),
          backgroundColor: Colors.redAccent,
          onPressed: (){removePic(imageUrl);}
      )
    ],
    //openWithTap: true,
    onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPicture(theImageUrl: imageUrl)));
    },
    child: Container(
        child: imageUrl != null ? Image.network(imageUrl,fit: BoxFit.fill):null
    ),
  );
}

