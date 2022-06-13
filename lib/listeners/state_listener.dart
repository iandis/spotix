import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class StateListener<T> {
  const StateListener();

  Stream<T> get onChanged;

  T get currentValue;

  @protected
  void onError(Object error, StackTrace? stackTrace);

  @mustCallSuper
  void dispose();
}
