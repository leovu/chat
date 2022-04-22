// /*
// * Created by: nguyenan
// * Created at: 2022/04/22 2:08 PM
// */
// import 'package:flutter/cupertino.dart';
//
// class AppSizes {
//   static double maxWidth;
//   static double maxHeight;
//   static double ultraPadding;
//   static double maxPadding;
//   static double minPadding;
//   static double sizeOnTap;
//   static double statusBarHeight;
//   static double bottomHeight;
//   static double sizeAppBar;
//   static double screenHeight;
//   static double border2;
//   static double border5;
//   static double border4;
//   static double border8;
//   static double border10;
//   static double border15;
//   static double border16;
//   static double border18;
//   static double border24;
//   static double titleImageSize;
//   static double iconSize;
//   static double dotSize;
//   static double loadmoreHeight;
//   static int maximumNumber;
//   static double smallButton;
//   static double totalMax;
//   static double heightLoadMore = 40.0;
//   static double double22 = 22.0;
//   static double avatarSize;
//
//   static init(BuildContext context) {
//     maxWidth = MediaQuery.of(context).size.width;
//     maxHeight = MediaQuery.of(context).size.height;
//     statusBarHeight = MediaQuery.of(context).padding.top;
//     bottomHeight = MediaQuery.of(context).padding.bottom;
//     maxPadding = 20.0;
//     minPadding = 15.0;
//     ultraPadding = maxWidth * 0.1;
//     sizeOnTap = 48.0;
//     screenHeight = maxHeight - statusBarHeight;
//     border2 = 2.0;
//     border5 = 5.0;
//     border4 = 4.0;
//     border8 = 8.0;
//     border10 = 10.0;
//     border15 = 15.0;
//     border16 = 16.0;
//     border18 = 18.0;
//     border24 = 24.0;
//     titleImageSize = 20.0;
//     iconSize = 24.0;
//     dotSize = 4.0;
//     loadmoreHeight = 40.0;
//     maximumNumber = 9999999;
//     smallButton = 25.0;
//     totalMax = 9999999999999.0;
//     heightLoadMore = 40.0 + maxPadding;
//   }
// }

import 'dart:ui';

class AppColors {
  static const primaryColor = Color(0xFFF37021);
  static const primary50Color = Color(0xFFF9DECF);
  static const white = Color(0xFFFFFFFF);
  static const white50 = Color(0xFFFAFAFA);
  static const black = Color(0xFF000000);
  static const lightGrey = Color(0xFFF6F6F6);
  static const grey600 = Color(0xFF777777);
  static const dark = Color(0xFF040C21);
  static const grey200 = Color(0xFFD8D8D8);
  static const lineColor = Color(0xFFEFF0F2);
  static const greenLightColor = Color(0xFFE5FAE6);
  static const greenBorderColor = Color(0xFFC1F0C1);
  static const paginationColor = Color(0xFFF1E4DC);
  static const tabActiveColor = Color(0xFF262B35);
  static const tabInActiveColor = Color(0xFF666D7C);
  static const promotionColor = Color(0xFFF3F4F6);
  static const iconInActiveColor = Color(0xFF727682);
  static const black50Color = Color(0xFF11192E);
  static const colorLine = Color(0xFFF1F1F1);
  static const colorLineImage = Color(0xFFE4E4E4);
  static const headerColorBackground = Color(0xFFFF7421);
  static const headerColorLinearTop = Color(0xFFFFF1D3);
  static const headerColorLinearBottom = Color(0xFFFFE5D4);
  static const colorSelectedService = Color(0xFFFFF5EB);
  static const colorUnSelectedService = Color(0xFFF4F6F8);
  static const colorBorderUnSelectedService = Color(0xFFEAEEF1);
  static const redColor = Color(0xFFE22119);
  static const colorRed = Color(0xFFFF0000);
  static const greenColor = Color(0xFF00D172);
  static const orangeColorGradientTop = Color(0xFFFFA93A);
  static const orangeColorGradientBottom = Color(0xFFFFF9ED);
  static const lineCardColor = Color(0xFFEFEFEF);
  static const blueColor = Color(0xFF2F80ED);
  static const colorBlue = Color(0xFF276EDF);
  static const grey500Color = Color(0xFFA0A4AF);
  static const grey700Color = Color(0xFFC7CBD7);
  static const grey600Color = Color(0xFFBEC0C7);
  static const grey300Color = Color(0xFFF9F9F9);
  static const grey200Color = Color(0xFFF4F4F4);
  static const greyF8Color = Color(0xFFF8F8F8);
  static const redAccColor = Color(0xFFFF8F8F);
  static const blueAccColor = Color(0xFF75AEFF);
  static const colorIconVersion = Color(0xFF4D515E);
  static const colorBgTextField = Color(0xFFF5F5F6);
  static const colorBgBank = Color(0xFFF8F9FB);
  static const shadowColor = Color(0xFFC6C6C6);
  static const colorGreen = Color(0xFF30D78B);
  static const colorGreen50 = Color(0xFFEFFFF8);
  static const colorOrange50 = Color(0xFFFFF2EB);
  static const lineBlueColor = Color(0xFFE4E6EB);
  static const lineTabInactiveColor = Color(0xFFE2E3E6);
  static const lineBoardColor = Color(0xFFE6E6E6);
  static const lineBorderColor = Color(0xFFD2D5DB);
  static const grayBackGround = Color(0xFFE5E5E5);
  static const brown = Color(0xFFC59A70);

