/*
* Created by: nguyenan
* Created at: 2024/04/26 09:37
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

class AppKeys {
  static const String keyHUD = "/HUD";
  static const String keyLanguage = "LANGUAGE";
}

class AppColors {
  static const primaryColor = Color(0xFF3398DC);
  static const primaryGradiantColor = Color(0xFF5FAEE3);
  static const primaryDarkColor = Color(0xFF1F7BBF);
  static const primaryLightColor = Color(0xFF9CCFF0);
  static const primaryColorMix = Color(0xFFE1F0FA);
  static const secondaryColor = Color(0xFF1A6497);
  static const secondaryColorMix = Color(0xFFD3E8F7);
  static const tertiaryColor = Color(0xFFFF9F0A);
  static const successColor = Color(0xFF34C759);
  static const warningColor = Color(0xFFFFB020);
  static const dangerColor = Color(0xFFFF3B30);
  static const surfaceColor = Color(0xFFF5F7F9);
  static const textTitleColor = Color(0xFF1E293B);
  static const textStrongColor = Color(0xFF334155);
  static const textBodyColor = Color(0xFF475569);
  static const textSecondaryColor = Color(0xFF64748B);
  static const textMutedColor = Color(0xFF94A3B8);
  static const primary50Color = Color(0xFFD3E8F7);
  static const white = Color(0xFFFFFFFF);
  static const white50 = Color(0xFFFAFAFA);
  static const line2Color = Color(0xFFE7E8EA);
  static const black = Color(0xFF000000);
  static const lightGrey = Color(0xFFF6F6F6);
  static const grey600 = Color(0xFF777777);
  static const dark = Color(0xFF040C21);
  static const grey200 = Color(0xFFD8D8D8);
  static const lineColor = Color(0xFFE1F0FA);
  static const greenLightColor = Color(0xFFE5FAE6);
  static const greenBorderColor = Color(0xFFC1F0C1);
  static const paginationColor = Color(0xFFD3E8F7);
  static const tabActiveColor = Color(0xFF262B35);
  static const tabInActiveColor = Color(0xFF666D7C);
  static const promotionColor = Color(0xFFF3F4F6);
  static const iconInActiveColor = Color(0xFF727682);
  static const black50Color = Color(0xFF11192E);
  static const colorLine = Color(0xFFF1F1F1);
  static const colorLineImage = Color(0xFFE4E4E4);
  static const headerColorBackground = Color(0xFF3398DC);
  static const headerColorLinearTop = Color(0xFFEDF2F6);
  static const headerColorLinearBottom = Color(0xFFE1F0FA);
  static const colorSelectedService = Color(0xFFE1F0FA);
  static const colorUnSelectedService = Color(0xFFF4F6F8);
  static const colorBorderUnSelectedService = Color(0xFFEAEEF1);
  static const redColor = Color(0xFFE22119);
  static const colorRed = Color(0xFFFF0000);
  static const greenColor = Color(0xFF00D172);
  static const orangeColorGradientTop = Color(0xFFFFA93A);
  static const orangeColorGradientBottom = Color(0xFFFFF9ED);
  static const orangeColorGradient1 = Color(0xFFFFA800);
  static const orangeColorGradient2 = Color(0xFFFF7A00);
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
  static const blueBackground = Color(0xFFD1E5FF);
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
  static const darkGray = Color(0xFF4F5E74);
  static const backgroundDarkGray = Color(0xFFF3F6F9);

  static const backgroundNotification = Color(0xFFECF4FF);
  static const grey34 = Color(0xFFF3F4F7);
  static const colorTabUnselected = Color(0xFF707581);
  static const editColor = Color(0xFFADB2BD);

  static const bluePromotion = Color(0xFF0A6EF4);
  static const bluePrimary = Color(0xFF4564ED);
  static const primaryUnselect = Color(0xFFE1F0FA);
  static const filterSelectedColor = Color(0xFFE1F0FA);
  static const backgroundRed = Color(0xFFFFF8F8);
  static const green = Color(0xFF4CD964);
  static const backgroundGrey = Color(0xFFF5F6F8);
  static const darkGrey = Color(0xFF98A1B3);
  static const ash = Color(0xFF7D8290);
  static const colorDot = Color(0xFFADB1B9);
  static const disableColor = Color(0xFFDADADA);
  static const line1Color = Color(0xFFE3E5EA);
  static const orange1 = Color(0xFFFF9255);
  static const orange2 = Color(0xFFFFE296);
  static const orange3 = Color(0xFFFFD7A9);
  static const grey = Color(0xFF464E5F);
}

class AppFonts {
  static const font = "Inter";
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double card = 16;
  static const double sheet = 26;
  static const double pill = 100;
}

class AppGlass {
  static const double radius = AppRadius.card;

  static const double sheetRadius = AppRadius.sheet;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryColor, AppColors.primaryGradiantColor],
  );

  static const LinearGradient activeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGradiantColor, AppColors.primaryColor],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDF2F6), AppColors.surfaceColor, Color(0xFFF2F4F6)],
    stops: [0.0, 0.45, 1.0],
  );

  static LinearGradient get sheetGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFDFEFF),
          Color.lerp(Colors.white, AppColors.primaryColor, 0.012)!,
          AppColors.surfaceColor,
        ],
        stops: const [0.0, 0.3, 1.0],
      );

  static LinearGradient get sentBubbleGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryColorMix,
          Color.lerp(
              AppColors.primaryColorMix, AppColors.primaryLightColor, 0.45)!,
        ],
      );

  static const Color headerForeground = AppColors.textTitleColor;
  static const SystemUiOverlayStyle headerOverlay = SystemUiOverlayStyle.dark;

  static const TextStyle headerTitleStyle = TextStyle(
      color: headerForeground, fontSize: 17.0, fontWeight: FontWeight.w600);

  static const TextStyle headerNameStyle = TextStyle(
      color: headerForeground, fontSize: 17.0, fontWeight: FontWeight.w600);

  static const Color hairlineColor = Color(0xFFE6EAF0);

  static const lg.LiquidGlassSettings sheetSettings = lg.LiquidGlassSettings(
    glassColor: Color(0xD9F7F9FC),
    blur: 24.0,
    thickness: 30.0,
    saturation: 1.8,
  );

  static List<BoxShadow> get solidShadow => [
        BoxShadow(
          offset: const Offset(0.0, 2.0),
          blurRadius: 10.0,
          spreadRadius: -2.0,
          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
        ),
      ];

  static Color get surface => Colors.white.withValues(alpha: 0.72);

  static Color get surfaceLight => Colors.white.withValues(alpha: 0.55);

  static Color get borderColor => Colors.white.withValues(alpha: 0.9);

  static Color get headerIconBackground =>
      AppColors.textTitleColor.withValues(alpha: 0.06);

  static List<BoxShadow> get shadow => [
        BoxShadow(
          offset: const Offset(0.0, 8.0),
          blurRadius: 22.0,
          spreadRadius: -4.0,
          color: AppColors.primaryDarkColor.withValues(alpha: 0.12),
        ),
        BoxShadow(
          offset: const Offset(0.0, 1.0),
          blurRadius: 3.0,
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
        ),
      ];

  static List<BoxShadow> get shadowPressed => [
        BoxShadow(
          offset: const Offset(0.0, 3.0),
          blurRadius: 10.0,
          spreadRadius: -2.0,
          color: AppColors.primaryDarkColor.withValues(alpha: 0.16),
        ),
      ];

  static List<BoxShadow> get headerShadow => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12.0,
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12.0,
          color: AppColors.primaryColor.withValues(alpha: 0.25),
        ),
      ];

  static List<BoxShadow> get sheetShadow => [
        BoxShadow(
          offset: const Offset(0, -6),
          blurRadius: 28.0,
          color: AppColors.primaryDarkColor.withValues(alpha: 0.14),
        ),
      ];

  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.92),
          Color.lerp(Colors.white, AppColors.primaryColor, 0.02)!
              .withValues(alpha: 0.74),
        ],
      );

  static const BorderRadius headerBorderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(AppRadius.card),
    bottomRight: Radius.circular(AppRadius.card),
  );

  static const ShapeBorder headerShape =
      RoundedRectangleBorder(borderRadius: headerBorderRadius);

  static BoxDecoration header({bool rounded = true}) {
    return const BoxDecoration(color: Colors.transparent);
  }

  static Widget headerBackground({bool rounded = true}) {
    return SizedBox.expand(
        child: DecoratedBox(decoration: header(rounded: rounded)));
  }

  static BoxDecoration card({double radius = AppGlass.radius, Color? color}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: color ?? Colors.white,
      border: Border.all(color: hairlineColor, width: 0.5),
      boxShadow: solidShadow,
    );
  }

  static BoxDecoration tile({double radius = AppRadius.md}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: Colors.white,
      border: Border.all(color: hairlineColor, width: 0.5),
    );
  }

  static BoxDecoration headerButton() {
    return BoxDecoration(
      color: headerIconBackground,
      shape: BoxShape.circle,
    );
  }

  static BoxDecoration pill({Color? color, Color? borderColor}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      color: color ?? surface,
      border:
          Border.all(color: borderColor ?? AppGlass.borderColor, width: 1.0),
    );
  }

  static BoxDecoration dialog() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.card),
      gradient: sheetGradient,
      border: Border.all(color: borderColor, width: 1.0),
      boxShadow: shadow,
    );
  }

  static BoxDecoration grabber() {
    return BoxDecoration(
      color: AppColors.primaryDarkColor.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    );
  }

  static BoxDecoration button({bool enable = true}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.md),
      gradient: enable ? activeGradient : null,
      color: enable ? null : AppColors.primaryLightColor,
      boxShadow: enable ? buttonShadow : null,
    );
  }

  static BoxDecoration outlineButton() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.md),
      color: surface,
      border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.4), width: 1.0),
    );
  }

  static BoxDecoration sheet() {
    return BoxDecoration(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      gradient: sheetGradient,
      border: const Border(top: BorderSide(color: Colors.white, width: 1.5)),
      boxShadow: sheetShadow,
    );
  }

  static BoxDecoration background() {
    return const BoxDecoration(gradient: backgroundGradient);
  }

  static InputDecoration input(
      {String? hintText,
      Widget? prefixIcon,
      Widget? suffixIcon,
      EdgeInsetsGeometry? contentPadding,
      double radius = AppRadius.md}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textMutedColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: true,
      filled: true,
      fillColor: surface,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      border: inputBorder(radius: radius),
      enabledBorder: inputBorder(radius: radius),
      disabledBorder: inputBorder(radius: radius),
      focusedBorder: inputBorder(radius: radius, color: AppColors.primaryColor),
    );
  }

  static OutlineInputBorder inputBorder(
      {double radius = AppRadius.md, Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color ?? borderColor, width: 1.0),
    );
  }

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static bool reduceTransparency(BuildContext context) =>
      MediaQuery.maybeHighContrastOf(context) ?? false;
}

class AppSizes {
  static double maxWidth = 0.0;
  static double maxWidthPopup = 0.0;
  static double maxHeight = 0.0;
  static double ultraPadding = 0.0;
  static double maxPadding = 0.0;
  static double minPadding = 0.0;
  static double sizeOnTap = 0.0;
  static double statusBarHeight = 0.0;
  static double bottomHeight = 0.0;
  static double sizeAppBar = 0.0;
  static double screenHeight = 0.0;
  static double border2 = 0.0;
  static double border5 = 0.0;
  static double border4 = 0.0;
  static double border8 = 0.0;
  static double border10 = 0.0;
  static double border15 = 0.0;
  static double border16 = 0.0;
  static double border18 = 0.0;
  static double border24 = 0.0;
  static double titleImageSize = 0.0;
  static double iconSize = 0.0;
  static double dotSize = 0.0;
  static double loadmoreHeight = 0.0;
  static int maximumNumber = 0;
  static double smallButton = 0.0;
  static double totalMax = 0.0;
  static double heightLoadMore = 40.0;
  static double double22 = 22.0;
  static double avatarSize = 0.0;

  static double tabBarHeight = 0.0;

  static init(BuildContext context) {
    maxWidth = MediaQuery.sizeOf(context).width;
    maxWidthPopup = MediaQuery.sizeOf(context).width;
    maxHeight = MediaQuery.sizeOf(context).height;
    statusBarHeight = MediaQuery.paddingOf(context).top;
    bottomHeight = MediaQuery.paddingOf(context).bottom;
    if (AppSizes.isLargeScreen(context)) {
      maxPadding = 20.0;
      minPadding = 15.0;
      // maxWidthPopup = AppSizeWebConfig.maxWidthWeb;
      // maxHeight = 926;
      // avatarSize = maxWidth / 6;
      avatarSize = 100;
    } else {
      maxPadding = maxWidth * 0.05;
      minPadding = maxPadding / 2;
      avatarSize = maxWidth / 4;
    }
    ultraPadding = maxWidth * 0.1;
    sizeOnTap = 48.0;
    // sizeAppBar = statusBarHeight + kToolbarHeight;
    screenHeight = maxHeight - statusBarHeight;
    border2 = 2.0;
    border5 = 5.0;
    border4 = 4.0;
    border8 = 8.0;
    border10 = 10.0;
    border15 = 15.0;
    border16 = 16.0;
    border18 = 18.0;
    border24 = 24.0;
    titleImageSize = 20.0;
    tabBarHeight = 46.0;
    iconSize = 24.0;
    dotSize = 4.0;
    loadmoreHeight = 40.0;
    maximumNumber = 9999999;
    smallButton = 25.0;
    totalMax = 9999999999999.0;
    heightLoadMore = 40.0 + maxPadding;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 800;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 800;
  }

// static bool isMediumScreen(BuildContext context) {
//   return MediaQuery.of(context).size.width >= 800 &&
//       MediaQuery.of(context).size.width <= 1200;
// }
}

class AppTextStyles {
  static TextStyle style12WhiteWeight700Italic = TextStyle(
    fontSize: AppTextSizes.size12,
    color: AppColors.white,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );
  static TextStyle style10WhiteWeight700Italic = TextStyle(
    fontSize: AppTextSizes.size10,
    color: AppColors.white,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );
  static TextStyle style18WhiteBoldItalic = TextStyle(
    fontSize: AppTextSizes.size18,
    color: AppColors.white,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
  );
  static TextStyle style20WhiteWeight700 = TextStyle(
      fontSize: AppTextSizes.size20,
      color: AppColors.white,
      fontWeight: FontWeight.w700);
  static TextStyle style20BlackWeight400 = TextStyle(
      fontSize: AppTextSizes.size20,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style36BlackNormal = TextStyle(
      fontSize: AppTextSizes.size36,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.normal);
  static TextStyle style25WhiteWeight800Italic = TextStyle(
    fontSize: AppTextSizes.size25,
    color: AppColors.white,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
  );
  static TextStyle style26BlackBold = TextStyle(
      fontSize: AppTextSizes.size26,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.bold);
  static TextStyle style25BlackWeight700 = TextStyle(
      fontSize: AppTextSizes.size25,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w700);
  static TextStyle style24BlackBold = TextStyle(
      fontSize: AppTextSizes.size24,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.bold);
  static TextStyle style22BlackBold = TextStyle(
      fontSize: AppTextSizes.size22,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.bold);
  static TextStyle style16BlackBold = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.bold);
  static TextStyle style18BlackBold = TextStyle(
      fontSize: AppTextSizes.size18,
      color: AppColors.textTitleColor,
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
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.normal);
  static TextStyle style15BlackBold = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.bold);
  static TextStyle style15Grey600Normal = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.textSecondaryColor,
      fontWeight: FontWeight.normal);
  static TextStyle style15Red600Normal = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.dangerColor,
      fontWeight: FontWeight.normal);
  static TextStyle style12Grey600Normal = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.textSecondaryColor,
      fontWeight: FontWeight.normal);
  static TextStyle style12Green600Normal = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.green,
      fontWeight: FontWeight.normal);
  static TextStyle style12RedNormal = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.dangerColor,
      fontWeight: FontWeight.normal);
  static TextStyle style12BlackW400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style11BlackW700 = TextStyle(
      fontSize: AppTextSizes.size11,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w700);
  static TextStyle style11PrimaryW400 = TextStyle(
      fontSize: AppTextSizes.size11,
      color: AppColors.primaryColor,
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
    fontStyle: FontStyle.italic,
  );
  static TextStyle style14Black50Weight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style14BlueUnderlineWeight400 = TextStyle(
    fontSize: AppTextSizes.size14,
    color: AppColors.blueColor,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.blueColor,
    fontWeight: FontWeight.w400,
  );
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
      color: AppColors.textMutedColor,
      fontWeight: FontWeight.w400);
  static TextStyle style14reyTabWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.textSecondaryColor,
      fontWeight: FontWeight.w400);
  static TextStyle style14reyTabWeight700 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.textSecondaryColor,
      fontWeight: FontWeight.w700);
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
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w600);
  static TextStyle style14BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w500);
  static TextStyle style14BlackWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style14BlackBold = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.bold);
  static TextStyle style13Black50Weight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13BlueUnderlineWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.blueColor,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.blueColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13BlackBold = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.bold);
  static TextStyle style13BlackWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w500);
  static TextStyle style13BlackWeight600 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w600);
  static TextStyle style13Grey500Weight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textMutedColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13BlackWeight700 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w700);
  static TextStyle style13RedWeight700 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.dangerColor,
      fontWeight: FontWeight.w700);
  static TextStyle style13RedWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.dangerColor,
      fontWeight: FontWeight.w400);
  static TextStyle style14RedWeight400 = TextStyle(
      fontSize: AppTextSizes.size14,
      color: AppColors.dangerColor,
      fontWeight: FontWeight.w400);
  static TextStyle style13Weight400 =
      TextStyle(fontSize: AppTextSizes.size13, fontWeight: FontWeight.w400);
  static TextStyle style13GrayWeight400 = TextStyle(
      fontSize: AppTextSizes.size13,
      color: AppColors.textSecondaryColor,
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
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w500);
  static TextStyle style12DartColorWeight400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style12Grey500ColorWeight400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.textMutedColor,
      fontWeight: FontWeight.w400);
  static TextStyle style11Grey500ColorWeight400 = TextStyle(
      fontSize: AppTextSizes.size11,
      color: AppColors.textMutedColor,
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
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w700);
  static TextStyle style16BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w500);
  static TextStyle style16BlackWeight600 = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w600);
  static TextStyle style16WhiteNormal = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.white,
      fontWeight: FontWeight.normal);
  static TextStyle style16WhiteBold = TextStyle(
      fontSize: AppTextSizes.size16,
      color: AppColors.white,
      fontWeight: FontWeight.bold);
  static TextStyle style20WhiteBold = TextStyle(
      fontSize: AppTextSizes.size20,
      color: AppColors.white,
      fontWeight: FontWeight.bold);
  static TextStyle style10WhiteBold = TextStyle(
      fontSize: AppTextSizes.size10,
      color: AppColors.white,
      fontWeight: FontWeight.bold);
  static TextStyle style10DarkGrayBold = TextStyle(
      fontSize: AppTextSizes.size10,
      color: AppColors.textBodyColor,
      fontWeight: FontWeight.bold);
  static TextStyle style10DarkGrayNormal = TextStyle(
      fontSize: AppTextSizes.size10,
      color: AppColors.textBodyColor,
      fontWeight: FontWeight.normal);
  static TextStyle style10BlueNormal = TextStyle(
      fontSize: AppTextSizes.size10,
      color: AppColors.blueColor,
      fontWeight: FontWeight.normal);
  static TextStyle style12BlackWeight500 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w500);
  static TextStyle style12Black50Weight500 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w500);
  static TextStyle style40Black50Weight600 = TextStyle(
      fontSize: AppTextSizes.size40,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w600);
  static TextStyle style12BlackWeight400 = TextStyle(
      fontSize: AppTextSizes.size12,
      color: AppColors.textTitleColor,
      fontWeight: FontWeight.w400);
  static TextStyle style15BlackWeight700 = TextStyle(
      fontSize: AppTextSizes.size15,
      color: AppColors.textTitleColor,
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
  static double size26 = 26.0;
  static double size28 = 28.0;
  static double size30 = 30.0;
  static double size36 = 36.0;
  static double size40 = 40.0;
}
