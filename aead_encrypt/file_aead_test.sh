#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

set -euo pipefail

#############################################################################
##### Tests for file_aead python example.

FILE_AEAD_CLI="$1"
KEYSET_FILE="$2"

DATA_FILE="$TEST_TMPDIR/example_data.txt"
OUTPUT_FILE="$TEST_TMPDIR/output"
TEMP_FILE="$TEST_TMPDIR/temp"
ASSOCIATED_DATA="Example associated data"

echo "This is some message to be encrypted." > "$DATA_FILE"

#############################################################################

# A helper function for getting the return code of a command that may fail
# Temporarily disables error safety and stores return value in $TEST_STATUS
# Usage:
# % test_command somecommand some args
# % echo $TEST_STATUS
test_command() {
  set +e
  "$@"
  TEST_STATUS=$?
  set -e
}

#############################################################################
#### Test good key and correct MAC verification.
test_name="normal_verification"
echo "+++ Starting test $test_name..."

##### Run verification
$FILE_AEAD_CLI "$KEYSET_FILE" encrypt "$ASSOCIATED_DATA" < "$DATA_FILE" > "$OUTPUT_FILE"
$FILE_AEAD_CLI "$KEYSET_FILE" decrypt "$ASSOCIATED_DATA" < "$OUTPUT_FILE" > "$TEMP_FILE"

cat "$DATA_FILE"
cat "$TEMP_FILE"

if cmp -s "$DATA_FILE" "$TEMP_FILE"; then
  echo "+++ Success: Decrypted data matched original"
else
  echo "--- Failure: Decrypted data did not match original"
  exit 1
fi


# TODO more tests, in the vein of those below
##############################################################################
##### Test good key and incorrect MAC verification.
#test_name="incorrect_mac_verification"
#echo "+++ Starting test $test_name..."

###### Create a plaintext and incorrect MAC.
#echo "ABCABCABCD" > "$EXPECTED_MAC_FILE"

###### Run verification.
#test_command $FILE_MAC_CLI $KEYSET_FILE $DATA_FILE $EXPECTED_MAC_FILE

#if [[ $TEST_STATUS -ne 0 ]]; then
#  echo "+++ Success: MAC verification reported non-match for incorrect MAC."
#else
#  echo "--- Failure: MAC verification reported match for incorrect MAC"
#  exit 1
#fi


##############################################################################
##### Test good key and non-hexadecimal MAC verification.
#test_name="non_hex_mac_verification"
#echo "+++ Starting test $test_name..."

###### Create a plaintext and non-hexadecimal MAC.
#echo "SMDHTBFYGM" > "$EXPECTED_MAC_FILE"

###### Run verification.
#test_command $FILE_MAC_CLI $KEYSET_FILE $DATA_FILE $EXPECTED_MAC_FILE

#if [[ $TEST_STATUS -ne 0 ]]; then
#  echo "+++ Success: MAC verification reported non-match for non-hex MAC."
#else
#  echo "--- Failure: MAC verification reported match for non-hex MAC"
#  exit 1
#fi


##############################################################################
##### Test good key MAC computation.
#test_name="mac_computation"
#echo "+++ Starting test $test_name..."

###### Create a plaintext and actual MAC.
#MAC_OUTPUT_FILE="$TEST_TMPDIR/computed_mac_log.txt"

###### Run computation.
#$FILE_MAC_CLI $KEYSET_FILE $DATA_FILE --alsologtostderr 2> "$MAC_OUTPUT_FILE"
###### Check that the correct MAC was produced in the logs
#test_command grep --quiet --ignore-case "$CORRECT_MAC" "$MAC_OUTPUT_FILE"

#if [[ $TEST_STATUS -eq 0 ]]; then
#  echo "+++ Success: MAC computation was successful."
#else
#  echo "--- Failure: MAC computation was unsuccessful"
#  exit 1
#fi


##############################################################################
##### Test bad key MAC computation.
#test_name="bad_key_computation"
#echo "+++ Starting test $test_name..."

###### Create a plaintext and bad keyset.
#BAD_KEY_FILE="$TEST_TMPDIR/bad_key.txt"
#echo "not a key" > "$BAD_KEY_FILE"

###### Run computation.
#test_command $FILE_MAC_CLI $BAD_KEY_FILE $DATA_FILE

#if [[ $TEST_STATUS -ne 0 ]]; then
#  echo "+++ Success: MAC computation failed with bad keyset."
#else
#  echo "--- Failure: MAC computation did not fail with bad keyset"
#  exit 1
#fi
