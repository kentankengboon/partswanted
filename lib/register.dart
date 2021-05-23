

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:partswanted/services/auth.dart';
import 'package:partswanted/services/database.dart';
import 'package:toast/toast.dart';

import 'main.dart';
import 'main_group.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();

}

class _RegisterState extends State<Register> {


  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formkey = GlobalKey<FormState>();
  TextEditingController mUserName = new TextEditingController();
  TextEditingController mEmail = new TextEditingController();
  TextEditingController mPassword = new TextEditingController();

  final FirebaseMessaging _messaging = FirebaseMessaging();
  //String tokenId;

  createAcc(){
    if (formkey.currentState.validate()){
      //print ("validate liao " + mEmail.text + " " + mPassword.text );
      authMethods.signUpWithEmailAndPassword (mEmail.text, mPassword.text).then((val){
        //print("authmetood ok ");

        FirebaseAuth.instance.currentUser().then((user) {

          //print("created ");

          if (user != null) {

            _messaging.getToken().then((token) {print ("tokrnId:::::  " + token);

            Map<String, String> userMap = {
              "userId" : user.uid,
              "tokenId" : token,
              "name" : mUserName.text,
              "email": mEmail.text,
              "image" : "",
              "status" : "here I am"
            };
            databaseMethods.writeUserToDatabase(userMap); // write to Users list, for admin purpose only
            });
            //final userData = User(userId: user.uid, userEmail: mEmail.text, userName: mUserName.text,);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));

          }else{
            Toast.show("User existed", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);}
        });
      });
    }
  }

  // when member create account and logged in, the device token ID will be re-written to firebase user\email\[tokenId]
  // only then can other member add him into any group
  // todo: when people add him, his tokenId will be added to groups\groudId\tokens\(tokenId)\[tokenId]
  // so that with that tokenId logged, he can get notification
  // when he log out and log in again, his token ID will again be re-written to both the users side and groups collection side
  // re-writing to users side already done below done: t0do: so need to write to groups collect side
  // means from users\email\group side, find the groupID attached to him, with the TokenId found here at Login below,
  // write to all groupdID in: groups\groupId\tokens\(tokenId)\[tokenId], so that he can get notification, even if if login again with mobile device changed
  // with that, he will resume the ability to receive notification todo: but then old device token not deleted from groups collection side
  // done: t0do: but before all the above can be done, need to create token data field at groups collection above when anyone newly form a group
  login(){
    if (formkey.currentState.validate()){
      authMethods.signInWithEmailAndPassword (mEmail.text, mPassword.text).then((val){
        FirebaseAuth.instance.currentUser().then((user){
          if (user != null) {
            _messaging.getToken().then((token) {print ("tokrnId:::::  " + token);
            Firestore.instance.collection("users").document(mEmail.text).updateData({"tokenId": token});

            Firestore.instance.collection("users").document(mEmail.text).collection("Group").getDocuments().then((value) {
              value.documents.forEach((result) {
                String groupId = result.data["groupId"];
                Firestore.instance.collection("groups").document(groupId).collection("tokens").document(token).updateData({"tokenId": token});
              }); });

            });

            //QuerySnapshot result = await Firestore.instance.collection("users").document(mEmail.text).collection("Group").getDocuments();





            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));}
          else{
            Toast.show("Login failed", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);}
        });


      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return new WillPopScope(
      onWillPop: () async => false,//to prevent back button clicking
      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Register',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 1,
              color: Colors.white,

            ),
          ),
        ),

        body: Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                TextFormField (
                  validator: (val){ return
                    val.isEmpty || val.length <3 ? "User name is not valid" : null;},
                  controller: mUserName,
                  decoration: InputDecoration(hintText: "user name"),
                ),
                TextFormField (
                  validator: (val){ return
                    val.isEmpty || val.length <3 ? "email is not valid" : null;},
                  controller: mEmail,
                  decoration: InputDecoration(hintText: "email"),
                ),
                TextFormField (
                  obscureText: true,
                  validator: (val) { return
                    val.length <6 ? "Password must be more than 6 characters" : null;},
                  controller: mPassword,
                  decoration: InputDecoration(hintText: "password"),
                ),
                SizedBox (height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      //TextButton(
                      onPressed: () {login();},

                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),

                    ),

                    //SizedBox(width: 100),
                    FlatButton(
                      //TextButton(
                      onPressed: () {createAcc();},
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(
                        "CreateAcc",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}
