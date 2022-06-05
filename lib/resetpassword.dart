import 'package:flutter/material.dart';
import 'package:partswanted/register.dart';
import 'package:partswanted/services/auth.dart';
import 'package:toast/toast.dart';

class ResetPassword extends StatefulWidget {
  //final theGroupId;
  //final theUserStatus;
  //MainMenu({this.theGroupId});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController mEmail = new TextEditingController();
  AuthMethods authMethods = new AuthMethods();

  resetPassword()async{
    await authMethods.sendPasswordResetEmail (mEmail.text);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Register()));
              //Navigator.pop(context);
            }),
        //backgroundColor: Colors.black,
        title: (Text("Reset password")),
      ),
      body:
      Padding(
        padding: const EdgeInsets.fromLTRB(20,30,20,10),
        child: Column(children: [
          TextFormField(
            validator: (val) {
              return val.isEmpty || val.length < 3 ? "email is not valid" : null;
            },
            controller: mEmail,
            decoration: InputDecoration(hintText: "email"),
          ),

          SizedBox(height: 20),

          Text ("Password reset link will be sent to your email above", style: TextStyle (color: Colors.grey)),
          SizedBox(height: 20),
          TextButton(
            style: TextButton.styleFrom(
              //primary: Colors.black,
              backgroundColor: Colors.blue,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
            ),
            onPressed: () {resetPassword();},
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40,2,40,2),
              child: Text(
                "Submit",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

        ]),
      ),


    );
  }
}
