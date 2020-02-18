import 'package:deep_seed/util/utils.dart';
import 'package:deep_seed/view/StateAwareSlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<Color> _defaultColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.white,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];

typedef PickerLayoutBuilder = Widget Function(
    BuildContext context,
    List<Color> colors,
    double alphaValue,
    PickerItem child,
    OnAlphaChanged onAlphaChanged,
    bool showSlider);
typedef PickerItem = Widget Function(Color color);
typedef OnAlphaChanged(double value);
typedef PickerItemBuilder = Widget Function(
  Color color,
  bool isCurrentColor,
  Function changeColor,
);

class BlockPicker extends StatefulWidget {
  const BlockPicker({
    @required this.pickerColor,
    @required this.alphaValue,
    @required this.onColorChanged,
    this.showAlphaPicker = true,
    this.layoutBuilder = defaultLayoutBuilder,
    this.itemBuilder = defaultItemBuilder,
  });
  final bool showAlphaPicker;
  final Color pickerColor;
  final double alphaValue;
  final ValueChanged<Color> onColorChanged;
  final PickerLayoutBuilder layoutBuilder;
  final PickerItemBuilder itemBuilder;

  static Widget defaultLayoutBuilder(
      BuildContext context,
      List<Color> colors,
      double alphaValue,
      PickerItem child,
      OnAlphaChanged onAlphaChanged,
      bool showSlider) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16, bottom: 16),
            width: orientation == Orientation.portrait ? 300.0 : 300.0,
            height: orientation == Orientation.portrait ? 380.0 : 200.0,
            child: GridView.count(
              crossAxisCount: orientation == Orientation.portrait ? 4 : 6,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              children: colors.map((Color color) => child(color)).toList(),
            ),
          ),
          showSlider
              ? Slider(
                  label: "Transparency",
                  value: alphaValue,
                  max: 255,
                  min: 0,
                  onChanged: (value) {
                    onAlphaChanged(value);
                  },
                )
              : Container()
        ]);
  }

  static Widget defaultItemBuilder(
      Color color, bool isCurrentColor, Function changeColor) {
    return Container(
        margin: EdgeInsets.all(5),
        child:
            Stack(alignment: Alignment.center, fit: StackFit.expand, children: [
          SvgPicture.asset("graphics/transparent_circle.svg"),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: color,
                border: Border.all(color: Colors.grey, width: 1)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: changeColor,
                borderRadius: BorderRadius.circular(50.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 210),
                  opacity: isCurrentColor ? 1.0 : 0.0,
                  child: Icon(
                    Icons.done,
                    color: Utils.useWhiteForeground(color)
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          )
        ]));
  }

  @override
  State<StatefulWidget> createState() => _BlockPickerState();
}

class _BlockPickerState extends State<BlockPicker> {
  Color _currentColor;

  double _currentAlphaValue;
  List<Color> availableColors = new List();

  @override
  void initState() {
    if (_currentColor == null) _currentColor = widget.pickerColor;
    if (_currentAlphaValue == null) _currentAlphaValue = widget.alphaValue;

    _defaultColors.forEach((element) {
      availableColors.add(element.withAlpha(widget.alphaValue.toInt()));
    });

    super.initState();
  }

  void changeColor(Color color) {
    setState(() => _currentColor = color);
    widget.onColorChanged(_currentColor);
  }

  void changeAlpha(double alpha) {
    setState(() {
      _currentAlphaValue = alpha;

      availableColors.clear();
      _defaultColors.forEach((element) {
        availableColors.add(element.withAlpha(_currentAlphaValue.toInt()));
      });
      _currentColor = _currentColor.withAlpha(alpha.toInt());
    });
    widget.onColorChanged(_currentColor);
  }

  @override
  Widget build(BuildContext context) {
    return widget.layoutBuilder(
        context,
        availableColors,
        _currentAlphaValue,
        (Color color, [bool _, Function __]) => widget.itemBuilder(
            color,
            (_currentColor.red == color.red &&
                _currentColor.green == color.green &&
                _currentColor.blue == color.blue),
            () => changeColor(color.withAlpha(_currentAlphaValue.toInt()))),
        (alpha) => changeAlpha(alpha),
        widget.showAlphaPicker);
  }
}
