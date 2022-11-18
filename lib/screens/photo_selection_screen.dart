import 'dart:developer';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_editor_app/utils/constants.dart';
import 'package:photo_editor_app/utils/permission_request.dart';

class PhotoSelectionPage extends StatefulWidget {
  const PhotoSelectionPage({Key? key}) : super(key: key);

  @override
  State<PhotoSelectionPage> createState() => _PhotoSelectionPageState();
}

class _PhotoSelectionPageState extends State<PhotoSelectionPage> {
  File? _image;

  Future getImage(ImageSource source) async {
    try {
      await requestPermission(Permission.camera);
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      }
      final imagePermanent = await saveFilePermanently(image.path);
      setState(() {
        _image = imagePermanent;
        log(_image!.path);
      });
    } on PlatformException catch (ex) {
      log('Failed to load image: $ex');
    }
  }

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = "photo_$time";
    final image = File("${directory.path}/$name");
    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(appBarSelectingPage,
            style: Theme.of(context).textTheme.headline6),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => getImage(ImageSource.camera),
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    size: 50,
                  ),
                ),
                const SizedBox(width: 40,),
                IconButton(
                  onPressed: () => getImage(ImageSource.gallery),
                  icon: const Icon(Icons.image_outlined, size: 50,),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            if (_image != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, editPhotoPage, arguments: _image),
                child: Text('Edit this photo', style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            const SizedBox(height: 20,),
            if (_image != null)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 0.6 * MediaQuery.of(context).size.height,
                  maxWidth: 0.8 * MediaQuery.of(context).size.width,
                ),
                child: Image.file(_image!,),
              ),
          ],
        ),
      ),
    );
  }
}
