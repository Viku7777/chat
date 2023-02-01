import 'dart:developer';

import 'package:chat/Search.dart';
import 'package:chat/auth/logIn.dart';
import 'package:chat/chatRoom.dart';
import 'package:chat/widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  String email = "";
  String name = "";
  String profileImage = "";

  Map<String, dynamic> seconduser = {
    "email": "",
    "name": "",
    "pp": "",
    "uid": "",
    "chatroomid": "",
    "lastmessage": "",
  };

  Map<String, dynamic> firstuser = {
    "email": "",
    "name": "",
    "pp": "",
    "chatroomid": "",
    "lastmessage": "",
    "uid": FirebaseAuth.instance.currentUser!.uid,
  };
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setstatus("online");
    getDataondb();
  }

  void setstatus(String status) async {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(firstuser["uid"])
        .update({"status": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setstatus("online");
    } else {
      setstatus("offline");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat App",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance
                    .signOut()
                    .then((value) => nextScreenReplace(context, const Login()));
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          nextScreen(context, const Search());
        }),
        child: const Icon(Icons.search),
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("participants.${FirebaseAuth.instance.currentUser!.uid}",
                  isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot data = snapshot.data as QuerySnapshot;
                return ListView.builder(
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        onTap: () async {
                          seconduser["name"] =
                              await data.docs[index]["targetname"];

                          seconduser["pp"] = await data.docs[index]["pp"];
                          seconduser["chatroomid"] =
                              await data.docs[index]["chatroomid"];

                          nextScreen(
                              context,
                              ChatRoom(
                                currentuser: firstuser,
                                targetuser: seconduser,
                              ));
                        },
                        leading: CircleAvatar(
                            maxRadius: 35,
                            backgroundImage:
                                NetworkImage(data.docs[index]["pp"])),
                        title: Text(
                          data.docs[index]["targetname"],
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        subtitle:
                            data.docs[index]["lastMessage"].toString().isEmpty
                                ? const Text(
                                    "Say hi to your new friend!",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  )
                                : Text(data.docs[index]["lastMessage"]));
                  },
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text("some Error"),
                );
              } else {
                return const Center(
                  child: Text("No Chats"),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      )),
    );
  }

  getDataondb() async {
    dynamic response =
        await FirebaseFirestore.instance.collection("user").doc(uid).get();
    var datachecker = response.data();

    print(datachecker['email']);
    setState(() {
      email = datachecker["email"].toString();
    });
    setState(() {
      name = datachecker["fullname"].toString();
    });
    setState(() {
      profileImage = datachecker["pp"].toString();
    });
  }
}
