
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


// secure secret Check page
class SecureSpace extends StatefulWidget {

  @override
  _SecureSpaceState createState() => _SecureSpaceState();

}

class _SecureSpaceState extends State<SecureSpace> {

  //String superUser;
  String userId;
  String userEmail;

  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    userEmail = FirebaseAuth.instance.currentUser.email;
  }

  //AuthMethods authMethods = new AuthMethods();
  //DatabaseMethods databaseMethods = new DatabaseMethods();
  final formkey = GlobalKey<FormState>();
  TextEditingController mPassword = new TextEditingController();


  enterSecureSpace(){
    //print (userId);
    if ((userId == "5HQjvArqxmZh5Cnwd7huTalo2bh1" || userId == "5ksQrdScGtRMNibBC9chqXnqbyF2") && mPassword.text == "mklvwdd29")
    //if ((userId == "oHbW3mrxT8VlvenzLUd4YKQjGXX2" || userId == "94b7TA43zVZiAD7rrBTMNXOvfUj2") && mPassword.text == "mklvwdd29")
    {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
          Food(theGroupId: "ken@r-logic.comAll about B2C")));
    }else{Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainGroup()));}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Secure Space',
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
        obscureText: true,
        //validator: (val) { return val.length <6 ? "Password must be more than 6 characters" : null;},
        controller: mPassword,
        decoration: InputDecoration(hintText: "Admin password"),
      ),
      SizedBox(height: 20),
      TextButton(
        style: TextButton.styleFrom(
          //primary: Colors.black,
          backgroundColor: Colors.blue,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
        ),
        onPressed: () {enterSecureSpace();},
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

    ]))),

    );
  }

}