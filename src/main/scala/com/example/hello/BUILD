load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library", "scala_binary", "scala_test")
load("@io_bazel_rules_docker//container:container.bzl", "container_push")
load("@io_bazel_rules_docker//scala:image.bzl", "scala_image")
load("@io_bazel_rules_k8s//k8s:object.bzl", "k8s_object")

scala_binary(
    name = "hello",
    srcs = ["HelloTest.scala"],
    main_class = "com.example.hello.HelloTest",
)

scala_image(
    name = "hellotest",
    srcs = ["HelloTest.scala"],
    main_class = "com.example.hello.HelloTest",
)

container_push(
    name = "push_hellotest",
    format = "Docker",
    image = ":hellotest",
    registry = "index.docker.io",
    repository = "netchris/hellotest",
    tag = "dev",
)

k8s_object(
    name = "dev",
    cluster = "k8s-kubetest",
    # An optional collection of docker_build images to publish
    # when this target is bazel run.  The digest of the published
    # image is substituted as a part of the resolution process.
    images = {
        "index.docker.io/netchris/hellotest:dev": ":hellotest",
    },
    kind = "deployment",
    namespace = "default",
    # A template of a Kubernetes Deployment object yaml.
    template = ":hello-deployment.yaml",
)
