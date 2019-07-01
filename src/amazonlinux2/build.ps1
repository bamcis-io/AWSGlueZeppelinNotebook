Param(
	[Parameter(Position = 0, ValueFromPipeline = $true)]
	[ValidateNotNullOrEmpty()]
	[System.String]$Version = "0.7.3"
)

docker build ../zeppelin-amazonlinux2 -t bamcis/zeppelin-amazonlinux2:$Version -t bamcis/zeppelin-amazonlinux2:latest --build-arg ZEPPELIN_VERSION=$Version