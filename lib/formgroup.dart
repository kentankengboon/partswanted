
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'main.dart';
import 'main_group.dart';

class FormGroup extends StatefulWidget {

  //final theImageUrl;
  //FormGroup({this.theImageUrl});
  final theMyEmail;
  FormGroup({this.theMyEmail});

  @override
  _FormGroupState createState() => _FormGroupState(myEmail: theMyEmail);
}

class _FormGroupState extends State<FormGroup> {

  //String dropdownValue = "One'";

  String downloadUrl;
  String nameEntered;
  TextEditingController groupName = new TextEditingController();
  String tokenId;
  String myEmail;
  _FormGroupState({this.myEmail});

  void initState() {
    super.initState();
    Firestore.instance.collection("users").document(myEmail).get()
        .then((value) {
      if (value.data != null) {
        if (value.data['tokenId'] != null) {tokenId = value.data['tokenId'];}
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    final formkey = GlobalKey<FormState>();

    TextEditingController email1 = new TextEditingController();
    TextEditingController email2 = new TextEditingController();
    TextEditingController email3 = new TextEditingController();
    TextEditingController email4 = new TextEditingController();
    TextEditingController email5 = new TextEditingController();
    String groupId;

//    String userId;
//    String myEmail;
    var otherEmail = List.filled(5,""); //List (5);
    var emailFound = List.filled(5,0); //List (5);
    //var emailNotFound = List (5);

/*
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        userId = user.uid;
        myEmail = user.email;
      } else {}
    });
*/

    String memberTokenId;
    findAndWriteToken(memberEmail)async{
      print ("memberemail:  " + memberEmail);
      await Firestore.instance.collection("users").document(memberEmail).get().then((value) {
        if (value.data != null) {
          if (value.data['tokenId'] != null) {memberTokenId = value.data['tokenId'];}
        }
      });
      Firestore.instance.collection("groups").document(groupId).collection("tokens").document(memberTokenId).setData({"tokenId" : memberTokenId});

    }


    setupFamilyGroup () async {

      if (groupName.text != "") {
        groupId = myEmail + groupName.text;
        //print("groupid " + groupId);
        //print("myemail " + myEmail);
        //print("groupName: " + groupName.text);
        otherEmail[0] = email1.text;
        otherEmail[1] = email2.text;
        otherEmail[2] = email3.text;
        otherEmail[3] = email4.text;
        otherEmail[4] = email5.text;

        await Firestore.instance.collection("users").document(myEmail)
            .collection("Group").document(groupName.text).get()
            .then((value) async {
          //print (value.data);
          if (value.data == null) {
            await Firestore.instance.collection("users").document(myEmail)
                .collection("Group").document(groupName.text)
                .setData({"groupId": groupId});}

          await Firestore.instance.collection("users").document(myEmail)
              .collection("Group").document(groupName.text)
              .updateData({"groupName": groupName.text});
          await Firestore.instance.collection("users").document(myEmail)
              .collection("Group").document(groupName.text)
              .updateData({"image": downloadUrl});
        });

        ////////////////////////////////  form the main groups and member data here  /////////////////
        //if first time forming, setData for first x, if not updateData, like below to the GP&Member data base
        //using groupID, first build up data: familyMame, myEmail, groupId, and imageUrl.
        // and this should be the first time setting up the data as the validate function above already check for existing groupName
        //then below update with all member email one by one as you go through the loop
        Map<String, String> userMap = {
          "groupId": groupId,
          "groupName": groupName.text,
          "image": downloadUrl,
          "member1": myEmail,
        };
        int m=1;
        await Firestore.instance.collection("groups").document(groupId).setData(userMap);
        if (otherEmail[0] != "") {++m; await Firestore.instance.collection("groups").document(groupId).updateData({"member2" : otherEmail[0]});
        findAndWriteToken(otherEmail[0]);}
        if (otherEmail[1] != "") {++m; await Firestore.instance.collection("groups").document(groupId).updateData({"member3" : otherEmail[1]});
        findAndWriteToken(otherEmail[1]);}
        if (otherEmail[2] != "") {++m; await Firestore.instance.collection("groups").document(groupId).updateData({"member4" : otherEmail[2]});
        findAndWriteToken(otherEmail[2]);}
        if (otherEmail[3] != "") {++m; await Firestore.instance.collection("groups").document(groupId).updateData({"member5" : otherEmail[3]});
        findAndWriteToken(otherEmail[3]);}
        if (otherEmail[4] != "") {++m; await Firestore.instance.collection("groups").document(groupId).updateData({"member6" : otherEmail[4]});
        findAndWriteToken(otherEmail[4]);}

        Firestore.instance.collection("groups").document(groupId).updateData({"memberCount" : m});
        Firestore.instance.collection("groups").document(groupId).collection("tokens").document(tokenId).setData({"tokenId" : tokenId});

        // record this groupName and info to each user data record
        for (int x = 0; x <= 4; x++) {
          //print("what is the xxxxxxxxxx: " + x.toString());
          if (otherEmail[x] != "") {
            await Firestore.instance.collection("users").document(
                otherEmail[x])
                .collection("Group").document(groupName.text).get()
                .then((value) async {
              //print (value.data);
              if (value.data == null) { //can I remove the == null so that it will always update? else how to update latest image?
                await Firestore.instance.collection("users").document(
                    otherEmail[x]).collection("Group").document(groupName.text)
                    .setData({"groupId": groupId});}

              await Firestore.instance.collection("users").document(
                  otherEmail[x]).collection("Group").document(groupName.text)
                  .updateData({"groupName": groupName.text});
              await Firestore.instance.collection("users").document(
                  otherEmail[x]).collection("Group").document(groupName.text)
                  .updateData({"image": downloadUrl});

            });
          }
        }



      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));

    }


    validate()async {
      int noGo;
      groupId = myEmail + groupName.text;
      //print("groupid " + groupId);
      //print("myemail " + myEmail);
      //print("groupName: " + groupName.text);
      otherEmail[0] = email1.text;
      otherEmail[1] = email2.text;
      otherEmail[2] = email3.text;
      otherEmail[3] = email4.text;
      otherEmail[4] = email5.text;

      QuerySnapshot qn = await Firestore.instance.collection("users").document(myEmail).collection ("Group").getDocuments();
      int docLength = qn.documents.length;
      int familyFound = 0;
      int groupIdFound = 0;
      for (int fn = 0; fn <= docLength-1; fn++){
        if (groupName.text == qn.documents[fn].data['groupName']) {familyFound = 1;}
        if (myEmail + groupName.text == qn.documents[fn].data['groupId']) {groupIdFound = 1;}
      }
      if (familyFound == 1){Toast.show("Family task: " + groupName.text + " existed." + "\n" + "Please re-enter family task name.", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP); noGo = 1;}
      if (groupIdFound == 1){Toast.show("GroupId: " + myEmail + groupName.text + " existed." + "\n" + "Please re-enter family task name.", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP); noGo = 1;}

      qn = await Firestore.instance.collection("users").getDocuments();
      docLength = qn.documents.length;

      for (int y = 0; y<=4; y++){
        emailFound[y] = 0;
        if (otherEmail[y] != "") {
          for (int x = 0; x <= docLength-1; x++) {
            if (otherEmail[y] == qn.documents[x].data['email']) {emailFound[y] = 1;}
          }
          if (emailFound[y] == 0){Toast.show(otherEmail[y] + " not found", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP); noGo = 1;}
        }
      }
      //print ("No Go: " + noGo.toString());
      if (noGo != 1) {setupFamilyGroup();}
    }

    File croppedImage;
    final picker = ImagePicker();
    var pickedImage;

    Future captureImage(ImageSource source) async {
      groupId = myEmail + groupName.text;
      nameEntered = groupName.text;
      pickedImage = await picker.getImage(source: source);
      print ("here1" +    pickedImage.path);
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
        print ("here2");
      }
//print ("groupId : " + groupId);

      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(groupId);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(croppedImage);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
//print ("downloadUrl :" + downloadUrl);
//print ("groupName: " + groupName.text);
//print ("nameEntered: " + nameEntered);
      setState(() {});
    }


    validategroupName()async {
      QuerySnapshot qn = await Firestore.instance.collection("users").document(myEmail).collection ("Group").getDocuments();
      int docLength = qn.documents.length;
      int familyFound = 0;
      for (int fn = 0; fn <= docLength-1; fn++){
        if (groupName.text == qn.documents[fn].data['groupName']) {familyFound = 1;}
      }
      if (familyFound == 1){Toast.show("Family task: " + groupName.text + " existed." + "\n" + "Please re-enter family task name.", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
      else{captureImage(ImageSource.gallery);}
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
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));
                }),

            title: (Text("Form Task Force")),

            actions: [
              GestureDetector(
                  onTap: () {
                    if (groupName.text != ""){validate();}else{Toast.show("Please enter a family task name", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,12,20,10),
                    child: Text("ok", style: TextStyle(fontSize: 20),),
                  )),
            ]
        ),

        body: SingleChildScrollView(
          reverse: true,
          child: Column(children: [


            SizedBox(height: 20),
            Text("Enter group purpose:", style: TextStyle(fontSize: 25, color: Colors.blue) ,),

            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                    child: TextField(
                      //validator: (val){ return val.isEmpty || val.length <3 ? "Family task Name is not valid" : null;},
                      style:
                      TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                      controller: groupName,
                      decoration: InputDecoration(
                        hintText: nameEntered,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.blue[400],
                          //fontStyle: FontStyle.italic
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                    flex: 1,
                    child:
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
                        child: GestureDetector(
                            onTap: () {

//////////////////////////// here if we are editing an existing family task, then no need to validate the Fam Name here.  Same when click the OK
                              if (groupName.text != ""){validategroupName();}else{Toast.show("Please enter a family task name first", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
                              //groupName.text != "" ? captureImage(ImageSource.gallery): //do the validate first then image thing
                              //Toast.show("Please enter a family task name first", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
                            },
                            child: Icon(Icons.photo, color: Colors.blue,))
                    )),
              ],
            ),
            SizedBox(height: 20),
            ClipRRect(
                child:
                downloadUrl != null?
                Image.network(downloadUrl, width: 200, height: 200, //fit: BoxFit.fill
                ):Image.asset("assets/groupIcon.png", width: 300, height: 150,),
                borderRadius: BorderRadius.circular(30)
            ),
            SizedBox(height: 10),
            Text("I want to invite: ", style: TextStyle(fontSize: 25, color: Colors.blue) ,),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                controller: email1,
                decoration: InputDecoration(
                  hintText: "email1",
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
                controller: email2,
                decoration: InputDecoration(
                  hintText: "email2",
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
                controller: email3,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "email3",
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
                controller: email4,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "email4",
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
                controller: email5,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "email5",
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
                      onPressed: () {
                        if (groupName.text != ""){validate();}else{Toast.show("Please enter a family task name", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
                        //validate();
                        //setupFamilyGroup();
                      },//{if (buttonTapped == false) {uploadStallInfo();}},
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
