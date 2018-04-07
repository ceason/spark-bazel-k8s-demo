load("@io_bazel_rules_docker//container:image.bzl", "container_image")
load("@io_bazel_rules_docker//container:push.bzl", "container_push")
load("@io_bazel_rules_docker//scala:image.bzl", "scala_image")

def _spark_submit_impl(ctx):
    published_image = ctx.attr.published_image.files.to_list()[0]
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.executable,
        is_executable = True,
        substitutions = {
            "${MAIN_CLASS}": ctx.attr.main_class,
            "${K8S_CONTEXT}": ctx.attr.kubectl_context or "",
            "${K8S_NAMESPACE}": ctx.attr.namespace or "",
            "${K8S_APP_NAME}": ctx.attr.app_name,
            "${K8S_APP_JAR}": ctx.attr.app_jar,
            "${K8S_SERVICE_ACCOUNT_NAME}": ctx.attr.service_account,
            "${IMAGE_PUSH_OUTPUT_FILE}": published_image.short_path,
        }
    )
    runfiles = ctx.runfiles(
        files=ctx.attr._runfiles.files.to_list() + [published_image])
    return [DefaultInfo(runfiles=runfiles)]


spark_submit = rule(
    implementation = _spark_submit_impl,
    attrs = {
        "main_class": attr.string(mandatory=True),
        "app_name": attr.string(mandatory=True),
        "app_jar": attr.string(mandatory=True),
        "kubectl_context": attr.string(),
        "service_account": attr.string(mandatory=True),
        "namespace": attr.string(),
        "published_image": attr.label(mandatory=True, allow_files=True),
        "_runfiles": attr.label(allow_files=True,
                                default=Label("@apache_spark_on_k8s//:assembly")),
        "_template": attr.label(allow_files=True, single_file=True,
                                default=Label("//spark:k8s-spark-submit.tpl.sh")),
    },
    executable=True,
)


def scala_spark_app(name, main_class, image_repository,
           k8s_context = None, k8s_namespace = None, files = [],
           image_base = "//spark:base_image",
           image_registry = "index.docker.io",
           image_tag = "dev", k8s_service_account = "default",
           **kwargs):
    """
        asdf
    """
    scala_image(
        name = name,
        base = image_base,
        main_class = main_class,
        **kwargs
    )

    container_image(
        name = "image",
        base = ":%s" % name,
        cmd = None,
        directory = "app",
        entrypoint = ["/entrypoint.sh"],
        env = {"PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"},
        files = files,
    )

    container_push(
        name = "image.push",
        format = "Docker",
        image = ":image",
        registry = image_registry,
        repository = image_repository,
        tag = image_tag,
    )

    native.genrule(
        name = "image.published_digest",
        outs = ["image_hash.txt"],
        cmd = "$(location :image.push)|tee $@",
        tools = [":image.push"],
    )

    spark_submit(
        name = "submit",
        app_jar = "local:///fake.jar",
        app_name = name,
        kubectl_context = k8s_context,
        main_class = main_class,
        namespace = k8s_namespace,
        published_image = ":image.published_digest",
        service_account = k8s_service_account,
    )





