abstract class AppException implements Exception {
  String toString() {
    return runtimeType.toString() + ": " + describe();
  }

  String describe();
}