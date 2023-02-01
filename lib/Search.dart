import 'dart:developer';

import 'package:chat/auth/logIn.dart';
import 'package:chat/chatRoom.dart';
import 'package:chat/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Gap(30),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                  hintText: "Search", prefixIcon: Icon(Icons.search)),
            ),
            const Gap(30),
            ElevatedButton(
                onPressed: () async {
                  // FirebaseAuth.instance.signOut();
                  // nextScreenReplace(context, Login());
                  seconduser["email"] = "";
                  seconduser["name"] = "";
                  seconduser["pp"] = "";
                  await searchFunction(searchController.text);

                  setState(() {});
                },
                child: const Text("Search")),
            seconduser["email"].isEmpty
                ? const Text("")
                : Card(
                    elevation: 10,
                    child: ListTile(
                      onTap: () async {
                        seconduser["chatroomid"] = "";
                        seconduser["lastmessage"] = "";
                        await findChatroom();
                        await nextScreen(
                            context,
                            ChatRoom(
                              currentuser: firstuser,
                              targetuser: seconduser,
                            ));
                      },
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundImage: NetworkImage(seconduser["pp"]),
                      ),
                      title: Text(seconduser["name"]),
                      subtitle: Text(seconduser["email"]),
                    ),
                  )
          ],
        ),
      )),
    );
  }

  searchFunction(String search) async {
    if (search.isEmpty) {
      log("Search Controller is Empty");
    } else {
      try {
        log("check 1");
        dynamic response =
            await FirebaseFirestore.instance.collection("user").get();
        log("check 2");

        dynamic data =
            response.docs.firstWhere((e) => e.data()["email"] == search);

        setState(() {
          seconduser["email"] = data["email"].toString();
        });
        setState(() {
          seconduser["uid"] = data["uid"].toString();
        });
        setState(() {
          seconduser["name"] = data["fullname"].toString();
        });
        setState(() {
          seconduser["pp"] = data["pp"].toString();
        });
      } on FirebaseException catch (e) {
        log("${e.message}");
      }
    }
  }

  findChatroom() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${firstuser["uid"]}", isEqualTo: true)
        .where("participants.${seconduser["uid"]}", isEqualTo: true)
        .get();
    String chatroomID = "${firstuser["uid"] + seconduser["uid"]}";

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      log("user exist");

      var docData = snapshot.docs[0];
      print(docData);
      seconduser["chatroomid"] = docData["chatroomid"];
      if (docData["lastMessage"].toString().isEmpty) {
        log("Last message is Empty");
      } else {
        seconduser["lastmessage"] = docData["lastMessage"];
      }

      print(docData["chatroomid"]);
    } else {
      log("user not exist");
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatroomID)
          .set(
        {
          "targetname": seconduser["name"],
          "pp": seconduser["pp"],
          "chatroomid": chatroomID,
          "lastMessage": "",
          "participants": {
            firstuser["uid"]: true,
            seconduser["uid"]: true,
          }
        },
      );

      seconduser["lastmessage"] = "";
      seconduser["chatroomid"] = chatroomID;
      log("new user Created in firestore");
    }
  }
}
