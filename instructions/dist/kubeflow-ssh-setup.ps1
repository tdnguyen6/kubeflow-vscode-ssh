if ($env:AUTH_METHOD -eq "token") {
  $AUTH_HEADERS = @{Authorization = "Bearer $env:API_TOKEN" }
  $CHISEL_AUTH_HEADERS = "--header `"Authorization: Bearer $env:API_TOKEN`""
}
else {
  $AUTH_HEADERS = @{
    'x-auth-key'   = "$env:AUTH_KEY"
    'x-auth-email' = "$env:AUTH_EMAIL"
  }
  $CHISEL_AUTH_HEADERS = "--header `"x-auth-key: $env:AUTH_KEY`" --header `"x-auth-email: $env:AUTH_EMAIL`""
}

$START_PATTERN = "# Added by Kubeflow SSH: $env:SSH_HOST"
$END_PATTERN = "# End of Kubeflow SSH: $env:SSH_HOST"

#################################### PRIVATE KEY ####################################
$CREDENTIAL_DIR = "$HOME\.ssh\kubeflow\$($env:SSH_HOST -replace "/", "\")"

if (!(Test-Path -Path $CREDENTIAL_DIR)) {
  New-Item -Path $CREDENTIAL_DIR -ItemType Directory
}

Invoke-WebRequest -useb -h $AUTH_HEADERS "$($env:API_ENDPOINT)id_rsa" -o "$CREDENTIAL_DIR\id_rsa"
#################################### PRIVATE KEY ####################################

#################################### SSH CONFIG ####################################
$SSH_CONFIG = "Host $env:SSH_HOST
	HostName localhost
	ProxyCommand chisel client $CHISEL_AUTH_HEADERS $env:API_ENDPOINT :stdio:%h:%p
	User jovyan
	IdentityFile $CREDENTIAL_DIR\id_rsa
	StrictHostKeyChecking yes"

("$(Get-Content $HOME\.ssh\config -Raw) " -replace "(?=$START_PATTERN)([\s\S]*?)(?<=$END_PATTERN)", "").Trim() | Out-File -Encoding ASCII $HOME\.ssh\config

"$START_PATTERN`r`n$SSH_CONFIG`r`n$END_PATTERN" | Out-File -Encoding ASCII -Append $HOME\.ssh\config
#################################### SSH CONFIG ####################################

#################################### HOST KEYS ####################################
$HOST_KEYS = (Invoke-WebRequest -useb -h $AUTH_HEADERS "$($env:API_ENDPOINT)host-keys")

("$(Get-Content $HOME\.ssh\known_hosts -Raw) " -replace "(?=$START_PATTERN)([\s\S]*?)(?<=$END_PATTERN)", "").Trim() | Out-File -Encoding ASCII $HOME\.ssh\known_hosts

"$START_PATTERN`r`n$HOST_KEYS`r`n$END_PATTERN" | Out-File -Encoding ASCII -Append $HOME\.ssh\known_hosts
#################################### HOST KEYS ####################################
