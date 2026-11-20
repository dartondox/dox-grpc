/// Limits and compression of the calls of one service.
class GrpcOptions {
  const GrpcOptions({
    this.maxReceiveMessageSize = 4 * 1024 * 1024,
    this.maxSendMessageSize = 4 * 1024 * 1024,
    this.gzipResponses = false,
    this.idleTimeout,
  });

  /// The largest request message, in bytes (also after unzip). A bigger
  /// one ends the call with `RESOURCE_EXHAUSTED`. Default 4 MiB, like
  /// other gRPC servers.
  final int maxReceiveMessageSize;

  /// The largest response message, in bytes. A bigger one ends the call
  /// with `RESOURCE_EXHAUSTED`. Default 4 MiB.
  final int maxSendMessageSize;

  /// Zip the response messages with gzip when the client accepts it
  /// (`grpc-accept-encoding`). Off by default: it costs CPU on each
  /// message, and most gRPC messages are small. Requests in gzip are
  /// always read.
  final bool gzipResponses;

  /// End a call that has no message in or out for this long, with
  /// `DEADLINE_EXCEEDED`. It frees a call of a client that never reads
  /// the answer, or a request that never ends. Off by default (null).
  ///
  /// The time also counts while your handler works and sends nothing, so
  /// set it longer than your slowest quiet handler. For example
  /// `Duration(minutes: 5)`. The deadline of the client
  /// (`grpc-timeout`) is separate and always works.
  final Duration? idleTimeout;
}
