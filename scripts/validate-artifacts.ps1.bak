# === ROBUST HTTP CHECK (in-memory patch) ===
$targetFqdn = $pip.properties.dnsSettings.fqdn
$targetIp   = $pip.properties.ipAddress
$urls = @()
if ($targetFqdn) { $urls += "http://$targetFqdn/" }
if ($targetIp)   { $urls += "http://$targetIp/" }

$ok = $false
foreach ($u in $urls) {
  Write-Verbose "Probing $u ..."
  for ($i=1; $i -le 10; $i++) {
    try {
      $resp = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 5
      if ($resp.StatusCode -eq 200) { $ok = $true; break }
    } catch {
      Start-Sleep -Seconds 2
    }
  }
  if ($ok) { break }
}
if (-not $ok) {
  throw "Unable to get a response from the web app via $($urls -join ', '). Ensure the VM app is running."
}
# === END ROBUST CHECK ===}

Write-Output ""
Write-Output "`u{1F973} Congratulations! All tests passed!"

