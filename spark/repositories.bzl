
#SPARK_ARCHIVE="https://github.com/apache-spark-on-k8s/spark/releases/download/v2.2.0-kubernetes-0.5.0/spark-2.2.0-k8s-0.5.0-bin-with-hadoop-2.7.3.tgz"
#SPARK_ARCHIVE_SHA256="a1a40fae019e50db7468b55bfba89c3cfa01483c5eb2c6c5220d019bf395468d"
#SPARK_ARCHIVE_PREFIX="spark-2.2.0-k8s-0.5.0-bin-2.7.3"

def spark_rules_dependencies():
    native.new_http_archive(
       name = "spark",
       workspace_file_content = """
workspace(name = "spark")
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
       strip_prefix = "spark-2.3.0-bin-hadoop2.7",
       sha256 = "5cfbc77d140454c895f2d8125c0a751465f53cbe12720da763b1785d25c63f05",
       urls = [
           "http://mirror.stjschools.org/public/apache/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.claz.org/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.cs.utah.edu/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.mesi.com.ar/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.mirrors.hoobly.com/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.mirrors.ionfish.org/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.mirrors.lucidnetworks.net/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.mirrors.pair.com/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.mirrors.tds.net/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
           "http://apache.osuosl.org/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz",
       ],
    )

    native.new_http_archive(
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

    native.http_file(
        name = "jq",
        sha256 = "c6b3a7d7d3e7b70c6f51b706a3b90bd01833846c54d32ca32f0027f00226ff6d",
        urls = ["https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"],
        executable = True,
#        urls = ["http://http.us.debian.org/debian/pool/main/j/jq/jq_1.5+dfsg-1.3_amd64.deb"]
    )