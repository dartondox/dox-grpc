import 'package:protobuf/protobuf.dart';

/// The 17 gRPC status codes.
enum GrpcStatus {
  ok(0),
  cancelled(1),
  unknown(2),
  invalidArgument(3),
  deadlineExceeded(4),
  notFound(5),
  alreadyExists(6),
  permissionDenied(7),
  resourceExhausted(8),
  failedPrecondition(9),
  aborted(10),
  outOfRange(11),
  unimplemented(12),
  internal(13),
  unavailable(14),
  dataLoss(15),
  unauthenticated(16);

  const GrpcStatus(this.code);

  /// the number sent in `grpc-status`
  final int code;

  /// The status for [code]. A code that is not known is [unknown], as the
  /// gRPC spec says.
  static GrpcStatus fromCode(int code) {
    if (code < 0 || code >= values.length) return unknown;
    return values[code];
  }
}

/// Throw it in a service method to end the call with [status].
///
/// [message] goes to the client in `grpc-message`. [details] are protobuf
/// messages (eg. from `google/rpc/error_details.proto`) that go to the
/// client in `grpc-status-details-bin`.
/// ```
/// throw GrpcException(GrpcStatus.notFound, 'No user 5');
/// ```
class GrpcException implements Exception {
  GrpcException(
    this.status, [
    this.message,
    this.details = const <GeneratedMessage>[],
  ]);

  final GrpcStatus status;
  final String? message;
  final List<GeneratedMessage> details;

  @override
  String toString() => 'GrpcException(${status.name}: $message)';
}
