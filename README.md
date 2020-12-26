# ACME-Monitorings
Automated Monitoring Solutions (Lambda + SNS + Python)


```
module "ACME-Monitoring" {
    source = "github.com/almoayyed/ACME-Monitoring/ACME-SystemPerformance-Monitoring"
    
    # ACME-AssignAlarm-EC2
    sns_topic_name = "ACME-AssignAlarm-EC2"
    functionname   = "ACME-AssignAlarm-EC2"
    
    # ACME-AssignAlarm-ALB
    functionname5  = "ACME-AssignAlarms-ALB"
    sns_topic_name5 = "ACME-AssignAlarms-ALB"
    
    #ACME-AssignAlarms-CLB
    functionname8   = "ACME-AssignAlarms-CLB"
    sns_topic_name8 = "ACME-AssignAlarms-CLB-SNS"
    
    #ACME-AssignAlarms-NLB
    functionname7    = "ACME-AssignAlarms-NLB"
    sns_topic_name7  = "ACME-AssignAlarms-NLB-SNS"
    
    #ACME-AssignAlarms-RDS
    functionname6    = "ACME-AssignAlarms-RDS"
    sns_topic_name6  = "ACME-AssignAlarms-RDS-SNS"
    
}
```