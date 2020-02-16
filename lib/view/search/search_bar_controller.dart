import 'dart:async';
import 'package:deep_seed/view/search/search_bar_style.dart';
import 'package:flutter/material.dart';

typedef void OnSearchQueryChanged(String query);
typedef void OnSuggestionShow(bool showSuggestion);

mixin _ControllerListener on State<SearchBar> {
  void onListChanged(List items) {}

  void onLoading() {}

  void onClear() {}

  void onError(Error error) {}
}

class SearchBar extends StatefulWidget {
  /// List of items showed by default
  final List suggestions;

  /// Callback returning the widget corresponding to a Suggestion item
  final Widget Function(dynamic item, int index) buildSuggestion;

  /// Minimum number of chars required for a search
  final int minimumChars;

  /// Callback returning the widget corresponding to an Error while searching
  final Widget Function(Error error) onError;

  /// Cooldown between each call to avoid too many
  final Duration debounceDuration;

  /// Widget to show when loading
  final Widget loader;

  /// Widget to show when no item were found
  final Widget emptyWidget;

  /// Widget to show by default
  final Widget placeHolder;

  /// Widget showed on left of the search bar
  final Widget icon;

  /// Widget placed between the search bar and the results
  final Widget header;

  /// Hint text of the search bar
  final String hintText;

  /// TextStyle of the hint text
  final TextStyle hintStyle;

  /// Color of the icon when search bar is active
  final Color iconActiveColor;

  /// Text style of the text in the search bar
  final TextStyle textStyle;

  /// Widget shown for cancellation
  final Widget cancellationWidget;

  /// Callback when cancel button is triggered
  final VoidCallback onCancelled;

  /// Enable to edit the style of the search bar
  final SearchBarStyle searchBarStyle;

  /// Number of items displayed on cross axis
  final int crossAxisCount;

  /// Weather the list should take the minimum place or not
  final bool shrinkWrap;

  /// Set the scrollDirection
  final Axis scrollDirection;

  /// Spacing between tiles on main axis
  final double mainAxisSpacing;

  /// Spacing between tiles on cross axis
  final double crossAxisSpacing;

  /// Set a padding on the search bar
  final EdgeInsetsGeometry searchBarPadding;

  /// Set a padding on the header
  final EdgeInsetsGeometry headerPadding;

  /// Set a padding on the list
  final EdgeInsetsGeometry listPadding;

  final OnSearchQueryChanged onSearchQueryChanged;

  final OnSuggestionShow onSuggestionShow;

  String lastSearchQuery = "";
  SearchBar({
    Key key,
    @required this.onSearchQueryChanged,
    this.onSuggestionShow,
    this.minimumChars = 3,
    this.debounceDuration = const Duration(milliseconds: 1000),
    this.loader = const Center(child: CircularProgressIndicator()),
    this.onError,
    this.emptyWidget = const SizedBox.shrink(),
    this.header,
    this.placeHolder,
    this.icon = const Icon(Icons.search),
    this.hintText = "",
    this.hintStyle = const TextStyle(color: Color.fromRGBO(142, 142, 147, 1)),
    this.iconActiveColor = Colors.grey,
    this.textStyle = const TextStyle(color: Colors.black),
    this.cancellationWidget = const Text(
      "Cancel",
      style: TextStyle(color: Colors.grey),
    ),
    this.onCancelled,
    this.suggestions = const [],
    this.buildSuggestion,
    this.searchBarStyle = const SearchBarStyle(),
    this.crossAxisCount = 1,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.listPadding = const EdgeInsets.all(0),
    this.searchBarPadding = const EdgeInsets.all(0),
    this.headerPadding = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with TickerProviderStateMixin, _ControllerListener {
  TextEditingController _searchQueryController;
  Timer _debounce;
  bool _animate = false;
  List _list = [];
  FocusNode _focusNode = FocusNode();
  String queryText = "";
  bool showSuggestion = false;
  @override
  void initState() {
    super.initState();
    _searchQueryController = TextEditingController(text: queryText);
    _focusNode.addListener(() {
      if (showSuggestion != _focusNode.hasFocus &&
          widget.onSuggestionShow != null) {
        showSuggestion = _focusNode.hasFocus;
        widget.onSuggestionShow(showSuggestion);
      }
    });
  }

  @override
  void onListChanged(List items) {
    setState(() {
      _list = items;
    });
  }

  @override
  void onLoading() {
    setState(() {
      _animate = true;
    });
  }

  @override
  void onClear() {
    _cancel();
  }

  @override
  void onError(Error error) {}

  _onTextChanged(String newText) async {
    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }
    if (newText.length >= widget.minimumChars) {
      widget.lastSearchQuery = newText;
    }
    _debounce = Timer(widget.debounceDuration, () async {
      bool shouldSearch = ((newText.length == 0 &&
                  widget.lastSearchQuery.length >= widget.minimumChars) ||
              newText.length >= widget.minimumChars) &&
          widget.onSearchQueryChanged != null;
      if (shouldSearch) {
        widget.onSearchQueryChanged(newText);
      } else {}
    });
  }

  void _cancel() {
    if (widget.onCancelled != null) {
      widget.onCancelled();
    }

    setState(() {
      _searchQueryController.clear();
      _list.clear();
      _animate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final widthMax = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: widget.searchBarPadding,
          child: Container(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: _animate ? widthMax * .8 : widthMax,
                    decoration: BoxDecoration(
                      borderRadius: widget.searchBarStyle.borderRadius,
                      color: widget.searchBarStyle.backgroundColor,
                    ),
                    child: Padding(
                      padding: widget.searchBarStyle.padding,
                      child: Theme(
                        child: TextField(
                          controller: _searchQueryController,
                          onChanged: _onTextChanged,
                          style: widget.textStyle,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            icon: widget.icon,
                            border: InputBorder.none,
                            hintText: widget.hintText,
                            hintStyle: widget.hintStyle,
                          ),
                        ),
                        data: Theme.of(context).copyWith(
                          primaryColor: widget.iconActiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _cancel,
                  child: AnimatedOpacity(
                    opacity: _animate ? 1.0 : 0,
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: _animate ? 800 : 0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width:
                          _animate ? MediaQuery.of(context).size.width * .1 : 0,
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: widget.cancellationWidget,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
