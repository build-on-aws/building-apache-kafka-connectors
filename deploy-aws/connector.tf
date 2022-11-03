resource "random_string" "random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  numeric = false
}

resource "aws_s3_bucket" "connector_bucket" {
  bucket = "${var.my_1st_kf_connector}-${random_string.random_string.result}"
}

resource "aws_s3_object" "connector_code" {
  bucket = aws_s3_bucket.connector_bucket.bucket
  key = "${var.my_1st_kf_connector}.jar"
  content_type = "application/java-archive"
  source = "../target/${var.my_1st_kf_connector}-1.0.jar"
}

resource "aws_mskconnect_custom_plugin" "plugin" {
  name = "${var.my_1st_kf_connector}-plugin"
  content_type = "JAR"
  location {
    s3 {
      bucket_arn = aws_s3_bucket.connector_bucket.arn
      file_key = aws_s3_object.connector_code.key
    }
  }
}

resource "aws_iam_role" "connector_role" {
  name = "${var.my_1st_kf_connector}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "kafkaconnect.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "connector_role_policy" {
  name = "${var.my_1st_kf_connector}-role-policy"
  role = aws_iam_role.connector_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListAllMyBuckets"
        ],
        "Resource": "arn:aws:s3:::*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "connector_log_group" {
  name = "kafka_connect_logs"
}

resource "aws_mskconnect_connector" "connector" {
  name = var.my_1st_kf_connector
  kafkaconnect_version = "2.7.1"
  capacity {
    autoscaling {
      mcu_count = 1
      min_worker_count = 1
      max_worker_count = 2
      scale_in_policy {
        cpu_utilization_percentage = 20
      }
      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }
  connector_configuration = {
    "connector.class" = "tutorial.buildon.aws.streaming.kafka.MyFirstKafkaConnector"
    "key.converter" = "org.apache.kafka.connect.converters.ByteArrayConverter"
    "value.converter" = "org.apache.kafka.connect.json.JsonConverter"
    "first.required.param" = "Kafka"
    "second.required.param" = "Connect"
    "tasks.max" = "1"
  }
  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.kafka.bootstrap_brokers
      vpc {
        security_groups = [aws_security_group.connector.id]
        subnets = [aws_subnet.private_subnet[0].id,
                   aws_subnet.private_subnet[1].id,
                   aws_subnet.private_subnet[2].id]
      }
    }
  }
  kafka_cluster_client_authentication {
    authentication_type = "NONE"
  }
  kafka_cluster_encryption_in_transit {
    encryption_type = "PLAINTEXT"
  }
  plugin {
    custom_plugin {
      arn = aws_mskconnect_custom_plugin.plugin.arn
      revision = aws_mskconnect_custom_plugin.plugin.latest_revision
    }
  }
  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled = true
        log_group = aws_cloudwatch_log_group.connector_log_group.name
      }
    }
  }
  service_execution_role_arn = aws_iam_role.connector_role.arn
}
