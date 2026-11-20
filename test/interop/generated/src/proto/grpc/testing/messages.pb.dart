// This is a generated file - do not edit.
//
// Generated from src/proto/grpc/testing/messages.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'messages.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'messages.pbenum.dart';

/// TODO(dgq): Go back to using well-known types once
/// https://github.com/grpc/grpc/issues/6980 has been fixed.
/// import "google/protobuf/wrappers.proto";
class BoolValue extends $pb.GeneratedMessage {
  factory BoolValue({
    $core.bool? value,
  }) {
    final result = BoolValue._();
    if (value != null) result.value = value;
    return result;
  }

  BoolValue._();

  factory BoolValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoolValue()..mergeFromBuffer(data, registry);
  factory BoolValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoolValue()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoolValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: BoolValue.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolValue copyWith(void Function(BoolValue) updates) =>
      super.copyWith((message) => updates(message as BoolValue)) as BoolValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoolValue() / BoolValue.new instead')
  static BoolValue create() => BoolValue._();
  static $pb.GeneratedMessage $_createMessage() => BoolValue._();
  @$core.override
  BoolValue createEmptyInstance() => BoolValue._();
  @$core.pragma('dart2js:noInline')
  static BoolValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoolValue>(BoolValue.$_createMessage);
  static BoolValue? _defaultInstance;

