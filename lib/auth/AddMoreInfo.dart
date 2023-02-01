import 'dart:developer';
import 'dart:io';

import 'package:chat/auth/firebaseService.dart';
import 'package:chat/home.dart';
import 'package:chat/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddMoreInfo extends StatefulWidget {
  const AddMoreInfo({super.key});

  @override
  State<AddMoreInfo> createState() => _AddMoreInfoState();
}

class _AddMoreInfoState extends State<AddMoreInfo> {
  File? profileImage;

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              const Gap(30),
              CupertinoButton(
                  child: CircleAvatar(
                      maxRadius: 40,
                      child: profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 45,
                            )
                          : null,
                      backgroundImage: profileImage == null
                          ? null
                          : FileImage(profileImage!)),
                  onPressed: () async {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: const Text("Upload Image: "),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                    onPressed: () async {
                                      XFile? selectImage = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.camera);

                                      if (selectImage != null) {
                                        File convertImage =
                                            File(selectImage.path);

                                        setState(() {
                                          profileImage = convertImage;
                                          log(convertImage.toString());
                                          backScreen(context);
                                        });
                                      } else {
                                        backScreen(context);
                                      }
                                    },
                                    child: const Text(
                                      "Camera",
                                      style: TextStyle(fontSize: 20),
                                    )),
                                TextButton(
                                    onPressed: () async {
                                      XFile? selectImage = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);

                                      if (selectImage != null) {
                                        File convertImage =
                                            File(selectImage.path);
                                        setState(() {
                                          profileImage = convertImage;
                                          log(convertImage.toString());
                                          backScreen(context);
                                        });
                                      } else {
                                        backScreen(context);
                                      }
                                    },
                                    child: const Text(
                                      "Albums",
                                      style: TextStyle(fontSize: 20),
                                    ))
                              ],
                            ));
                      },
                    );
                  }),
              const Gap(45),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.abc), hintText: "Full Name"),
              ),
              const Gap(20),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () {
                        showLoading(context);
                        uploadImage(nameController.text);
                      },
                      child: const Text("Submit"))),
            ],
          ),
        ),
      )),
    );
  }

  uploadImage(String name) async {
    final ref = FirebaseStorage.instance
        .ref("users")
        .child("data")
        .child("pp")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask task = ref.putFile(profileImage!);
    TaskSnapshot snapshot = await task;
    String imageurl = await snapshot.ref.getDownloadURL();

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .update({"fullname": name, "pp": imageurl}).then((value) {
        nextScreenReplace(context, const Home());
      });
    } on FirebaseAuthException catch (e) {
      log("${e.message}");
      backScreen(context);
      showmsg(context, e.message.toString());
    }
  }
}
