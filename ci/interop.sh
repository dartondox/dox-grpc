#!/usr/bin/env bash
# Tests dox_grpc with real gRPC tools. It starts the interop server
# (test/interop/server.dart) and calls it:
#
#   ci/interop.sh direct    grpc-go interop client, straight to Dox
#   ci/interop.sh grpcurl   grpcurl with -proto files (no reflection), and
#                           the health sync between isolates (ISOLATES=2)
#   ci/interop.sh nginx     interop client through nginx (grpc_pass)
#   ci/interop.sh caddy     interop client through Caddy (h2c)
#
# Needs: the Dart deps (dart pub get), Docker for the proxies, and the
# tools in PATH or set here:
#   INTEROP_CLIENT  grpc-go interop client:
#                   go install google.golang.org/grpc/interop/client@v1.85.0
#   GRPCURL         go install github.com/fullstorydev/grpcurl/cmd/grpcurl@v1.9.4
# ISOLATES (default 1) sets the isolates of the server.
#
# The .proto files in test/interop/protos and protos/ come from the grpc
# release v1.85.3 (src/proto/grpc/testing/*.proto and the health proto). To
# update: copy the new files from that release, then make the Dart code with
#   protoc --dart_out=grpc:test/interop/generated -Itest/interop/protos \
#     test/interop/protos/src/proto/grpc/testing/*.proto
#
# It fails when one case fails. It stops the server and the containers it
# started.
set -euo pipefail

mode=${1:?usage: ci/interop.sh direct|grpcurl|nginx|caddy}
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

port=10000
proxy_port=8080
isolates=${ISOLATES:-1}
client=${INTEROP_CLIENT:-client}
grpcurl=${GRPCURL:-grpcurl}
nginx_image=nginx:1.29.3-alpine@sha256:b3c656d55d7ad751196f21b7fd2e8d4da9cb430e32f646adcf92441b72f82b14
caddy_image=caddy:2.10.2-alpine@sha256:4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d

# grpc-go's interop client has no gzip cases. Gzip is tested in
# test/e2e_test.dart with package:grpc.
all_cases="empty_unary large_unary client_streaming server_streaming
ping_pong empty_stream timeout_on_sleeping_server cancel_after_begin
cancel_after_first_response status_code_and_message special_status_message
custom_metadata unimplemented_method unimplemented_service"

server_pid=
container=
work=$(mktemp -d)

cleanup() {
  [ -n "$container" ] && docker rm -f "$container" >/dev/null 2>&1 || true
  [ -n "$server_pid" ] && kill "$server_pid" 2>/dev/null || true
  rm -rf "$work"
}
trap cleanup EXIT

health() {
  "$grpcurl" -plaintext -max-time 5 -import-path protos \
    -proto grpc/health/v1/health.proto "$@" grpc.health.v1.Health/Check
}

# waits until $1 answers the health check
wait_ready() {
  for _ in $(seq 1 120); do
    if health "$1" >/dev/null 2>&1; then return 0; fi
    if [ -n "$server_pid" ] && ! kill -0 "$server_pid" 2>/dev/null; then
      echo "the server stopped"
      cat "$work/server.log"
      exit 1
    fi
    sleep 0.5
  done
  echo "$1 is not ready"
  cat "$work/server.log"
  [ -n "$container" ] && docker logs "$container" | tail -50
  exit 1
}

# runs the interop cases $2 against host:port $1
run_cases() {
  local target=$1 failed=0
  for c in $2; do
    if timeout 60 "$client" --server_host="${target%:*}" \
      --server_port="${target#*:}" --use_tls=false --test_case="$c" \
      >"$work/case.log" 2>&1; then
      echo "PASS $c"
    else
      echo "FAIL $c"
      cat "$work/case.log"
      failed=1
    fi
  done
  return $failed
}

dart run test/interop/server.dart --port $port --isolates "$isolates" \
  >"$work/server.log" 2>&1 &
server_pid=$!
wait_ready 127.0.0.1:$port

case $mode in
direct)
  run_cases 127.0.0.1:$port "$all_cases"
  ;;
grpcurl)
  test_proto=(-plaintext -max-time 10 -import-path test/interop/protos
    -proto src/proto/grpc/testing/test.proto)
  set -x
  out=$("$grpcurl" "${test_proto[@]}" -d '{"response_size": 3}' \
    127.0.0.1:$port grpc.testing.TestService/UnaryCall)
  grep -q '"body": "AAAA"' <<<"$out"
  out=$("$grpcurl" "${test_proto[@]}" \
    -d '{"response_parameters": [{"size": 1}, {"size": 2}, {"size": 3}]}' \
    127.0.0.1:$port grpc.testing.TestService/StreamingOutputCall)
  [ "$(grep -c '"body"' <<<"$out")" = 3 ]
  out=$(health -d '{"service": "grpc.testing.TestService"}' 127.0.0.1:$port)
  grep -q '"status": "SERVING"' <<<"$out"
  out=$(health 127.0.0.1:$port)
  grep -q '"status": "SERVING"' <<<"$out"
  # an unknown service: grpcurl exits with the status
  if "$grpcurl" "${test_proto[@]}" 127.0.0.1:$port \
    grpc.testing.UnimplementedService/UnimplementedCall 2>"$work/err"; then
    exit 1
  fi
  grep -q Unimplemented "$work/err"
  # A health change in one isolate reaches all of them. Each grpcurl call
  # is a new connection, and Linux spreads them over the isolates.
  "$grpcurl" "${test_proto[@]}" 127.0.0.1:$port \
    grpc.testing.XdsUpdateHealthService/SetNotServing
  sleep 0.5
  # The server sends its isolate id in the x-dox-isolate header. All checks
  # must see NOT_SERVING, and at least 2 isolates must have answered.
  ids=
  for _ in $(seq 1 20); do
    out=$(health -v -d '{"service": "grpc.testing.TestService"}' \
      127.0.0.1:$port 2>&1)
    grep -q '"status": "NOT_SERVING"' <<<"$out"
    ids+=$(sed -n 's/^x-dox-isolate: *//p' <<<"$out" | tr -d '\r')$'\n'
  done
  [ "$(sort -u <<<"$ids" | grep -c .)" -ge 2 ] || {
    echo "fewer than 2 isolates answered: $ids"
    exit 1
  }
  set +x
  echo "grpcurl: all checks passed"
  ;;
nginx | caddy)
  if [ "$mode" = nginx ]; then
    cat >"$work/conf" <<EOF
events {}
http {
  server {
    listen $proxy_port;
    http2 on;
    location / {
      grpc_pass grpc://host.docker.internal:$port;
    }
  }
}
EOF
    image=$nginx_image
    mount=/etc/nginx/nginx.conf
  else
    cat >"$work/conf" <<EOF
{
  auto_https off
  admin off
  servers {
    protocols h1 h2c
  }
}
:$proxy_port {
  reverse_proxy h2c://host.docker.internal:$port
}
EOF
    image=$caddy_image
    mount=/etc/caddy/Caddyfile
  fi
  container=$(docker run -d --rm --add-host=host.docker.internal:host-gateway \
    -p $proxy_port:$proxy_port -v "$work/conf:$mount:ro" "$image")
  wait_ready 127.0.0.1:$proxy_port
  if ! run_cases 127.0.0.1:$proxy_port "$all_cases"; then
    docker logs "$container" | tail -50
    exit 1
  fi
  ;;
*)
  echo "unknown mode $mode"
  exit 2
  ;;
esac
