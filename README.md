# Tink Python external example (unofficial)
This is a small test project showing how to use Tink Python as an external developer, using Bazel. Hopefully Tink will be [usable through pip](https://github.com/google/tink/issues/248#issuecomment-606350083) soon as well.

**This project is not an official Tink project and I might be wrong about how things work.**

The WORKSPACE file is essentially copied from Tink's [`examples/python/WORKSPACE`](https://github.com/google/tink/blob/master/examples/python/WORKSPACE).
The `BUILD.bazel`, `file_aead_cleartext.py`, and its test are heavily inspired by Tink's
Python example [`file_mac`](https://github.com/google/tink/tree/master/examples/python/file_mac). I decided to do an AEAD version
instead just for some variety.

## Python File AEAD

This is a command-line tool that can encrypt/decrypt from stdin to stdout using Tink's [AEAD](https://github.com/google/tink/blob/master/docs/PRIMITIVES.md#authenticated-encryption-with-associated-data).

It demonstrates the basic steps of using Tink, namely loading key material,
obtaining a primitive, and using the primitive to do crypto.

The key material was generated with:

```shell
tinkey create-keyset --key-template AES128_GCM --out aes_gcm_128_test_keyset.json
```

### Build and Run

#### Bazel

```shell
git clone https://github.com/expectocode/tink-py-external
cd tink-py-external
bazelisk build ... # This takes a while as it has to build the dependencies
echo "some data" > /tmp/input_file

./bazel-bin/aead_encrypt/file_aead_cleartext aead_encrypt/aes_gcm_128_test_keyset.json \
    encrypt "example associated data" < /tmp/input_file > /tmp/output_file

# You must use the same associated data to decrypt.
# This should print out the original contents of input_file
./bazel-bin/aead_encrypt/file_aead_cleartext aead_encrypt/aes_gcm_128_test_keyset.json \
    decrypt "example associated data" < /tmp/output_file
```
