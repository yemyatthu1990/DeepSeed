import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StateAwareSlider extends StatefulWidget {
  final double currentFontSize;
  final OnFontSizeChangeListener onFontSizeChangeListener;

  StateAwareSlider({this.currentFontSize, this.onFontSizeChangeListener});

  @override
  State<StatefulWidget> createState() {
    return StateAwareSliderState(currentFontSize: this.currentFontSize);
  }
}

class StateAwareSliderState extends State<StateAwareSlider> {
  double currentFontSize;
  StateAwareSliderState({this.currentFontSize});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      Expanded(
          child: Slider(
        activeColor: Colors.black,
        value: currentFontSize >= 12 ? currentFontSize : 12,
        onChanged: (value) {
          setState(() {
            currentFontSize = value;
            widget.onFontSizeChangeListener(currentFontSize);
          });
        },
        min: 12,
        max: 32,
      )),
      Padding(
          padding: EdgeInsets.only(right: 16),
          child: Text(currentFontSize.round().toString() + " sp"))
    ]);
  }
}
