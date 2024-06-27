import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

abstract class BaseBloc{
  late BuildContext _context;

  setContext(BuildContext context) => _context = context;
  BuildContext get context => _context;

  set(BehaviorSubject<dynamic> stream, dynamic event){
    if(!stream.isClosed) {
      stream.sink.add(event);
    }
  }

  setError(BehaviorSubject<dynamic> stream, dynamic event){
    if(!stream.isClosed) {
      stream.sink.addError(event);
    }
  }

  @protected
  @mustCallSuper
  void dispose(){

  }
}