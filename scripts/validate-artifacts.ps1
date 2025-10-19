# === BEGIN: PS7-safe HTTP probe with proper $pip init ===

# 1) ensure temp/exported-template.json існує (беремо URL з artifacts.json)
$RepoRoot   = Get-Location
$TempFolder = Join-Path $RepoRoot "temp"
$LocalTpl   = Join-Path $TempFolder "exported-template.json"

if (-not (Test-Path $LocalTpl)) {
  if (-not (Test-Path $TempFolder)) { $null = New-Item -ItemType Directory -Path $TempFolder }
  $art = Get-Content (Join-Path $RepoRoot "artifacts.json") -Raw | ConvertFrom-Json
  if (-not $art.resourcesTemplate -or [string]::IsNullOrWhiteSpace($art.resourcesTemplate)) {
    throw "No resourcesTemplate URL in artifacts.json. Run scripts/generate-artifacts.ps1 and commit artifacts.json."
  }
  Write-Verbose "Downloading exported template from $($art.resourcesTemplate)"
  Invoke-WebRequest -Uri $art.resourcesTemplate -OutFile $LocalTpl
}

# 2) витягуємо Public IP з шаблону
$tpl = Get-Content $LocalTpl -Raw | ConvertFrom-Json
$pip = $tpl.resources | Where-Object { $_.type -eq 'Microsoft.Network/publicIPAddresses' } | Select-Object -First 1
if (-not $pip) {
  throw "No Microsoft.Network/publicIPAddresses resource found in exported-template.json. Re-generate artifacts after deploying Public IP."
}

# 3) формуємо цілі
$targetFqdn = $pip.properties.dnsSettings.fqdn
$targetIp   = $pip.properties.ipAddress

$urls = @()
if ($targetFqdn) { $urls += "http://$targetFqdn/" }
if ($targetIp)   { $urls += "http://$targetIp/" }

if ($urls.Count -eq 0) {
  throw "No target FQDN or IP found in artifacts/template (dnsSettings.fqdn / ipAddress are empty). Check exported-template.json and scripts/generate-artifacts.ps1 output."
}

# 4) ретраї без -UseBasicParsing (PS7-safe)
$ok = $false
foreach ($u in $urls) {
  Write-Verbose "Probing $u ..."
  for ($i = 1; $i -le 10; $i++) {
    try {
      $resp = Invoke-WebRequest -Uri $u -TimeoutSec 5
      if ($resp.StatusCode -eq 200) { $ok = $true; break }
    } catch {
      Start-Sleep -Seconds 2
    }
  }
  if ($ok) { break }
}

if (-not $ok) {
  throw "Unable to get a response from the web app via $($urls -join ', '). Ensure the VM app is running and re-run scripts/generate-artifacts.ps1 to refresh artifacts.json."
}

# === END: PS7-safe HTTP probe ===
# === BEGIN: PS7-safe HTTP probe with proper $pip init ===

# 1) ensure temp/exported-template.json існує (беремо URL з artifacts.json)
$RepoRoot   = Get-Location
$TempFolder = Join-Path $RepoRoot "temp"
$LocalTpl   = Join-Path $TempFolder "exported-template.json"

if (-not (Test-Path $LocalTpl)) {
  if (-not (Test-Path $TempFolder)) { $null = New-Item -ItemType Directory -Path $TempFolder }
  $art = Get-Content (Join-Path $RepoRoot "artifacts.json") -Raw | ConvertFrom-Json
  if (-not $art.resourcesTemplate -or [string]::IsNullOrWhiteSpace($art.resourcesTemplate)) {
    throw "No resourcesTemplate URL in artifacts.json. Run scripts/generate-artifacts.ps1 and commit artifacts.json."
  }
  Write-Verbose "Downloading exported template from $($art.resourcesTemplate)"
  Invoke-WebRequest -Uri $art.resourcesTemplate -OutFile $LocalTpl
}

# 2) витягуємо Public IP з шаблону
$tpl = Get-Content $LocalTpl -Raw | ConvertFrom-Json
$pip = $tpl.resources | Where-Object { $_.type -eq 'Microsoft.Network/publicIPAddresses' } | Select-Object -First 1
if (-not $pip) {
  throw "No Microsoft.Network/publicIPAddresses resource found in exported-template.json. Re-generate artifacts after deploying Public IP."
}

# 3) формуємо цілі
$targetFqdn = $pip.properties.dnsSettings.fqdn
$targetIp   = $pip.properties.ipAddress

$urls = @()
if ($targetFqdn) { $urls += "http://$targetFqdn/" }
if ($targetIp)   { $urls += "http://$targetIp/" }

if ($urls.Count -eq 0) {
  throw "No target FQDN or IP found in artifacts/template (dnsSettings.fqdn / ipAddress are empty). Check exported-template.json and scripts/generate-artifacts.ps1 output."
}

