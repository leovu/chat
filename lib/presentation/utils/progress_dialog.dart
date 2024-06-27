library progress_dialog;

import 'package:chat/common/custom_navigator.dart';
import 'package:chat/common/theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';

const int MAX_TIME = 90;

class ProgressDialog {
  bool _isShowing = false;
  Timer? _timer;
  BuildContext buildContext;
  bool isWarning;

  ProgressDialog(this.buildContext, {this.isWarning = false});

  show() {
    _showDialog();
    _isShowing = true;
    startTimer();
  }

  startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timer.tick > MAX_TIME) {
        _timer!.cancel();
        await hide();
      }
    });
  }

  stopTimer() {
    if (_timer != null&&_timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }

  bool isShowing() {
    return _isShowing;
  }

  hide() {
    _isShowing = false;
    if(buildContext.mounted) {
      CustomNavigator.pop(buildContext);
    }
    stopTimer();
  }

  _showDialog() {
    Navigator.of(buildContext, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        settings: const RouteSettings(name: AppKeys.keyHUD),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.3),
              body: SizedBox(
                height: MediaQuery.sizeOf(context).height,
                child: const Center(child: CircularProgressIndicator()
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
