import 'package:barcode_image/barcode_image.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

class Dialogs {
  static Future<void> isbnDialog(BuildContext context,
      Map<String, dynamic> data) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Barcode? type = (data["type"] == "ISBN_13") ? Barcode.isbn() : null;
          if(type == null) Navigator.of(context).pop();

          return AlertDialog(
            title: Text(data["type"]),
            content: Stack(
              alignment: Alignment.center,
              children: [
                BarcodeWidget(
                  data: data["identifier"],
                  barcode: Barcode.isbn(),
                  height: 150,
                ),
                Container(
                  color: Colors.white,
                  height: 170,
                  width: 320,
                )
              ].reversed.toList()
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.of(context).pop();
              }, child: const Text("Close"))
            ],
          );
        }
    );
  }
}