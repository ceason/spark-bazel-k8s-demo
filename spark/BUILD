load("@io_bazel_rules_docker//container:image.bzl", "container_image")

exports_files(["k8s-spark-submit.tpl.sh"])

container_image(
    name = "hadoop",
    base = "@openjdk_8//image",
    directory = "opt/hadoop/lib/native",
    files = [
        "@hadoop//:lib_native",
    ],
)

container_image(
    name = "base_image",
    base = ":hadoop",
    cmd = None,
    entrypoint = ["/entrypoint.sh"],
    files = [
        ":entrypoint.sh",
        "@jq//file",
    ],
    symlinks = {
        "/usr/local/bin/jq": "/jq-linux64",
    },
    visibility = ["//visibility:public"],
)
