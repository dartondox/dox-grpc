// This is a generated file - do not edit.
//
// Generated from src/proto/grpc/testing/test.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'empty.pb.dart' as $0;
import 'messages.pb.dart' as $1;

export 'test.pb.dart';

/// A simple service to test the various types of RPCs and experiment with
/// performance with various types of payload.
@$pb.GrpcServiceName('grpc.testing.TestService')
class TestServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TestServiceClient(super.channel, {super.options, super.interceptors});

  /// One empty request followed by one empty response.
  $grpc.ResponseFuture<$0.Empty> emptyCall(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$emptyCall, request, options: options);
  }

  /// One request followed by one response.
  $grpc.ResponseFuture<$1.SimpleResponse> unaryCall(
    $1.SimpleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unaryCall, request, options: options);
  }

  /// One request followed by one response. Response has cache control
  /// headers set such that a caching HTTP proxy (such as GFE) can
  /// satisfy subsequent requests.
  $grpc.ResponseFuture<$1.SimpleResponse> cacheableUnaryCall(
    $1.SimpleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cacheableUnaryCall, request, options: options);
  }

  /// One request followed by a sequence of responses (streamed download).
  /// The server returns the payload with client desired type and sizes.
  $grpc.ResponseStream<$1.StreamingOutputCallResponse> streamingOutputCall(
    $1.StreamingOutputCallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamingOutputCall, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// A sequence of requests followed by one response (streamed upload).
  /// The server returns the aggregated size of client payload as the result.
  $grpc.ResponseFuture<$1.StreamingInputCallResponse> streamingInputCall(
    $async.Stream<$1.StreamingInputCallRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$streamingInputCall, request, options: options)
        .single;
  }

  /// A sequence of requests with each request served by the server immediately.
  /// As one request could lead to multiple responses, this interface
  /// demonstrates the idea of full duplexing.
  $grpc.ResponseStream<$1.StreamingOutputCallResponse> fullDuplexCall(
    $async.Stream<$1.StreamingOutputCallRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$fullDuplexCall, request, options: options);
  }

  /// A sequence of requests followed by a sequence of responses.
  /// The server buffers all the client requests and then serves them in order. A
  /// stream of responses are returned to the client when the server starts with
  /// first request.
  $grpc.ResponseStream<$1.StreamingOutputCallResponse> halfDuplexCall(
    $async.Stream<$1.StreamingOutputCallRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$halfDuplexCall, request, options: options);
  }

  /// The test server will not implement this method. It will be used
  /// to test the behavior when clients call unimplemented methods.
  $grpc.ResponseFuture<$0.Empty> unimplementedCall(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unimplementedCall, request, options: options);
  }

  // method descriptors

  static final _$emptyCall = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/grpc.testing.TestService/EmptyCall',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$unaryCall =
      $grpc.ClientMethod<$1.SimpleRequest, $1.SimpleResponse>(
          '/grpc.testing.TestService/UnaryCall',
          ($1.SimpleRequest value) => value.writeToBuffer(),
          $1.SimpleResponse.fromBuffer);
  static final _$cacheableUnaryCall =
      $grpc.ClientMethod<$1.SimpleRequest, $1.SimpleResponse>(
          '/grpc.testing.TestService/CacheableUnaryCall',
          ($1.SimpleRequest value) => value.writeToBuffer(),
          $1.SimpleResponse.fromBuffer);
  static final _$streamingOutputCall = $grpc.ClientMethod<
          $1.StreamingOutputCallRequest, $1.StreamingOutputCallResponse>(
      '/grpc.testing.TestService/StreamingOutputCall',
      ($1.StreamingOutputCallRequest value) => value.writeToBuffer(),
      $1.StreamingOutputCallResponse.fromBuffer);
  static final _$streamingInputCall = $grpc.ClientMethod<
          $1.StreamingInputCallRequest, $1.StreamingInputCallResponse>(
      '/grpc.testing.TestService/StreamingInputCall',
      ($1.StreamingInputCallRequest value) => value.writeToBuffer(),
      $1.StreamingInputCallResponse.fromBuffer);
  static final _$fullDuplexCall = $grpc.ClientMethod<
          $1.StreamingOutputCallRequest, $1.StreamingOutputCallResponse>(
      '/grpc.testing.TestService/FullDuplexCall',
      ($1.StreamingOutputCallRequest value) => value.writeToBuffer(),
      $1.StreamingOutputCallResponse.fromBuffer);
  static final _$halfDuplexCall = $grpc.ClientMethod<
          $1.StreamingOutputCallRequest, $1.StreamingOutputCallResponse>(
      '/grpc.testing.TestService/HalfDuplexCall',
      ($1.StreamingOutputCallRequest value) => value.writeToBuffer(),
      $1.StreamingOutputCallResponse.fromBuffer);
  static final _$unimplementedCall = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/grpc.testing.TestService/UnimplementedCall',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
}

