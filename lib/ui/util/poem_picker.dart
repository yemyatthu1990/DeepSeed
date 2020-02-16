import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PoemPicker extends StatefulWidget {
  final Stream<QuerySnapshot> snapshots;
  PoemPicker({this.snapshots});

  @override
  State<StatefulWidget> createState() {
    return PoemPickerState();
  }
}

class PoemPickerState extends State<PoemPicker> {
  bool showLoading = true;
  List<Poem> poems = new List();
  @override
  void initState() {
    super.initState();
    widget.snapshots.listen((event) {
      setState(() {
        showLoading = false;
        event.documents.forEach((snapshot) {
          Poem poem = new Poem();
          poem.body = snapshot["body"];
          poem.title = snapshot["title"];
          poem.author = snapshot["author"];
          poems.add(poem);
        });
        showLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
        border: Border.all(
            width: 1.0, style: BorderStyle.solid, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(5.0)));
    List<Widget> childWidgets = new List();
    poems.forEach((poem) {
      Container container = Container(
        padding: const EdgeInsets.all(10.0),
        decoration: decoration,
        child: IntrinsicHeight(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(child: Text(poem.body)),
            Text(poem.author),
          ],
        )),
      );

      childWidgets.add(new SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, poem);
        },
        child: container,
      ));
    });
    return SimpleDialog(
      children: showLoading
          ? [
              Center(
                  child: Container(
                      padding: EdgeInsets.all(100),
                      color: Theme.of(context).dialogBackgroundColor,
                      child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ))))
            ]
          : childWidgets,
    );
  }
}
