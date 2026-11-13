# ScenarioTest.ps1
# Switches between your three layouts in an order that covers every transition
# (A->B for all pairs, and the same layout twice), checks the result each time,
# and writes test-result.txt next to this script.
#
# Usage (one line, use your own monitor IDs and positions - see README):
#   powershell -ExecutionPolicy Bypass -File tools\ScenarioTest.ps1 `
#     -Short  "ABC1234=0,0" `
#     -Double "DEF5678=0,0 ABC1234=0,-1080" `
#     -Hold   "GHI9012=0,0 DEF5678=1920,0 ABC1234=1920,-1080"
#
# The screens switch many times while the test runs (1-3 minutes).

param(
    [Parameter(Mandatory = $true)][string]$Short,
    [Parameter(Mandatory = $true)][string]$Double,
    [Parameter(Mandatory = $true)][string]$Hold,
    [string]$Script = (Join-Path $PSScriptRoot '..\com.monitorswitch.sdPlugin\bin\Display.ps1')
)

$out = Join-Path $PSScriptRoot 'test-result.txt'

function Parse($spec) {
    $map = @{}
    foreach ($item in ($spec -split '\s+' | Where-Object { $_ })) {
        $id, $pos = $item -split '=', 2
        $x, $y = $pos -split ','
        $map[$id.ToUpper()] = "$([int]$x) $([int]$y)"
    }
    return $map
}

$layouts = @{ 'short' = $Short; 'double' = $Double; 'hold' = $Hold }

function Get-Layout {
    $map = @{}
    foreach ($l in (& powershell -NoProfile -ExecutionPolicy Bypass -File $Script --list)) {
        $p = "$l" -split "`t"
        if ($p.Count -ge 3 -and $p[0].Trim()) { $map[$p[0].Trim().ToUpper()] = "$($p[1]) $($p[2])" }
    }
    return $map
}

# Covers: hold->short, short->hold, hold->double, double->short, short->double, double->hold,
# and pressing the same one twice.
$steps = 'hold', 'short', 'hold', 'double', 'short', 'double', 'hold', 'hold', 'double', 'double', 'short', 'short', 'hold'

$result = New-Object System.Collections.Generic.List[string]
$result.Add("Scenario test  $(Get-Date -Format 'yyyy/MM/dd HH:mm:ss')")
$result.Add('')
$prev = '?'; $fail = 0; $n = 0

foreach ($s in $steps) {
    $n++
    $args2 = $layouts[$s] -split '\s+' | Where-Object { $_ }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @args2 | Out-Null
    Start-Sleep -Seconds 2

    $now = Get-Layout
    $want = Parse $layouts[$s]
    $problems = @()
    foreach ($id in $want.Keys) {
        if (-not $now.ContainsKey($id)) { $problems += "$id is off (should be on at $($want[$id]))" }
        elseif ($now[$id] -ne $want[$id]) { $problems += "$id at $($now[$id]) (should be $($want[$id]))" }
    }
    foreach ($id in $now.Keys) { if (-not $want.ContainsKey($id)) { $problems += "$id is on (should be off)" } }

    $title = "{0,2}. {1} -> {2}" -f $n, $prev, $s
    if ($problems.Count -eq 0) { $result.Add("PASS  $title") }
    else { $fail++; $result.Add("FAIL  $title"); foreach ($p in $problems) { $result.Add("        $p") } }
    $prev = $s
}

$result.Add('')
if ($fail -eq 0) { $result.Add("ALL PASSED ($n steps)") } else { $result.Add("$fail of $n steps FAILED") }
$result | Set-Content -Path $out -Encoding UTF8
$result | ForEach-Object { Write-Host $_ }
