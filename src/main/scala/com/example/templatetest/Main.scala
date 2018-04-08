package com.example.templatetest

import org.apache.spark.sql.SparkSession

import scala.collection.JavaConverters._

/**
  *
  */
object Main {


	def main(args: Array[String]): Unit = {
		println("Args:")
		args.foreach(println)
		val props = System.getProperties
		println("System properties:")
		props.stringPropertyNames.asScala.toList.sorted.foreach { prop ⇒
			println(s"  $prop = ${props.get(prop)}")
		}
		println("Environment:")
		sys.env.toList.sorted.foreach { case (k, v) ⇒
			println(s"  $k = $v")
		}

		val spark: SparkSession = SparkSession.builder
			.master(System.getProperty("spark.master", "local[*]"))
			.appName(getClass.getName)
			.getOrCreate

		import spark.implicits._

		val lines = spark.readStream
			.format("socket")
			.option("host", args.headOption.getOrElse("localhost"))
			.option("port", 9999)
			.load()

		// Split the lines into words
		val words = lines.as[String].flatMap(_.split(" "))

		// Generate running word count
		val wordCounts = words.groupBy("value").count()

		// Start running the query that prints the running counts to the console
		val query = wordCounts.writeStream
			.outputMode("complete")
			.format("console")
			.start()

		query.awaitTermination()
	}

}
