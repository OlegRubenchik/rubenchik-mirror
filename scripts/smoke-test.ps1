# Smoke test on the runner with a stripped PATH, so only the bundled DLLs can satisfy uxplay.exe.
param([Parameter(Mandatory)] [string] $App)
$ErrorActionPreference = 'Stop'
$bin = Join-Path $App 'bin'
$env:PATH = "$env:SystemRoot\System32;$env:SystemRoot"   # no MSYS2, no Git, no GStreamer
Remove-Item Env:GST_PLUGIN_PATH, Env:GST_PLUGIN_SYSTEM_PATH, Env:GST_REGISTRY -ErrorAction SilentlyContinue

Write-Host "== uxplay -h"
$out = Join-Path $env:RUNNER_TEMP 'help.txt'
$hp = Start-Process -FilePath "$bin\uxplay.exe" -ArgumentList '-h' -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError "$out.err"
$help = (Get-Content $out, "$out.err" -ErrorAction SilentlyContinue) -join "`n"
Write-Host "exit code: $($hp.ExitCode)"
Write-Host $help
if ($hp.ExitCode -gt 1 -or [string]::IsNullOrWhiteSpace($help)) { throw "uxplay.exe -h failed (exit $($hp.ExitCode)) - missing DLL?" }
foreach ($flag in '-n ', '-nh', '-fs', '-s wxh', '-fps', '-vs ', '-rc', '-pin') {
  if ($help -notmatch [regex]::Escape($flag)) { throw "Flag '$flag' not found in 'uxplay -h' - update packaging/uxplayrc" }
}

Write-Host "== GStreamer elements"
$required = 'appsrc','h264parse','avdec_h264','d3d11videosink','d3d11convert','videoconvert','audioconvert',
            'audioresample','wasapisink','queue','avdec_aac','avdec_alac','level','jpegdec','imagefreeze','textoverlay','videoscale','volume'
$optional = 'd3d11h264dec','directsoundsink','autovideosink','autoaudiosink','aacparse','videoflip','audiobuffersplit'
foreach ($e in $required + $optional) {
  & "$bin\gst-inspect-1.0.exe" $e *> $null
  if ($LASTEXITCODE -ne 0) {
    if ($required -contains $e) { throw "Required GStreamer element missing: $e" }
    Write-Host "::warning::optional GStreamer element missing: $e"
  } else { Write-Host "ok  $e" }
}

Write-Host "== server starts and stays alive"
$rc = Join-Path $App 'uxplayrc'
$log = Join-Path $env:RUNNER_TEMP 'uxplay.log'
$p = Start-Process -FilePath "$bin\uxplay.exe" -ArgumentList '-rc', "`"$rc`"" -PassThru -RedirectStandardOutput $log -RedirectStandardError "$log.err" -WindowStyle Hidden
Start-Sleep -Seconds 8
$alive = -not $p.HasExited
Get-Content $log, "$log.err" -ErrorAction SilentlyContinue | Write-Host
if ($alive) { Stop-Process -Id $p.Id -Force } else { throw "uxplay.exe exited early with code $($p.ExitCode)" }
Write-Host "Smoke test passed."
