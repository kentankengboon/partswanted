


import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'editstall.dart';


class ViewPO extends StatefulWidget {

  final thePoUrl;
  final theMyEmail;
  final theGroupId;
  final theStallId;
  ViewPO({this.thePoUrl, this.theMyEmail, this.theGroupId, this.theStallId});

  @override
  _ViewPOState createState() => _ViewPOState(poUrl: thePoUrl, myEmail: theMyEmail, groupId: theGroupId, stallId: theStallId);
}



class _ViewPOState extends State<ViewPO> {

  String poUrl;
  String myEmail;
  String groupId;
  String stallId;
  PDFDocument poDoc;
  int justApproved = 0;
  String poStatus;
  int stage=0;
  String custCode;

  _ViewPOState({this.poUrl, this.myEmail, this.groupId, this.stallId});

  void initState() {
    super.initState();
    //viewNow();
    chkPoStatusAndView();
  }

/*
  viewNow() async{
    //print ("poUrl2:   " + poUrl);
    poDoc = await PDFDocument.fromURL(poUrl);
    setState(() {});
  }
*/
  chkPoStatusAndView() async{
    //read chk po status from firebase
    //print ("groupId: " + groupId);
    //print ("stallId: " + stallId);
    await FirebaseFirestore.instance
        .collection(groupId)
        .doc(stallId)
        .get()
        .then((value) async {
      if (value.data() != null) {
        if (await value.data()["poStatus"] != null)
        {poStatus = value["poStatus"]; stage = value["stage"];
        //setState(() {});
        //print("poStatus111:   " + poStatus.toString());
        }

        // todone: identify customer here for updating condCode later when stage change
        if (await value.data()["customer"] != null) {
          String customer = await value["customer"];
          if (customer == "Harvey Norman"){custCode = "HVN";}
            else{if (customer == "Courts"){custCode = "COU";}
              else{if (customer == "Asus"){custCode = "ASU";}
                else{if (customer == "BSC"){custCode = "BSC";}
                  else{custCode = "XXX";}
                  }
                }
              }
        }
        //print("poStatus222:   " + poStatus.toString());
      }
    });

    poDoc = await PDFDocument.fromURL(poUrl);
    setState(() {});

  }

/*
  loadPdf()async{
    //print("here");
    //print("poDoc2a:   " + poDoc.toString());
    await viewNow();
    //print("poDoc2b:   " + poDoc.toString());
  }
*/

  approvePO() {
    //if (poStatus != "approved") {
    if (stage < 4 ) {
      //print ("This PO is approved by" + myEmail);
      FirebaseFirestore.instance.collection(groupId).doc(stallId)
          .update({"poStatus": "approved", "poApproveDate": DateTime.now(), "stage": 4});
      poStatus = "approved";
      stage = 4;
      justApproved = 1;
      FirebaseFirestore.instance.collection(groupId).doc(stallId).update({"condCode": [ custCode+"ARN", "4ARN" ]});
      setState(() {});
      Navigator.pop(context, justApproved);
    }
    // if email authorised, then add approve data to field at firebase under poUploaded
  }

  @override
  Widget build(BuildContext context) {
    //int loadcount;
    //if (loadcount ==0){loadPdf();loadcount=1;}else{}

    //viewNow();
    return
      Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                  ),
                  onPressed: () {
                    //Navigator.pop(context);
                    Navigator.pop(context, justApproved);
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditStall()));
                  }),
              //automaticallyImplyLeading: true,
              title: (Text ("Purchase order")),

              actions: [
                // only do below when stage < 4
                //poStatus != "approved"?
                stage <4?
                GestureDetector(
                  onTap: () {
                    myEmail == "ken@r-logic.com" || myEmail == "kenneth@r-logic.com"? approvePO():
                    Toast.show("You are not an authorizer", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                  },
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20,20,0),
                      child: Text("Approve",
                        style: TextStyle(color: Colors.white),
                      )
                  ),
                ): Text("",
                  style: TextStyle(color: Colors.white),
                )
              ]




          ),

          body:


          Column(
            children: [

              Expanded(flex:1, child:
              //poStatus == "approved"?
              stage >= 4?

              Padding(
                padding: const EdgeInsets.fromLTRB(0,10,0,0),
                child:
                //Text (">>> PO approved by " + myEmail + " <<<"),
                Text (">>> PO approved <<<"),
              )


                  :Padding(
                    padding: const EdgeInsets.fromLTRB(0,10,0,0),
                    child: Text("Pending PO approval"),
                  )),


              Expanded(flex:20,
                child: poDoc == null?
                Center(child: Text ("coming up...",
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),)):

                PDFViewer(document: poDoc),
              ),
            ],
          )


      );
  }

}
