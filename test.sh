#!/bin/sh

set -e

test() {
  if [ "$2" != "" ]; then
    echo "----------------------------------------"
  fi
  echo "$1"
  echo "----------------------------------------"
}

test "compress"
./gzstd LICENSE
if [ ! -f "LICENSE.z" ]; then
  echo "archive not compressed"
  exit 1
fi

test "decompress"
./gunzstd LICENSE.z
if [ ! -f "LICENSE.uz" ]; then
  echo "archive not decompressed"
  exit 1
fi

test "compare"
diff LICENSE LICENSE.uz
if [ $? -ne 0 ]; then
  exit 1
fi

rm LICENSE.z LICENSE.uz

echo "done"