@$pb.GrpcServiceName('grpc.testing.TestService')
abstract class TestServiceBase extends $grpc.Service {
  $core.String get $name => 'grpc.testing.TestService';

  TestServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'EmptyCall',
        emptyCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SimpleRequest, $1.SimpleResponse>(
        'UnaryCall',
        unaryCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.SimpleRequest.fromBuffer(value),
        ($1.SimpleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SimpleRequest, $1.SimpleResponse>(
        'CacheableUnaryCall',
        cacheableUnaryCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.SimpleRequest.fromBuffer(value),
        ($1.SimpleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.StreamingOutputCallRequest,
            $1.StreamingOutputCallResponse>(
        'StreamingOutputCall',
        streamingOutputCall_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $1.StreamingOutputCallRequest.fromBuffer(value),
        ($1.StreamingOutputCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.StreamingInputCallRequest,
            $1.StreamingInputCallResponse>(
        'StreamingInputCall',
        streamingInputCall,
        true,
        false,
        ($core.List<$core.int> value) =>
            $1.StreamingInputCallRequest.fromBuffer(value),
        ($1.StreamingInputCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.StreamingOutputCallRequest,
            $1.StreamingOutputCallResponse>(
        'FullDuplexCall',
        fullDuplexCall,
        true,
        true,
        ($core.List<$core.int> value) =>
            $1.StreamingOutputCallRequest.fromBuffer(value),
        ($1.StreamingOutputCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.StreamingOutputCallRequest,
            $1.StreamingOutputCallResponse>(
        'HalfDuplexCall',
        halfDuplexCall,
        true,
        true,
        ($core.List<$core.int> value) =>
            $1.StreamingOutputCallRequest.fromBuffer(value),
        ($1.StreamingOutputCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'UnimplementedCall',
        unimplementedCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> emptyCall_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return emptyCall($call, await $request);
  }

  $async.Future<$0.Empty> emptyCall($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.SimpleResponse> unaryCall_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.SimpleRequest> $request) async {
    return unaryCall($call, await $request);
  }

  $async.Future<$1.SimpleResponse> unaryCall(
      $grpc.ServiceCall call, $1.SimpleRequest request);

  $async.Future<$1.SimpleResponse> cacheableUnaryCall_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.SimpleRequest> $request) async {
    return cacheableUnaryCall($call, await $request);
  }

  $async.Future<$1.SimpleResponse> cacheableUnaryCall(
      $grpc.ServiceCall call, $1.SimpleRequest request);

  $async.Stream<$1.StreamingOutputCallResponse> streamingOutputCall_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$1.StreamingOutputCallRequest> $request) async* {
    yield* streamingOutputCall($call, await $request);
  }

  $async.Stream<$1.StreamingOutputCallResponse> streamingOutputCall(
      $grpc.ServiceCall call, $1.StreamingOutputCallRequest request);

  $async.Future<$1.StreamingInputCallResponse> streamingInputCall(
      $grpc.ServiceCall call,
      $async.Stream<$1.StreamingInputCallRequest> request);

  $async.Stream<$1.StreamingOutputCallResponse> fullDuplexCall(
      $grpc.ServiceCall call,
      $async.Stream<$1.StreamingOutputCallRequest> request);

  $async.Stream<$1.StreamingOutputCallResponse> halfDuplexCall(
      $grpc.ServiceCall call,
      $async.Stream<$1.StreamingOutputCallRequest> request);

  $async.Future<$0.Empty> unimplementedCall_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return unimplementedCall($call, await $request);
  }

  $async.Future<$0.Empty> unimplementedCall(
      $grpc.ServiceCall call, $0.Empty request);
}

/// A simple service NOT implemented at servers so clients can test for
/// that case.
@$pb.GrpcServiceName('grpc.testing.UnimplementedService')
class UnimplementedServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  UnimplementedServiceClient(super.channel,
      {super.options, super.interceptors});

  /// A call that no server should implement
  $grpc.ResponseFuture<$0.Empty> unimplementedCall(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unimplementedCall, request, options: options);
  }

  // method descriptors

  static final _$unimplementedCall = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/grpc.testing.UnimplementedService/UnimplementedCall',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
}

@$pb.GrpcServiceName('grpc.testing.UnimplementedService')
abstract class UnimplementedServiceBase extends $grpc.Service {
  $core.String get $name => 'grpc.testing.UnimplementedService';

  UnimplementedServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'UnimplementedCall',
        unimplementedCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> unimplementedCall_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return unimplementedCall($call, await $request);
  }

  $async.Future<$0.Empty> unimplementedCall(
      $grpc.ServiceCall call, $0.Empty request);
}

/// A service used to control reconnect server.
@$pb.GrpcServiceName('grpc.testing.ReconnectService')
class ReconnectServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ReconnectServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Empty> start(
    $1.ReconnectParams request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$start, request, options: options);
  }

  $grpc.ResponseFuture<$1.ReconnectInfo> stop(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$stop, request, options: options);
  }

  // method descriptors

  static final _$start = $grpc.ClientMethod<$1.ReconnectParams, $0.Empty>(
      '/grpc.testing.ReconnectService/Start',
      ($1.ReconnectParams value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$stop = $grpc.ClientMethod<$0.Empty, $1.ReconnectInfo>(
      '/grpc.testing.ReconnectService/Stop',
      ($0.Empty value) => value.writeToBuffer(),
      $1.ReconnectInfo.fromBuffer);
}

@$pb.GrpcServiceName('grpc.testing.ReconnectService')
abstract class ReconnectServiceBase extends $grpc.Service {
  $core.String get $name => 'grpc.testing.ReconnectService';

  ReconnectServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.ReconnectParams, $0.Empty>(
        'Start',
        start_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.ReconnectParams.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.ReconnectInfo>(
        'Stop',
        stop_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.ReconnectInfo value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> start_Pre($grpc.ServiceCall $call,
      $async.Future<$1.ReconnectParams> $request) async {
    return start($call, await $request);
  }

  $async.Future<$0.Empty> start(
      $grpc.ServiceCall call, $1.ReconnectParams request);

  $async.Future<$1.ReconnectInfo> stop_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return stop($call, await $request);
  }

  $async.Future<$1.ReconnectInfo> stop(
      $grpc.ServiceCall call, $0.Empty request);
}

/// A service used to obtain stats for verifying LB behavior.
@$pb.GrpcServiceName('grpc.testing.LoadBalancerStatsService')
class LoadBalancerStatsServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  LoadBalancerStatsServiceClient(super.channel,
      {super.options, super.interceptors});

  /// Gets the backend distribution for RPCs sent by a test client.
  $grpc.ResponseFuture<$1.LoadBalancerStatsResponse> getClientStats(
    $1.LoadBalancerStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getClientStats, request, options: options);
  }

  /// Gets the accumulated stats for RPCs sent by a test client.
  $grpc.ResponseFuture<$1.LoadBalancerAccumulatedStatsResponse>
      getClientAccumulatedStats(
    $1.LoadBalancerAccumulatedStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getClientAccumulatedStats, request,
        options: options);
  }

  // method descriptors

  static final _$getClientStats = $grpc.ClientMethod<
          $1.LoadBalancerStatsRequest, $1.LoadBalancerStatsResponse>(
      '/grpc.testing.LoadBalancerStatsService/GetClientStats',
      ($1.LoadBalancerStatsRequest value) => value.writeToBuffer(),
      $1.LoadBalancerStatsResponse.fromBuffer);
  static final _$getClientAccumulatedStats = $grpc.ClientMethod<
          $1.LoadBalancerAccumulatedStatsRequest,
          $1.LoadBalancerAccumulatedStatsResponse>(
      '/grpc.testing.LoadBalancerStatsService/GetClientAccumulatedStats',
      ($1.LoadBalancerAccumulatedStatsRequest value) => value.writeToBuffer(),
      $1.LoadBalancerAccumulatedStatsResponse.fromBuffer);
}

@$pb.GrpcServiceName('grpc.testing.LoadBalancerStatsService')
abstract class LoadBalancerStatsServiceBase extends $grpc.Service {
  $core.String get $name => 'grpc.testing.LoadBalancerStatsService';

  LoadBalancerStatsServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.LoadBalancerStatsRequest,
            $1.LoadBalancerStatsResponse>(
        'GetClientStats',
        getClientStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.LoadBalancerStatsRequest.fromBuffer(value),
        ($1.LoadBalancerStatsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.LoadBalancerAccumulatedStatsRequest,
            $1.LoadBalancerAccumulatedStatsResponse>(
        'GetClientAccumulatedStats',
        getClientAccumulatedStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.LoadBalancerAccumulatedStatsRequest.fromBuffer(value),
        ($1.LoadBalancerAccumulatedStatsResponse value) =>
            value.writeToBuffer()));
  }

  $async.Future<$1.LoadBalancerStatsResponse> getClientStats_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$1.LoadBalancerStatsRequest> $request) async {
    return getClientStats($call, await $request);
  }

  $async.Future<$1.LoadBalancerStatsResponse> getClientStats(
      $grpc.ServiceCall call, $1.LoadBalancerStatsRequest request);

  $async.Future<$1.LoadBalancerAccumulatedStatsResponse>
      getClientAccumulatedStats_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$1.LoadBalancerAccumulatedStatsRequest>
              $request) async {
    return getClientAccumulatedStats($call, await $request);
  }

