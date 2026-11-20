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

import 'package:protobuf/protobuf.dart' as $pb;

/// The type of payload that should be returned.
class PayloadType extends $pb.ProtobufEnum {
  /// Compressable text format.
  static const PayloadType COMPRESSABLE =
      PayloadType._(0, _omitEnumNames ? '' : 'COMPRESSABLE');

  static const $core.List<PayloadType> values = <PayloadType>[
    COMPRESSABLE,
  ];

  static final $core.List<PayloadType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 0);
  static PayloadType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PayloadType._(super.value, super.name);
}

/// The type of route that a client took to reach a server w.r.t. gRPCLB.
/// The server must fill in "fallback" if it detects that the RPC reached
/// the server via the "gRPCLB fallback" path, and "backend" if it detects
/// that the RPC reached the server via "gRPCLB backend" path (i.e. if it got
/// the address of this server from the gRPCLB server BalanceLoad RPC). Exactly
/// how this detection is done is context and server dependent.
class GrpclbRouteType extends $pb.ProtobufEnum {
  /// Server didn't detect the route that a client took to reach it.
  static const GrpclbRouteType GRPCLB_ROUTE_TYPE_UNKNOWN =
      GrpclbRouteType._(0, _omitEnumNames ? '' : 'GRPCLB_ROUTE_TYPE_UNKNOWN');

  /// Indicates that a client reached a server via gRPCLB fallback.
  static const GrpclbRouteType GRPCLB_ROUTE_TYPE_FALLBACK =
      GrpclbRouteType._(1, _omitEnumNames ? '' : 'GRPCLB_ROUTE_TYPE_FALLBACK');

  /// Indicates that a client reached a server as a gRPCLB-given backend.
  static const GrpclbRouteType GRPCLB_ROUTE_TYPE_BACKEND =
      GrpclbRouteType._(2, _omitEnumNames ? '' : 'GRPCLB_ROUTE_TYPE_BACKEND');

  static const $core.List<GrpclbRouteType> values = <GrpclbRouteType>[
    GRPCLB_ROUTE_TYPE_UNKNOWN,
    GRPCLB_ROUTE_TYPE_FALLBACK,
    GRPCLB_ROUTE_TYPE_BACKEND,
  ];

  static final $core.List<GrpclbRouteType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static GrpclbRouteType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GrpclbRouteType._(super.value, super.name);
}

class LoadBalancerStatsResponse_MetadataType extends $pb.ProtobufEnum {
  static const LoadBalancerStatsResponse_MetadataType UNKNOWN =
      LoadBalancerStatsResponse_MetadataType._(
          0, _omitEnumNames ? '' : 'UNKNOWN');
  static const LoadBalancerStatsResponse_MetadataType INITIAL =
      LoadBalancerStatsResponse_MetadataType._(
          1, _omitEnumNames ? '' : 'INITIAL');
  static const LoadBalancerStatsResponse_MetadataType TRAILING =
      LoadBalancerStatsResponse_MetadataType._(
          2, _omitEnumNames ? '' : 'TRAILING');

  static const $core.List<LoadBalancerStatsResponse_MetadataType> values =
      <LoadBalancerStatsResponse_MetadataType>[
    UNKNOWN,
    INITIAL,
    TRAILING,
  ];

  static final $core.List<LoadBalancerStatsResponse_MetadataType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static LoadBalancerStatsResponse_MetadataType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LoadBalancerStatsResponse_MetadataType._(super.value, super.name);
}

/// Type of RPCs to send.
class ClientConfigureRequest_RpcType extends $pb.ProtobufEnum {
  static const ClientConfigureRequest_RpcType EMPTY_CALL =
      ClientConfigureRequest_RpcType._(0, _omitEnumNames ? '' : 'EMPTY_CALL');
  static const ClientConfigureRequest_RpcType UNARY_CALL =
      ClientConfigureRequest_RpcType._(1, _omitEnumNames ? '' : 'UNARY_CALL');

  static const $core.List<ClientConfigureRequest_RpcType> values =
      <ClientConfigureRequest_RpcType>[
    EMPTY_CALL,
    UNARY_CALL,
  ];

  static final $core.List<ClientConfigureRequest_RpcType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static ClientConfigureRequest_RpcType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ClientConfigureRequest_RpcType._(super.value, super.name);
}

class HookRequest_HookRequestCommand extends $pb.ProtobufEnum {
  /// Default value
  static const HookRequest_HookRequestCommand UNSPECIFIED =
      HookRequest_HookRequestCommand._(0, _omitEnumNames ? '' : 'UNSPECIFIED');

  /// Start the HTTP endpoint
  static const HookRequest_HookRequestCommand START =
      HookRequest_HookRequestCommand._(1, _omitEnumNames ? '' : 'START');

  /// Stop
  static const HookRequest_HookRequestCommand STOP =
      HookRequest_HookRequestCommand._(2, _omitEnumNames ? '' : 'STOP');

  /// Return from HTTP GET/POST
  static const HookRequest_HookRequestCommand RETURN =
      HookRequest_HookRequestCommand._(3, _omitEnumNames ? '' : 'RETURN');

  static const $core.List<HookRequest_HookRequestCommand> values =
      <HookRequest_HookRequestCommand>[
    UNSPECIFIED,
    START,
    STOP,
    RETURN,
  ];

  static final $core.List<HookRequest_HookRequestCommand?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static HookRequest_HookRequestCommand? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HookRequest_HookRequestCommand._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
