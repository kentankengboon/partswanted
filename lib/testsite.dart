
// this is a testsite used to test supplier data entry to fireStore
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:image_cropper/image_cropper.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:geocoder/geocoder.dart';
//import 'package:location_permissions/location_permissions.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:permission/permission.dart';
import 'package:intl/intl.dart';

import 'food.dart';

class TestSite extends StatefulWidget {

  final theSupplier;
  TestSite({this.theSupplier});

  @override
  _TestSiteState createState() => _TestSiteState(supplier: theSupplier);
}

class _TestSiteState extends State<TestSite> {
  //String groupId;
  //String userName;
  //String userEmail;
  final supplier;
  _TestSiteState({this.supplier});

  writeSupplierInfo() {
    String partNumber = 'PNCBL333';
    //String supplier = 'Tian Xing';
    Map<String, String> userMap = {
      "pn": partNumber, //whatUse
      "supplier": supplier, //whatModel
      //"whatPN": food, //WhatPN
      //"whatQty": qty, //whatQty
      //"address": inputAddress.text,
      //"remark": remark,
    };

    FirebaseFirestore.instance.collection('supplier').doc('MB').collection(supplier).doc(partNumber).set(userMap);
  }

  writeTransactionInfo (){ // just flat write supplier and pn to each doc
    String partNumber = 'PNMB111';
    Map<String, String> userMap = {
      "pn": partNumber,
      "supplier": supplier,
      "category": "LCD",
      "price": "RMB 30",
      "date": DateFormat('yyyyMMddHHmmss').format(DateTime.now())
    };
    FirebaseFirestore.instance.collection('transactions').doc(DateFormat('yyyyMMddHHmmss').format(DateTime.now())).set(userMap);
  }

  insertNewSupplier(supplierName, partNumber){
    //print ("here");
    FirebaseFirestore.instance.collection('supplier')
        .get().then((result) {
          //print ("length : " + result.docs.length.toString());
      if (result.docs.length > 0) {
        //print ("stallIdOrder:  " + stallIdOrder.length.toString() + "      gotMail:  " + gotMail.length.toString() + "       stallCount:   " + stallCount.toString());
        result.docs.forEach((category) {
          print ("cat:   " +  category.id);
          FirebaseFirestore.instance.collection('supplier').doc(category.id).collection(supplierName)
              .get().then((result2) {
                if (result2.docs.length > 0) { // means supplier found

                  print (category.id + " existed");
                  result2.docs.forEach((pn) {
                    print (pn.id);
                    // if partNumber = pn.id, means existed, means update the price to this existing record can liao, then all done by setting found=1
                    // and might have a few supplier having this partNumber...so must registered the cheapest and latest

                    // if not, ignore first, keep searching until all and where also cannot find
                  });



                }else{print(category.id + " Not Found");}
          });

        });
      }
    })
    // here if != 1 (might need some await thing above) then means all and where also cannot find, then create a record for this category > supplier > pn > fieldMap
    ;

  }

  @override
  Widget build(BuildContext context) {
    //print ("here....1     " + supplier);
    //writeSupplierInfo();
    //insertNewSupplier("XIAO HE", "PNMB444");

    writeTransactionInfo();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20,),
      onPressed: () {Navigator.pop(context);
      }),
    ));

  }}