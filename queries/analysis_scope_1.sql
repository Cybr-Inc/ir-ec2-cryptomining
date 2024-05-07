/*
Use access key ID to run a query that lists out actions for the past 7 days
*/
SELECT 
    awsregion, 
    eventsource, 
    eventname, 
    readonly, 
    errorcode, 
    errormessage, 
    count(eventid) as COUNT
FROM "default"."cloudtrail_logs_aws_cloudtrail_logs_299551924423_519675f4"
WHERE useridentity.accesskeyid = 'AKIAULPVPUDD4OVY4FDT'
      AND eventTime >= '2024-04-22 00:00:00'
      AND eventTime <= '2024-04-29 00:00:00'
GROUP BY 
    awsregion, 
    eventsource, 
    eventname, 
    readonly, 
    errorcode, 
    errormessage
ORDER BY COUNT DESC

/*
Investigate actions related to the launched EC2 instance suspected of cryptomining
*/
SELECT awsregion,
	useridentity.arn,
	eventsource,
	eventname,
	readonly,
	errorcode,
	errormessage,
	count(eventid) as COUNT
FROM "default"."cloudtrail_logs_aws_cloudtrail_logs_299551924423_519675f4"
WHERE eventsource = 'ec2.amazonaws.com'
	AND (
		eventTime >= '2024-04-22 00:00:00'
		AND eventTime <= '2024-04-29 00:00:00'
	)
	AND (
		requestparameters LIKE '%i-072ee2cee415150ea%'
	)
GROUP BY awsregion,
	useridentity.arn,
	eventsource,
	eventname,
	readonly,
	errorcode,
	errormessage
ORDER BY COUNT DESC;

/*
Narrow down actions taken by compromised user Michael
*/
SELECT sourceipaddress,
	useragent,
	count(eventid) as COUNT
FROM "default"."cloudtrail_logs_aws_cloudtrail_logs_299551924423_519675f4"
WHERE useridentity.arn = 'arn:aws:iam::272281913033:user/Michael'
	AND eventTime >= '2024-04-22 00:00:00'
	AND eventTime <= '2024-04-29 00:00:00'
GROUP BY sourceipaddress,
	useragent
ORDER BY COUNT DESC

/*
List source IP address and user agent for actions taken by compromised user Michael
*/
SELECT awsregion,
	eventsource,
	eventname,
	readonly,
	errorcode,
	errormessage,
	count(eventid) as COUNT
FROM "default"."cloudtrail_logs_aws_cloudtrail_logs_299551924423_519675f4"
WHERE useridentity.arn = 'arn:aws:iam::272281913033:user/Michael'
	AND eventTime >= '2024-04-22 00:00:00'
	AND eventTime <= '2024-04-29 00:00:00'
GROUP BY awsregion,
	eventsource,
	eventname,
	readonly,
	errorcode,
	errormessage
ORDER BY COUNT DESC

/*
List all actions taken by compromised user Michael in a 7-day period
*/
SELECT awsregion,
	eventsource,
	eventname,
	readonly,
	errorcode,
	errormessage,
	count(eventid) as COUNT
FROM "default"."cloudtrail_logs_aws_cloudtrail_logs_299551924423_519675f4"
WHERE useridentity.arn = 'arn:aws:iam::272281913033:user/Michael'
	AND eventTime >= '2024-04-22 00:00:00'
	AND eventTime <= '2024-04-29 00:00:00'
GROUP BY awsregion,
	eventsource,
	eventname,
	readonly,
	errorcode,
	errormessage
ORDER BY COUNT DESC

/*
Get details about the RunInstance API calls
*/
SELECT eventtime, awsregion, eventname, requestparameters, responseelements, errorcode, errormessage
FROM "default"."cloudtrail_logs_aws_cloudtrail_logs_299551924423_519675f4"
WHERE useridentity.arn = 'arn:aws:iam::272281913033:user/Michael'
      AND eventTime >= '2024-04-22 00:00:00'
			AND eventTime <= '2024-04-29 00:00:00'
      AND eventname IN ('RunInstances')