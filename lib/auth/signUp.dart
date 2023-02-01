import 'dart:developer';

import 'package:chat/auth/AddMoreInfo.dart';
import 'package:chat/auth/logIn.dart';
import 'package:chat/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(65),
                const Text(
                  "Chat App",
                  style: TextStyle(
                      fontSize: 55,
                      color: Colors.blue,
                      fontWeight: FontWeight.w800),
                ),
                const Gap(45),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email), hintText: "Enter Email"),
                ),
                const Gap(25),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock), hintText: "Enter Password"),
                ),
                const Gap(25),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        onPressed: () {
                          showLoading(context);
                          signup(context);
                        },
                        child: const Text("Create Account"))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already Have Any Account?"),
                    TextButton(
                        onPressed: () {
                          nextScreenReplace(context, const Login());
                        },
                        child: const Text("Log in"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  signup(BuildContext context) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      if (credential.user != null) {
        await FirebaseFirestore.instance
            .collection("user")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          "email": emailController.text,
          "password": passwordController.text,
          "status": "online",
          "fullname": "",
          "uid": FirebaseAuth.instance.currentUser!.uid,
          "pp": ""
        }).then((value) {
          nextScreenReplace(context, const AddMoreInfo());
        });
      }
    } on FirebaseAuthException catch (e) {
      log("${e.message}");
      backScreen(context);
      showmsg(context, e.message.toString());
    }
  }
}
