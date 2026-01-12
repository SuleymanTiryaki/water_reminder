
import 'package:flutter/services.dart';
import 'package:waterreminder/constant/constant.dart';

class PlatformMessenger {
  PlatformMessenger._();
  static const _platformCahnnel = MethodChannel(Constant.platformChannelName);

  static void invokeMethod(String method, [dynamic arguments]) {
    _platformCahnnel.invokeMethod(method, arguments).catchError((error) {
      // iOS'ta native kod olmadığı için sessizce geç
      // Android'de çalışacak
    });
  }

  static void setMethodCallHandler(Future<dynamic> Function(MethodCall) call) {
    _platformCahnnel.setMethodCallHandler(call);
  }
}
