#!/usr/bin/env bash
# Runs each integration_test/**/*_test.dart file as its own `flutter test` invocation.
#
# Why: `flutter test integration_test -d macos` (pointed at the whole directory) fails
# after the first file — the previous test run's app process doesn't tear down cleanly
# before the next file tries to launch its own ("Unable to start the app on the device").
# This is a real constraint of running desktop integration tests this way, not a flake;
# running one file per `flutter test` invocation works reliably.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f test.env.json ]; then
  echo "Missing test.env.json — copy test.env.example.json and fill it in." >&2
  exit 1
fi

device="${INTEGRATION_TEST_DEVICE:-macos}"
status=0

while IFS= read -r -d '' file; do
  echo "── flutter test $file -d $device"
  if ! flutter test "$file" -d "$device" --dart-define-from-file=test.env.json; then
    status=1
  fi
done < <(find integration_test -name "*_test.dart" -print0 | sort -z)

exit $status
