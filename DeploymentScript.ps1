param(
    [string] [Parameter(Mandatory=$true)] $clusterUrl,
    [string] [Parameter(Mandatory=$true)] $dbName,
    [string] [Parameter(Mandatory=$true)] $logsTableName,
    [string] [Parameter(Mandatory=$true)] $logsTableNameIngestionMappingName
)

Write-Host $clusterUrl
Write-Host $dbName
Write-Host $logsTableName
Write-Host $logsTableNameIngestionMappingName


$token=(Get-AzAccessToken -ResourceUrl $clusterUrl).Token

$header = @{
 "Authorization"="Bearer $token"
 "Content-Type"="application/json"
}

$body = @{
 "db"="$dbName"
 "csl"=".create table [$logsTableName]  (['log']: string, ['stream']: string, docker: dynamic, kubernetes: dynamic, fluentd_time: long, host: string, namespace_name: string, pod_name: string, container_name: string, fluentd_datetime: datetime)"
} | ConvertTo-Json
$result = Invoke-RestMethod -Uri "$clusterUrl/v1/rest/mgmt" -Method 'Post' -Body $body -Headers $header 

$csl = ".create table $($logsTableName) ingestion json mapping '$($logsTableNameIngestionMappingName)' '[{ ""column"" : ""log"", ""Properties"":{""Path"":""$.log""}}, { ""column"" : ""stream"", ""Properties"":{""Path"":""$.stream""}},	{ ""column"" : ""docker"", ""Properties"":{""Path"":""$.docker""}}, { ""column"" : ""kubernetes"", ""Properties"":{""Path"":""$.kubernetes""}},	{ ""column"" : ""fluentd_time"", ""Properties"":{""Path"":""$.fluentd_time""}},	{ ""column"" : ""host"", ""Properties"":{""Path"":""$.kubernetes.host""}},	{ ""column"" : ""namespace_name"", ""Properties"":{""Path"":""$.kubernetes.namespace_name""}}, 	{ ""column"" : ""pod_name"",""Properties"":{""Path"":""$.kubernetes.pod_name""}}, 	{ ""column"" : ""container_name"", ""Properties"":{""Path"":""$.kubernetes.container_name""}}, 	{ ""column"" : ""fluentd_datetime"",""Properties"":{""Path"":""$.fluentd_time"",""Transform"":""DateTimeFromUnixMilliseconds""}} ]'"
Write-Host $csl

$body = @{
    "db"="$dbName"
    "csl"=$csl
} | ConvertTo-Json
Write-Host $body

$result = Invoke-RestMethod -Uri "$clusterUrl/v1/rest/mgmt" -Method 'Post' -Body $body -Headers $header 
      

$body = @{
 "db"="$dbName"
 "csl"=".show tables"
} | ConvertTo-Json
$result = Invoke-RestMethod -Uri "$clusterUrl/v1/rest/mgmt" -Method 'Post' -Body $body -Headers $header 
$result | ConvertTo-Json -Depth 5
