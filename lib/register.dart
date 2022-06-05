

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:partswanted/resetpassword.dart';
import 'package:partswanted/services/auth.dart';
import 'package:partswanted/services/database.dart';
import 'package:toast/toast.dart';

import 'food.dart';
import 'main.dart';
import 'main_group.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();

}

class _RegisterState extends State<Register> {

  String superUser;
  void initState() {
    super.initState();
  }


  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final formkey = GlobalKey<FormState>();
  TextEditingController mUserName = new TextEditingController();
  TextEditingController mEmail = new TextEditingController();
  TextEditingController mPassword = new TextEditingController();
  final FirebaseMessaging _messaging = FirebaseMessaging();


  createAcc()async{
    if (formkey.currentState.validate()){
      //print ("validate liao " + mEmail.text.toLowerCase() + " " + mPassword.text );
      await authMethods.signUpWithEmailAndPassword (mEmail.text.toLowerCase(), mPassword.text).then((val){
        //print("authmetood ok ");

        User user = FirebaseAuth.instance.currentUser;
        //userId = FirebaseAuth.instance.currentUser.uid;

        //FirebaseAuth.instance.currentUser().then((user) {

        //print("created ");
        //String tokenId;
        if (user != null) {

         _messaging.getToken().then((token) {
            //tokenId = token;
            //print ("tokrnId:::::  " + token);
          Map<String, String> userMap = {
            "userId" : user.uid,
            "tokenId" : token,
            "name" : mUserName.text,
            "email": mEmail.text.toLowerCase(),
            "image" : "",
            "status" : "here I am"
          };
          databaseMethods.writeUserToDatabase(userMap); // write to Users list, for admin purpose only

            ////// Set up all data structure for requestors/buyers here
            //// Hard set up the Group data structure which always only have user and me
            // At users collection
            Map<String, String> userGroupMap = {
              "groupId" : mEmail.text.toLowerCase(),
              "groupName" : mEmail.text.toLowerCase(),
              "image" : "",
            };
            FirebaseFirestore.instance.collection("users").doc(mEmail.text.toLowerCase()).collection("Group").doc(mEmail.text.toLowerCase())
                .set(userGroupMap);
          FirebaseFirestore.instance.collection("users").doc("ken@r-logic.com").collection("Group").doc(mEmail.text.toLowerCase())
              .set(userGroupMap);

            // At groups collection
            Map<String, String> groupMap = {
              "groupId": mEmail.text.toLowerCase(),
              "groupName": mEmail.text.toLowerCase(),
              "image": "",
              "member1": "ken@r-logic.com", //here it means group automatically formed between ken and the new member
              "member2": mEmail.text.toLowerCase()
            };
            FirebaseFirestore.instance.collection("groups").doc(mEmail.text.toLowerCase())
                .set(groupMap);
            FirebaseFirestore.instance.collection("groups").doc(mEmail.text.toLowerCase())
                .update({"memberCount": 2});
            FirebaseFirestore.instance.collection("groups").doc(mEmail.text.toLowerCase()).collection("tokens").doc(mEmail.text.toLowerCase())
                .set({"tokenId": token});

          });


          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));
         //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: mEmail.text.toLowerCase())));

        }else{
          Toast.show("User existed", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);}
        //});
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

/*  checking user status will not work because user will never have permission to access to firestore before actually logged in
    await FirebaseFirestore.instance
        .collection("users")
        .doc(mEmail.text.toLowerCase())
        .get()
        .then((value) {
      if (value.data()['userStatus'] != null){
        if (value['userStatus'] == "SuperUser"){
          superUser = "y";
        } else{superUser = "n"; }
      }else{superUser = "n";}
    });
*/

    if (mPassword.text == "tebieguandao"){ // this 'if', hence the 'else', is only for YQ, if not just do the else, no need if
      print ("tebieguandao1");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup(theSpecialChnPassword:"tebieguandao")));} // added for yq
    else{
    if (formkey.currentState.validate()){
      authMethods.signInWithEmailAndPassword (mEmail.text.toLowerCase(), mPassword.text).then((val){

        User user = FirebaseAuth.instance.currentUser;
        //userId = FirebaseAuth.instance.currentUser.uid;
        //FirebaseAuth.instance.currentUser().then((user){
        if (user != null) {
          _messaging.getToken().then((token) {
            //print ("tokrnId:::::  " + token);
          FirebaseFirestore.instance.collection("users").doc(mEmail.text.toLowerCase()).update({"tokenId": token});

          FirebaseFirestore.instance.collection("users").doc(mEmail.text.toLowerCase()).collection("Group").get().then((value) {
            value.docs.forEach((result) {
              String groupId = result["groupId"];
              //print ("groupId:::::::::::::: " + groupId);
              //print (result['groupId']);

/*
              // this section added to remove any same tokenId, if existed. here if got existing tokenId field value = token, delete it first
              FirebaseFirestore.instance.collection("groups").doc(groupId).collection("tokens").get().then((tokenValue) {
                value.docs.forEach((tokenValue) {
                  if (tokenValue["tokenId"] == token){

                  }
                });
              });
*/

              FirebaseFirestore.instance.collection("groups").doc(groupId).collection("tokens").doc(mEmail.text.toLowerCase()).set({"tokenId": token});
            }); });

          });

          //superUser == "y"?
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Food(theGroupId: mEmail.text.toLowerCase())));
        }

        else{
          Toast.show("Login failed", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);}
        //});
      });
    }

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

/*
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
*/
                    //SizedBox(width: 100),
                    TextButton(
                      style: TextButton.styleFrom(
                        //primary: Colors.black,
                        backgroundColor: Colors.blue,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      onPressed: () {login();},
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40,2,40,2),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                      style: TextButton.styleFrom(
                        //primary: Colors.black,
                        backgroundColor: Colors.blue,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      onPressed: () {createAcc();},
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40,2,40,2),
                        child: Text(
                          "Create Acc",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),




/*
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
*/

                  ],
                ),


                SizedBox(height: 10),
                GestureDetector(
                  onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResetPassword()));},
                  child: Text("Forget password?",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      letterSpacing: 1.0,
                    )),
                )



              ],
            ),
          ),
        ),
      ),
    );

  }
}