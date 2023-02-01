import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

nextScreen(BuildContext context, dynamic screen) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return screen;
    },
  ));
}

nextScreenReplace(BuildContext context, dynamic screen) {
  Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (context) {
      return screen;
    },
  ));
}

backScreen(BuildContext context) {
  Navigator.pop(context);
}

showLoading(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              Gap(15),
              Text("Loading")
            ],
          ),
        ),
      );
    },
  );
}

showmsg(BuildContext context, String msg) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("An error occured"),
        content: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(msg)],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                backScreen(context);
              },
              child: const Text("Ok"))
        ],
      );
    },
  );
}
