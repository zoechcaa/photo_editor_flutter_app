import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_image_matrix/on_image_matrix.dart';
import 'package:photo_editor_app/utils/constants.dart';
import 'package:photo_editor_app/widgets/edit_image_view_model.dart';
import 'package:photo_editor_app/widgets/image_text.dart';
import 'package:screenshot/screenshot.dart';

class PhotoEditPage extends StatefulWidget {
  final File? image;
  const PhotoEditPage({Key? key, required this.image}) : super(key: key);

  @override
  PhotoEditPageState createState() => PhotoEditPageState();
}

class PhotoEditPageState extends PhotoEditPageModel {
  File? _image;
  File? _imageStart;

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      _image = widget.image;
      _imageStart = widget.image;
    }
  }

  void clear() {
    setState(() {
      brightnessAndContrast = 0.0;
      exposure = 0.0;
      saturation = 1.0;
      photoText = [];
      currentIndex = 0;
      _image = _imageStart;
      croppedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                clear();
                const resetSnackBar = SnackBar(
                  content: Text('Settings reset'),
                  duration: Duration(milliseconds: 700),
                );
                ScaffoldMessenger.of(context).showSnackBar(resetSnackBar);
              },
              icon: Icon(
                Icons.restore_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            IconButton(
              onPressed: () => saveToGallery(context),
              icon: Icon(
                Icons.save_alt_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Screenshot(
              controller: screenshotController,
              child: OnImageMatrixWidget(
                colorFilter: OnImageMatrix.matrix(
                  brightnessAndContrast: brightnessAndContrast,
                  exposure: exposure,
                  saturation: saturation,
                ),
                child: Stack(children: [
                  _image == null
                      ? Text("Some error with loading image: image is null",
                          style: Theme.of(context).textTheme.titleMedium)
                      : _imageWidget(),
                  for (int i = 0; i < photoText.length; i++)
                    Positioned(
                      left: photoText[i].left,
                      top: photoText[i].top,
                      child: GestureDetector(
                        onLongPress: () => setState(() {
                            currentIndex = i;
                            removeText(context);
                          }),
                        onTap: () {
                          setCurrentIndex(context, i);
                          changeMode('text');
                        },
                        child: Draggable(
                            feedback: ImageText(
                              photoText: photoText[i],
                            ),
                            child: ImageText(
                              photoText: photoText[i],
                            ),
                            onDragEnd: (drag) {
                              final renderBox = context.findRenderObject() as RenderBox;
                              Offset off = renderBox.globalToLocal(drag.offset);
                              setState(() {
                                photoText[i].top = off.dy - 96;
                                photoText[i].left = off.dx;
                              });
                            }),
                      ),
                    ),
                  createdTextEditingController.text.isNotEmpty
                      ? Positioned(
                          left: 0,
                          bottom: 0,
                          child: Text(
                            createdTextEditingController.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ]),
              ),
            ),
            const Divider(),
            Expanded(
              child: Column(
                children: [
                  if(mode == "text") Text(textEditingDescription, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,),
                  if (mode == "text") editText(context),
                  if (mode == "brightness")Text(
                        'Brightness and contrast - [${brightnessAndContrast.toStringAsFixed(2)}]',
                        style: Theme.of(context).textTheme.headline4),
                  if (mode == "brightness")Slider(
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      max: 5.0,
                      min: -8.0,
                      value: brightnessAndContrast,
                      onChanged: (brightnessAndContrast) {
                        setState(() {
                          this.brightnessAndContrast = brightnessAndContrast;
                        });
                      },
                    ),
                  if (mode == "exposure")Text('Exposition - [${exposure.toStringAsFixed(2)}]',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  if (mode == "exposure")Slider(
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      max: 2.5,
                      min: -0.5,
                      value: exposure,
                      onChanged: (exposure) {
                        setState(() {
                          this.exposure = exposure;
                        });
                      },
                    ),
                  if (mode == "saturation")Text('Saturation - [${saturation.toStringAsFixed(2)}]',
                        style: Theme.of(context).textTheme.headline4),
                  if (mode == "saturation")Slider(
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      max: 5.0,
                      min: -1,
                      value: saturation,
                      onChanged: (saturation) {
                        setState(() {
                          this.saturation = saturation;
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomSheet: bottomSheetRow(context),
      ),
    );
  }

  Widget bottomSheetRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: 'Brightness',
          onPressed: () => setState(() => mode = 'brightness'),
          icon: Icon(
            Icons.brightness_6_sharp,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => mode = 'exposure'),
          icon: Icon(
            Icons.exposure,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => mode = 'saturation'),
          icon: Icon(
            Icons.invert_colors,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => mode = 'text'),
          icon: Icon(
            Icons.format_color_text_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        FloatingActionButton(
          heroTag: 1,
          onPressed: () => addNewDialog(context),
          tooltip: 'Write text',
          child: const Icon(Icons.mode_edit_outline_outlined),
        ),
        FloatingActionButton(
          heroTag: 2,
          onPressed: () => sendToCrop(context),
          tooltip: 'Crop',
          child: const Icon(Icons.crop),
        )
      ],
    );
  }

  Widget editText(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Enlarge font',
                      onPressed: enlargeFont,
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reduce font size',
                      onPressed: reduceFont,
                      icon: Icon(
                        Icons.remove,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Align center',
                      onPressed: alignCenter,
                      icon: Icon(
                        Icons.format_align_center,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Align left',
                      onPressed: alignLeft,
                      icon: Icon(
                        Icons.format_align_left,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Align right',
                      onPressed: alignRight,
                      icon: Icon(
                        Icons.format_align_right,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bold',
                      onPressed: makeBold,
                      icon: Icon(
                        Icons.format_bold,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add new line',
                      onPressed: addLinesToText,
                      icon: Icon(
                        Icons.space_bar,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    Tooltip(
                      message: 'Red',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.red),
                        child: const CircleAvatar(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                      message: 'White',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.white),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                      message: 'Blue',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.blue),
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                      message: 'Black',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.black),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                      message: 'Green',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.green),
                        child: const CircleAvatar(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                      message: 'Yellow',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.yellow),
                        child: const CircleAvatar(
                          backgroundColor: Colors.yellow,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                      message: 'Orange',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.orange),
                        child: const CircleAvatar(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                      message: 'Purple',
                      child: GestureDetector(
                        onTap: () => changeTextColor(Colors.purple),
                        child: const CircleAvatar(
                          backgroundColor: Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (croppedFile != null) {
      final path = croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.6 * screenHeight,
        ),
        child: Image.file(File(path)),
      );
    } else if (_image != null) {
      final path = _image!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
