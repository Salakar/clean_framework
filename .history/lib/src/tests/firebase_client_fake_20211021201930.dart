import 'dart:async';
import 'package:mocktail/mocktail.dart';

import 'package:clean_framework/src/defaults/providers/firebase/firebase_client.dart';

class FirebaseClientFake extends Mock implements FirebaseClient {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  late Map<String, dynamic> _content;
  FirebaseClientFake(_content);

  @override
  Future<void> delete(
      {required String path, required String id, BatchKey? batchKey}) async {}

  @override
  Future<Map<String, dynamic>> read(
      {required String path, required String id}) async {
    return _content;
  }

  @override
  Future<Map<String, dynamic>> readAll({required String path}) async {
    return _content;
  }

  @override
  Future<void> update(
      {required String path,
      required Map<String, dynamic> content,
      required String id,
      BatchKey? batchKey}) async {}

  @override
  Stream<Map<String, dynamic>> watch(
      {required String path, required String id}) {
    Future.delayed(
        Duration(milliseconds: 100), () => _controller.sink.add(_content));
    return _controller.stream;
  }

  @override
  Stream<Map<String, dynamic>> watchAll({required String path}) {
    Future.delayed(
        Duration(milliseconds: 100), () => _controller.sink.add(_content));
    return _controller.stream;
  }

  @override
  Future<String> write(
      {required String path,
      required Map<String, dynamic> content,
      String? id,
      BatchKey? batchKey}) async {
    content['content'] = content;
    return 'id';
  }

  @override
  void createQuery(String path, SnapshotQuery<Map<String, dynamic>> query) {}

  @override
  clearQuery() {}

  void dispose() {
    _controller.close();
  }
}