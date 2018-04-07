load("//spark:k8s.bzl", "scala_spark_app")

scala_spark_app(
    name = "sparkstreamtest",
    srcs = ["SparkStreamtest.scala"],
    files = [":log4j.properties"],
    image_repository = "netchris/sparkstreamtest",
    layers = ["@apache_spark_on_k8s//:spark_assembly"],
    main_class = "com.example.sparkstreamtest.SparkStreamtest",
)
