import 'dart:async';

void main() async {
  Future<String> fetchSomething(bool fail) async {
    if (fail) throw Exception('failed');
    return 'success';
  }

  final futures = [
    fetchSomething(false).then<String?>((s) => s).catchError((_) => null),
    fetchSomething(true).then<String?>((s) => s).catchError((_) => null),
  ];
  
  final results = await Future.wait(futures);
  final filtered = results.whereType<String>().toList();
  print(filtered);
}
