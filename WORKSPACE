workspace(name = "examples_python")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "tink_base",
    urls = ["https://github.com/google/tink/archive/master.zip"],
    strip_prefix = "tink-master/",
)

http_archive(
    name = "tink_py",
    urls = ["https://github.com/google/tink/archive/master.zip"],
    strip_prefix = "tink-master/python",
)

http_archive(
    name = "tink_cc",
    urls = ["https://github.com/google/tink/archive/master.zip"],
    strip_prefix = "tink-master/cc",
)


# Load Tink dependencies. Note that the Python dependencies have to be loaded
# first, as they rely on a newer version of rules_python.
load("@tink_py//:tink_py_deps.bzl", "tink_py_deps")
tink_py_deps()

load("@tink_py//:tink_py_deps_init.bzl", "tink_py_deps_init")
tink_py_deps_init()

load("@tink_py_pip_deps//:requirements.bzl", "pip_install")
pip_install()

load("@tink_base//:tink_base_deps.bzl", "tink_base_deps")
tink_base_deps()

load("@tink_base//:tink_base_deps_init.bzl", "tink_base_deps_init")
tink_base_deps_init()

load("@tink_cc//:tink_cc_deps.bzl", "tink_cc_deps")
tink_cc_deps()

load("@tink_cc//:tink_cc_deps_init.bzl", "tink_cc_deps_init")
tink_cc_deps_init()

# Load rules_python for your pip dependencies
http_archive(
    name = "rules_python",
    strip_prefix = "rules_python-94677401bc56ed5d756f50b441a6a5c7f735a6d4",
    url = "https://github.com/bazelbuild/rules_python/archive/94677401bc56ed5d756f50b441a6a5c7f735a6d4.zip",
    sha256 = "de39bc4d6605e6d395faf5e07516c64c8d833404ee3eb132b5ff1161f9617dec",
)
load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()
load("@rules_python//python:pip.bzl", "pip_repositories", "pip3_import")
pip_repositories()
pip3_import(
   name = "pip_deps",
   requirements = "//:requirements.txt",
)
load("@pip_deps//:requirements.bzl", "pip_install")
pip_install()
