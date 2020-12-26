import json
import boto3
import os

aws_cw_cli_rds = boto3.client('rds')
aws_cw_cli  = boto3.client(service_name='cloudwatch')

sns_topic  = os.environ['Sns_Topic_Arn']

def lambda_handler(event, context):
    # TODO implement
    dbresponse = aws_cw_cli_rds.describe_db_instances()
    for db in dbresponse['DBInstances']:
        dbins = db['DBInstanceIdentifier']
        print(dbins)
        alloc_storage = db['AllocatedStorage']
        print(alloc_storage)
        
        ##Convert GB to Bytes
        calculated_byte_storage = alloc_storage*1000*1000*1000
        print(calculated_byte_storage)
         #Calculate 20% of it. We will use it to set the threshold
        free_space = calculated_byte_storage*20 / 100
        print(free_space)
        
        FreeStorageSpace = aws_cw_cli.put_metric_alarm(
            AlarmName="Automated detect- %s Free Space is Critical" % dbins,
            AlarmDescription='Free Space <= 20% For 15 minutes',
            ActionsEnabled=True,
            AlarmActions=[sns_topic],
            MetricName='FreeStorageSpace',
            Namespace='AWS/RDS',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'DBInstanceIdentifier',
                    'Value': "%s" % dbins
                },
            ],
            Period=300,
            EvaluationPeriods=3,
            Threshold=free_space,
            TreatMissingData = "notBreaching",
            ComparisonOperator='LessThanOrEqualToThreshold'
        )
        CPUUtilization = aws_cw_cli.put_metric_alarm(
            AlarmName="Automated detect- %s High CPU Utilization" % dbins,
            AlarmDescription='CPUUtilization >= 80% For 5 minutes',
            ActionsEnabled=True,
            AlarmActions=[sns_topic],
            MetricName='CPUUtilization',
            Namespace='AWS/RDS',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'DBInstanceIdentifier',
                    'Value': "%s" % dbins
                },
            ],
            Period=300,
            EvaluationPeriods=3,
            Threshold=80.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
        )
        
        CPUCreditBalance = aws_cw_cli.put_metric_alarm(
            AlarmName="Automated detect- %s RDS Credit Balance Warning" % dbins,
            AlarmDescription='CPU Credit Balance <= 25 for 30 Minutes',
            ActionsEnabled=True,
            AlarmActions=[sns_topic],
            MetricName='CPUCreditBalance',
            Namespace='AWS/RDS',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'DBInstanceIdentifier',
                    'Value': "%s" % dbins
                },
            ],
            Period=300,
            EvaluationPeriods=6,
            Threshold=25.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='LessThanOrEqualToThreshold'
        )
        WriteLatency = aws_cw_cli.put_metric_alarm(
            AlarmName="Automated detect- %s RDS Write Latency Critical" % dbins,
            AlarmDescription='Write Latency >= 12ms for 15 Minutes',
            ActionsEnabled=True,
            AlarmActions=[sns_topic],
            MetricName='WriteLatency',
            Namespace='AWS/RDS',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'DBInstanceIdentifier',
                    'Value': "%s" % dbins
                },
            ],
            Period=300,
            EvaluationPeriods=3,
            Threshold=.012,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
        )
        ReadLatency = aws_cw_cli.put_metric_alarm(
            AlarmName="Automated detect- %s RDS Read Latency Critical" % dbins,
            AlarmDescription='Read Latency >= 5ms for 15 Minutes',
            ActionsEnabled=True,
            AlarmActions=[sns_topic],
            MetricName='ReadLatency',
            Namespace='AWS/RDS',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'DBInstanceIdentifier',
                    'Value': "%s" % dbins
                },
            ],
            Period=300,
            EvaluationPeriods=3,
            Threshold=.005,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
        )