  static const backgroundNotification = Color(0xFFECF4FF);
  static const grey34 = Color(0xFFF3F4F7);
  static const colorTabUnselected = Color(0xFF707581);
  static const editColor = Color(0xFFADB2BD);

  static const bluePrimary = Color(0xFF4564ED);
  static const primaryUnselect = Color(0xFFFFEAD6);
  static const filterSelectedColor = Color(0xFFFFF5EF);
  static const backgroundRed = Color(0xFFFFF8F8);
  static const green = Color(0xFF4CD964);
  static const backgroundGrey = Color(0xFFF5F6F8);
  static const darkGrey = Color(0xFF98A1B3);
  static const ash = Color(0xFF7D8290);
  static const colorDot = Color(0xFFADB1B9);
  static const disableColor = Color(0xFFDADADA);
}

class AppTextStyles {

  static TextStyle style12WhiteWeight700Italic = TextStyle(
    fontSize: AppTextSizes.size12,
    color: AppColors.white,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,);
  static TextStyle style10WhiteWeight700Italic = TextStyle(
    fontSize: AppTextSizes.size10,
    color: AppColors.white,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,);
  static TextStyle style18WhiteBoldItalic = TextStyle(
    fontSize: AppTextSizes.size18,
    color: AppColors.white,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,);
  static TextStyle style20WhiteWeight700= TextStyle(
      fontSize: AppTextSizes.size20,
      color: AppColors.white,
      fontWeight: FontWeight.w700);
  static TextStyle style36BlackNormal = TextStyle(
      fontSize: AppTextSizes.size36,
      color: AppColors.black,
      fontWeight: FontWeight.normal);

  static TextStyle style25WhiteWeight800Italic = TextStyle(
    fontSize: AppTextSizes.size25,
    color: AppColors.white,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,);

