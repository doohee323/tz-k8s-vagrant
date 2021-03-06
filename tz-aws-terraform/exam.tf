provider "aws" {
  version = "=2.44"
  region  = "eu-west-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "upload-bucket"
  acl    = "private"
}

resource "aws_sqs_queue" "queue" {
  name                      = "upload-queue"
  delay_seconds             = 60
  max_message_size          = 200
  message_retention_seconds = 172800
  receive_wait_time_seconds = 30

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:s3-event-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket.arn}" }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notif" {
  bucket = aws_s3_bucket.bucket.id
  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

resource "aws_iam_role_policy" "iam_notif_policy_doc" {
  name = "data"
  role = aws_iam_role.test_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource": ["arn:aws:s3:::upload-bucket/*"]
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "test_role" {
  name = "test_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_sqs_queue_policy" "notif_policy" {
  queue_url = aws_sqs_queue.queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.queue.arn}"
        }
      }
    }
  ]
}
POLICY
}


/**

Compilation successful.

(OBLIGATORY) TestObligatory - test_01_aws_s3_bucket_exists
OK

(OBLIGATORY) TestObligatory - test_02_aws_sqs_queue_exists
OK

TestVerify - test_001_syntax_should_be_valid
OK

TestVerify - test_002_should_have_no_errors
OK

TestVerify - test_003_should_have_no_warnings
OK

TestVerify - test_01_aws_s3_bucket_name
OK

TestVerify - test_02_aws_s3_bucket_ref_matches_spec
OK

TestVerify - test_03_aws_sqs_queue_name
OK

TestVerify - test_04_aws_sqs_queue_ref_matches_spec
OK

TestVerify - test_05_aws_sqs_queue_delay_seconds
OK

TestVerify - test_06_aws_sqs_queue_max_message_size
OK

TestVerify - test_07_aws_sqs_queue_message_retention_seconds
OK

TestVerify - test_08_aws_sqs_queue_receive_wait_time_seconds
OK

TestVerify - test_13_aws_sqs_queue_policy_exists
OK

TestVerify - test_14_aws_sqs_queue_policy_ref_matches_spec
OK

TestVerify - test_15_aws_sqs_queue_policy_queue_url
OK

TestVerify - test_16_aws_sqs_queue_policy_policy
OK

TestVerify - test_17_aws_s3_bucket_notification_exists
OK

TestVerify - test_18_aws_s3_bucket_notification_ref_matches_spec
OK

TestVerify - test_19_aws_s3_bucket_notification_bucket
OK

TestVerify - test_20_aws_s3_bucket_notification_queue_arn
OK

TestVerify - test_09_data_aws_iam_policy_document_statement_effect
Output (stderr):
Traceback (most recent call last):
  File "terraform_s3_sqs_verify.py", line 128, in test_09_data_aws_iam_policy_document_statement_effect
    self.assertTrue(tfObject['statement'][0]['Effect'] == "Allow", msg="Property 'effect' is different than expected")
KeyError: 'statement'
RUNTIME ERROR

TestVerify - test_10_data_aws_iam_policy_document_statement_actions
Output (stderr):
Traceback (most recent call last):
  File "terraform_s3_sqs_verify.py", line 136, in test_10_data_aws_iam_policy_document_statement_actions
    self.assertTrue(tfObject['statement'][0]['Action'] == "sqs:SendMessage", msg="Property 'action' is different than expected")
KeyError: 'statement'
RUNTIME ERROR

TestVerify - test_11_data_aws_iam_policy_document_statement_principals_type
Output (stderr):
Traceback (most recent call last):
  File "terraform_s3_sqs_verify.py", line 145, in test_11_data_aws_iam_policy_document_statement_principals_type
    self.assertTrue(tfObject['statement'][0]['Principal'] is not None, msg="Property 'type' is different than expected")
KeyError: 'statement'
RUNTIME ERROR

TestVerify - test_12_data_aws_iam_policy_document_statement_condition_test
Output (stderr):
Traceback (most recent call last):
  File "terraform_s3_sqs_verify.py", line 154, in test_12_data_aws_iam_policy_document_statement_condition_test
    self.assertTrue(tfObject['statement'][0]['Condition']['ArnEquals'] is not None, msg="Property 'test' is different than expected")
KeyError: 'statement'
RUNTIME ERROR

Detected some errors.

**/