# 4) ретраї без -UseBasicParsing (PS7-safe)
$ok = $false
foreach ($u in $urls) {
  Write-Verbose "Probing $u ..."
  for ($i = 1; $i -le 10; $i++) {
    try {
      $resp = Invoke-WebRequest -Uri $u -TimeoutSec 5
      if ($resp.StatusCode -eq 200) { $ok = $true; break }
    } catch {
      Start-Sleep -Seconds 2
    }
  }
  if ($ok) { break }
}

if (-not $ok) {
  throw "Unable to get a response from the web app via $($urls -join ', '). Ensure the VM app is running and re-run scripts/generate-artifacts.ps1 to refresh artifacts.json."
}

# === END: PS7-safe HTTP probe ===
# === BEGIN: PS7-safe HTTP probe with proper $pip init ===

# 1) ensure temp/exported-template.json існує (беремо URL з artifacts.json)
$RepoRoot   = Get-Location
$TempFolder = Join-Path $RepoRoot "temp"
$LocalTpl   = Join-Path $TempFolder "exported-template.json"

if (-not (Test-Path $LocalTpl)) {
  if (-not (Test-Path $TempFolder)) { $null = New-Item -ItemType Directory -Path $TempFolder }
  $art = Get-Content (Join-Path $RepoRoot "artifacts.json") -Raw | ConvertFrom-Json
  if (-not $art.resourcesTemplate -or [string]::IsNullOrWhiteSpace($art.resourcesTemplate)) {
    throw "No resourcesTemplate URL in artifacts.json. Run scripts/generate-artifacts.ps1 and commit artifacts.json."
  }
  Write-Verbose "Downloading exported template from $($art.resourcesTemplate)"
  Invoke-WebRequest -Uri $art.resourcesTemplate -OutFile $LocalTpl
}

# 2) витягуємо Public IP з шаблону
$tpl = Get-Content $LocalTpl -Raw | ConvertFrom-Json
$pip = $tpl.resources | Where-Object { $_.type -eq 'Microsoft.Network/publicIPAddresses' } | Select-Object -First 1
if (-not $pip) {
  throw "No Microsoft.Network/publicIPAddresses resource found in exported-template.json. Re-generate artifacts after deploying Public IP."
}

# 3) формуємо цілі
$targetFqdn = $pip.properties.dnsSettings.fqdn
$targetIp   = $pip.properties.ipAddress

$urls = @()
if ($targetFqdn) { $urls += "http://$targetFqdn/" }
if ($targetIp)   { $urls += "http://$targetIp/" }

if ($urls.Count -eq 0) {
  throw "No target FQDN or IP found in artifacts/template (dnsSettings.fqdn / ipAddress are empty). Check exported-template.json and scripts/generate-artifacts.ps1 output."
}

# 4) ретраї без -UseBasicParsing (PS7-safe)
$ok = $false
foreach ($u in $urls) {
  Write-Verbose "Probing $u ..."
  for ($i = 1; $i -le 10; $i++) {
    try {
      $resp = Invoke-WebRequest -Uri $u -TimeoutSec 5
      if ($resp.StatusCode -eq 200) { $ok = $true; break }
    } catch {
      Start-Sleep -Seconds 2
    }
  }
  if ($ok) { break }
}

if (-not $ok) {
  throw "Unable to get a response from the web app via $($urls -join ', '). Ensure the VM app is running and re-run scripts/generate-artifacts.ps1 to refresh artifacts.json."
}

# === END: PS7-safe HTTP probe ===
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
      $resp = # --- robust HTTP probe: FQDN → IP with retries, PS7-safe ---
if (-not $pip) {
    $pip = (Get-Content .\temp\exported-template.json -Raw | ConvertFrom-Json).resources |
        Where-Object { $_.type -eq "Microsoft.Network/publicIPAddresses" } |
        Select-Object -First 1
}

$targetFqdn = $pip.properties.dnsSettings.fqdn
$targetIp   = $pip.properties.ipAddress

$urls = @()
if ($targetFqdn) { $urls += "http://$targetFqdn/" }
if ($targetIp)   { $urls += "http://$targetIp/" }

if ($urls.Count -eq 0) {
    throw "No target FQDN or IP found in artifacts — check artifacts.json and generate-artifacts.ps1 output."
}

$response = $null
$ok = $false
foreach ($u in $urls) {
    Write-Verbose "Probing $u ..."
    for ($i = 1; $i -le 10; $i++) {
        try {
            $resp = Invoke-WebRequest -Uri $u -TimeoutSec 5
            if ($resp.StatusCode -eq 200) {
                $response = $resp
                $ok = $true
                break
            }
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    if ($ok) { break }
}

if (-not $ok -or -not $response) {
    throw "Unable to get a response from the web app via $($urls -join ', '). Ensure the VM app is running and that generate-artifacts.ps1 was run to update artifacts.json."
}
# --- end robust HTTP probe ---
Invoke-WebRequest -Uri $u -TimeoutSec 5
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





