#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$Root = (Split-Path $PSScriptRoot -Parent),
    [switch]$CheckRemote,
    [switch]$RequireDirectConfig,
    [ValidateRange(1, 120)][int]$TimeoutSeconds = 20
)

function Get-RuleEntries {
    param([AllowEmptyString()][string]$Content)
    @($Content -split '\r?\n' | ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') -and -not $_.StartsWith('//') })
}

function Test-RuleContent {
    param(
        [AllowEmptyString()][string]$Content,
        [ValidateSet('RULE-SET', 'DOMAIN-SET')][string]$Kind
    )
    if ($Content -match '(?i)<!doctype\s+html|<\s*/?\s*(html|head|body)\b') { return $false }
    $entries = @(Get-RuleEntries -Content $Content)
    if ($entries.Count -eq 0) { return $false }
    foreach ($entry in $entries) {
        if ($Kind -eq 'DOMAIN-SET') {
            if ($entry -notmatch '^(?:\+\.|\*\.|\.)?(?:[a-zA-Z0-9_-]+\.)+[a-zA-Z0-9_-]+$') { return $false }
        } elseif ($entry -notmatch '^(DOMAIN(?:-SUFFIX|-KEYWORD|-WILDCARD)?|IP-CIDR6?|IP-ASN|USER-AGENT|URL-REGEX),[^,\s][^,]*(?:,[^,\r\n]+)*$') {
            return $false
        } else {
            $parts = $entry -split ','
            $type = $parts[0]
            $target = $parts[1]
            switch -Regex ($type) {
                '^DOMAIN(?:-SUFFIX)?$' {
                    if ($target -notmatch '^(?:[a-zA-Z0-9_](?:[a-zA-Z0-9_-]*[a-zA-Z0-9_])?\.)*[a-zA-Z0-9_](?:[a-zA-Z0-9_-]*[a-zA-Z0-9_])?$') { return $false }
                }
                '^DOMAIN-WILDCARD$' {
                    if ($target -notmatch '^[a-zA-Z0-9_*?-]+(?:\.[a-zA-Z0-9_*?-]+)*$') { return $false }
                }
                '^IP-CIDR6?$' {
                    $cidr = $target -split '/'
                    $address = $null
                    $prefix = 0
                    if ($cidr.Count -ne 2 -or -not [Net.IPAddress]::TryParse($cidr[0], [ref]$address) -or
                        $cidr[1] -notmatch '^\d+$' -or -not [int]::TryParse($cidr[1], [ref]$prefix)) { return $false }
                    if ($type -eq 'IP-CIDR6' -and $address.AddressFamily -ne [Net.Sockets.AddressFamily]::InterNetworkV6) {
                        return $false
                    }
                    if ($address.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork) {
                        if ($cidr[0] -notmatch '^\d{1,3}(?:\.\d{1,3}){3}$' -or $prefix -gt 32) { return $false }
                    } elseif ($address.AddressFamily -ne [Net.Sockets.AddressFamily]::InterNetworkV6 -or $prefix -gt 128) {
                        return $false
                    }
                }
                '^IP-ASN$' {
                    $asn = [uint32]0
                    if ($target -notmatch '^\d+$' -or -not [uint32]::TryParse($target, [ref]$asn) -or $asn -eq 0) { return $false }
                }
                '^URL-REGEX$' {
                    try { [regex]::new($target) | Out-Null } catch { return $false }
                }
            }
        }
    }
    return $true
}

function Read-RemoteRules {
    param([string]$Url, [int]$TimeoutSeconds)
    $client = [System.Net.Http.HttpClient]::new()
    try {
        $client.Timeout = [TimeSpan]::FromSeconds($TimeoutSeconds)
        $response = $client.GetAsync($Url).GetAwaiter().GetResult()
        try {
            $response.EnsureSuccessStatusCode() | Out-Null
            $bytes = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
            return [System.Text.UTF8Encoding]::new($false, $true).GetString($bytes)
        } finally { $response.Dispose() }
    } finally { $client.Dispose() }
}

function Invoke-ModuleValidation {
    param([string]$Root, [switch]$CheckRemote, [int]$TimeoutSeconds, [switch]$RequireDirectConfig)
    $errors = [System.Collections.Generic.List[string]]::new()
    $references = [System.Collections.Generic.List[object]]::new()
    $texts = @{}
    $checked = 0
    $remotePassed = 0
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        Write-Output "ERROR: Root directory does not exist: $Root"
        return 1
    }
    $rootPath = (Resolve-Path -LiteralPath $Root).Path
    $ownRoot = (Resolve-Path -LiteralPath (Split-Path $PSScriptRoot -Parent)).Path
    if (($RequireDirectConfig -or $rootPath -eq $ownRoot) -and
        -not (Test-Path -LiteralPath (Join-Path $rootPath 'configs/direct.conf') -PathType Leaf)) {
        $errors.Add('Missing required configuration: configs/direct.conf')
    }
    $files = @(Get-ChildItem -LiteralPath $rootPath -File -Force -Recurse | Where-Object {
        $relative = [System.IO.Path]::GetRelativePath($rootPath, $_.FullName).Replace('\', '/')
        $relative -notmatch '^(\.git|work)/' -and (
            $_.Extension -in '.conf', '.module', '.sgmodule', '.md', '.ps1', '.yaml', '.yml', '.json', '.html', '.js' -or
            $_.Name -in '.gitattributes', '.gitignore'
        )
    })
    foreach ($file in $files) {
        $relative = [System.IO.Path]::GetRelativePath($rootPath, $file.FullName).Replace('\', '/')
        try {
            $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xef -and $bytes[1] -eq 0xbb -and $bytes[2] -eq 0xbf) {
                throw 'UTF-8 BOM is not allowed.'
            }
            $content = [System.Text.UTF8Encoding]::new($false, $true).GetString($bytes)
            if ($content.Contains("`r")) { throw 'Use LF line endings, not CRLF or CR.' }
            $texts[$relative] = $content
            $checked++
        } catch { $errors.Add("${relative}: $($_.Exception.Message)") }
    }
    $configs = @($files | Where-Object { $_.Extension -eq '.conf' })
    foreach ($config in $configs) {
        $relative = [System.IO.Path]::GetRelativePath($rootPath, $config.FullName).Replace('\', '/')
        if ($relative -cne 'configs/direct.conf') {
            $errors.Add("${relative}: Unsupported configuration; expected configs/direct.conf.")
            continue
        }
        if (-not $texts.ContainsKey($relative)) { continue }
        $settings = @{}
        $requiredSettings = @{
            'fallback-dns-server' = 'system'
            'dns-direct-fallback-proxy' = 'false'
            'private-ip-answer' = 'true'
            'udp-policy-not-supported-behaviour' = 'REJECT'
        }
        $configSection = ''
        $configSections = [System.Collections.Generic.HashSet[string]]::new()
        $configRules = [System.Collections.Generic.List[string]]::new()
        $configLine = 0
        foreach ($rawLine in ($texts[$relative] -split "`n")) {
            $configLine++
            $line = $rawLine.Trim()
            $location = "${relative}:$configLine"
            if (-not $line -or $line.StartsWith('#')) { continue }
            if ($line -match '^\[(.+)\]$') {
                $configSection = $Matches[1]
                if ($configSection -cnotin 'General', 'Rule') {
                    $errors.Add("${location}: Only [General] and [Rule] are allowed in direct.conf.")
                } elseif (-not $configSections.Add($configSection)) {
                    $errors.Add("${location}: Duplicate [$configSection] section.")
                }
                continue
            }
            if ($configSection -ceq 'Rule') {
                $configRules.Add($line)
                continue
            }
            if ($configSection -cne 'General' -or $line -notmatch '^([a-z-]+)\s*=\s*(.+)$') {
                $errors.Add("${location}: Expected a setting inside [General] or a rule inside [Rule].")
                continue
            }
            $key = $Matches[1]
            $value = $Matches[2].Trim()
            if ($settings.ContainsKey($key)) { $errors.Add("${location}: Duplicate $key setting.") }
            $settings[$key] = $value
            if ($key -ceq 'dns-server') {
                foreach ($url in ($value -split ',')) {
                    $uri = $null
                    if (-not [Uri]::TryCreate($url.Trim(), [UriKind]::Absolute, [ref]$uri) -or
                        $uri.Scheme -ne 'https' -or -not $uri.Host -or $uri.UserInfo -or $uri.Fragment) {
                        $errors.Add("${location}: dns-server must contain valid HTTPS DNS URLs.")
                    }
                }
            } elseif (-not $requiredSettings.ContainsKey($key)) {
                $errors.Add("${location}: Unsupported direct.conf setting: $key")
            } elseif ($value -cne $requiredSettings[$key]) {
                $errors.Add("${location}: $key must be $($requiredSettings[$key]) for this routing policy.")
            }
        }
        foreach ($key in @('dns-server') + @($requiredSettings.Keys)) {
            if (-not $settings.ContainsKey($key)) { $errors.Add("${relative}: Missing required $key setting.") }
        }
        if (-not $configSections.Contains('Rule') -or $configRules.Count -ne 1 -or $configRules[0] -cne 'FINAL,DIRECT') {
            $errors.Add("${relative}: [Rule] must contain only FINAL,DIRECT.")
        }
    }
    $modules = @($files | Where-Object { $_.Extension -in '.module', '.sgmodule' })
    if ($modules.Count -eq 0) { $errors.Add('No module files found under modules/routing/.') }
    foreach ($module in $modules) {
        $relative = [System.IO.Path]::GetRelativePath($rootPath, $module.FullName).Replace('\', '/')
        if ($relative -notmatch '^modules/routing/.+\.module$') {
            $errors.Add("${relative}: Unsupported module location or extension; expected modules/routing/*.module.")
            continue
        }
        if (-not $texts.ContainsKey($relative)) { continue }
        $metadata = @{}
        $section = ''
        $referenceCount = 0
        $lineNumber = 0
        foreach ($rawLine in ($texts[$relative] -split "`n")) {
            $lineNumber++
            $line = $rawLine.Trim()
            $location = "${relative}:$lineNumber"
            if (-not $line) { continue }
            if ($line -match '^#!(name|desc)=(.*)$') {
                $key = $Matches[1]
                if ($metadata.ContainsKey($key)) { $errors.Add("${location}: Duplicate #!$key metadata.") }
                $metadata[$key] = $Matches[2].Trim()
                continue
            }
            if ($line.StartsWith('#')) { continue }
            if ($line -match '^\[(.+)\]$') {
                $section = $Matches[1]
                if ($section -cne 'Rule') { $errors.Add("${location}: Only [Rule] is allowed in routing modules.") }
                continue
            }
            if ($section -cne 'Rule') { $errors.Add("${location}: Rule reference must be inside [Rule]."); continue }
            if ($line -notmatch '^(RULE-SET|DOMAIN-SET),([^,]+),(PROXY|DIRECT|REJECT)$') {
                $errors.Add("${location}: Expected RULE-SET or DOMAIN-SET with HTTPS URL and PROXY/DIRECT/REJECT policy.")
                continue
            }
            $kind = $Matches[1]
            $url = $Matches[2]
            $uri = $null
            if (-not [Uri]::TryCreate($url, [UriKind]::Absolute, [ref]$uri) -or
                $uri.Scheme -ne 'https' -or -not $uri.Host -or $uri.UserInfo -or $uri.Fragment) {
                $errors.Add("${location}: Invalid HTTPS rule URL: $url")
                continue
            }
            $referenceCount++
            $references.Add([pscustomobject]@{ Kind = $kind; Url = $url })
        }
        foreach ($key in 'name', 'desc') {
            if (-not $metadata.ContainsKey($key) -or -not $metadata[$key]) { $errors.Add("${relative}: Missing non-empty #!$key metadata.") }
        }
        if ($referenceCount -eq 0) { $errors.Add("${relative}: No valid remote rule references.") }
    }
    if ($CheckRemote -and $errors.Count -eq 0) {
        $cache = @{}
        foreach ($reference in ($references | Sort-Object Url, Kind -Unique)) {
            try {
                if (-not $cache.ContainsKey($reference.Url)) {
                    $cache[$reference.Url] = Read-RemoteRules -Url $reference.Url -TimeoutSeconds $TimeoutSeconds
                }
                $content = $cache[$reference.Url]
                if (-not (Test-RuleContent -Content $content -Kind $reference.Kind)) {
                    throw 'Response is empty, HTML, or contains unsupported/malformed rule text.'
                }
                $count = @(Get-RuleEntries -Content $content).Count
                Write-Output "PASS: $($reference.Kind) $($reference.Url) ($count entries)"
                $remotePassed++
            } catch { $errors.Add("$($reference.Url): $($_.Exception.Message)") }
        }
    }
    foreach ($message in $errors) { Write-Output "ERROR: $message" }
    Write-Output "Validation: $checked text files checked, $($configs.Count) configs, $($modules.Count) modules, $remotePassed remote sets passed, $($errors.Count) errors."
    if ($errors.Count -gt 0) { return 1 }
    return 0
}

# Dot-sourcing exposes functions without running or exiting the caller.
if ($MyInvocation.InvocationName -ne '.') {
    $results = @(Invoke-ModuleValidation -Root $Root -CheckRemote:$CheckRemote -TimeoutSeconds $TimeoutSeconds -RequireDirectConfig:$RequireDirectConfig)
    $code = [int]$results[-1]
    $results | Select-Object -SkipLast 1 | Write-Output
    exit $code
}
