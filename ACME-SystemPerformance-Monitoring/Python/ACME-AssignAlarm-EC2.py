import boto3
import os
aws_cw_cli = boto3.client('cloudwatch')
aws_ec2_cli = boto3.resource('ec2')
sns_topic  = os.environ['Sns_Topic_Arn']


def lambda_handler(event, context):
    instances = aws_ec2_cli.instances.filter(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    for instance in instances:
        ins = instance.id
        print (ins)
    
        aws_cw_cli.put_metric_alarm(
            AlarmName='Automated-detect-CPU_Utilization_%s' % ins,
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=1,
            MetricName='CPUUtilization',
            Namespace='AWS/EC2',
            Period=60,
            Statistic='Average',
            Threshold=80.0,
            ActionsEnabled=False,
            AlarmDescription='Alarm when server CPU exceeds 80%',
            AlarmActions = [sns_topic],
            TreatMissingData = "notBreaching",
            Dimensions=[
                {
                    'Name': 'InstanceId',
                    'Value': ins
                },
            ],
            Unit='Seconds'
    )
        aws_cw_cli.put_metric_alarm(
            AlarmName='Automated-detect-instance-check-failed_%s' % ins,
            AlarmDescription='Status Check Failed (System) for 5 Minutes',
            ActionsEnabled=True,
            AlarmActions=[sns_topic,
                          'arn:aws:automate:eu-west-1:ec2:reboot'
                          ],
            MetricName='StatusCheckFailed_System',
            Namespace='AWS/EC2',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'InstanceId',
                    'Value': ins
                },
            ],
            Period=60,
            EvaluationPeriods=3,
            Threshold=1.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
        )

        aws_cw_cli.put_metric_alarm(
            AlarmName='Automated-detect-system-check-failed_%s' % ins,
            AlarmDescription='Status Check Failed (Instance) for 10 Minutes',
            ActionsEnabled=True,
            AlarmActions=[sns_topic,
                          'arn:aws:automate:eu-west-1:ec2:reboot'
                          ],
            MetricName='StatusCheckFailed_Instance',
            Namespace='AWS/EC2',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'InstanceId',
                    'Value': ins
                },
            ],
            Period=60,
            EvaluationPeriods=10,
            Threshold=1.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
        )