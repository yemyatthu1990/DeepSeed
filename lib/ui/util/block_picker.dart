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
    OnShadowChanged onShadowChanged,
    bool showSlider,
    bool showShadow,
    bool isShadowEnabled);
typedef PickerItem = Widget Function(Color color);
typedef OnAlphaChanged(double value);
typedef OnShadowChanged(bool value);
typedef PickerItemBuilder = Widget Function(
  Color color,
  bool isCurrentColor,
  Function changeColor,
);

class BlockPicker extends StatefulWidget {
  BlockPicker({
    @required this.pickerColor,
    @required this.alphaValue,
    @required this.onColorChanged,
    @required this.onShadowChanged,
    this.isShadowEnabled,
    this.showAlphaPicker = true,
    this.showShadowPicker = false,
    this.layoutBuilder = defaultLayoutBuilder,
    this.itemBuilder = defaultItemBuilder,
  });
  final bool showAlphaPicker;
  final bool showShadowPicker;
  final Color pickerColor;
  final double alphaValue;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<bool> onShadowChanged;
  final PickerLayoutBuilder layoutBuilder;
  final PickerItemBuilder itemBuilder;
  final isShadowEnabled;
  static Widget defaultLayoutBuilder(
      BuildContext context,
      List<Color> colors,
      double alphaValue,
      PickerItem child,
      OnAlphaChanged onAlphaChanged,
      OnShadowChanged onShadowChanged,
      bool showSlider,
      bool showShadow,
      bool isShadowEnabled) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16, bottom: 16),
            height: deviceHeight / 1.89 > 400 ? 400 : deviceHeight / 1.89,
            width: deviceWidth / 1.34,
            child: GridView.count(
              crossAxisCount: 4,
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
              : Container(),
          showShadow
              ? Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(mainAxisSize: MainAxisSize.max, children: [
                    Checkbox(
                      onChanged: (value) {
                        onShadowChanged(value);
                      },
                      value: isShadowEnabled,
                    ),
                    Flexible(child: Text("Add font shadow"))
                  ]))
              : Container(),
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

class _BlockPickerState extends State<BlockPicker>
    with AutomaticKeepAliveClientMixin<BlockPicker> {
  Color _currentColor;

  double _currentAlphaValue;
  bool _isShadowEnabled;
  List<Color> availableColors = new List();

  @override
  void initState() {
    if (_currentColor == null) _currentColor = widget.pickerColor;
    if (_currentAlphaValue == null) _currentAlphaValue = widget.alphaValue;
    if (_isShadowEnabled == null) _isShadowEnabled = widget.isShadowEnabled;
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

  void changeShadow(bool value) {
    setState(() {
      _isShadowEnabled = value;
    });

    widget.onShadowChanged(value);
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
        (shadow) => changeShadow(shadow),
        widget.showAlphaPicker,
        widget.showShadowPicker,
        _isShadowEnabled);
  }

  @override
  bool get wantKeepAlive => true;
}
