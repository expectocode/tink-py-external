# Copyright 2019 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""A command-line utility for encrypting and decrypting stdin to stdout.

It loads cleartext keys from disk - this is not recommended!

It requires 3 arguments:
  keyset-file: name of the file with the keyset to be used for the AEAD crypto
  operation: either 'encrypt' or 'decrypt'
  associated-data: string to be used (in utf-8 encoded form) as associated data
      for the AEAD encryption / decryption.

It takes input data on standard input, and writes its output to standard
output. Both streams are considered byte streams (not text).
"""

from __future__ import absolute_import
from __future__ import division
# Placeholder for import for type annotations
from __future__ import print_function

import binascii
import sys

# Special imports
from absl import app
from absl import flags
from absl import logging
import tink
from tink.core import cleartext_keyset_handle

FLAGS = flags.FLAGS


def main(argv):
    if len(argv) != 4:
        raise app.UsageError(
            'Expected 3 arguments, got %d.\n'
            'Usage: %s keyset-file (encrypt | decrypt) associated-data' %
            (len(argv) - 1, argv[0]))

    keyset_filename = argv[1]
    operation = argv[2]
    aad = argv[3].encode('utf-8') # TODO take hex and binascii.unhexlify

    if operation not in ('encrypt', 'decrypt'):
        logging.error('Operation %s not recognised', operation)
        return 1


    # Initialise Tink.
    try:
        tink.tink_config.register()
    except tink.TinkError as e:
        logging.error('Error initialising Tink: %s', e)
        return 1

    # Read the keyset.
    with open(keyset_filename, 'rb') as keyset_file:
        try:
            text = keyset_file.read()
            keyset = cleartext_keyset_handle.read(tink.JsonKeysetReader(text))
        except tink.TinkError as e:
            logging.error('Error reading key: %s', e)
            return 1

    # Get the primitive.
    try:
        cipher = keyset.primitive(tink.Aead)
    except tink.TinkError as e:
        logging.error('Error creating primitive: %s', e)
        return 1

    # Compute the operation.
    input_data = sys.stdin.buffer.read()

    try:
        if operation == 'encrypt':
            output_data = cipher.encrypt(input_data, aad)
        elif operation == 'decrypt':
            output_data = cipher.decrypt(input_data, aad)
        else:
            # Unreachable: We checked operation at the start.
            logging.error('(unreachable) Operation %s not recognised', operation)
            return 1
    except tink.TinkError as e:
        logging.error('Operation failed: %s', e)
        return 1

    sys.stdout.buffer.write(output_data)
    return 0


if __name__ == '__main__':
    app.run(main)
