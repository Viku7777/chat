import 'dart:developer';

import 'package:chat/auth/firebaseService.dart';
import 'package:chat/auth/signUp.dart';
import 'package:chat/home.dart';
import 'package:chat/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
                        onPressed: () async {
                          showLoading(context);

                          try {
                            UserCredential credential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text);
                            if (credential.user != null) {
                              nextScreenReplace(context, Home());
                            }
                          } on FirebaseAuthException catch (e) {
                            backScreen(context);

                            showmsg(context, e.message.toString());
                          }
                        },
                        child: const Text("Log In"))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't Have Any Account?"),
                    TextButton(
                        onPressed: () {
                          nextScreenReplace(context, const SignUp());
                        },
                        child: const Text("Create Account"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
