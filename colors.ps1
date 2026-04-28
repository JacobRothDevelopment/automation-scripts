[CmdletBinding()]

param ()

#region Globals

# $colors = ("Black", "DarkGray", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")
$colors = [enum]::GetValues([System.ConsoleColor])

#endregion

Write-Output "Preset Colors"
for ($i = 0; $i -lt $colors.Count; $i++) {
    for ($j = 0; $j -lt $colors.Count; $j++) {
        Write-Host "|$($colors[$j])|" -ForegroundColor $colors[$j] -BackgroundColor $colors[$i] -NoNewline
    }
    # Write-Host "`r"
    Write-Host " on $($colors[$i])"
}

Write-Output "`nCustom Colors"

$reset = $PSStyle.Reset
$step = 24

for ($c1 = 0; $c1 -lt 256; $c1 = $c1 + $step) {
    for ($c2 = 0; $c2 -lt 256; $c2 = $c2 + $step) {
        for ($c3 = 0; $c3 -lt 256; $c3 = $c3 + $step) {
            $color = $PSStyle.Foreground.FromRgb($c1, $c2, $c3)
            Write-Host "${color}O${reset}" -NoNewline
            # Write-Host "${color} $c1 $c2 $c3 ${reset}" 
        }
    }
    Write-Host ""
}

Write-Output "`nCustom Colors - Grey scale"

$reset = $PSStyle.Reset
$step_grey = 2

for ($c = 0; $c -lt 256; $c = $c + $step_grey) {
    $color = $PSStyle.Foreground.FromRgb($c, $c, $c)
    Write-Host "${color}O${reset}" -NoNewline
}
Write-Host ""