  /// The bool value.
  @$pb.TagNumber(1)
  $core.bool get value => $_getBF(0);
  @$pb.TagNumber(1)
  set value($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

/// A block of data, to simply increase gRPC message size.
class Payload extends $pb.GeneratedMessage {
  factory Payload({
    PayloadType? type,
    $core.List<$core.int>? body,
  }) {
    final result = Payload._();
    if (type != null) result.type = type;
    if (body != null) result.body = body;
    return result;
  }

  Payload._();

  factory Payload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Payload()..mergeFromBuffer(data, registry);
  factory Payload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Payload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Payload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: Payload.$_createMessage)
    ..aE<PayloadType>(1, _omitFieldNames ? '' : 'type',
        enumValues: PayloadType.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'body', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Payload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Payload copyWith(void Function(Payload) updates) =>
      super.copyWith((message) => updates(message as Payload)) as Payload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Payload() / Payload.new instead')
  static Payload create() => Payload._();
  static $pb.GeneratedMessage $_createMessage() => Payload._();
  @$core.override
  Payload createEmptyInstance() => Payload._();
  @$core.pragma('dart2js:noInline')
  static Payload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Payload>(Payload.$_createMessage);
  static Payload? _defaultInstance;

  /// The type of data in body.
  @$pb.TagNumber(1)
  PayloadType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(PayloadType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  /// Primary contents of payload.
  @$pb.TagNumber(2)
  $core.List<$core.int> get body => $_getN(1);
  @$pb.TagNumber(2)
  set body($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);
}

/// A protobuf representation for grpc status. This is used by test
/// clients to specify a status that the server should attempt to return.
class EchoStatus extends $pb.GeneratedMessage {
  factory EchoStatus({
    $core.int? code,
    $core.String? message,
  }) {
    final result = EchoStatus._();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  EchoStatus._();

  factory EchoStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EchoStatus()..mergeFromBuffer(data, registry);
  factory EchoStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EchoStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EchoStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: EchoStatus.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EchoStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EchoStatus copyWith(void Function(EchoStatus) updates) =>
      super.copyWith((message) => updates(message as EchoStatus)) as EchoStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EchoStatus() / EchoStatus.new instead')
  static EchoStatus create() => EchoStatus._();
  static $pb.GeneratedMessage $_createMessage() => EchoStatus._();
  @$core.override
  EchoStatus createEmptyInstance() => EchoStatus._();
  @$core.pragma('dart2js:noInline')
  static EchoStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EchoStatus>(EchoStatus.$_createMessage);
  static EchoStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// Unary request.
class SimpleRequest extends $pb.GeneratedMessage {
  factory SimpleRequest({
    PayloadType? responseType,
    $core.int? responseSize,
    Payload? payload,
    $core.bool? fillUsername,
    $core.bool? fillOauthScope,
    BoolValue? responseCompressed,
    EchoStatus? responseStatus,
    BoolValue? expectCompressed,
    $core.bool? fillServerId,
    $core.bool? fillGrpclbRouteType,
    TestOrcaReport? orcaPerQueryReport,
  }) {
    final result = SimpleRequest._();
    if (responseType != null) result.responseType = responseType;
    if (responseSize != null) result.responseSize = responseSize;
    if (payload != null) result.payload = payload;
    if (fillUsername != null) result.fillUsername = fillUsername;
    if (fillOauthScope != null) result.fillOauthScope = fillOauthScope;
    if (responseCompressed != null)
      result.responseCompressed = responseCompressed;
    if (responseStatus != null) result.responseStatus = responseStatus;
    if (expectCompressed != null) result.expectCompressed = expectCompressed;
    if (fillServerId != null) result.fillServerId = fillServerId;
    if (fillGrpclbRouteType != null)
      result.fillGrpclbRouteType = fillGrpclbRouteType;
    if (orcaPerQueryReport != null)
      result.orcaPerQueryReport = orcaPerQueryReport;
    return result;
  }

  SimpleRequest._();

  factory SimpleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SimpleRequest()..mergeFromBuffer(data, registry);
  factory SimpleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SimpleRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimpleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: SimpleRequest.$_createMessage)
    ..aE<PayloadType>(1, _omitFieldNames ? '' : 'responseType',
        enumValues: PayloadType.values)
    ..aI(2, _omitFieldNames ? '' : 'responseSize')
    ..aOM<Payload>(3, _omitFieldNames ? '' : 'payload',
        subBuilder: Payload.$_createMessage)
    ..aOB(4, _omitFieldNames ? '' : 'fillUsername')
    ..aOB(5, _omitFieldNames ? '' : 'fillOauthScope')
    ..aOM<BoolValue>(6, _omitFieldNames ? '' : 'responseCompressed',
        subBuilder: BoolValue.$_createMessage)
    ..aOM<EchoStatus>(7, _omitFieldNames ? '' : 'responseStatus',
        subBuilder: EchoStatus.$_createMessage)
    ..aOM<BoolValue>(8, _omitFieldNames ? '' : 'expectCompressed',
        subBuilder: BoolValue.$_createMessage)
    ..aOB(9, _omitFieldNames ? '' : 'fillServerId')
    ..aOB(10, _omitFieldNames ? '' : 'fillGrpclbRouteType')
    ..aOM<TestOrcaReport>(11, _omitFieldNames ? '' : 'orcaPerQueryReport',
        subBuilder: TestOrcaReport.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimpleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimpleRequest copyWith(void Function(SimpleRequest) updates) =>
      super.copyWith((message) => updates(message as SimpleRequest))
          as SimpleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SimpleRequest() / SimpleRequest.new instead')
  static SimpleRequest create() => SimpleRequest._();
  static $pb.GeneratedMessage $_createMessage() => SimpleRequest._();
  @$core.override
  SimpleRequest createEmptyInstance() => SimpleRequest._();
  @$core.pragma('dart2js:noInline')
  static SimpleRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SimpleRequest>(
          SimpleRequest.$_createMessage);
  static SimpleRequest? _defaultInstance;

  /// Desired payload type in the response from the server.
  /// If response_type is RANDOM, server randomly chooses one from other formats.
  @$pb.TagNumber(1)
  PayloadType get responseType => $_getN(0);
  @$pb.TagNumber(1)
  set responseType(PayloadType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasResponseType() => $_has(0);
  @$pb.TagNumber(1)
  void clearResponseType() => $_clearField(1);

  /// Desired payload size in the response from the server.
  @$pb.TagNumber(2)
  $core.int get responseSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set responseSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasResponseSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearResponseSize() => $_clearField(2);

  /// Optional input payload sent along with the request.
  @$pb.TagNumber(3)
  Payload get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload(Payload value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);
  @$pb.TagNumber(3)
  Payload ensurePayload() => $_ensure(2);

  /// Whether SimpleResponse should include username.
  @$pb.TagNumber(4)
  $core.bool get fillUsername => $_getBF(3);
  @$pb.TagNumber(4)
  set fillUsername($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFillUsername() => $_has(3);
  @$pb.TagNumber(4)
  void clearFillUsername() => $_clearField(4);

  /// Whether SimpleResponse should include OAuth scope.
  @$pb.TagNumber(5)
  $core.bool get fillOauthScope => $_getBF(4);
  @$pb.TagNumber(5)
  set fillOauthScope($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFillOauthScope() => $_has(4);
  @$pb.TagNumber(5)
  void clearFillOauthScope() => $_clearField(5);

  /// Whether to request the server to compress the response. This field is
  /// "nullable" in order to interoperate seamlessly with clients not able to
  /// implement the full compression tests by introspecting the call to verify
  /// the response's compression status.
  @$pb.TagNumber(6)
  BoolValue get responseCompressed => $_getN(5);
  @$pb.TagNumber(6)
  set responseCompressed(BoolValue value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasResponseCompressed() => $_has(5);
  @$pb.TagNumber(6)
  void clearResponseCompressed() => $_clearField(6);
  @$pb.TagNumber(6)
  BoolValue ensureResponseCompressed() => $_ensure(5);

  /// Whether server should return a given status
  @$pb.TagNumber(7)
  EchoStatus get responseStatus => $_getN(6);
  @$pb.TagNumber(7)
  set responseStatus(EchoStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasResponseStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearResponseStatus() => $_clearField(7);
  @$pb.TagNumber(7)
  EchoStatus ensureResponseStatus() => $_ensure(6);

  /// Whether the server should expect this request to be compressed.
  @$pb.TagNumber(8)
  BoolValue get expectCompressed => $_getN(7);
  @$pb.TagNumber(8)
  set expectCompressed(BoolValue value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasExpectCompressed() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpectCompressed() => $_clearField(8);
  @$pb.TagNumber(8)
  BoolValue ensureExpectCompressed() => $_ensure(7);

  /// Whether SimpleResponse should include server_id.
  @$pb.TagNumber(9)
  $core.bool get fillServerId => $_getBF(8);
  @$pb.TagNumber(9)
  set fillServerId($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFillServerId() => $_has(8);
  @$pb.TagNumber(9)
  void clearFillServerId() => $_clearField(9);

  /// Whether SimpleResponse should include grpclb_route_type.
  @$pb.TagNumber(10)
  $core.bool get fillGrpclbRouteType => $_getBF(9);
  @$pb.TagNumber(10)
  set fillGrpclbRouteType($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFillGrpclbRouteType() => $_has(9);
  @$pb.TagNumber(10)
  void clearFillGrpclbRouteType() => $_clearField(10);

  /// If set the server should record this metrics report data for the current RPC.
  @$pb.TagNumber(11)
  TestOrcaReport get orcaPerQueryReport => $_getN(10);
  @$pb.TagNumber(11)
  set orcaPerQueryReport(TestOrcaReport value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasOrcaPerQueryReport() => $_has(10);
  @$pb.TagNumber(11)
  void clearOrcaPerQueryReport() => $_clearField(11);
  @$pb.TagNumber(11)
  TestOrcaReport ensureOrcaPerQueryReport() => $_ensure(10);
}

/// Unary response, as configured by the request.
class SimpleResponse extends $pb.GeneratedMessage {
  factory SimpleResponse({
    Payload? payload,
    $core.String? username,
    $core.String? oauthScope,
    $core.String? serverId,
    GrpclbRouteType? grpclbRouteType,
    $core.String? hostname,
  }) {
    final result = SimpleResponse._();
    if (payload != null) result.payload = payload;
    if (username != null) result.username = username;
    if (oauthScope != null) result.oauthScope = oauthScope;
    if (serverId != null) result.serverId = serverId;
    if (grpclbRouteType != null) result.grpclbRouteType = grpclbRouteType;
    if (hostname != null) result.hostname = hostname;
    return result;
  }

  SimpleResponse._();

  factory SimpleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SimpleResponse()..mergeFromBuffer(data, registry);
  factory SimpleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SimpleResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimpleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: SimpleResponse.$_createMessage)
    ..aOM<Payload>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: Payload.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'oauthScope')
    ..aOS(4, _omitFieldNames ? '' : 'serverId')
    ..aE<GrpclbRouteType>(5, _omitFieldNames ? '' : 'grpclbRouteType',
        enumValues: GrpclbRouteType.values)
    ..aOS(6, _omitFieldNames ? '' : 'hostname')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimpleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimpleResponse copyWith(void Function(SimpleResponse) updates) =>
      super.copyWith((message) => updates(message as SimpleResponse))
          as SimpleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SimpleResponse() / SimpleResponse.new instead')
  static SimpleResponse create() => SimpleResponse._();
  static $pb.GeneratedMessage $_createMessage() => SimpleResponse._();
  @$core.override
  SimpleResponse createEmptyInstance() => SimpleResponse._();
  @$core.pragma('dart2js:noInline')
  static SimpleResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SimpleResponse>(
          SimpleResponse.$_createMessage);
  static SimpleResponse? _defaultInstance;

  /// Payload to increase message size.
  @$pb.TagNumber(1)
  Payload get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload(Payload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  Payload ensurePayload() => $_ensure(0);

  /// The user the request came from, for verifying authentication was
  /// successful when the client expected it.
  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  /// OAuth scope.
  @$pb.TagNumber(3)
  $core.String get oauthScope => $_getSZ(2);
  @$pb.TagNumber(3)
  set oauthScope($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOauthScope() => $_has(2);
  @$pb.TagNumber(3)
  void clearOauthScope() => $_clearField(3);

  /// Server ID. This must be unique among different server instances,
  /// but the same across all RPC's made to a particular server instance.
  @$pb.TagNumber(4)
  $core.String get serverId => $_getSZ(3);
  @$pb.TagNumber(4)
  set serverId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasServerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearServerId() => $_clearField(4);

  /// gRPCLB Path.
  @$pb.TagNumber(5)
  GrpclbRouteType get grpclbRouteType => $_getN(4);
  @$pb.TagNumber(5)
  set grpclbRouteType(GrpclbRouteType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasGrpclbRouteType() => $_has(4);
  @$pb.TagNumber(5)
  void clearGrpclbRouteType() => $_clearField(5);

  /// Server hostname.
  @$pb.TagNumber(6)
  $core.String get hostname => $_getSZ(5);
  @$pb.TagNumber(6)
  set hostname($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHostname() => $_has(5);
  @$pb.TagNumber(6)
  void clearHostname() => $_clearField(6);
}

/// Client-streaming request.
class StreamingInputCallRequest extends $pb.GeneratedMessage {
  factory StreamingInputCallRequest({
    Payload? payload,
    BoolValue? expectCompressed,
  }) {
    final result = StreamingInputCallRequest._();
    if (payload != null) result.payload = payload;
    if (expectCompressed != null) result.expectCompressed = expectCompressed;
    return result;
  }

  StreamingInputCallRequest._();

  factory StreamingInputCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingInputCallRequest()..mergeFromBuffer(data, registry);
  factory StreamingInputCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingInputCallRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamingInputCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: StreamingInputCallRequest.$_createMessage)
    ..aOM<Payload>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: Payload.$_createMessage)
    ..aOM<BoolValue>(2, _omitFieldNames ? '' : 'expectCompressed',
        subBuilder: BoolValue.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingInputCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingInputCallRequest copyWith(
          void Function(StreamingInputCallRequest) updates) =>
      super.copyWith((message) => updates(message as StreamingInputCallRequest))
          as StreamingInputCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use StreamingInputCallRequest() / StreamingInputCallRequest.new instead')
  static StreamingInputCallRequest create() => StreamingInputCallRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      StreamingInputCallRequest._();
  @$core.override
  StreamingInputCallRequest createEmptyInstance() =>
      StreamingInputCallRequest._();
  @$core.pragma('dart2js:noInline')
  static StreamingInputCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamingInputCallRequest>(
          StreamingInputCallRequest.$_createMessage);
  static StreamingInputCallRequest? _defaultInstance;

  /// Optional input payload sent along with the request.
  @$pb.TagNumber(1)
  Payload get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload(Payload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  Payload ensurePayload() => $_ensure(0);

  /// Whether the server should expect this request to be compressed. This field
  /// is "nullable" in order to interoperate seamlessly with servers not able to
  /// implement the full compression tests by introspecting the call to verify
  /// the request's compression status.
  @$pb.TagNumber(2)
  BoolValue get expectCompressed => $_getN(1);
  @$pb.TagNumber(2)
  set expectCompressed(BoolValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectCompressed() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectCompressed() => $_clearField(2);
  @$pb.TagNumber(2)
  BoolValue ensureExpectCompressed() => $_ensure(1);
}

/// Client-streaming response.
class StreamingInputCallResponse extends $pb.GeneratedMessage {
  factory StreamingInputCallResponse({
    $core.int? aggregatedPayloadSize,
  }) {
    final result = StreamingInputCallResponse._();
    if (aggregatedPayloadSize != null)
      result.aggregatedPayloadSize = aggregatedPayloadSize;
    return result;
  }

  StreamingInputCallResponse._();

  factory StreamingInputCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingInputCallResponse()..mergeFromBuffer(data, registry);
  factory StreamingInputCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingInputCallResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamingInputCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: StreamingInputCallResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'aggregatedPayloadSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingInputCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingInputCallResponse copyWith(
          void Function(StreamingInputCallResponse) updates) =>
      super.copyWith(
              (message) => updates(message as StreamingInputCallResponse))
          as StreamingInputCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use StreamingInputCallResponse() / StreamingInputCallResponse.new instead')
  static StreamingInputCallResponse create() => StreamingInputCallResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      StreamingInputCallResponse._();
  @$core.override
  StreamingInputCallResponse createEmptyInstance() =>
      StreamingInputCallResponse._();
  @$core.pragma('dart2js:noInline')
  static StreamingInputCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamingInputCallResponse>(
          StreamingInputCallResponse.$_createMessage);
  static StreamingInputCallResponse? _defaultInstance;

  /// Aggregated size of payloads received from the client.
  @$pb.TagNumber(1)
  $core.int get aggregatedPayloadSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set aggregatedPayloadSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAggregatedPayloadSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearAggregatedPayloadSize() => $_clearField(1);
}

/// Configuration for a particular response.
class ResponseParameters extends $pb.GeneratedMessage {
  factory ResponseParameters({
    $core.int? size,
    $core.int? intervalUs,
    BoolValue? compressed,
    BoolValue? fillPeerSocketAddress,
  }) {
    final result = ResponseParameters._();
    if (size != null) result.size = size;
    if (intervalUs != null) result.intervalUs = intervalUs;
    if (compressed != null) result.compressed = compressed;
    if (fillPeerSocketAddress != null)
      result.fillPeerSocketAddress = fillPeerSocketAddress;
    return result;
  }

  ResponseParameters._();

  factory ResponseParameters.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResponseParameters()..mergeFromBuffer(data, registry);
  factory ResponseParameters.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResponseParameters()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseParameters',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: ResponseParameters.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'size')
    ..aI(2, _omitFieldNames ? '' : 'intervalUs')
    ..aOM<BoolValue>(3, _omitFieldNames ? '' : 'compressed',
        subBuilder: BoolValue.$_createMessage)
    ..aOM<BoolValue>(4, _omitFieldNames ? '' : 'fillPeerSocketAddress',
        subBuilder: BoolValue.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseParameters clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseParameters copyWith(void Function(ResponseParameters) updates) =>
      super.copyWith((message) => updates(message as ResponseParameters))
          as ResponseParameters;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResponseParameters() / ResponseParameters.new instead')
  static ResponseParameters create() => ResponseParameters._();
  static $pb.GeneratedMessage $_createMessage() => ResponseParameters._();
  @$core.override
  ResponseParameters createEmptyInstance() => ResponseParameters._();
  @$core.pragma('dart2js:noInline')
  static ResponseParameters getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseParameters>(
          ResponseParameters.$_createMessage);
  static ResponseParameters? _defaultInstance;

  /// Desired payload sizes in responses from the server.
  @$pb.TagNumber(1)
  $core.int get size => $_getIZ(0);
  @$pb.TagNumber(1)
  set size($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearSize() => $_clearField(1);

  /// Desired interval between consecutive responses in the response stream in
  /// microseconds.
  @$pb.TagNumber(2)
  $core.int get intervalUs => $_getIZ(1);
  @$pb.TagNumber(2)
  set intervalUs($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIntervalUs() => $_has(1);
  @$pb.TagNumber(2)
  void clearIntervalUs() => $_clearField(2);

  /// Whether to request the server to compress the response. This field is
  /// "nullable" in order to interoperate seamlessly with clients not able to
  /// implement the full compression tests by introspecting the call to verify
  /// the response's compression status.
  @$pb.TagNumber(3)
  BoolValue get compressed => $_getN(2);
  @$pb.TagNumber(3)
  set compressed(BoolValue value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCompressed() => $_has(2);
  @$pb.TagNumber(3)
  void clearCompressed() => $_clearField(3);
  @$pb.TagNumber(3)
  BoolValue ensureCompressed() => $_ensure(2);

  /// Whether to request the server to send the requesting peer's socket
  /// address in the response.
  @$pb.TagNumber(4)
  BoolValue get fillPeerSocketAddress => $_getN(3);
  @$pb.TagNumber(4)
  set fillPeerSocketAddress(BoolValue value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFillPeerSocketAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearFillPeerSocketAddress() => $_clearField(4);
  @$pb.TagNumber(4)
  BoolValue ensureFillPeerSocketAddress() => $_ensure(3);
}

/// Server-streaming request.
class StreamingOutputCallRequest extends $pb.GeneratedMessage {
  factory StreamingOutputCallRequest({
    PayloadType? responseType,
    $core.Iterable<ResponseParameters>? responseParameters,
    Payload? payload,
    EchoStatus? responseStatus,
    TestOrcaReport? orcaOobReport,
  }) {
    final result = StreamingOutputCallRequest._();
    if (responseType != null) result.responseType = responseType;
    if (responseParameters != null)
      result.responseParameters.addAll(responseParameters);
    if (payload != null) result.payload = payload;
    if (responseStatus != null) result.responseStatus = responseStatus;
    if (orcaOobReport != null) result.orcaOobReport = orcaOobReport;
    return result;
  }

  StreamingOutputCallRequest._();

  factory StreamingOutputCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingOutputCallRequest()..mergeFromBuffer(data, registry);
  factory StreamingOutputCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingOutputCallRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamingOutputCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: StreamingOutputCallRequest.$_createMessage)
    ..aE<PayloadType>(1, _omitFieldNames ? '' : 'responseType',
        enumValues: PayloadType.values)
    ..pPM<ResponseParameters>(2, _omitFieldNames ? '' : 'responseParameters',
        subBuilder: ResponseParameters.$_createMessage)
    ..aOM<Payload>(3, _omitFieldNames ? '' : 'payload',
        subBuilder: Payload.$_createMessage)
    ..aOM<EchoStatus>(7, _omitFieldNames ? '' : 'responseStatus',
        subBuilder: EchoStatus.$_createMessage)
    ..aOM<TestOrcaReport>(8, _omitFieldNames ? '' : 'orcaOobReport',
        subBuilder: TestOrcaReport.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingOutputCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingOutputCallRequest copyWith(
          void Function(StreamingOutputCallRequest) updates) =>
      super.copyWith(
              (message) => updates(message as StreamingOutputCallRequest))
          as StreamingOutputCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use StreamingOutputCallRequest() / StreamingOutputCallRequest.new instead')
  static StreamingOutputCallRequest create() => StreamingOutputCallRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      StreamingOutputCallRequest._();
  @$core.override
  StreamingOutputCallRequest createEmptyInstance() =>
      StreamingOutputCallRequest._();
  @$core.pragma('dart2js:noInline')
  static StreamingOutputCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamingOutputCallRequest>(
          StreamingOutputCallRequest.$_createMessage);
  static StreamingOutputCallRequest? _defaultInstance;

  /// Desired payload type in the response from the server.
  /// If response_type is RANDOM, the payload from each response in the stream
  /// might be of different types. This is to simulate a mixed type of payload
  /// stream.
  @$pb.TagNumber(1)
  PayloadType get responseType => $_getN(0);
  @$pb.TagNumber(1)
  set responseType(PayloadType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasResponseType() => $_has(0);
  @$pb.TagNumber(1)
  void clearResponseType() => $_clearField(1);

  /// Configuration for each expected response message.
  @$pb.TagNumber(2)
  $pb.PbList<ResponseParameters> get responseParameters => $_getList(1);

  /// Optional input payload sent along with the request.
  @$pb.TagNumber(3)
  Payload get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload(Payload value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);
  @$pb.TagNumber(3)
  Payload ensurePayload() => $_ensure(2);

  /// Whether server should return a given status
  @$pb.TagNumber(7)
  EchoStatus get responseStatus => $_getN(3);
  @$pb.TagNumber(7)
  set responseStatus(EchoStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasResponseStatus() => $_has(3);
  @$pb.TagNumber(7)
  void clearResponseStatus() => $_clearField(7);
  @$pb.TagNumber(7)
  EchoStatus ensureResponseStatus() => $_ensure(3);

  /// If set the server should update this metrics report data at the OOB server.
  @$pb.TagNumber(8)
  TestOrcaReport get orcaOobReport => $_getN(4);
  @$pb.TagNumber(8)
  set orcaOobReport(TestOrcaReport value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasOrcaOobReport() => $_has(4);
  @$pb.TagNumber(8)
  void clearOrcaOobReport() => $_clearField(8);
  @$pb.TagNumber(8)
  TestOrcaReport ensureOrcaOobReport() => $_ensure(4);
}

/// Server-streaming response, as configured by the request and parameters.
class StreamingOutputCallResponse extends $pb.GeneratedMessage {
  factory StreamingOutputCallResponse({
    Payload? payload,
    $core.String? peerSocketAddress,
  }) {
    final result = StreamingOutputCallResponse._();
    if (payload != null) result.payload = payload;
    if (peerSocketAddress != null) result.peerSocketAddress = peerSocketAddress;
    return result;
  }

  StreamingOutputCallResponse._();

  factory StreamingOutputCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingOutputCallResponse()..mergeFromBuffer(data, registry);
  factory StreamingOutputCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StreamingOutputCallResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamingOutputCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: StreamingOutputCallResponse.$_createMessage)
    ..aOM<Payload>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: Payload.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'peerSocketAddress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingOutputCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamingOutputCallResponse copyWith(
          void Function(StreamingOutputCallResponse) updates) =>
      super.copyWith(
              (message) => updates(message as StreamingOutputCallResponse))
          as StreamingOutputCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use StreamingOutputCallResponse() / StreamingOutputCallResponse.new instead')
  static StreamingOutputCallResponse create() =>
      StreamingOutputCallResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      StreamingOutputCallResponse._();
  @$core.override
  StreamingOutputCallResponse createEmptyInstance() =>
      StreamingOutputCallResponse._();
  @$core.pragma('dart2js:noInline')
  static StreamingOutputCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamingOutputCallResponse>(
          StreamingOutputCallResponse.$_createMessage);
  static StreamingOutputCallResponse? _defaultInstance;

  /// Payload to increase response size.
  @$pb.TagNumber(1)
  Payload get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload(Payload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  Payload ensurePayload() => $_ensure(0);

  /// The peer's socket address if requested.
  @$pb.TagNumber(2)
  $core.String get peerSocketAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set peerSocketAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeerSocketAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerSocketAddress() => $_clearField(2);
}

/// For reconnect interop test only.
/// Client tells server what reconnection parameters it used.
class ReconnectParams extends $pb.GeneratedMessage {
  factory ReconnectParams({
    $core.int? maxReconnectBackoffMs,
  }) {
    final result = ReconnectParams._();
    if (maxReconnectBackoffMs != null)
      result.maxReconnectBackoffMs = maxReconnectBackoffMs;
    return result;
  }

  ReconnectParams._();

  factory ReconnectParams.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconnectParams()..mergeFromBuffer(data, registry);
  factory ReconnectParams.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconnectParams()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconnectParams',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: ReconnectParams.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'maxReconnectBackoffMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconnectParams clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconnectParams copyWith(void Function(ReconnectParams) updates) =>
      super.copyWith((message) => updates(message as ReconnectParams))
          as ReconnectParams;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReconnectParams() / ReconnectParams.new instead')
  static ReconnectParams create() => ReconnectParams._();
  static $pb.GeneratedMessage $_createMessage() => ReconnectParams._();
  @$core.override
  ReconnectParams createEmptyInstance() => ReconnectParams._();
  @$core.pragma('dart2js:noInline')
  static ReconnectParams getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconnectParams>(
          ReconnectParams.$_createMessage);
  static ReconnectParams? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get maxReconnectBackoffMs => $_getIZ(0);
  @$pb.TagNumber(1)
  set maxReconnectBackoffMs($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMaxReconnectBackoffMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearMaxReconnectBackoffMs() => $_clearField(1);
}

/// For reconnect interop test only.
/// Server tells client whether its reconnects are following the spec and the
/// reconnect backoffs it saw.
class ReconnectInfo extends $pb.GeneratedMessage {
  factory ReconnectInfo({
    $core.bool? passed,
    $core.Iterable<$core.int>? backoffMs,
  }) {
    final result = ReconnectInfo._();
    if (passed != null) result.passed = passed;
    if (backoffMs != null) result.backoffMs.addAll(backoffMs);
    return result;
  }

  ReconnectInfo._();

  factory ReconnectInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconnectInfo()..mergeFromBuffer(data, registry);
  factory ReconnectInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReconnectInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReconnectInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: ReconnectInfo.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'passed')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'backoffMs', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconnectInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReconnectInfo copyWith(void Function(ReconnectInfo) updates) =>
      super.copyWith((message) => updates(message as ReconnectInfo))
          as ReconnectInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReconnectInfo() / ReconnectInfo.new instead')
  static ReconnectInfo create() => ReconnectInfo._();
  static $pb.GeneratedMessage $_createMessage() => ReconnectInfo._();
  @$core.override
  ReconnectInfo createEmptyInstance() => ReconnectInfo._();
  @$core.pragma('dart2js:noInline')
  static ReconnectInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconnectInfo>(
          ReconnectInfo.$_createMessage);
  static ReconnectInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get passed => $_getBF(0);
  @$pb.TagNumber(1)
  set passed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassed() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassed() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get backoffMs => $_getList(1);
}

class LoadBalancerStatsRequest extends $pb.GeneratedMessage {
  factory LoadBalancerStatsRequest({
    $core.int? numRpcs,
    $core.int? timeoutSec,
    $core.Iterable<$core.String>? metadataKeys,
  }) {
    final result = LoadBalancerStatsRequest._();
    if (numRpcs != null) result.numRpcs = numRpcs;
    if (timeoutSec != null) result.timeoutSec = timeoutSec;
    if (metadataKeys != null) result.metadataKeys.addAll(metadataKeys);
    return result;
  }

  LoadBalancerStatsRequest._();

  factory LoadBalancerStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsRequest()..mergeFromBuffer(data, registry);
  factory LoadBalancerStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: LoadBalancerStatsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'numRpcs')
    ..aI(2, _omitFieldNames ? '' : 'timeoutSec')
    ..pPS(3, _omitFieldNames ? '' : 'metadataKeys')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsRequest copyWith(
          void Function(LoadBalancerStatsRequest) updates) =>
      super.copyWith((message) => updates(message as LoadBalancerStatsRequest))
          as LoadBalancerStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerStatsRequest() / LoadBalancerStatsRequest.new instead')
  static LoadBalancerStatsRequest create() => LoadBalancerStatsRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoadBalancerStatsRequest._();
  @$core.override
  LoadBalancerStatsRequest createEmptyInstance() =>
      LoadBalancerStatsRequest._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadBalancerStatsRequest>(
          LoadBalancerStatsRequest.$_createMessage);
  static LoadBalancerStatsRequest? _defaultInstance;

  /// Request stats for the next num_rpcs sent by client.
  @$pb.TagNumber(1)
  $core.int get numRpcs => $_getIZ(0);
  @$pb.TagNumber(1)
  set numRpcs($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNumRpcs() => $_has(0);
  @$pb.TagNumber(1)
  void clearNumRpcs() => $_clearField(1);

  /// If num_rpcs have not completed within timeout_sec, return partial results.
  @$pb.TagNumber(2)
  $core.int get timeoutSec => $_getIZ(1);
  @$pb.TagNumber(2)
  set timeoutSec($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimeoutSec() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeoutSec() => $_clearField(2);

  /// Response header + trailer metadata entries we want the values of.
  /// Matching of the keys is case-insensitive as per rfc7540#section-8.1.2
  /// * (asterisk) is a special value that will return all metadata entries
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get metadataKeys => $_getList(2);
}

class LoadBalancerStatsResponse_MetadataEntry extends $pb.GeneratedMessage {
  factory LoadBalancerStatsResponse_MetadataEntry({
    $core.String? key,
    $core.String? value,
    LoadBalancerStatsResponse_MetadataType? type,
  }) {
    final result = LoadBalancerStatsResponse_MetadataEntry._();
    if (key != null) result.key = key;
    if (value != null) result.value = value;
    if (type != null) result.type = type;
    return result;
  }

  LoadBalancerStatsResponse_MetadataEntry._();

  factory LoadBalancerStatsResponse_MetadataEntry.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_MetadataEntry()
        ..mergeFromBuffer(data, registry);
  factory LoadBalancerStatsResponse_MetadataEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_MetadataEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerStatsResponse.MetadataEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance:
          LoadBalancerStatsResponse_MetadataEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..aE<LoadBalancerStatsResponse_MetadataType>(
        3, _omitFieldNames ? '' : 'type',
        enumValues: LoadBalancerStatsResponse_MetadataType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_MetadataEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_MetadataEntry copyWith(
          void Function(LoadBalancerStatsResponse_MetadataEntry) updates) =>
      super.copyWith((message) =>
              updates(message as LoadBalancerStatsResponse_MetadataEntry))
          as LoadBalancerStatsResponse_MetadataEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerStatsResponse_MetadataEntry() / LoadBalancerStatsResponse_MetadataEntry.new instead')
  static LoadBalancerStatsResponse_MetadataEntry create() =>
      LoadBalancerStatsResponse_MetadataEntry._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerStatsResponse_MetadataEntry._();
  @$core.override
  LoadBalancerStatsResponse_MetadataEntry createEmptyInstance() =>
      LoadBalancerStatsResponse_MetadataEntry._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerStatsResponse_MetadataEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              LoadBalancerStatsResponse_MetadataEntry>(
          LoadBalancerStatsResponse_MetadataEntry.$_createMessage);
  static LoadBalancerStatsResponse_MetadataEntry? _defaultInstance;

  /// Key, exactly as received from the server. Case may be different from what
  /// was requested in the LoadBalancerStatsRequest)
  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  /// Value, exactly as received from the server.
  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  /// Metadata type
  @$pb.TagNumber(3)
  LoadBalancerStatsResponse_MetadataType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(LoadBalancerStatsResponse_MetadataType value) =>
      $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);
}

class LoadBalancerStatsResponse_RpcMetadata extends $pb.GeneratedMessage {
  factory LoadBalancerStatsResponse_RpcMetadata({
    $core.Iterable<LoadBalancerStatsResponse_MetadataEntry>? metadata,
  }) {
    final result = LoadBalancerStatsResponse_RpcMetadata._();
    if (metadata != null) result.metadata.addAll(metadata);
    return result;
  }

  LoadBalancerStatsResponse_RpcMetadata._();

  factory LoadBalancerStatsResponse_RpcMetadata.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_RpcMetadata()..mergeFromBuffer(data, registry);
  factory LoadBalancerStatsResponse_RpcMetadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_RpcMetadata()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerStatsResponse.RpcMetadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance:
          LoadBalancerStatsResponse_RpcMetadata.$_createMessage)
    ..pPM<LoadBalancerStatsResponse_MetadataEntry>(
        1, _omitFieldNames ? '' : 'metadata',
        subBuilder: LoadBalancerStatsResponse_MetadataEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_RpcMetadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_RpcMetadata copyWith(
          void Function(LoadBalancerStatsResponse_RpcMetadata) updates) =>
      super.copyWith((message) =>
              updates(message as LoadBalancerStatsResponse_RpcMetadata))
          as LoadBalancerStatsResponse_RpcMetadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerStatsResponse_RpcMetadata() / LoadBalancerStatsResponse_RpcMetadata.new instead')
  static LoadBalancerStatsResponse_RpcMetadata create() =>
      LoadBalancerStatsResponse_RpcMetadata._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerStatsResponse_RpcMetadata._();
  @$core.override
  LoadBalancerStatsResponse_RpcMetadata createEmptyInstance() =>
      LoadBalancerStatsResponse_RpcMetadata._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerStatsResponse_RpcMetadata getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              LoadBalancerStatsResponse_RpcMetadata>(
          LoadBalancerStatsResponse_RpcMetadata.$_createMessage);
  static LoadBalancerStatsResponse_RpcMetadata? _defaultInstance;

  /// metadata values for each rpc for the keys specified in
  /// LoadBalancerStatsRequest.metadata_keys.
  @$pb.TagNumber(1)
  $pb.PbList<LoadBalancerStatsResponse_MetadataEntry> get metadata =>
      $_getList(0);
}

class LoadBalancerStatsResponse_MetadataByPeer extends $pb.GeneratedMessage {
  factory LoadBalancerStatsResponse_MetadataByPeer({
    $core.Iterable<LoadBalancerStatsResponse_RpcMetadata>? rpcMetadata,
  }) {
    final result = LoadBalancerStatsResponse_MetadataByPeer._();
    if (rpcMetadata != null) result.rpcMetadata.addAll(rpcMetadata);
    return result;
  }

  LoadBalancerStatsResponse_MetadataByPeer._();

  factory LoadBalancerStatsResponse_MetadataByPeer.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_MetadataByPeer()
        ..mergeFromBuffer(data, registry);
  factory LoadBalancerStatsResponse_MetadataByPeer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_MetadataByPeer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerStatsResponse.MetadataByPeer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance:
          LoadBalancerStatsResponse_MetadataByPeer.$_createMessage)
    ..pPM<LoadBalancerStatsResponse_RpcMetadata>(
        1, _omitFieldNames ? '' : 'rpcMetadata',
        subBuilder: LoadBalancerStatsResponse_RpcMetadata.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_MetadataByPeer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_MetadataByPeer copyWith(
          void Function(LoadBalancerStatsResponse_MetadataByPeer) updates) =>
      super.copyWith((message) =>
              updates(message as LoadBalancerStatsResponse_MetadataByPeer))
          as LoadBalancerStatsResponse_MetadataByPeer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerStatsResponse_MetadataByPeer() / LoadBalancerStatsResponse_MetadataByPeer.new instead')
  static LoadBalancerStatsResponse_MetadataByPeer create() =>
      LoadBalancerStatsResponse_MetadataByPeer._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerStatsResponse_MetadataByPeer._();
  @$core.override
  LoadBalancerStatsResponse_MetadataByPeer createEmptyInstance() =>
      LoadBalancerStatsResponse_MetadataByPeer._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerStatsResponse_MetadataByPeer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              LoadBalancerStatsResponse_MetadataByPeer>(
          LoadBalancerStatsResponse_MetadataByPeer.$_createMessage);
  static LoadBalancerStatsResponse_MetadataByPeer? _defaultInstance;

  /// List of RpcMetadata in for each RPC with a given peer
  @$pb.TagNumber(1)
  $pb.PbList<LoadBalancerStatsResponse_RpcMetadata> get rpcMetadata =>
      $_getList(0);
}

class LoadBalancerStatsResponse_RpcsByPeer extends $pb.GeneratedMessage {
  factory LoadBalancerStatsResponse_RpcsByPeer({
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? rpcsByPeer,
  }) {
    final result = LoadBalancerStatsResponse_RpcsByPeer._();
    if (rpcsByPeer != null) result.rpcsByPeer.addEntries(rpcsByPeer);
    return result;
  }

  LoadBalancerStatsResponse_RpcsByPeer._();

  factory LoadBalancerStatsResponse_RpcsByPeer.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_RpcsByPeer()..mergeFromBuffer(data, registry);
  factory LoadBalancerStatsResponse_RpcsByPeer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse_RpcsByPeer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerStatsResponse.RpcsByPeer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: LoadBalancerStatsResponse_RpcsByPeer.$_createMessage)
    ..m<$core.String, $core.int>(1, _omitFieldNames ? '' : 'rpcsByPeer',
        entryClassName: 'LoadBalancerStatsResponse.RpcsByPeer.RpcsByPeerEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('grpc.testing'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_RpcsByPeer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse_RpcsByPeer copyWith(
          void Function(LoadBalancerStatsResponse_RpcsByPeer) updates) =>
      super.copyWith((message) =>
              updates(message as LoadBalancerStatsResponse_RpcsByPeer))
          as LoadBalancerStatsResponse_RpcsByPeer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerStatsResponse_RpcsByPeer() / LoadBalancerStatsResponse_RpcsByPeer.new instead')
  static LoadBalancerStatsResponse_RpcsByPeer create() =>
      LoadBalancerStatsResponse_RpcsByPeer._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerStatsResponse_RpcsByPeer._();
  @$core.override
  LoadBalancerStatsResponse_RpcsByPeer createEmptyInstance() =>
      LoadBalancerStatsResponse_RpcsByPeer._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerStatsResponse_RpcsByPeer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              LoadBalancerStatsResponse_RpcsByPeer>(
          LoadBalancerStatsResponse_RpcsByPeer.$_createMessage);
  static LoadBalancerStatsResponse_RpcsByPeer? _defaultInstance;

  /// The number of completed RPCs for each peer.
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.int> get rpcsByPeer => $_getMap(0);
}

class LoadBalancerStatsResponse extends $pb.GeneratedMessage {
  factory LoadBalancerStatsResponse({
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? rpcsByPeer,
    $core.int? numFailures,
    $core.Iterable<
            $core.MapEntry<$core.String, LoadBalancerStatsResponse_RpcsByPeer>>?
        rpcsByMethod,
    $core.Iterable<
            $core
            .MapEntry<$core.String, LoadBalancerStatsResponse_MetadataByPeer>>?
        metadatasByPeer,
  }) {
    final result = LoadBalancerStatsResponse._();
    if (rpcsByPeer != null) result.rpcsByPeer.addEntries(rpcsByPeer);
    if (numFailures != null) result.numFailures = numFailures;
    if (rpcsByMethod != null) result.rpcsByMethod.addEntries(rpcsByMethod);
    if (metadatasByPeer != null)
      result.metadatasByPeer.addEntries(metadatasByPeer);
    return result;
  }

  LoadBalancerStatsResponse._();

  factory LoadBalancerStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse()..mergeFromBuffer(data, registry);
  factory LoadBalancerStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: LoadBalancerStatsResponse.$_createMessage)
    ..m<$core.String, $core.int>(1, _omitFieldNames ? '' : 'rpcsByPeer',
        entryClassName: 'LoadBalancerStatsResponse.RpcsByPeerEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('grpc.testing'))
    ..aI(2, _omitFieldNames ? '' : 'numFailures')
    ..m<$core.String, LoadBalancerStatsResponse_RpcsByPeer>(
        3, _omitFieldNames ? '' : 'rpcsByMethod',
        entryClassName: 'LoadBalancerStatsResponse.RpcsByMethodEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: LoadBalancerStatsResponse_RpcsByPeer.$_createMessage,
        valueDefaultOrMaker: LoadBalancerStatsResponse_RpcsByPeer.getDefault,
        packageName: const $pb.PackageName('grpc.testing'))
    ..m<$core.String, LoadBalancerStatsResponse_MetadataByPeer>(
        4, _omitFieldNames ? '' : 'metadatasByPeer',
        entryClassName: 'LoadBalancerStatsResponse.MetadatasByPeerEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: LoadBalancerStatsResponse_MetadataByPeer.$_createMessage,
        valueDefaultOrMaker:
            LoadBalancerStatsResponse_MetadataByPeer.getDefault,
        packageName: const $pb.PackageName('grpc.testing'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerStatsResponse copyWith(
          void Function(LoadBalancerStatsResponse) updates) =>
      super.copyWith((message) => updates(message as LoadBalancerStatsResponse))
          as LoadBalancerStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerStatsResponse() / LoadBalancerStatsResponse.new instead')
  static LoadBalancerStatsResponse create() => LoadBalancerStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerStatsResponse._();
  @$core.override
  LoadBalancerStatsResponse createEmptyInstance() =>
      LoadBalancerStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadBalancerStatsResponse>(
          LoadBalancerStatsResponse.$_createMessage);
  static LoadBalancerStatsResponse? _defaultInstance;

  /// The number of completed RPCs for each peer.
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.int> get rpcsByPeer => $_getMap(0);

  /// The number of RPCs that failed to record a remote peer.
  @$pb.TagNumber(2)
  $core.int get numFailures => $_getIZ(1);
  @$pb.TagNumber(2)
  set numFailures($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNumFailures() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumFailures() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, LoadBalancerStatsResponse_RpcsByPeer>
      get rpcsByMethod => $_getMap(2);

  /// All the metadata of all RPCs for each peer.
  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, LoadBalancerStatsResponse_MetadataByPeer>
      get metadatasByPeer => $_getMap(3);
}

/// Request for retrieving a test client's accumulated stats.
class LoadBalancerAccumulatedStatsRequest extends $pb.GeneratedMessage {
  factory LoadBalancerAccumulatedStatsRequest() =>
      LoadBalancerAccumulatedStatsRequest._();

  LoadBalancerAccumulatedStatsRequest._();

  factory LoadBalancerAccumulatedStatsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerAccumulatedStatsRequest()..mergeFromBuffer(data, registry);
  factory LoadBalancerAccumulatedStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerAccumulatedStatsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerAccumulatedStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: LoadBalancerAccumulatedStatsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerAccumulatedStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerAccumulatedStatsRequest copyWith(
          void Function(LoadBalancerAccumulatedStatsRequest) updates) =>
      super.copyWith((message) =>
              updates(message as LoadBalancerAccumulatedStatsRequest))
          as LoadBalancerAccumulatedStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerAccumulatedStatsRequest() / LoadBalancerAccumulatedStatsRequest.new instead')
  static LoadBalancerAccumulatedStatsRequest create() =>
      LoadBalancerAccumulatedStatsRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerAccumulatedStatsRequest._();
  @$core.override
  LoadBalancerAccumulatedStatsRequest createEmptyInstance() =>
      LoadBalancerAccumulatedStatsRequest._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerAccumulatedStatsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              LoadBalancerAccumulatedStatsRequest>(
          LoadBalancerAccumulatedStatsRequest.$_createMessage);
  static LoadBalancerAccumulatedStatsRequest? _defaultInstance;
}

class LoadBalancerAccumulatedStatsResponse_MethodStats
    extends $pb.GeneratedMessage {
  factory LoadBalancerAccumulatedStatsResponse_MethodStats({
    $core.int? rpcsStarted,
    $core.Iterable<$core.MapEntry<$core.int, $core.int>>? result,
  }) {
    final result$ = LoadBalancerAccumulatedStatsResponse_MethodStats._();
    if (rpcsStarted != null) result$.rpcsStarted = rpcsStarted;
    if (result != null) result$.result.addEntries(result);
    return result$;
  }

  LoadBalancerAccumulatedStatsResponse_MethodStats._();

  factory LoadBalancerAccumulatedStatsResponse_MethodStats.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerAccumulatedStatsResponse_MethodStats()
        ..mergeFromBuffer(data, registry);
  factory LoadBalancerAccumulatedStatsResponse_MethodStats.fromJson(
          $core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerAccumulatedStatsResponse_MethodStats()
        ..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames
          ? ''
          : 'LoadBalancerAccumulatedStatsResponse.MethodStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance:
          LoadBalancerAccumulatedStatsResponse_MethodStats.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'rpcsStarted')
    ..m<$core.int, $core.int>(2, _omitFieldNames ? '' : 'result',
        entryClassName:
            'LoadBalancerAccumulatedStatsResponse.MethodStats.ResultEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('grpc.testing'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerAccumulatedStatsResponse_MethodStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerAccumulatedStatsResponse_MethodStats copyWith(
          void Function(LoadBalancerAccumulatedStatsResponse_MethodStats)
              updates) =>
      super.copyWith((message) => updates(
              message as LoadBalancerAccumulatedStatsResponse_MethodStats))
          as LoadBalancerAccumulatedStatsResponse_MethodStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerAccumulatedStatsResponse_MethodStats() / LoadBalancerAccumulatedStatsResponse_MethodStats.new instead')
  static LoadBalancerAccumulatedStatsResponse_MethodStats create() =>
      LoadBalancerAccumulatedStatsResponse_MethodStats._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerAccumulatedStatsResponse_MethodStats._();
  @$core.override
  LoadBalancerAccumulatedStatsResponse_MethodStats createEmptyInstance() =>
      LoadBalancerAccumulatedStatsResponse_MethodStats._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerAccumulatedStatsResponse_MethodStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              LoadBalancerAccumulatedStatsResponse_MethodStats>(
          LoadBalancerAccumulatedStatsResponse_MethodStats.$_createMessage);
  static LoadBalancerAccumulatedStatsResponse_MethodStats? _defaultInstance;

  /// The number of RPCs that were started for this method.
  @$pb.TagNumber(1)
  $core.int get rpcsStarted => $_getIZ(0);
  @$pb.TagNumber(1)
  set rpcsStarted($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRpcsStarted() => $_has(0);
  @$pb.TagNumber(1)
  void clearRpcsStarted() => $_clearField(1);

  /// The number of RPCs that completed with each status for this method.  The
  /// key is the integral value of a google.rpc.Code; the value is the count.
  @$pb.TagNumber(2)
  $pb.PbMap<$core.int, $core.int> get result => $_getMap(1);
}

/// Accumulated stats for RPCs sent by a test client.
class LoadBalancerAccumulatedStatsResponse extends $pb.GeneratedMessage {
  factory LoadBalancerAccumulatedStatsResponse({
    @$core.Deprecated('This field is deprecated.')
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>?
        numRpcsStartedByMethod,
    @$core.Deprecated('This field is deprecated.')
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>?
        numRpcsSucceededByMethod,
    @$core.Deprecated('This field is deprecated.')
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>?
        numRpcsFailedByMethod,
    $core.Iterable<
            $core.MapEntry<$core.String,
                LoadBalancerAccumulatedStatsResponse_MethodStats>>?
        statsPerMethod,
  }) {
    final result = LoadBalancerAccumulatedStatsResponse._();
    if (numRpcsStartedByMethod != null)
      result.numRpcsStartedByMethod.addEntries(numRpcsStartedByMethod);
    if (numRpcsSucceededByMethod != null)
      result.numRpcsSucceededByMethod.addEntries(numRpcsSucceededByMethod);
    if (numRpcsFailedByMethod != null)
      result.numRpcsFailedByMethod.addEntries(numRpcsFailedByMethod);
    if (statsPerMethod != null)
      result.statsPerMethod.addEntries(statsPerMethod);
    return result;
  }

  LoadBalancerAccumulatedStatsResponse._();

  factory LoadBalancerAccumulatedStatsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerAccumulatedStatsResponse()..mergeFromBuffer(data, registry);
  factory LoadBalancerAccumulatedStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoadBalancerAccumulatedStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadBalancerAccumulatedStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: LoadBalancerAccumulatedStatsResponse.$_createMessage)
    ..m<$core.String, $core.int>(
        1, _omitFieldNames ? '' : 'numRpcsStartedByMethod',
        entryClassName:
            'LoadBalancerAccumulatedStatsResponse.NumRpcsStartedByMethodEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('grpc.testing'))
    ..m<$core.String, $core.int>(
        2, _omitFieldNames ? '' : 'numRpcsSucceededByMethod',
        entryClassName:
            'LoadBalancerAccumulatedStatsResponse.NumRpcsSucceededByMethodEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('grpc.testing'))
    ..m<$core.String, $core.int>(
        3, _omitFieldNames ? '' : 'numRpcsFailedByMethod',
        entryClassName:
            'LoadBalancerAccumulatedStatsResponse.NumRpcsFailedByMethodEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('grpc.testing'))
    ..m<$core.String, LoadBalancerAccumulatedStatsResponse_MethodStats>(
        4, _omitFieldNames ? '' : 'statsPerMethod',
        entryClassName:
            'LoadBalancerAccumulatedStatsResponse.StatsPerMethodEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator:
            LoadBalancerAccumulatedStatsResponse_MethodStats.$_createMessage,
        valueDefaultOrMaker:
            LoadBalancerAccumulatedStatsResponse_MethodStats.getDefault,
        packageName: const $pb.PackageName('grpc.testing'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerAccumulatedStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadBalancerAccumulatedStatsResponse copyWith(
          void Function(LoadBalancerAccumulatedStatsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as LoadBalancerAccumulatedStatsResponse))
          as LoadBalancerAccumulatedStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LoadBalancerAccumulatedStatsResponse() / LoadBalancerAccumulatedStatsResponse.new instead')
  static LoadBalancerAccumulatedStatsResponse create() =>
      LoadBalancerAccumulatedStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LoadBalancerAccumulatedStatsResponse._();
  @$core.override
  LoadBalancerAccumulatedStatsResponse createEmptyInstance() =>
      LoadBalancerAccumulatedStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static LoadBalancerAccumulatedStatsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              LoadBalancerAccumulatedStatsResponse>(
          LoadBalancerAccumulatedStatsResponse.$_createMessage);
  static LoadBalancerAccumulatedStatsResponse? _defaultInstance;

  /// The total number of RPCs have ever issued for each type.
  /// Deprecated: use stats_per_method.rpcs_started instead.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.int> get numRpcsStartedByMethod => $_getMap(0);

  /// The total number of RPCs have ever completed successfully for each type.
  /// Deprecated: use stats_per_method.result instead.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.int> get numRpcsSucceededByMethod =>
      $_getMap(1);

  /// The total number of RPCs have ever failed for each type.
  /// Deprecated: use stats_per_method.result instead.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.int> get numRpcsFailedByMethod => $_getMap(2);

  /// Per-method RPC statistics.  The key is the RpcType in string form; e.g.
  /// 'EMPTY_CALL' or 'UNARY_CALL'
  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, LoadBalancerAccumulatedStatsResponse_MethodStats>
      get statsPerMethod => $_getMap(3);
}

/// Metadata to be attached for the given type of RPCs.
class ClientConfigureRequest_Metadata extends $pb.GeneratedMessage {
  factory ClientConfigureRequest_Metadata({
    ClientConfigureRequest_RpcType? type,
    $core.String? key,
    $core.String? value,
  }) {
    final result = ClientConfigureRequest_Metadata._();
    if (type != null) result.type = type;
    if (key != null) result.key = key;
    if (value != null) result.value = value;
    return result;
  }

  ClientConfigureRequest_Metadata._();

  factory ClientConfigureRequest_Metadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientConfigureRequest_Metadata()..mergeFromBuffer(data, registry);
  factory ClientConfigureRequest_Metadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientConfigureRequest_Metadata()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientConfigureRequest.Metadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: ClientConfigureRequest_Metadata.$_createMessage)
    ..aE<ClientConfigureRequest_RpcType>(1, _omitFieldNames ? '' : 'type',
        enumValues: ClientConfigureRequest_RpcType.values)
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..aOS(3, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientConfigureRequest_Metadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientConfigureRequest_Metadata copyWith(
          void Function(ClientConfigureRequest_Metadata) updates) =>
      super.copyWith(
              (message) => updates(message as ClientConfigureRequest_Metadata))
          as ClientConfigureRequest_Metadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientConfigureRequest_Metadata() / ClientConfigureRequest_Metadata.new instead')
  static ClientConfigureRequest_Metadata create() =>
      ClientConfigureRequest_Metadata._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientConfigureRequest_Metadata._();
  @$core.override
  ClientConfigureRequest_Metadata createEmptyInstance() =>
      ClientConfigureRequest_Metadata._();
  @$core.pragma('dart2js:noInline')
  static ClientConfigureRequest_Metadata getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientConfigureRequest_Metadata>(
          ClientConfigureRequest_Metadata.$_createMessage);
  static ClientConfigureRequest_Metadata? _defaultInstance;

  @$pb.TagNumber(1)
  ClientConfigureRequest_RpcType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ClientConfigureRequest_RpcType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get value => $_getSZ(2);
  @$pb.TagNumber(3)
  set value($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);
}

/// Configurations for a test client.
class ClientConfigureRequest extends $pb.GeneratedMessage {
  factory ClientConfigureRequest({
    $core.Iterable<ClientConfigureRequest_RpcType>? types,
    $core.Iterable<ClientConfigureRequest_Metadata>? metadata,
    $core.int? timeoutSec,
  }) {
    final result = ClientConfigureRequest._();
    if (types != null) result.types.addAll(types);
    if (metadata != null) result.metadata.addAll(metadata);
    if (timeoutSec != null) result.timeoutSec = timeoutSec;
    return result;
  }

  ClientConfigureRequest._();

  factory ClientConfigureRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientConfigureRequest()..mergeFromBuffer(data, registry);
  factory ClientConfigureRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientConfigureRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientConfigureRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: ClientConfigureRequest.$_createMessage)
    ..pc<ClientConfigureRequest_RpcType>(
        1, _omitFieldNames ? '' : 'types', $pb.PbFieldType.KE,
        valueOf: ClientConfigureRequest_RpcType.valueOf,
        enumValues: ClientConfigureRequest_RpcType.values,
        defaultEnumValue: ClientConfigureRequest_RpcType.EMPTY_CALL)
    ..pPM<ClientConfigureRequest_Metadata>(2, _omitFieldNames ? '' : 'metadata',
        subBuilder: ClientConfigureRequest_Metadata.$_createMessage)
    ..aI(3, _omitFieldNames ? '' : 'timeoutSec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientConfigureRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientConfigureRequest copyWith(
          void Function(ClientConfigureRequest) updates) =>
      super.copyWith((message) => updates(message as ClientConfigureRequest))
          as ClientConfigureRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientConfigureRequest() / ClientConfigureRequest.new instead')
  static ClientConfigureRequest create() => ClientConfigureRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientConfigureRequest._();
  @$core.override
  ClientConfigureRequest createEmptyInstance() => ClientConfigureRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientConfigureRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientConfigureRequest>(
          ClientConfigureRequest.$_createMessage);
  static ClientConfigureRequest? _defaultInstance;

  /// The types of RPCs the client sends.
  @$pb.TagNumber(1)
  $pb.PbList<ClientConfigureRequest_RpcType> get types => $_getList(0);

  /// The collection of custom metadata to be attached to RPCs sent by the client.
  @$pb.TagNumber(2)
  $pb.PbList<ClientConfigureRequest_Metadata> get metadata => $_getList(1);

  /// The deadline to use, in seconds, for all RPCs.  If unset or zero, the
  /// client will use the default from the command-line.
  @$pb.TagNumber(3)
  $core.int get timeoutSec => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeoutSec($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeoutSec() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeoutSec() => $_clearField(3);
}

/// Response for updating a test client's configuration.
class ClientConfigureResponse extends $pb.GeneratedMessage {
  factory ClientConfigureResponse() => ClientConfigureResponse._();

  ClientConfigureResponse._();

  factory ClientConfigureResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientConfigureResponse()..mergeFromBuffer(data, registry);
  factory ClientConfigureResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientConfigureResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientConfigureResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: ClientConfigureResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientConfigureResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientConfigureResponse copyWith(
          void Function(ClientConfigureResponse) updates) =>
      super.copyWith((message) => updates(message as ClientConfigureResponse))
          as ClientConfigureResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientConfigureResponse() / ClientConfigureResponse.new instead')
  static ClientConfigureResponse create() => ClientConfigureResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientConfigureResponse._();
  @$core.override
  ClientConfigureResponse createEmptyInstance() => ClientConfigureResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientConfigureResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientConfigureResponse>(
          ClientConfigureResponse.$_createMessage);
  static ClientConfigureResponse? _defaultInstance;
}

class MemorySize extends $pb.GeneratedMessage {
  factory MemorySize({
    $fixnum.Int64? rss,
  }) {
    final result = MemorySize._();
    if (rss != null) result.rss = rss;
    return result;
  }

  MemorySize._();

  factory MemorySize.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemorySize()..mergeFromBuffer(data, registry);
  factory MemorySize.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MemorySize()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemorySize',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: MemorySize.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'rss')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemorySize clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemorySize copyWith(void Function(MemorySize) updates) =>
      super.copyWith((message) => updates(message as MemorySize)) as MemorySize;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MemorySize() / MemorySize.new instead')
  static MemorySize create() => MemorySize._();
  static $pb.GeneratedMessage $_createMessage() => MemorySize._();
  @$core.override
  MemorySize createEmptyInstance() => MemorySize._();
  @$core.pragma('dart2js:noInline')
  static MemorySize getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemorySize>(MemorySize.$_createMessage);
  static MemorySize? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get rss => $_getI64(0);
  @$pb.TagNumber(1)
  set rss($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRss() => $_has(0);
  @$pb.TagNumber(1)
  void clearRss() => $_clearField(1);
}

/// Metrics data the server will update and send to the client. It mirrors orca load report
/// https://github.com/cncf/xds/blob/eded343319d09f30032952beda9840bbd3dcf7ac/xds/data/orca/v3/orca_load_report.proto#L15,
/// but avoids orca dependency. Used by both per-query and out-of-band reporting tests.
class TestOrcaReport extends $pb.GeneratedMessage {
  factory TestOrcaReport({
    $core.double? cpuUtilization,
    $core.double? memoryUtilization,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? requestCost,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? utilization,
  }) {
    final result = TestOrcaReport._();
    if (cpuUtilization != null) result.cpuUtilization = cpuUtilization;
    if (memoryUtilization != null) result.memoryUtilization = memoryUtilization;
    if (requestCost != null) result.requestCost.addEntries(requestCost);
    if (utilization != null) result.utilization.addEntries(utilization);
    return result;
  }

  TestOrcaReport._();

  factory TestOrcaReport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestOrcaReport()..mergeFromBuffer(data, registry);
  factory TestOrcaReport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TestOrcaReport()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestOrcaReport',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: TestOrcaReport.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'cpuUtilization')
    ..aD(2, _omitFieldNames ? '' : 'memoryUtilization')
    ..m<$core.String, $core.double>(3, _omitFieldNames ? '' : 'requestCost',
        entryClassName: 'TestOrcaReport.RequestCostEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('grpc.testing'))
    ..m<$core.String, $core.double>(4, _omitFieldNames ? '' : 'utilization',
        entryClassName: 'TestOrcaReport.UtilizationEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('grpc.testing'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestOrcaReport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestOrcaReport copyWith(void Function(TestOrcaReport) updates) =>
      super.copyWith((message) => updates(message as TestOrcaReport))
          as TestOrcaReport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TestOrcaReport() / TestOrcaReport.new instead')
  static TestOrcaReport create() => TestOrcaReport._();
  static $pb.GeneratedMessage $_createMessage() => TestOrcaReport._();
  @$core.override
  TestOrcaReport createEmptyInstance() => TestOrcaReport._();
  @$core.pragma('dart2js:noInline')
  static TestOrcaReport getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestOrcaReport>(
          TestOrcaReport.$_createMessage);
  static TestOrcaReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get cpuUtilization => $_getN(0);
  @$pb.TagNumber(1)
  set cpuUtilization($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCpuUtilization() => $_has(0);
  @$pb.TagNumber(1)
  void clearCpuUtilization() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get memoryUtilization => $_getN(1);
  @$pb.TagNumber(2)
  set memoryUtilization($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemoryUtilization() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemoryUtilization() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.double> get requestCost => $_getMap(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.double> get utilization => $_getMap(3);
}

/// Status that will be return to callers of the Hook method
class SetReturnStatusRequest extends $pb.GeneratedMessage {
  factory SetReturnStatusRequest({
    $core.int? grpcCodeToReturn,
    $core.String? grpcStatusDescription,
  }) {
    final result = SetReturnStatusRequest._();
    if (grpcCodeToReturn != null) result.grpcCodeToReturn = grpcCodeToReturn;
    if (grpcStatusDescription != null)
      result.grpcStatusDescription = grpcStatusDescription;
    return result;
  }

  SetReturnStatusRequest._();

  factory SetReturnStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetReturnStatusRequest()..mergeFromBuffer(data, registry);
  factory SetReturnStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetReturnStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetReturnStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: SetReturnStatusRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'grpcCodeToReturn')
    ..aOS(2, _omitFieldNames ? '' : 'grpcStatusDescription')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetReturnStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetReturnStatusRequest copyWith(
          void Function(SetReturnStatusRequest) updates) =>
      super.copyWith((message) => updates(message as SetReturnStatusRequest))
          as SetReturnStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SetReturnStatusRequest() / SetReturnStatusRequest.new instead')
  static SetReturnStatusRequest create() => SetReturnStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetReturnStatusRequest._();
  @$core.override
  SetReturnStatusRequest createEmptyInstance() => SetReturnStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static SetReturnStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetReturnStatusRequest>(
          SetReturnStatusRequest.$_createMessage);
  static SetReturnStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get grpcCodeToReturn => $_getIZ(0);
  @$pb.TagNumber(1)
  set grpcCodeToReturn($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGrpcCodeToReturn() => $_has(0);
  @$pb.TagNumber(1)
  void clearGrpcCodeToReturn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get grpcStatusDescription => $_getSZ(1);
  @$pb.TagNumber(2)
  set grpcStatusDescription($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGrpcStatusDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearGrpcStatusDescription() => $_clearField(2);
}

class HookRequest extends $pb.GeneratedMessage {
  factory HookRequest({
    HookRequest_HookRequestCommand? command,
    $core.int? grpcCodeToReturn,
    $core.String? grpcStatusDescription,
    $core.int? serverPort,
  }) {
    final result = HookRequest._();
    if (command != null) result.command = command;
    if (grpcCodeToReturn != null) result.grpcCodeToReturn = grpcCodeToReturn;
    if (grpcStatusDescription != null)
      result.grpcStatusDescription = grpcStatusDescription;
    if (serverPort != null) result.serverPort = serverPort;
    return result;
  }

  HookRequest._();

  factory HookRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HookRequest()..mergeFromBuffer(data, registry);
  factory HookRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HookRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HookRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: HookRequest.$_createMessage)
    ..aE<HookRequest_HookRequestCommand>(1, _omitFieldNames ? '' : 'command',
        enumValues: HookRequest_HookRequestCommand.values)
    ..aI(2, _omitFieldNames ? '' : 'grpcCodeToReturn')
    ..aOS(3, _omitFieldNames ? '' : 'grpcStatusDescription')
    ..aI(4, _omitFieldNames ? '' : 'serverPort')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HookRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HookRequest copyWith(void Function(HookRequest) updates) =>
      super.copyWith((message) => updates(message as HookRequest))
          as HookRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HookRequest() / HookRequest.new instead')
  static HookRequest create() => HookRequest._();
  static $pb.GeneratedMessage $_createMessage() => HookRequest._();
  @$core.override
  HookRequest createEmptyInstance() => HookRequest._();
  @$core.pragma('dart2js:noInline')
  static HookRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HookRequest>(
          HookRequest.$_createMessage);
  static HookRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HookRequest_HookRequestCommand get command => $_getN(0);
  @$pb.TagNumber(1)
  set command(HookRequest_HookRequestCommand value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommand() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommand() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get grpcCodeToReturn => $_getIZ(1);
  @$pb.TagNumber(2)
  set grpcCodeToReturn($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGrpcCodeToReturn() => $_has(1);
  @$pb.TagNumber(2)
  void clearGrpcCodeToReturn() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get grpcStatusDescription => $_getSZ(2);
  @$pb.TagNumber(3)
  set grpcStatusDescription($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGrpcStatusDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearGrpcStatusDescription() => $_clearField(3);

  /// Server port to listen to
  @$pb.TagNumber(4)
  $core.int get serverPort => $_getIZ(3);
  @$pb.TagNumber(4)
  set serverPort($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasServerPort() => $_has(3);
  @$pb.TagNumber(4)
  void clearServerPort() => $_clearField(4);
}

class HookResponse extends $pb.GeneratedMessage {
  factory HookResponse() => HookResponse._();

  HookResponse._();

  factory HookResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HookResponse()..mergeFromBuffer(data, registry);
  factory HookResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HookResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HookResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'grpc.testing'),
      createEmptyInstance: HookResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HookResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HookResponse copyWith(void Function(HookResponse) updates) =>
      super.copyWith((message) => updates(message as HookResponse))
          as HookResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HookResponse() / HookResponse.new instead')
  static HookResponse create() => HookResponse._();
  static $pb.GeneratedMessage $_createMessage() => HookResponse._();
  @$core.override
  HookResponse createEmptyInstance() => HookResponse._();
  @$core.pragma('dart2js:noInline')
  static HookResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HookResponse>(
          HookResponse.$_createMessage);
  static HookResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
