#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'validate.ps1')

# Shadowrocket IP-CIDR accepts both address families; IP-CIDR6 is IPv6 only.
$cases = @(
    @{ Name = 'IPv4 CIDR'; Rule = 'IP-CIDR,192.0.2.0/24,no-resolve'; Expected = $true },
    @{ Name = 'IPv6 in IP-CIDR'; Rule = 'IP-CIDR,2001:db8::/32,no-resolve'; Expected = $true },
    @{ Name = 'IPv6 in IP-CIDR6'; Rule = 'IP-CIDR6,2001:db8::/32,no-resolve'; Expected = $true },
    @{ Name = 'IPv4 host prefix'; Rule = 'IP-CIDR,192.0.2.1/32'; Expected = $true },
    @{ Name = 'IPv6 host prefix'; Rule = 'IP-CIDR,2001:db8::1/128'; Expected = $true },
    @{ Name = 'IPv4 in IP-CIDR6'; Rule = 'IP-CIDR6,192.0.2.1/32'; Expected = $false },
    @{ Name = 'IPv4 prefix overflow'; Rule = 'IP-CIDR,192.0.2.1/33'; Expected = $false },
    @{ Name = 'IPv6 prefix overflow'; Rule = 'IP-CIDR,2001:db8::1/129'; Expected = $false },
    @{ Name = 'Invalid IPv4'; Rule = 'IP-CIDR,999.999.999.999/24'; Expected = $false },
    @{ Name = 'Abbreviated IPv4'; Rule = 'IP-CIDR,127.1/8'; Expected = $false },
    @{ Name = 'Invalid IPv6'; Rule = 'IP-CIDR,2001:xyz::/32'; Expected = $false },
    @{ Name = 'Negative prefix'; Rule = 'IP-CIDR,192.0.2.1/-1'; Expected = $false },
    @{ Name = 'Missing prefix'; Rule = 'IP-CIDR,2001:db8::'; Expected = $false }
)
$failed = 0
foreach ($case in $cases) {
    if ((Test-RuleContent -Content $case.Rule -Kind RULE-SET) -ne $case.Expected) {
        Write-Output "FAIL: $($case.Name)"
        $failed++
    } else {
        Write-Output "PASS: $($case.Name)"
    }
}
Write-Output "Rule content regression: $($cases.Count - $failed) passed, $failed failed."
if ($failed) { exit 1 }
