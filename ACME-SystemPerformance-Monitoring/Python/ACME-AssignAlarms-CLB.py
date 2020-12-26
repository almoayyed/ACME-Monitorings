import boto3
import re
import os

aws_elb_cli = boto3.client(service_name='elb')
aws_ec2_cli = boto3.client(service_name='ec2')
aws_cw_cli  = boto3.client(service_name='cloudwatch')
sns_topic  = os.environ['Sns_Topic_Arn']

def lambda_handler(event, context):
    print(event)
    clbresponse = aws_elb_cli.describe_load_balancers()
    print(clbresponse)
    for clb in clbresponse['LoadBalancerDescriptions']:
        actual_clb = clb['LoadBalancerName']
        

        UnHealthyHostCount = aws_cw_cli.put_metric_alarm(
            AlarmName='Automated-detect-clb-%s-UnHealthyHostCount' % actual_clb,
            AlarmDescription='Alarm triggered:- CLB UnHealthyHostCount',
            ActionsEnabled=True,
            AlarmActions = [sns_topic],
            MetricName= 'UnHealthyHostCount', #'UnHealthyHostCount',  #
            Namespace= 'AWS/ELB', #'AWS/NetworkELB',
            Statistic='Minimum',
            Dimensions=[
                {
                    'Name': 'LoadBalancerName',
                    'Value': actual_clb     #'arn:aws:elasticloadbalancing:eu-west-1:366775409521:loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                },
            ],
            Period=300,
            EvaluationPeriods=1,
            Threshold=1.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
    )
    
        BackendConnectionErrors = aws_cw_cli.put_metric_alarm(
            AlarmName='Automated-detect-clb-%s-BackendConnectionErrors' % actual_clb,
            AlarmDescription='Alarm triggered:- CLB BackendConnectionErrors',
            ActionsEnabled=True,
            AlarmActions = [sns_topic],
            MetricName= 'BackendConnectionErrors', #'UnHealthyHostCount',  #
            Namespace= 'AWS/ELB', #'AWS/NetworkELB',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'LoadBalancerName',
                    'Value': actual_clb     #'arn:aws:elasticloadbalancing:eu-west-1::loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                },
            ],
            Period=300,
            EvaluationPeriods=1,
            Threshold=1.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
    )
    
# Client Error
    
        HTTPCode_Backend_4XX = aws_cw_cli.put_metric_alarm(
            AlarmName='Automated-detect-clb-%s-HTTPCode_Backend_4XX' % actual_clb,
            AlarmDescription='Alarm triggered:- CLB HTTPCode_Backend_4XX',
            ActionsEnabled=True,
            AlarmActions = [sns_topic],
            MetricName= 'HTTPCode_Backend_4XX', #'UnHealthyHostCount',  #
            Namespace= 'AWS/ELB', #'AWS/NetworkELB',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'LoadBalancerName',
                    'Value': actual_clb     #'arn:aws:elasticloadbalancing:eu-west-1::loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                },
            ],
            Period=300,
            EvaluationPeriods=1,
            Threshold=1.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
    )
    
        HTTPCode_Backend_5XX = aws_cw_cli.put_metric_alarm(
            AlarmName='Automated-detect-clb-%s-HTTPCode_Backend_5XX' % actual_clb,
            AlarmDescription='Alarm triggered:- CLB HTTPCode_Backend_5XX',
            ActionsEnabled=True,
            AlarmActions = [sns_topic],
            MetricName= 'HTTPCode_Backend_5XX', #'UnHealthyHostCount',  #
            Namespace= 'AWS/ELB', #'AWS/NetworkELB',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'LoadBalancerName',
                    'Value': actual_clb     #'arn:aws:elasticloadbalancing:eu-west-1::loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                },
            ],
            Period=300,
            EvaluationPeriods=1,
            Threshold=1.0,
            TreatMissingData = "notBreaching",
            ComparisonOperator='GreaterThanOrEqualToThreshold'
    )