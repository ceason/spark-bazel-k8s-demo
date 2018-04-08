load("@io_bazel_rules_docker//container:image.bzl", "container_image")
load("@io_bazel_rules_docker//scala:image.bzl", "scala_image")


def spark_scala_image(name, main_class,
           files = [],
           base = "//spark:base_image",
           **kwargs):
    """
        asdf
    """
    scala_image(
        name = "%s.image" % name,
        base = base,
        main_class = main_class,
        **kwargs
    )

    container_image(
        name = name,
        base = ":%s.image" % name,
        cmd = None,
        directory = "app",
        entrypoint = ["/entrypoint.sh"],
        env = {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "MAIN_CLASS": main_class,
        },
        files = files,
    )




