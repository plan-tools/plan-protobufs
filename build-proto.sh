#!/bin/bash
#
#
# See:
#    plan-systems/plan-protobuf/README.md
#    http://plan-systems.org
#
#


if [[ $# -ne 3 ]]; then
    echo "Usage: ./build-proto.sh <pkg_name> <proto_compiler> <out_path>"
    echo "proto_compiler: go|gofast|csharp"
    exit
fi

PKG_NAME=$1
PROTO_VERB=$2
OUT_PATH=$3


# Dir of where this script resides -- should be alongside all the available proto fiiles
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


if [[ "$OSTYPE" == "linux-gnu" ]]; then
    BIN_DIR="$SELF_DIR/Grpc.Tools/tools/linux_x64"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    BIN_DIR="$SELF_DIR/Grpc.Tools/tools/macosx_x64"
else
    echo "Unknown environment"
    exit
fi

protoc="$BIN_DIR/protoc"
protoc_vers=$($protoc --version)

if [[ 0 == 1 ]]; then
    echo
    echo
    echo "\$SELF_DIR=$SELF_DIR"
    echo "  \$protoc=$protoc"
    echo
    echo "Using: $protoc_vers"
    echo
fi


proto_pathname="$SELF_DIR/pkg/$PKG_NAME/$PKG_NAME.proto"
proto_include=$(dirname "${proto_pathname}")

# Let plan-protobuf's pkg dir be a root include
proto_include=$(dirname  "${proto_include}")
#echo "include::::::::: $proto_include"
#echo "OUT ---> $OUT_PATH"

printf "$protoc_vers: %18s  --$PROTO_VERB-->  $proto_pathname\n" "$PKG_NAME"

if [[ "$PROTO_VERB" == "go" ]]; then
    $protoc -I="$proto_include"  -I="$GOPATH/src" \
            --go_out="$OUT_PATH" \
            "$proto_pathname"
fi

if [[ "$PROTO_VERB" == "gofast" ]]; then
    $protoc -I="$proto_include"  -I="$GOPATH/src" \
            --gofast_out=plugins="grpc:$OUT_PATH" \
            "$proto_pathname"
fi

if [[ "$PROTO_VERB" == "csharp" ]]; then
    $protoc -I="$proto_include"  -I="$GOPATH/src" \
            --csharp_out "$OUT_PATH" \
            --grpc_out "$OUT_PATH" \
            --plugin=protoc-gen-grpc="$BIN_DIR/grpc_csharp_plugin" \
            "$proto_pathname"
fi
