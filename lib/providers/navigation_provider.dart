import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _screenIndex = 0;
  bool _requestSearchFocus = false;

  int get screenIndex => _screenIndex;
  bool get requestSearchFocus => _requestSearchFocus;

  void setScreenIndex(int index) {
    _screenIndex = index;
    notifyListeners();
  }

  void goToSearch({bool focus = false}) {
    _requestSearchFocus = focus;
    _screenIndex = 1; // search tab index
    notifyListeners();
  }

  void clearSearchFocusRequest() {
    _requestSearchFocus = false;
  }
}
