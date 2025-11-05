class ErrorDataException implements Exception {
  final String message;

  ErrorDataException({required this.message});

  @override
  String toString() => message;
}
