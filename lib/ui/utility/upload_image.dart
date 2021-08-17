import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konoyubi/ui/components/typography.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUpload {
  const ImageUpload(this.source,
      {this.quality = 15, this.minHeight = 300, this.minWidth = 450});

  final ImageSource source;
  final int quality;
  final int minHeight;
  final int minWidth;

  Future<File?> getImageFromDevice() async {
    // 撮影/選択したFileが返ってくる
    final imageFile = await ImagePicker().pickImage(source: source);
    // Androidで撮影せずに閉じた場合はnullになる
    if (imageFile == null) {
      return null;
    }
    final filePath = imageFile.path;
    final lastIndex = filePath.lastIndexOf('.');
    final split = filePath.substring(0, lastIndex);
    final outPath = '${split}_out.jpg';
    final File? compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      minHeight: minHeight,
      minWidth: minWidth,
      quality: quality,
    );
    return compressedFile;
  }
}

Future<void> uploadImage(
  String uploadTo,
  BuildContext context,
  String uid,
  StateController<String> avatarURLController,
) async {
  showCupertinoModalPopup<int>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Body1('カメラで撮影'),
            onPressed: () {
              Navigator.pop(context, 0);
            },
          ),
          CupertinoActionSheetAction(
            child: const Body1('アルバムから選択'),
            onPressed: () {
              Navigator.pop(context, 1);
            },
          ),
          CupertinoActionSheetAction(
            child: const Body1('キャンセル'),
            onPressed: () {
              Navigator.pop(context, 2);
            },
            isDestructiveAction: true,
            isDefaultAction: true,
          ),
        ],
      );
    },
  ).then((value) async {
    print("画像選択");
    print(value);

    switch (value) {
      case 0:
        return await const ImageUpload(ImageSource.camera).getImageFromDevice();
      case 1:
        return await const ImageUpload(ImageSource.gallery)
            .getImageFromDevice();
      case 2:
        break;
    }
  }).then((value) async {
    print("storeにアップロード");
    if (value == null) {
      print('nullだよん');

      return null;
    } else {
      print('成功');
      return await FirebaseStorage.instance
          .ref()
          .child('user')
          .child(uid)
          .child(uploadTo)
          .putFile(value);
    }
  }).then((value) async {
    print("URLを取得");
    print(value);
    print(await value?.ref.getDownloadURL());

    await FirebaseFirestore.instance
        .collection('userList')
        .doc(uid)
        .update({"avatarURL": await value?.ref.getDownloadURL()});
    return value?.ref.getDownloadURL();
  }).then((value) {
    print("更新");
    print(value);
    if (value != null) {
      avatarURLController.state = value;
    }
  });
}