  $async.Future<$1.LoadBalancerAccumulatedStatsResponse>
      getClientAccumulatedStats($grpc.ServiceCall call,
          $1.LoadBalancerAccumulatedStatsRequest request);
}

/// Hook service. Used to keep Kubernetes from shutting the pod down.
@$pb.GrpcServiceName('grpc.testing.HookService')
class HookServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  HookServiceClient(super.channel, {super.options, super.interceptors});

  /// Sends a request that will "hang" until the return status is set by a call
  /// to a SetReturnStatus
  $grpc.ResponseFuture<$0.Empty> hook(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$hook, request, options: options);
  }

  /// Sets a return status for pending and upcoming calls to Hook
  $grpc.ResponseFuture<$0.Empty> setReturnStatus(
    $1.SetReturnStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setReturnStatus, request, options: options);
  }

  /// Clears the return status. Incoming calls to Hook will "hang"
  $grpc.ResponseFuture<$0.Empty> clearReturnStatus(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clearReturnStatus, request, options: options);
  }

  // method descriptors

  static final _$hook = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/grpc.testing.HookService/Hook',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$setReturnStatus =
      $grpc.ClientMethod<$1.SetReturnStatusRequest, $0.Empty>(
          '/grpc.testing.HookService/SetReturnStatus',
          ($1.SetReturnStatusRequest value) => value.writeToBuffer(),
          $0.Empty.fromBuffer);
  static final _$clearReturnStatus = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/grpc.testing.HookService/ClearReturnStatus',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
}

