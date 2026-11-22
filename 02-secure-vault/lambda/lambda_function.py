# Our Lambda function will not need a server running all day waiting for backup uploads. Instead, it will execute automatically when triggered by an event from our S3 bucket, 
# process the backup information, and record it in DynamoDB.

# Our Lambda function has two roles attached to it 
# 1) Just like our EC2 app server, our Lambda function needs permissions to interact with other AWS services. The IAM role attached to our Lambda function determines what actions
     # it is allowed to perform when it executes. For now, Lambda has its basic execution permissions, which allow it to write logs to CloudWatch.

# 2) However, our function also needs permission to write backup records into our DynamoDB table. 
# We will therefore extend its permissions by adding a policy that allows it to write records to our backup-log table.

# After creating the roles, one for upload log to cloudwatch, the other to upload log to dynanmodb, we will then starter file containing our code.

import boto3, urllib.parse

table = boto3.resource("dynamodb").Table("backup-log")

def lambda_handler(event, context):
    for rec in event["Records"]:
        key = urllib.parse.unquote_plus(rec["s3"]["object"]["key"])
        table.put_item(Item={
            "backup_id": key,
            "size_bytes": rec["s3"]["object"]["size"],
            "uploaded_at": rec["eventTime"],
            "bucket": rec["s3"]["bucket"]["name"],
        })
    return {"statusCode": 200}


