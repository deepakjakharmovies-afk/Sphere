import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:photo_view/photo_view.dart';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:permission_handler/permission_handler.dart';
List <AssetImage> images = [
  AssetImage("assets/logo.png"),
  AssetImage("assets/logo.png"),
  AssetImage("assets/logo.png"),
  AssetImage("assets/logo.png"),
  AssetImage("assets/logo.png"),
  AssetImage("assets/logo.png"),
];
class PhotoV extends StatefulWidget {
  const PhotoV({super.key});
  
  

  

  @override
  State<PhotoV> createState() => _PhotoVState();
}


  
class _PhotoVState extends State<PhotoV> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Images"),centerTitle: true,),
      body: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
       itemBuilder: 
       (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(child: Image(image: images[index],fit: BoxFit.cover,),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
                  appBar: AppBar(title: Text("Image View"),centerTitle: true,),
                  body: Container(
                    child: PhotoView(
                      imageProvider: images[index],
                    ),
                    
                  ),
                  floatingActionButton: FloatingActionButton(onPressed: (){},child: Icon(Icons.download),
                )
                )
                )
                );
              }
              ,),
      
            )
          ),
        );
       },
        itemCount: images.length,),
    );
  }
  
  
}  