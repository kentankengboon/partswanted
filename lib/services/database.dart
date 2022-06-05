
//import 'dart:html';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {


  writeUserToDatabase(userMap) {

/*
    String userId;
    FirebaseAuth.instance.currentUser().then((user) {
      userId = user.uid;
      //log ("at here3: " + userId);
      Firestore.instance.collection("users").document(user.email)
          .setData(userMap);
    });

*/

    String userId;
    User user = FirebaseAuth.instance.currentUser;
    userId = FirebaseAuth.instance.currentUser.uid;
    FirebaseFirestore.instance.collection("users").doc(user.email)
        .set(userMap);
  }
}