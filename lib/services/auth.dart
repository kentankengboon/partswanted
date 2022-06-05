import 'package:firebase_auth/firebase_auth.dart';
import 'package:partswanted/model/user.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // condition ? True : False
  projectUser _userFromFirebaseUser(User user) {
    return user != null
        ? projectUser(userId: user.uid)
        : null; // this simply put the value FirebaseUser's UID to userId as established in user.dart, right?
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword
        (email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword
        (email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {}
  }


  Future sendPasswordResetEmail (String email) async {
    //print ("authMethod here");
    try { return await _auth.sendPasswordResetEmail (email: email);
    } catch (e) {}
  }

}