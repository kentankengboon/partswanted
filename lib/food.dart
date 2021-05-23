
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:partswanted/pictures.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:toast/toast.dart';

import 'addstall.dart';
import 'editstall.dart';
//import 'addstall.dart';
//import 'editstall.dart';

class Food extends StatefulWidget {
  final theGroupId;
  final theStallIndex;
  Food({this.theGroupId, this.theStallIndex});


  @override
  _FoodState createState() => _FoodState(groupId: theGroupId);
}

class _FoodState extends State<Food> {
  //int connected;
  final groupId;
  _FoodState({this.groupId});

  Future _getStall;
  AutoScrollController controller;
  final scrollDirection = Axis.vertical;
  //var controller = IndexedScrollController();

  int stallIndex;
  //String docId;

  void initState(){
    super.initState();
    _getStall = getStall();
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: scrollDirection);
  }

  getStall() async {
    QuerySnapshot qn = await Firestore.instance.collection(groupId).orderBy("since").getDocuments();
    //QuerySnapshot qn = await Firestore.instance.collection(groupId).orderBy("since").where("since", isEqualTo: "archived").getDocuments();
    //print ("here A: " + qn.documents.length.toString());
    //docLength = qn.documents.length.toString();
    return qn.documents; // this return all the documents (an Array snapshot) in users collection
  }

  //int clicked;
  //int indexNo;
  //int rateDown;
  //int rateUp;

  //var rate = List (10); // << replaced
  //List rate = [];
  var rate = List.filled(100,0);//List (100); //means users can only made changes to 100 stall rating at ome time without quiting the page
  var indexHolding = List.filled(100,-1); //List (100); //this is because this rating list store all the new changed rating for the stall that rating was changed
  // if exceed 100, then user can't changed the rating anymore. Well, but he just need to exit the page and come in again
  // then the new changed rating will be uploaded to firestore and all the list become empty for new changes again
  // cannot fille indexholding with 0 because 0 is a begining existing index, so cannot use that

  //List indexHolding = [];
  //List indexHolding = List.empty(growable: true);
  int rateCount=0;
  int indexCount=0;


  //int archiveIndex;
  archiveItem(docId)async{
    print ("yes here");
    print (docId);
    await Firestore.instance.collection(groupId).document(docId).updateData({"since": "archived"});
    setState(() {});
    /*
      QuerySnapshot archiveSnap = await Firestore.instance.collection(groupId).getDocuments();
      Map<String, String> userMap = {
        "whatUse": archiveSnap. //whatUse
        "whatModel": stall, //whatModel
        "whatPN": food, //WhatPN
        "whatQty": qty, //whatQty
        //"address": inputAddress.text,
        "remark": remark,
      };
      */
  }

  //findDocId(docIdIndex){}

  @override
  Widget build(BuildContext context) {
    //String groupId = widget.theGroupId;
    stallIndex = widget.theStallIndex;
    //if (stallIndex == null) {stallIndex =0;}
    String userId;
    String stallId;
    File croppedImage;
    int rating;
    //String stallId;
    int existed;

    Future forDebug() async{
      var image =  File ('/Users/kengboon/MyDocuments/MyClone/assets/food.jpg');
      croppedImage = await ImageCropper.cropImage(sourcePath: image.path);
      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddStall(croppedImage: image)));
    }

    final picker = ImagePicker();
    Future captureImage(ImageSource source) async {
      var image = await picker.getImage(source: source);
      //File compressedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 85);
      if (image.path == null ){} else {
        croppedImage = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 500,
            maxHeight: 500,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.blue,
              toolbarTitle: "Crop it",
            ));
        //setState(() {_image = cropped;flag=1;});
        if (croppedImage != null ) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddStall(croppedImage: croppedImage, theGroupId: groupId)));
        }
      }
    }


    Future getRating() async {
      await Firestore.instance.collection("FoodStall").document(stallId).get()
          .then((value) {
        rating = value.data['rating'];
        //return _rating;
      });
    }

    upClick (){
      if (rating <5) {rating ++;}
      Firestore.instance.collection("FoodStall").document(stallId).updateData({"rating": rating});
      //clicked = 1;
      setState(() {
      });
    }

    downClick () async {
      //if (rating>1) {rating --;}
      //await Firestore.instance.collection("FoodStall").document(stallId).updateData({"rating": rating});
      //clicked = 1;
      //setState(() {});
    }



    int goToIndex;
    Future _scrollToIndex() async {
      if (stallIndex != null){
        if (stallIndex > 0){goToIndex = stallIndex-1;}else{goToIndex = stallIndex;}}
      await controller.scrollToIndex(goToIndex, preferPosition: AutoScrollPosition.begin);
      //await controller.scrollToIndex(6);
      //controller.jumpToIndex(7);
      //print ("hererere");
    }
    _scrollToIndex();

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          //automaticallyImplyLeading: true,
          title: (Text("Parts in discuss")),
          backgroundColor: Colors.black,
          actions: [
            GestureDetector(
                onTap: () {
                  captureImage(ImageSource.camera);
                  //forDebug(); ///////////////////////////////////
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.add_a_photo),
                )),

            GestureDetector(
                onTap: () {
                  captureImage(ImageSource.gallery);
                  //forDebug(); ///////////////////////////////////
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.photo),
                ))
          ],
        ),

        body:
        Container(
          child: FutureBuilder(
            //future: getStall(),
              future: _getStall,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text("Loading..."),
                  );
                } else {
                  SizedBox(height: 100);
                  return ListView.builder(
                    //return IndexedListView.builder(
                      scrollDirection: scrollDirection,
                      controller: controller,
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {

                        //stallId = snapshot.data[index].documentID;
                        //getRating();
                        rating = snapshot.data[index].data['rating'];
                        //Firestore.instance.collection("FoodStall").getDocuments().then((value) {rating = value.documents[index].data['rating'];});
                        //print ("index :" + '$index');
                        //print ("before build: " + '$rating');
                        for (int x = 0; x <= 99; x++) {
                          if (indexHolding[x] == index){rating = rate[x];}
                          // check if index is one of the indexx[count]
                          // if yes, then rating  =  rate [count]
                          // then goto next index (this auto by flutter)
                        }
                        //if (index == indexNo && rateDown==1) {rating--; rateDown =0;}
                        //if (index == indexNo && rateUp==1) {rating++; rateUp =0;}

                        //return AutoScrollTag(key: key, controller: controller, index: index,
                        return AutoScrollTag(key: ValueKey(index), controller: controller, index: index,


                          child: Slidable(
                            //delegate: SlidableDrawerDelegate(),
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Container(
                              child: ListTile(
                                //key: ValueKey(index),
                                //controller: controller,
                                //index: index,
                                title: GestureDetector(

                                  onTap: () {
                                    stallId = snapshot.data[index].documentID;
                                    ////////////// if I put push instead of push replacement, then if I click ok, it will get back to Food
                                    ////////////// but this push action means this food page still there. so after click ok which navigate to Food
                                    //////////// then click back arrow, it will still remain at Food


                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditStall(
                                      theIndex: index,
                                      theStallId: stallId,
                                      theImage: snapshot.data[index].data['image'], //image
                                      theStall: snapshot.data[index].data['whatModel'], //whatstall
                                      theFood: snapshot.data[index].data['whatPN'], //whatfood
                                      thePlace: snapshot.data[index].data['whatUse'], //where
                                      theQty: snapshot.data[index].data['whatQty'], //
                                      theRemark: snapshot.data[index].data['remark'], //remark
                                      //theAddress: snapshot.data[index].data['address'],
                                      theGroupId: groupId,
                                    )));


                                  },
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(5, 5, 10, 0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                //child: snapshot.data[index].data['image'] != null ?
                                                child: GestureDetector(
                                                  onTap: () {
                                                    stallId = snapshot.data[index].documentID;


                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Pictures(
                                                      theIndex: index,
                                                      theStallId: stallId,
                                                      theGroupId : groupId,
                                                      theImage: snapshot.data[index].data['image'],
                                                      theStall :snapshot.data[index].data['whatModel'],
                                                      theFood: snapshot.data[index].data['whatPN'],
                                                      thePlace: snapshot.data[index].data['whatUse'],
                                                      theRemark: snapshot.data[index].data['remark'],
                                                      //theAddress: snapshot.data[index].data['address'],
                                                    )));
                                                  },

                                                  child: ClipRRect(
                                                      child: Image.network(
                                                        snapshot.data[index].data['image'],
                                                        width: 250,
                                                        height: 120,
                                                        //fit: BoxFit.fill
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(20)),
                                                ),
                                              ),


                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0,5,0,0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 3),
                                                    GestureDetector(onTap: () async {

                                                      if (indexCount < 100) {

                                                        stallId = snapshot.data[index].documentID;

                                                        for (int x = 0; x <= 99; x++) {

                                                          if(indexHolding[x] == index)
                                                          {existed =1; if (rate[x] >0) {rate[x] -- ; rating = rate[x];} else rating = 0;}
                                                        }

                                                        if (existed !=1){
                                                          rating = snapshot.data[index].data['rating'];
                                                          rating --;
                                                          rate[indexCount] = rating;
                                                          //rateCount++;
                                                          indexHolding[indexCount] = index;
                                                          indexCount ++;}
                                                        else {existed = 0;}

                                                        await Firestore.instance.collection(groupId).document(stallId).updateData({"rating": rating});
                                                        setState(() {});
                                                      }
                                                    },
                                                        child: Icon(Icons.keyboard_arrow_left, size: 20, color: Colors.blue)
                                                    ),

                                                    rating >= 1  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey),
                                                    rating >= 2  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey),
                                                    rating >= 3  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey),
                                                    rating >= 4  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey),
                                                    rating >= 5  ?  Icon(Icons.star, size: 14, color: Colors.blue) : Icon(Icons.star_border, size: 14, color: Colors.grey),
                                                    GestureDetector(onTap: () async {
                                                      if (indexCount < 100){
                                                        stallId = snapshot.data[index].documentID;
                                                        for (int x = 0; x <= 99; x++) {
                                                          if(indexHolding[x] == index)
                                                          {existed =1; if (rate[x]<5) {rate[x] ++ ;rating = rate[x];} else{rating = 5;} }
                                                        }

                                                        if (existed !=1){
                                                          rating = snapshot.data[index].data['rating'];
                                                          rating ++;
                                                          rate[indexCount] = rating;
                                                          //rateCount++;
                                                          indexHolding[indexCount] = index;
                                                          indexCount ++;}
                                                        else {existed = 0;}

                                                        await Firestore.instance.collection(groupId).document(stallId).updateData({"rating": rating});
                                                        setState(() {});
                                                      }
                                                    },
                                                        child: Icon(Icons.keyboard_arrow_right, size: 20, color: Colors.blue)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 70),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Align(alignment: Alignment.centerLeft),
                                              Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      20, 0, 0, 0),
                                                  child:
                                                  stallIndex != null && index == stallIndex?
                                                  Text(
                                                    snapshot.data[index].data[
                                                    'whatModel'], //textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ) :

                                                  Text(
                                                    snapshot.data[index].data[
                                                    'whatModel'], //textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text(
                                                  snapshot.data[index].data[
                                                  'whatPN'], //textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text(
                                                  snapshot.data[index].data[
                                                  'whatQty'], //textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text(
                                                  snapshot.data[index].data[
                                                  'whatUse'], //textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),



                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text(
                                                  snapshot.data[index].data[
                                                  'remark'], //textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text(
                                                  snapshot.data[index].data[
                                                  'whenAsk'], //textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),


                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text(
                                                  //"",
                                                  snapshot.data[index].data['whoupload'],
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),

/*
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text(
                                                  snapshot
                                                      .data[index].data['rating'].toString(),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
*/
/*
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Text('$rating'),
                                              ),
                                              //Text(DateTime.now().toString()),
*/
                                              Divider(color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              IconSlideAction(
                                caption: 'Archive',
                                color: Colors.blue,
                                icon: Icons.archive,
                                onTap: (){
                                  //docId = findDocId(index);
                                  archiveItem(snapshot.data[index].documentID);},

                                //onTap: () => archiveItem(index),
                              ),
                            ],
                          ),
                        );
                      });
                } ///////else
              }),
        )
    );
  }
}
