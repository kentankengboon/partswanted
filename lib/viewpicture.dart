
import 'package:flutter/material.dart';


class ViewPicture extends StatefulWidget {

  final theImageUrl;
  ViewPicture({this.theImageUrl});

  @override
  _ViewPictureState createState() => _ViewPictureState();
}

class _ViewPictureState extends State<ViewPicture> {

  @override
  Widget build(BuildContext context) {

    String imageUrl = widget.theImageUrl;
//print (imageUrl);
    return

      InteractiveViewer(
        panEnabled: false, // Set it to false
        boundaryMargin: EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 2,
        child: GestureDetector(
          onTap: (){Navigator.pop(context); },
          child: ClipRRect (
            child: Image.network(imageUrl, height: 300,),

          ),
        ),
      );
  }

}
