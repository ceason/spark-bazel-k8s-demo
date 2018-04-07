SCALA_BUILD_FILE = """
# scala.BUILD
java_import(
    name = "scala-xml",
    jars = glob(["lib/scala-xml_2.11-*.jar"]),
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-parser-combinators",
    jars = glob(["lib/scala-parser-combinators_2.11-*.jar"]),
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-library",
    jars = ["lib/scala-library.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-compiler",
    jars = ["lib/scala-compiler.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-reflect",
    jars = ["lib/scala-reflect.jar"],
    visibility = ["//visibility:public"],
)
"""

def scala_repositories(scala_version="2.11.8"):
  native.new_http_archive(
    name = "scala",
    strip_prefix = "scala-%s" % scala_version,
    url = "https://downloads.lightbend.com/scala/%s/scala-%s.tgz" % (scala_version, scala_version),
    build_file_content = SCALA_BUILD_FILE,
  )

  # scalatest has macros, note http_jar is invoking ijar
  native.http_jar(
    name = "scalatest",
    url = "https://mirror.bazel.build/oss.sonatype.org/content/groups/public/org/scalatest/scalatest_2.11/2.2.6/scalatest_2.11-2.2.6.jar",
    sha256 = "f198967436a5e7a69cfd182902adcfbcb9f2e41b349e1a5c8881a2407f615962",
  )

  native.maven_server(
    name = "scalac_deps_maven_server",
    url = "https://mirror.bazel.build/repo1.maven.org/maven2/",
  )

  native.maven_jar(
    name = "scalac_rules_protobuf_java",
    artifact = "com.google.protobuf:protobuf-java:3.1.0",
    sha1 = "e13484d9da178399d32d2d27ee21a77cfb4b7873",
    server = "scalac_deps_maven_server",
  )

  # Template for binary launcher
  BAZEL_JAVA_LAUNCHER_VERSION = "0.4.5"
  java_stub_template_url = ("raw.githubusercontent.com/bazelbuild/bazel/" +
                            BAZEL_JAVA_LAUNCHER_VERSION +
                            "/src/main/java/com/google/devtools/build/lib/bazel/rules/java/" +
                            "java_stub_template.txt")
  native.http_file(
    name = "java_stub_template",
    urls = ["https://mirror.bazel.build/%s" % java_stub_template_url,
            "https://%s" % java_stub_template_url],
    sha256 = "f09d06d55cd25168427a323eb29d32beca0ded43bec80d76fc6acd8199a24489",
  )

  native.bind(name = "io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java", actual = "@scalac_rules_protobuf_java//jar")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/parser_combinators", actual = "@scala//:scala-parser-combinators")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_compiler", actual = "@scala//:scala-compiler")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_library", actual = "@scala//:scala-library")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_reflect", actual = "@scala//:scala-reflect")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_xml", actual = "@scala//:scala-xml")

  native.bind(name = "io_bazel_rules_scala/dependency/scalatest/scalatest", actual = "@scalatest//jar")