@$pb.GrpcServiceName('grpc.testing.HookService')
abstract class HookServiceBase extends $grpc.Service {
  $core.String get $name => 'grpc.testing.HookService';

  HookServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'Hook',
        hook_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SetReturnStatusRequest, $0.Empty>(
        'SetReturnStatus',
        setReturnStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.SetReturnStatusRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'ClearReturnStatus',
        clearReturnStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> hook_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return hook($call, await $request);
  }

  $async.Future<$0.Empty> hook($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Empty> setReturnStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$1.SetReturnStatusRequest> $request) async {
    return setReturnStatus($call, await $request);
  }

  $async.Future<$0.Empty> setReturnStatus(
      $grpc.ServiceCall call, $1.SetReturnStatusRequest request);

  $async.Future<$0.Empty> clearReturnStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return clearReturnStatus($call, await $request);
  }

  $async.Future<$0.Empty> clearReturnStatus(
      $grpc.ServiceCall call, $0.Empty request);
}

/// A service to remotely control health status of an xDS test server.
@$pb.GrpcServiceName('grpc.testing.XdsUpdateHealthService')
class XdsUpdateHealthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  XdsUpdateHealthServiceClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Empty> setServing(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setServing, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> setNotServing(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setNotServing, request, options: options);
  }

  $grpc.ResponseFuture<$1.HookResponse> sendHookRequest(
    $1.HookRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendHookRequest, request, options: options);
  }

  // method descriptors

  static final _$setServing = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/grpc.testing.XdsUpdateHealthService/SetServing',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$setNotServing = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/grpc.testing.XdsUpdateHealthService/SetNotServing',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$sendHookRequest =
      $grpc.ClientMethod<$1.HookRequest, $1.HookResponse>(
          '/grpc.testing.XdsUpdateHealthService/SendHookRequest',
          ($1.HookRequest value) => value.writeToBuffer(),
          $1.HookResponse.fromBuffer);
}

