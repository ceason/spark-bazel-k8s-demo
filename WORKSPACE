workspace(name = "com_github_ceason_bazel_test")

rules_scala_version = "095dcc33a2620056e177da879a544d127748d966"  # update this as needed

http_archive(
    name = "io_bazel_rules_scala",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
)

RULES_DOCKER_VERSION = "bf925ec58ad96f2ead21cd8379caedbe3c26efc9"

http_archive(
    name = "io_bazel_rules_docker",
    url = "https://github.com/bazelbuild/rules_docker/archive/%s.tar.gz" % RULES_DOCKER_VERSION,
    strip_prefix = "rules_docker-%s" % RULES_DOCKER_VERSION,
)

new_http_archive(
    name = "apache_spark_on_k8s",
    workspace_file_content = """
workspace(name = "apache_spark_on_k8s")
""",
    build_file_content = """
package(default_visibility = ["//visibility:public"])
filegroup (
    name = "assembly",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
java_import(
    name = "spark_assembly",
    jars = glob(["jars/*.jar"]),
    visibility = ["//visibility:public"],
)
""",
    strip_prefix = "spark-2.2.0-k8s-0.5.0-bin-2.7.3",
    sha256 = "a1a40fae019e50db7468b55bfba89c3cfa01483c5eb2c6c5220d019bf395468d",
    url = "https://github.com/apache-spark-on-k8s/spark/releases/download/v2.2.0-kubernetes-0.5.0/spark-2.2.0-k8s-0.5.0-bin-with-hadoop-2.7.3.tgz",
)

new_http_archive(
    name = "hadoop",
    workspace_file_content = """
workspace(name = "hadoop")
""",
    build_file_content = """
package(default_visibility = ["//visibility:public"])
filegroup (
    name = "lib_native",
    srcs = glob(["lib/native/*"]),
    visibility = ["//visibility:public"],
)
""",
    strip_prefix = "hadoop-2.7.5",
    sha256 = "0bfc4d9b04be919be2fdf36f67fa3b4526cdbd406c512a7a1f5f1b715661f831",
    urls = [
        "http://apache.claz.org/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz",
        "http://apache.mirrors.tds.net/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz",
        "http://apache.mirrors.ionfish.org/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz",
    ]
)


git_repository(
    name = "io_bazel_rules_k8s",
    commit = "3756369d4920033c32c12d16207e8ee14fee1b18",
    remote = "https://github.com/bazelbuild/rules_k8s.git",
)

#load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
load("//third_party:skoola.bzl", "scala_repositories")
load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
load("@io_bazel_rules_docker//container:pull.bzl", "container_pull")
load(
    "@io_bazel_rules_docker//container:container.bzl",
    container_repositories = "repositories",
)
load(
    "@io_bazel_rules_docker//scala:image.bzl",
    _scala_image_repos = "repositories",
)

load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_repositories")

container_repositories()

scala_repositories()

scala_register_toolchains()

_scala_image_repos()




k8s_repositories()

container_pull(
    name = "openjdk_8",
    registry = "index.docker.io",
    repository = "library/openjdk",
    tag = "8-jre",
    visibility = ["//visibility:public"],
)
