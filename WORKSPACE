workspace(name = "com_github_ceason_spark_bazel_k8s_demo")

rules_scala_version = "095dcc33a2620056e177da879a544d127748d966"  # update this as needed
RULES_DOCKER_VERSION = "bf925ec58ad96f2ead21cd8379caedbe3c26efc9"
RULES_K8S_VERSION = "3756369d4920033c32c12d16207e8ee14fee1b18"

http_archive(
    name = "io_bazel_rules_scala",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
)

http_archive(
    name = "io_bazel_rules_docker",
    url = "https://github.com/bazelbuild/rules_docker/archive/%s.tar.gz" % RULES_DOCKER_VERSION,
    strip_prefix = "rules_docker-%s" % RULES_DOCKER_VERSION,
)

git_repository(
    name = "io_bazel_rules_k8s",
    commit = RULES_K8S_VERSION,
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

load("//spark:repositories.bzl", "spark_rules_dependencies")

container_repositories()

scala_repositories()

scala_register_toolchains()

_scala_image_repos()


k8s_repositories()

spark_rules_dependencies()

container_pull(
    name = "openjdk_8",
    registry = "index.docker.io",
    repository = "library/openjdk",
    tag = "8-jre",
    visibility = ["//visibility:public"],
)
