class RestoreResult {
  final bool success;
  final String? errorMessage;
  final int? clientsCount;

  RestoreResult({
    required this.success,
    this.errorMessage,
    this.clientsCount,
  });
}
