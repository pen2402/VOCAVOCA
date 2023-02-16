import 'package:flutter/material.dart';

class SizeConfig{
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double screenPixel;
  static double screenRatio;
  static double defaultSize;
  static Orientation orientation;


  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width; //+ _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    screenHeight = _mediaQueryData.size.height; //+ _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    screenPixel = screenWidth / 300;
    screenRatio = screenWidth / screenHeight;
    orientation = _mediaQueryData.orientation;
  }
}

double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  return (inputHeight / 812.0) * screenHeight;
}

double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  return (inputWidth / 812.0) * screenWidth;
}