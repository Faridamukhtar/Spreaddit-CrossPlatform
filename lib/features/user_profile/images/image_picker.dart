import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


Future<File?> pickImageFromFilePicker() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }
    return File(image.path);
  } on PlatformException catch (e) {
    print('Failed to pick image $e');
    return null;
  }
}


  ImageProvider selectImage(File? ImageFile , String? ImageURL) {
    if (ImageFile != null) {
      return FileImage(ImageFile);
    } else if (ImageURL != null && ImageURL.isNotEmpty) {
      return NetworkImage(ImageURL);
    } else {
      return NetworkImage('https://addlogo.imageonline.co/image.jpg');
    }
  }
