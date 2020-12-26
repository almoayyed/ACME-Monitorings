import boto3
import re
import os


aws_elb_cli = boto3.client(service_name='elbv2')
aws_ec2_cli = boto3.client(service_name='ec2')
aws_cw_cli  = boto3.client(service_name='cloudwatch')
sns_topic  = os.environ['Sns_Topic_Arn']

def lambda_handler(event, context):
    albresponse = aws_elb_cli.describe_target_groups()
    print(albresponse)
    for tg in albresponse['TargetGroups']:
        actual_tg = tg['TargetGroupArn']
        #print(actual_tg)
        chunks = actual_tg.split(':')
        tggroup = (chunks[5])
        print(tggroup) # 1ST
        for alb in tg['LoadBalancerArns']:
            #print(alb)
            chunks = alb.split(':')
            san = (chunks[5])
            actual_alb = (san[13:]) #2ND
            print(actual_alb)
            albname = (actual_alb[4:-17]) #3RD
            print(albname)
            
            HTTPCode_ELB_4XX_Count = aws_cw_cli.put_metric_alarm(
                AlarmName='Automated-detect-alb-%s-HTTPCode_ELB_4XX_Count' % albname,
                AlarmDescription='HTTPCode_ELB_4XX_Count >= 1 for 5minute',
                ActionsEnabled=True,
                AlarmActions = [sns_topic],
                MetricName= 'HTTPCode_ELB_4XX_Count', #'UnHealthyHostCount',  #
                Namespace= 'AWS/ApplicationELB', #'AWS/NetworkELB',
                Statistic='Sum',
                Dimensions=[
                    {
                        'Name': 'LoadBalancer',
                        'Value': actual_alb     #'arn:aws:elasticloadbalancing:eu-west-1:366775409521:loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                    },
                ],
                Period=300,
                EvaluationPeriods=1,
                Threshold=1.0,
                TreatMissingData = "notBreaching",
                ComparisonOperator='GreaterThanOrEqualToThreshold'
            )
            
            HTTPCode_ELB_5XX_Count = aws_cw_cli.put_metric_alarm(
                AlarmName='Automated-detect-alb-%s-HTTPCode_ELB_5XX_Count' % albname,
                AlarmDescription='HTTPCode_ELB_5XX_Count >= 1 for 5minute',
                ActionsEnabled=True,
                AlarmActions = [sns_topic],
                MetricName= 'HTTPCode_ELB_5XX_Count', #'UnHealthyHostCount',  #
                Namespace= 'AWS/ApplicationELB', #'AWS/NetworkELB',
                Statistic='Sum',
                Dimensions=[
                    {
                        'Name': 'LoadBalancer',
                        'Value': actual_alb     #'arn:aws:elasticloadbalancing:eu-west-1:366775409521:loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                    },
                ],
                Period=300,
                EvaluationPeriods=1,
                Threshold=1.0,
                TreatMissingData = "notBreaching",
                ComparisonOperator='GreaterThanOrEqualToThreshold'
        )
    
        # Target put Metric
    
            TargetConnectionErrorCount = aws_cw_cli.put_metric_alarm(
                AlarmName='Automated-detect-alb-TG-%s-TargetConnectionErrorCount' % albname,
                AlarmDescription='TargetConnectionErrorCount >= 1 for 5minute',
                ActionsEnabled=True,
                AlarmActions = [sns_topic],
                MetricName= 'TargetConnectionErrorCount', #'UnHealthyHostCount',  #
                Namespace= 'AWS/ApplicationELB', #'AWS/NetworkELB',
                Statistic='Sum',
                Dimensions=[
                    {
                        'Name': 'LoadBalancer',
                        'Value': actual_alb     #'arn:aws:elasticloadbalancing:eu-west-1:366775409521:loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                    },
                    {
                        'Name': 'TargetGroup',
                        'Value': tggroup     
                    },
                ],
                Period=300,
                EvaluationPeriods=1,
                Threshold=1.0,
                TreatMissingData = "notBreaching",
                ComparisonOperator='GreaterThanOrEqualToThreshold'
        )
    
            UnHealthyHostCount = aws_cw_cli.put_metric_alarm(
                AlarmName='Automated-detect-alb-TG-%s-UnHealthyHostCount' % albname,
                AlarmDescription='Alarm triggered:- ALB UnHealthyHostCount',
                ActionsEnabled=True,
                AlarmActions = [sns_topic],
                MetricName= 'UnHealthyHostCount', #'UnHealthyHostCount',  #
                Namespace= 'AWS/ApplicationELB', #'AWS/NetworkELB',
                Statistic='Minimum',
                Dimensions=[
                    {
                        'Name': 'LoadBalancer',
                        'Value': actual_alb     #'arn:aws:elasticloadbalancing:eu-west-1:366775409521:loadbalancer/app/SanALB/2bd9cf55bcdbb5ea' #'app/AUB-ELB-Test/12dc3d839e385e7f' #'net/EX-NLB/4525490cdf163d99'
                    },
                    {
                        'Name': 'TargetGroup',
                        'Value': tggroup     
                    },
                ],
                Period=300,
                EvaluationPeriods=1,
                Threshold=1.0,
                TreatMissingData = "notBreaching",
                ComparisonOperator='GreaterThanOrEqualToThreshold'
        )