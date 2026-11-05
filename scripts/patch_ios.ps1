# Tu dong cau hinh iOS cho Hapy: Info.plist + AppDelegate.swift
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$utf8 = New-Object System.Text.UTF8Encoding($false)

# ---------- Info.plist ----------
$plist = Join-Path $root 'ios\Runner\Info.plist'
if (-not (Test-Path $plist)) { Write-Host '[LOI] Khong thay ios\Runner\Info.plist'; exit 1 }
$t = [IO.File]::ReadAllText($plist)

if ($t -notmatch 'NSPhotoLibraryUsageDescription') {
    $msg = [regex]::Unescape('Ch\u1ECDn \u1EA3nh minh h\u1ECDa cho b\u00E0i h\u1ECDc c\u1EE7a b\u00E9')
    $add = "`t<key>NSPhotoLibraryUsageDescription</key>`n`t<string>$msg</string>`n"
    $i = $t.LastIndexOf('</dict>')
    $t = $t.Insert($i, $add)
    Write-Host 'Da them NSPhotoLibraryUsageDescription vao Info.plist'
}

# Quyen micro + nhan dang giong noi (nhap tu/cau bang giong noi)
$voiceKeys = @(
    @('NSMicrophoneUsageDescription', 'Hapy d\u00F9ng micro \u0111\u1EC3 b\u00E9 n\u00F3i thay v\u00EC g\u00F5 ch\u1EEF'),
    @('NSSpeechRecognitionUsageDescription', 'Hapy nh\u1EADn bi\u1EBFt gi\u1ECDng n\u00F3i \u0111\u1EC3 chuy\u1EC3n l\u1EDDi b\u00E9 n\u00F3i th\u00E0nh ch\u1EEF')
)
foreach ($pair in $voiceKeys) {
    if ($t -notmatch $pair[0]) {
        $m = [regex]::Unescape($pair[1])
        $i = $t.LastIndexOf('</dict>')
        $t = $t.Insert($i, "`t<key>$($pair[0])</key>`n`t<string>$m</string>`n")
        Write-Host "Da them $($pair[0]) vao Info.plist"
    }
}

$t = [regex]::Replace($t, '(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)', '${1}Hapy${2}')
[IO.File]::WriteAllText($plist, $t, $utf8)
Write-Host 'Da dat ten hien thi: Hapy'

# ---------- AppDelegate.swift ----------
$ad = Join-Path $root 'ios\Runner\AppDelegate.swift'
if (Test-Path $ad) {
    $s = [IO.File]::ReadAllText($ad)
    if ($s -match 'UNUserNotificationCenter') {
        Write-Host 'AppDelegate.swift da duoc cau hinh san'
    } else {
        $pattern = '(?m)^([ \t]*)return super\.application\(application, didFinishLaunchingWithOptions: launchOptions\)'
        if ($s -match $pattern) {
            $eval = [System.Text.RegularExpressions.MatchEvaluator]{
                param($m)
                $ind = $m.Groups[1].Value
                $ind + 'if #available(iOS 10.0, *) {' + "`n" +
                $ind + '  UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate' + "`n" +
                $ind + '}' + "`n" + $m.Value
            }
            $s = [regex]::Replace($s, $pattern, $eval)
            [IO.File]::WriteAllText($ad, $s, $utf8)
            Write-Host 'Da cau hinh thong bao trong AppDelegate.swift'
        } else {
            Write-Host '[CANH BAO] Khong tu sua duoc AppDelegate.swift (mau Flutter khac). Bo qua; xem HUONG_DAN.md de sua tay.'
        }
    }
}
exit 0
