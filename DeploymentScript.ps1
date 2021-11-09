param(
    [string] [Parameter(Mandatory=$true)] $clusterUrl,
    [string] [Parameter(Mandatory=$true)] $dbName,
    [string] [Parameter(Mandatory=$true)] $logsTableName
    
)

Write-Host $clusterUrl
Write-Host $dbName
Write-Host $logsTableName



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




$body = @{
 "db"="$dbName"
 "csl"=".show tables"
} | ConvertTo-Json
$result = Invoke-RestMethod -Uri "$clusterUrl/v1/rest/mgmt" -Method 'Post' -Body $body -Headers $header 
$result | ConvertTo-Json -Depth 5