  static TextStyle style25BlackWeight700 = TextStyle(
      fontSize: AppTextSizes.size25,
      color: AppColors.black,
      fontWeight: FontWeight.w700);
  static TextStyle style24BlackBold = TextStyle(
      fontSize: AppTextSizes.size24,
      color: AppColors.black,
      fontWeight: FontWeight.bold);
  static TextStyle style22BlackBold = TextStyle(
      fontSize: AppTextSizes.size22,
      color: AppColors.black,
      fontWeight: FontWeight.bold);
  static TextStyle style16BlackBold = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.black,
      fontWeight: FontWeight.bold);
  static TextStyle style18BlackBold = TextStyle(
      fontSize: AppTextSizes.size18,
      color: AppColors.black,
      fontWeight: FontWeight.bold);
  static TextStyle style18PrimaryBold = TextStyle(
      fontSize: AppTextSizes.size18,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.bold);
  static TextStyle style17WhiteNormal = TextStyle(
      fontSize: AppTextSizes.size17,
      color: AppColors.white,
      fontWeight: FontWeight.normal);
  static TextStyle style15PrimaryNormal = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.normal);
  static TextStyle style15WhiteNormal = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.white,
      fontWeight: FontWeight.normal);
  static TextStyle style15BlackNormal = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.black,
      fontWeight: FontWeight.normal);
  static TextStyle style15BlackBold = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.black,
      fontWeight: FontWeight.bold);
  static TextStyle style15Grey600Normal = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.grey600,
      fontWeight: FontWeight.normal);
  static TextStyle style15Red600Normal = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.redColor,
      fontWeight: FontWeight.normal);
  static TextStyle style12Grey600Normal = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.grey600,
      fontWeight: FontWeight.normal);
  static TextStyle style12Green600Normal = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.green,
      fontWeight: FontWeight.normal);
  static TextStyle style12RedNormal = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.redColor,
      fontWeight: FontWeight.normal);
  static TextStyle style12BlackW400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.black,
      fontWeight: FontWeight.w400);
  static TextStyle style12PrimaryW400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w400);
  static TextStyle style12WhiteNormal = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.white,
      fontWeight: FontWeight.normal);
  static TextStyle style12PrimaryWeight600 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600);
  static TextStyle style14WhiteWeight700Italic = TextStyle(
    fontSize: AppTextSizes.size14,
    color: AppColors.white,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,);
  static TextStyle style14Black50Weight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.black50Color,
      fontWeight: FontWeight.w400);
  static TextStyle style14BlueUnderlineWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.blueColor,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w400);
  static TextStyle style14WhiteWeight600 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.white,
      fontWeight: FontWeight.w600);
  static TextStyle style14WhiteWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.white,
      fontWeight: FontWeight.w400);
  static TextStyle style14Grey500Weight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.grey500Color,
      fontWeight: FontWeight.w400);
  static TextStyle style14reyTabWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.tabInActiveColor,
      fontWeight: FontWeight.w400);
  static TextStyle style14PrimaryWeight600 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600);
  static TextStyle style14PrimaryWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w400);
  static TextStyle style14BlueWeight500 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.bluePrimary,
      fontWeight: FontWeight.w500);
  static TextStyle style14BlackWeight600 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.black,
      fontWeight: FontWeight.w600);
  static TextStyle style14BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.black,
      fontWeight: FontWeight.w500);
  static TextStyle style14BlackWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.black,
      fontWeight: FontWeight.w400);
  static TextStyle style14BlackBold = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.black,
      fontWeight: FontWeight.bold);
  static TextStyle style13BlackWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.black,
      fontWeight: FontWeight.w400);
  static TextStyle style13BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.black,
      fontWeight: FontWeight.w500);
  static TextStyle style13BlackWeight600 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.black,
      fontWeight: FontWeight.w600);
  static TextStyle style13BlackWeight700 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.black,
      fontWeight: FontWeight.w700);
  static TextStyle style13RedWeight700 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.redColor,
      fontWeight: FontWeight.w700);
  static TextStyle style13RedWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.redColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13Weight400 =
  TextStyle(fontSize: AppTextSizes.size13, fontWeight: FontWeight.w400);
  static TextStyle style13GrayWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.tabInActiveColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13GreenWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.green,
      fontWeight: FontWeight.w400);
  static TextStyle style13PrimaryWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13WhiteWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.white,
      fontWeight: FontWeight.w400);
  static TextStyle style13GreenWeight500 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.greenColor,
      fontWeight: FontWeight.w500);
  static TextStyle style13BlueWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.bluePrimary,
      fontWeight: FontWeight.w400);
  static TextStyle style13BlueWeight500 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.bluePrimary,
      fontWeight: FontWeight.w500);
  static TextStyle style13BluePrimaryWeight600 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.bluePrimary,
      fontWeight: FontWeight.w600);
  static TextStyle style13BluePrimaryWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.bluePrimary,
      fontWeight: FontWeight.w400);
  static TextStyle style12DartColorWeight500 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.dark,
      fontWeight: FontWeight.w500);
  static TextStyle style12DartColorWeight400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.dark,
      fontWeight: FontWeight.w400);
  static TextStyle style12Grey500ColorWeight400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.grey500Color,
      fontWeight: FontWeight.w400);
  static TextStyle style11Grey500ColorWeight400 = TextStyle(
      fontSize: AppTextSizes.size11,
      color: AppColors.grey500Color,
      fontWeight: FontWeight.w400);
  static TextStyle style11WhiteWeight500 = TextStyle(
      fontSize: AppTextSizes.size11,
      color: AppColors.white,
      fontWeight: FontWeight.w500);
  static TextStyle style11WhiteNormal = TextStyle(
      fontSize: AppTextSizes.size11,
      color: AppColors.white,
      fontWeight: FontWeight.normal);
  static TextStyle style16BlackWeight700 = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.black,
      fontWeight: FontWeight.w700);
  static TextStyle style16BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.black,
      fontWeight: FontWeight.w500);
  static TextStyle style16BlackWeight600 = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.black,
      fontWeight: FontWeight.w600);
  static TextStyle style16WhiteBold = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.white,
      fontWeight: FontWeight.bold);
  static TextStyle style10WhiteBold = TextStyle(
      fontSize: AppTextSizes.size10,
      color: AppColors.white,
      fontWeight: FontWeight.bold);
  static TextStyle style12BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.black,
      fontWeight: FontWeight.w500);
  static TextStyle style12BlackWeight400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.black,
      fontWeight: FontWeight.w400);
  static TextStyle style15BlackWeight700 = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.black,
      fontWeight: FontWeight.w700);
}

class AppTextSizes {
  // static double size7 = 7.0;
  static double size8 = 8.0;
  static double size10 = 10.0;
  static double size11 = 11.0;
  static double size12 = 12.0;
  static double size13 = 13.0;
  static double size14 = 14.0;
  static double size15 = 15.0;
  static double size16 = 16.0;
  static double size17 = 17.0;
  static double size18 = 18.0;
  static double size20 = 20.0;
  static double size22 = 22.0;
  static double size24 = 24.0;
  static double size25 = 25.0;
  static double size28 = 28.0;
  static double size30 = 30.0;
  static double size36 = 36.0;
}