@$pb.GrpcServiceName('grpc.testing.XdsUpdateHealthService')
abstract class XdsUpdateHealthServiceBase extends $grpc.Service {
  $core.String get $name => 'grpc.testing.XdsUpdateHealthService';

  XdsUpdateHealthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'SetServing',
        setServing_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'SetNotServing',
        setNotServing_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.HookRequest, $1.HookResponse>(
        'SendHookRequest',
        sendHookRequest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.HookRequest.fromBuffer(value),
        ($1.HookResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> setServing_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return setServing($call, await $request);
  }

  $async.Future<$0.Empty> setServing($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Empty> setNotServing_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return setNotServing($call, await $request);
  }

  $async.Future<$0.Empty> setNotServing(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.HookResponse> sendHookRequest_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.HookRequest> $request) async {
    return sendHookRequest($call, await $request);
  }

  $async.Future<$1.HookResponse> sendHookRequest(
      $grpc.ServiceCall call, $1.HookRequest request);
}

/// A service to dynamically update the configuration of an xDS test client.
@$pb.GrpcServiceName('grpc.testing.XdsUpdateClientConfigureService')
class XdsUpdateClientConfigureServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  XdsUpdateClientConfigureServiceClient(super.channel,
      {super.options, super.interceptors});

  /// Update the tes client's configuration.
  $grpc.ResponseFuture<$1.ClientConfigureResponse> configure(
    $1.ClientConfigureRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$configure, request, options: options);
  }

  // method descriptors

  static final _$configure =
      $grpc.ClientMethod<$1.ClientConfigureRequest, $1.ClientConfigureResponse>(
          '/grpc.testing.XdsUpdateClientConfigureService/Configure',
          ($1.ClientConfigureRequest value) => value.writeToBuffer(),
          $1.ClientConfigureResponse.fromBuffer);
}

@$pb.GrpcServiceName('grpc.testing.XdsUpdateClientConfigureService')
abstract class XdsUpdateClientConfigureServiceBase extends $grpc.Service {
  $core.String get $name => 'grpc.testing.XdsUpdateClientConfigureService';

  XdsUpdateClientConfigureServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.ClientConfigureRequest,
            $1.ClientConfigureResponse>(
        'Configure',
        configure_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.ClientConfigureRequest.fromBuffer(value),
        ($1.ClientConfigureResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.ClientConfigureResponse> configure_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$1.ClientConfigureRequest> $request) async {
    return configure($call, await $request);
  }

  $async.Future<$1.ClientConfigureResponse> configure(
      $grpc.ServiceCall call, $1.ClientConfigureRequest request);
}
