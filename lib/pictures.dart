
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
import 'package:toast/toast.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:network_to_file_image/network_to_file_image.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:http/http.dart' as http;
//import 'dart:math';

class Pictures extends StatefulWidget {
  final theIndex;
  final theStallId;
  final theStall;
  final theFood;
  final thePlace;
  final theRemark;
  final theAddress;
  final theImage;
  final theGroupId;
  Pictures({this.theIndex, this.theStallId, this.theImage, this.theStall, this.theFood, this.thePlace, this.theRemark, this.theAddress, this.theGroupId});

  @override
  _PicturesState createState() => _PicturesState();
}

class _PicturesState extends State<Pictures> {
  int index;
  String stallId;
  String stall;
  String food;
  String place;
  String remark;
  String address;
  String image;
  String groupId;

  var imageUrl = List (20);
  //List imageUrl = List.empty(growable:true);
  //List imageUrl = List.filled(20, "dd");
  //var imageUrl = [];

  int docLength;
  int getPicDone;
  int picIndex;

  getPictures() async {
    QuerySnapshot qn = await Firestore.instance.collection(groupId).document(stallId).collection("pictures").getDocuments();
    docLength = qn.documents.length;
    //print ("doclength: " + docLength.toString());
    //nextPicIndex = docLength;
    int x;
    for (x=0; x< docLength ; x++) {
      imageUrl [x] = await qn.documents[x].data['image'];
      //print (x.toString() + "   " + imageUrl [x]);
    }
    imageUrl [docLength] = null;
    if (getPicDone!=1) {setState(() {}); getPicDone = 1;}
    //print (stallId);
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

/*
    String userId;
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        userId = user.uid;
      } else {}
    });
*/
    getPictures();

    File croppedImage;
    final picker = ImagePicker();
    var pickedImage;
    var downloadUrl;
    String pictureId;
    Future captureImage(ImageSource source) async {
      pickedImage = await picker.getImage(source: source);
      if (pickedImage.path == null ){} else {
        croppedImage = await ImageCropper.cropImage(
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

      pictureId = stallId + DateTime.now().toString();
      StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(pictureId);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(croppedImage);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await Firestore.instance.collection(groupId).document(stallId).collection("pictures").document(pictureId).setData({"image": downloadUrl});
      docLength ++;
      getPicDone = 0;
      setState(() {});
    }

/*
    removePic() async {
      QuerySnapshot qn = await Firestore.instance.collection("FoodStall").document(stallId).collection("pictures").getDocuments();

      Firestore.instance
          .collection("FoodStall").document(stallId).collection("pictures").where("image", isEqualTo: imageUrl[picIndex]) .getDocuments()
          .then((value) {
        value.documents.forEach((result) async{
          await Firestore.instance.collection("FoodStall").document(stallId).collection("pictures")
              .document(result.documentID).delete();
          print(result.documentID);
        }); });

      StorageReference firebaseStorageRef = await FirebaseStorage.instance.getReferenceFromUrl(imageUrl[picIndex]);
      await firebaseStorageRef.delete();
      getPicDone = 0;
      setState(() {});
    }
*/
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: (Text("Memories")),
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
            Expanded(flex:1, child: Text (stall, style: TextStyle(color: Colors.white,)),),
            Expanded(flex:1, child: Text (food, style: TextStyle(color: Colors.white)),),
            Expanded(flex:1, child: Divider(color: Colors.grey)),
            Expanded(
              flex: 30,
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(5),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,

                children: imageUrl.map((imageUrl) => buildCard((context), imageUrl)).toList(),

/*
              children: <Widget>[
                GestureDetector(
                  onTap: (){picIndex =0; removePic();},
                  child: Container(
                    child: imageUrl[0] != null ? Image.network(imageUrl[0],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =1; removePic();},
                  child: Container(
                      child: imageUrl[1] != null ? Image.network(imageUrl[1],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =2; removePic();},
                  child: Container(
                      child: imageUrl[2] != null ? Image.network(imageUrl[2],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =3; removePic();},
                  child: Container(
                      child: imageUrl[3] != null ? Image.network(imageUrl[3],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =4; removePic();},
                  child: Container(
                      child: imageUrl[4] != null ? Image.network(imageUrl[4],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =5; removePic();},
                  child: Container(
                      child: imageUrl[5] != null ? Image.network(imageUrl[5],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =6; removePic();},
                  child: Container(
                      child: imageUrl[6] != null ? Image.network(imageUrl[6],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =7; removePic();},
                  child: Container(
                      child: imageUrl[7] != null ? Image.network(imageUrl[7],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =8; removePic();},
                  child: Container(
                      child: imageUrl[8] != null ? Image.network(imageUrl[8],fit: BoxFit.fill):null
                  ),
                ),
                GestureDetector(
                  onTap: (){picIndex =9; removePic();},
                  child: Container(
                      child: imageUrl[9] != null ? Image.network(imageUrl[9],fit: BoxFit.fill):null
                  ),
                ),
              ],
*/

              ),
            ),
          ],
        )

/* ///////////////// A template for list view //////////////
      Column(
          children: [
          SizedBox(height: 20),
          Text(stall, style: TextStyle(color: Colors.white)),
          Text(food, style: TextStyle(color: Colors.white)),
          Divider(color: Colors.grey),

          FutureBuilder(
            future: getPictures(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text("Loading..."),);
              } else {
            SizedBox(height: 100);
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {

                  return ListTile();

                });


              }


            })

          ]

      )
*/

    );
  }

  removePic(urlClicked) async {
    //QuerySnapshot qn = await Firestore.instance.collection("FoodStall").document(stallId).collection("pictures").getDocuments();
    //print("here: " + urlClicked);

    Firestore.instance
        .collection(groupId).document(stallId).collection("pictures").where("image", isEqualTo: urlClicked) .getDocuments()
        .then((value) {
      value.documents.forEach((result) async{
        await Firestore.instance.collection(groupId).document(stallId).collection("pictures")
            .document(result.documentID).delete();
        //print(result.documentID);
      }); });

    StorageReference firebaseStorageRef = await FirebaseStorage.instance.getReferenceFromUrl(urlClicked);
    await firebaseStorageRef.delete();
    getPicDone = 0;
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
