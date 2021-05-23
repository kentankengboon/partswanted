
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'main.dart';
import 'main_group.dart';


class EditGroup extends StatefulWidget {

  final theGroupName;
  final theGroupId;
  final theImageUrl;
  EditGroup({this.theGroupName, this.theGroupId, this.theImageUrl});

  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {

  String groupId;
  String groupName;
  String imageUrl;
  int change=0;

  @override
  Widget build(BuildContext context) {


    groupName = widget.theGroupName;
    groupId = widget.theGroupId;
    if (change == 0){imageUrl = widget.theImageUrl;}

    TextEditingController email1 = new TextEditingController();
    TextEditingController email2 = new TextEditingController();
    TextEditingController email3 = new TextEditingController();
    TextEditingController email4 = new TextEditingController();
    TextEditingController email5 = new TextEditingController();


    String userId;
    String myEmail;
    //var otherEmail = List.filled(5,"");//List (5);
    var otherEmail = List (5);
    //var emailFound = List.filled(5,0);//List (5);
    var emailFound = List(5);
    //var emailNotFound = List (5);



    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        userId = user.uid;
        myEmail = user.email;
      } else {}
    });





    setupFamilyGroup () async {

      //if (groupName != "") {
      //groupId = myEmail + groupName;
      //print("groupid " + groupId);
      //print("myemail " + myEmail);
      //print("groupName: " + groupName);
      otherEmail[0] = email1.text;
      otherEmail[1] = email2.text;
      otherEmail[2] = email3.text;
      otherEmail[3] = email4.text;
      otherEmail[4] = email5.text;

      // write and attaching group info to users database
      await Firestore.instance.collection("users").document(myEmail)
          .collection("Group").document(groupName).get()
          .then((value) async {

/*      // can never be null for myEmail group record since I am editing it here already, right? so I comment it out, as groupId and groupName will never be changed here
        if (value.data == null) {
          await Firestore.instance.collection("users").document(myEmail)
              .collection("Group").document(groupName)
              .setData({"groupId": groupId});}

        await Firestore.instance.collection("users").document(myEmail)
            .collection("Group").document(groupName)
            .updateData({"groupName": groupName});
*/

        await Firestore.instance.collection("users").document(myEmail)
            .collection("Group").document(groupName)
            .updateData({"image": imageUrl});
      });




//////////////////////// >>>>>>>>>>>>>>>>  here below you update all new entered email, but for edit must go update existing emails to be founc in Group&Mem info
      // So update new info to existing group member here
      // get the user email of existing group member which is recorded in Group&Member collection
      //QuerySnapshot qn = await Firestore.instance.collection("groups").getDocuments();

      // after group info was edited, update all group info (namely image, new member email, memberCount) to Group collection data base
      int memberCount;
      String tokenId;
      Firestore.instance.collection("groups").document(groupId).get().then((result)async{
        memberCount = await result.data["memberCount"]; // this is to first determine how many existing member are there in this group

        // then knowing the existing mamberCount, one by one find who they are (by email), then update the image change, if indeed changed
        if (change==1) {
          for (int x = 1; x <= memberCount; x++) {
            //print(result.data["member" + x.toString()]);
            String existingMember = result.data["member" + x.toString()];
            // update the image change each to respective users data record
            await Firestore.instance.collection("users").document(
                existingMember).collection("Group").document(groupName)
                .updateData({"image": imageUrl});
          }
          // also change the image value in the 'groups' data since image has been changed
          Firestore.instance.collection("groups").document(groupId).updateData({"image": imageUrl});
        }
        // then also, knowing the memberCount of existing member recorded in 'groups' data, continue to add in new member added here
        int mCount = memberCount;
        for (int x = 0; x <= 4; x++) {
          if (otherEmail[x] != "") {
            /////// but first must check if this newly added member already existed in the 'groups' record, if yes dont double add

            int y;
            int existed=0;
            for (y=1; y<= memberCount; y++){
              if (otherEmail[x] == result.data["member" + y.toString()]) {existed =1;}
              //print ("existed: " + existed.toString());
            }
            if (existed != 1) {
              //update groups member records and the count of member
              // at this point and same time get tokenId of this added member and update to the groups\token collection
              await Firestore.instance.collection("users").document(otherEmail[x]).get()
                  .then((value) async {
                if (value.data != null) {
                  tokenId = await value.data["tokenId"];
                  ///////////////// write tokenId to groups \ tokens collection/////////////////
                  await Firestore.instance.collection("groups").document(
                      groupId).collection("tokens").document(tokenId)
                      .setData({"tokenId": tokenId});
                }
              });

              mCount++; Firestore.instance.collection("groups").document(groupId).updateData({"member" + mCount.toString(): otherEmail[x]});

              // then here update info of this group, which the added member is now attached to, to its own record at users collection: users\email\Group\groupName\[]
              // and here i dont check if record groupName existed in users's Grouop collection. which shouldnt be since on top already check existed !=1
              await Firestore.instance.collection("users").document(
                  otherEmail[x]).collection("Group").document(groupName)
                  .setData({"groupId": groupId});

              await Firestore.instance.collection("users").document(
                  otherEmail[x]).collection("Group").document(groupName)
                  .updateData({"groupName": groupName});
              await Firestore.instance.collection("users").document(
                  otherEmail[x]).collection("Group").document(groupName)
                  .updateData({"image": imageUrl});
            }
          }
        }
        Firestore.instance.collection("groups").document(groupId).updateData({"memberCount": mCount});
      });


      // then here update info of this group, which the added member is now attached to, to its own record at users collection: users\email\Group\groupName\[]
      for (int x = 0; x <= 4; x++) {
        if (otherEmail[x] != "") {
          await Firestore.instance.collection("users").document(
              otherEmail[x])
              .collection("Group").document(groupName).get()
              .then((value) async {

            /* /// shift it up on top
            if (value.data == null) { //can I remove the == null so that it will always update? else how to update latest image?
              await Firestore.instance.collection("users").document(
                  otherEmail[x]).collection("Group").document(groupName)
                  .setData({"groupId": groupId});
            }

            await Firestore.instance.collection("users").document(
                otherEmail[x]).collection("Group").document(groupName)
                .updateData({"groupName": groupName});
            await Firestore.instance.collection("users").document(
                otherEmail[x]).collection("Group").document(groupName)
                .updateData({"image": imageUrl});

 */
          });
        }
      }

      ////////////////////////////////  form the groups & member data here  /////////////////
      //if first time forming, setData for first x, if not updateData, like below to the GP&Member data base
      //using groupID, first build up data: familyMame, myEmail, groupId, and imageUrl.
      // and this should be the first time setting up the data as the validate function above already check for existing groupName
      //then below update with all member email one by one as you go through the loop
      //Map<String, String> userMap = {
      //  "groupId": groupId,
      //  "groupName": groupName,
      //  "image": imageUrl,
      //  "member1": myEmail,
      //  "member2": otherEmail[0]};
      //await Firestore.instance.collection("groups").document(groupId).setData(userMap);
      //}
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));
    }

    validateEmail()async{
      int noGo=0;
      otherEmail[0] = email1.text;
      otherEmail[1] = email2.text;
      otherEmail[2] = email3.text;
      otherEmail[3] = email4.text;
      otherEmail[4] = email5.text;
      QuerySnapshot qn = await Firestore.instance.collection("users").getDocuments();
      int docLength = qn.documents.length;
//print ("doclength: " + docLength.toString());
      for (int y = 0; y<=4; y++){
        emailFound[y] = 0;
        if (otherEmail[y] != "") {
          for (int x = 0; x <= docLength-1; x++) {
            if (otherEmail[y] == qn.documents[x].data['email']) {emailFound[y] = 1;change =1;}
          }
          //print ("y: " + y.toString());
          //print ("otherEmail[y]:  " + otherEmail[y]);
          //print ("emailFound[y]: " + emailFound[y].toString());
          if (emailFound[y] == 0){Toast.show(otherEmail[y] + " not found", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP); noGo = 1;}
        }
      }
      //print ("No Go: " + noGo.toString());

      if (noGo == 1){} else{
        if (change == 1){setupFamilyGroup();}else{
          Navigator.pop(context);
        }
      }

      /*
      if (noGo == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage())); //ExpensesMain()));
      }else {
        if (noGo != 1) {
          setupFamilyGroup();
        }
      }
      */

    }




    validate()async {
      int noGo;
      groupId = myEmail + groupName;
      //print("groupid " + groupId);
      //print("myemail " + myEmail);
      //print("groupName: " + groupName);
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
        if (groupName == qn.documents[fn].data['groupName']) {familyFound = 1;}
        if (myEmail + groupName == qn.documents[fn].data['groupId']) {groupIdFound = 1;}
      }
      if (familyFound == 1){Toast.show("Family task: " + groupName + " existed." + "\n" + "Please re-enter family task name.", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP); noGo = 1;}
      if (groupIdFound == 1){Toast.show("GroupId: " + myEmail + groupName + " existed." + "\n" + "Please re-enter family task name.", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP); noGo = 1;}

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
      //groupId = myEmail + groupName;
      //nameEntered = groupName;
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
      //print ("groupId : " + groupId);

      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(groupId);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(croppedImage);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      imageUrl = await taskSnapshot.ref.getDownloadURL();
      change = 1;
      //print ("downloadUrl :" + imageUrl);
      //print ("groupName: " + groupName);
      //print ("nameEntered: " + nameEntered);

      //for (int ss=1; ss<=2; ss++){setState(() {});}
      setState(() {});

    }


    validategroupName()async {
      QuerySnapshot qn = await Firestore.instance.collection("users").document(myEmail).collection ("Group").getDocuments();
      int docLength = qn.documents.length;
      int familyFound = 0;
      for (int fn = 0; fn <= docLength-1; fn++){
        if (groupName == qn.documents[fn].data['groupName']) {familyFound = 1;}
      }
      if (familyFound == 1){Toast.show("Family task: " + groupName + " existed." + "\n" + "Please re-enter family task name.", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
      else{captureImage(ImageSource.gallery);}
    }






    return Scaffold(
      //backgroundColor: Colors.grey[200],
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            title: (Text("Edit Group")),
            //backgroundColor: Colors.grey,

            actions: [
              GestureDetector(
                  onTap: () {
                    //Toast.show(imageUrl, context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    ////////////////////////////////////////// wait need to at least validate email existed
                    validateEmail();
                    //setupFamilyGroup();
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

            /*
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.menu),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),

              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });

                items: <String>['One', 'Two', 'Free', 'Four']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList();

              },

            ),
*/
            /*
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
            */

            SizedBox(height: 20),
            //Text("Group Name:", style: TextStyle(fontSize: 25, color: Colors.blue)),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
              child:

              Text(groupName, style: TextStyle(fontSize: 25, color: Colors.blue)
                //validator: (val){ return val.isEmpty || val.length <3 ? "Family task Name is not valid" : null;},
              ),
              //Text (imageUrl),
            ),

            Row(
              children: [
                SizedBox(width: 90),
                ClipRRect(
                    child:
                    //imageUrl != null?
                    Image.network(imageUrl, width: 200, height: 200, //fit: BoxFit.fill
                    )
                    //:Image.asset("assets/groupIcon.jpg")
                    ,
                    borderRadius: BorderRadius.circular(30)
                ),

                GestureDetector(
                  onTap: () {
//////////////////////////// here if we are editing an existing family task, then no need to validate the Fam Name here.  Same when click the OK
                    if (groupName != ""){captureImage(ImageSource.gallery);}else{Toast.show("Please enter a family task name first", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);}
                    //groupName.text != "" ? captureImage(ImageSource.gallery): //do the validate first then image thing
                    //Toast.show("Please enter a family task name first", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  },

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20,160,0,0),
                    child: Icon(Icons.photo, color: Colors.blue),
                  ),
                ),
              ],
            ),


            SizedBox(height: 40),
            Text("I want to add: ", style: TextStyle(fontSize: 25, color: Colors.blue) ,),

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
                          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);},
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
                        //validate(); ////////////////////////////////////////// wait need to at least validate email existed
                        validateEmail();
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
  }}
