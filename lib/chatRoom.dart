import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  Map<String, dynamic>? targetuser;
  Map<String, dynamic>? currentuser;
  ChatRoom({super.key, this.targetuser, this.currentuser});
  String status = "";

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final sendmessage = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetuser!["pp"]),
            ),
            const SizedBox(width: 15),
            Column(
              children: [
                Text(widget.targetuser!["name"]),
              ],
            )
          ],
        ),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.targetuser!["chatroomid"])
                    .collection("message")
                    .orderBy("don", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Firebase have some error");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    QuerySnapshot data = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: (snapshot.data!.docs[index]
                                      ["sender"] ==
                                  widget.currentuser!["uid"])
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: (snapshot.data!.docs[index]
                                                ["sender"] ==
                                            widget.currentuser!["uid"])
                                        ? Colors.grey
                                        : Colors.blue,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "${data.docs[index]["msg"]}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                                )),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            )),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    controller: sendmessage,
                    maxLength: null,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Enter Message"),
                  )),
                  InkWell(
                    onTap: () {
                      sendMessage();
                      setState(() {
                        sendmessage.clear();
                      });
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  data() async {
    StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("user")
          .doc(widget.targetuser!["uid"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("data");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("data");
        } else {
          return AppBar();
        }
      },
    );
  }

  sendMessage() async {
    String sendTextMessage = sendmessage.text.trim();
    String messageID = DateTime.now().microsecondsSinceEpoch.toString();
    if (sendTextMessage.isEmpty) {
      log("Empty Message");
    } else {
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.targetuser!["chatroomid"])
          .collection("message")
          .doc(messageID)
          .set({
        "messageid": messageID,
        "sender": widget.currentuser!["uid"],
        "seen": false,
        "don": DateTime.now(),
        "msg": sendTextMessage
      });
      log("Message send");
      widget.targetuser!["lastmessage"] = sendTextMessage;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.targetuser!["chatroomid"])
          .update({"lastMessage": sendTextMessage});
      log("set last message");
    }
  }
}
