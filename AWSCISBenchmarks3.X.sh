export AWS_PROFILE='default'
export AWS_DEFAULT_REGION='us-east-1'
email='user@example.com'

account=$(aws sts get-caller-identity --query 'Account' --output text)

loggroup='CloudTrail/DefaultLogGroup'
topic='arn:aws:sns:'$AWS_DEFAULT_REGION':'$account':CISBenchmarks'

aws sns create-topic --name CISBenchmarks
aws sns subscribe --topic-arn $topic --protocol email --notification-endpoint $email

#3.1
metric='unauthorized_api_calls_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern  '{($.errorCode = "*UnauthorizedOperation") || ($.errorCode = "AccessDenied*")}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.2
metric='no_mfa_console_signin_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern  '{($.eventName = "ConsoleLogin") && ($.additionalEventData.MFAUsed != "Yes") }'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.3
metric='root_usage_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern  '{ $.userIdentity.type = "Root" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != "AwsServiceEvent" }'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.4
metric='iam_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.5
metric='cloudtrail_cfg_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging)}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.6
metric='console_signin_failure_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern  '{($.eventName = ConsoleLogin) && ($.errorMessage = "Failed authentication") }'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.7
metric='disable_or_delete_cmk_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventSource = kms.amazonaws.com) && (($.eventName=DisableKey)||($.eventName=ScheduleKeyDeletion))}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.8
metric='s3_bucket_policy_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication))}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.9
metric='aws_config_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel) ||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder))}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.10
metric='security_group_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup)}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.11
metric='nacl_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation)}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.12
metric='network_gw_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway)}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.13
metric='route_table_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable)}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic

#3.14
metric='vpc_changes_metric'
aws logs put-metric-filter --log-group-name $loggroup  --filter-name $metric --metric-transformations metricName=$metric,metricNamespace='CISBenchmark',metricValue=1 --filter-pattern '{($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink)}'
aws cloudwatch put-metric-alarm --alarm-name $metric --metric-name $metric  --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --namespace 'CISBenchmark' --alarm-actions $topic
