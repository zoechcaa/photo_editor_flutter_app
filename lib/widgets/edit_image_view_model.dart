import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_editor_app/models/text_model.dart';
import 'package:photo_editor_app/screens/photo_editing_screen.dart';
import 'package:photo_editor_app/utils/permission_request.dart';
import 'package:screenshot/screenshot.dart';

abstract class PhotoEditPageModel extends State<PhotoEditPage> {
  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController createdTextEditingController = TextEditingController();

  List<TextModel> photoText = [];
  int currentIndex = 0;
  CroppedFile? croppedFile;

  String mode = "";

  double brightnessAndContrast = 0.0;
  double exposure = 0.0;
  double saturation = 1.0;


  saveToGallery(BuildContext context) async{
    screenshotController.capture().then((Uint8List? image) {
      saveImage(image!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to gallery'),
        ),
      );
    }).catchError((err) => log(err));
  }


  saveImage(Uint8List bytes) async{
    final time = DateTime.now().toIso8601String().replaceAll('.', '-').replaceAll(':', '-');
    final name = "photo_$time";
    await requestPermission(Permission.storage);
    await ImageGallerySaver.saveImage(bytes, name: name);
  }

  removeText(BuildContext context){
    setState(() {
      photoText.removeAt(currentIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text deleted'), duration: Duration(milliseconds: 700),));
  }

  sendToCrop(BuildContext context) async{
    screenshotController.capture().then((Uint8List? bytes) async {
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image.png').create();
      file.writeAsBytesSync(bytes!);
      cropImage(file);
    });
  }

  changeMode(String text){
    setState(() {
      mode = text;
    });
  }

  Future<void> cropImage(File file) async {
    var croppedFileIn = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop photo',
            toolbarColor: Theme.of(context).backgroundColor,
            toolbarWidgetColor: Theme.of(context).colorScheme.secondary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );
    if (croppedFileIn != null) {
      setState(() {
        croppedFile = croppedFileIn;
      });
    }
  }


  setCurrentIndex(BuildContext context, int index){
    setState(() {
      currentIndex=index;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected for styling'),duration: Duration(milliseconds: 700),));
  }

  changeTextColor(Color color){
    setState(() {
      if(photoText.contains(photoText[currentIndex])){
        photoText[currentIndex].color = color;
      }
    });
  }

  enlargeFont(){
    setState(() {
      if(photoText.contains(photoText[currentIndex])){
        photoText[currentIndex].fontSize = photoText[currentIndex].fontSize +=2;
      }
    });
  }

  reduceFont(){
    setState(() {
      if(photoText.contains(photoText[currentIndex])){
        photoText[currentIndex].fontSize = photoText[currentIndex].fontSize -=2;
      }
    });
  }

  alignLeft(){
    setState(() {
      if(photoText.contains(photoText[currentIndex])){
        photoText[currentIndex].textAlign = TextAlign.left;
      }
    });
  }

  alignRight(){
    setState(() {
      if(photoText.contains(photoText[currentIndex])){
        photoText[currentIndex].textAlign = TextAlign.right;
      }
    });
  }

  alignCenter(){
    setState(() {
      if(photoText.contains(photoText[currentIndex])){
        photoText[currentIndex].textAlign = TextAlign.center;
      }
    });
  }

  makeBold(){
    setState(() {
      if(photoText.contains(photoText[currentIndex])){
        if(photoText[currentIndex].fontWeight == FontWeight.bold){
          photoText[currentIndex].fontWeight = FontWeight.normal;
        } else{
          photoText[currentIndex].fontWeight = FontWeight.bold;
        }
      }
    });
  }

  addLinesToText(){
    setState(() {
      if(currentIndex>=0){
        if(photoText[currentIndex].text.contains('\n')){
          photoText[currentIndex].text = photoText[currentIndex].text.replaceAll('\n', ' ');
        }else{
          photoText[currentIndex].text = photoText[currentIndex].text.replaceAll(' ', '\n');
        }
      }
    });
  }

  addNewText(BuildContext context){
    setState(() {
      if(textEditingController.text.isNotEmpty){
        photoText.add(TextModel(
          text: textEditingController.text,
          left: 0,
          top: 0,
          color: Colors.black87,
          fontWeight: FontWeight.normal,
          fontSize: 20,
          textAlign: TextAlign.left,
        ));
      }
    });
    Navigator.of(context).pop();
  }

  addNewDialog(context) {
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: const Text('Add new text'),
        content: TextField(
          controller: textEditingController,
          maxLines: 5,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.mode_edit_outline_outlined),
            filled: true,
            hintText: 'your text here...',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed:(){
              Navigator.pop(context);
              textEditingController.clear();
            } ,
            child: Text('Cancel', style: Theme.of(context).textTheme.subtitle1,),
          ),
          ElevatedButton(
            onPressed:(){
              addNewText(context);
              textEditingController.clear();
              changeMode('text');
            } ,
            child: Text('Add', style: Theme.of(context).textTheme.subtitle1,),
          ),
        ],
      ),
    );
  }

}