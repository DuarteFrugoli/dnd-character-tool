$b = "C:\Users\Pedro Frugoli\Desktop\pessoal\vscode\dnd-character-tool\assets\data\i18n\pt"
$enc = [System.Text.Encoding]::UTF8
$noBom = New-Object System.Text.UTF8Encoding $false

# class_features.json only
# From: [ { class, features: [{ name, original, description }] } ]
# To:   { "ClassName": { "EN Feature": { "name": "PT", "description": "PT" } } }
$raw = [System.IO.File]::ReadAllText("$b\class_features.json", $enc) | ConvertFrom-Json
$out = [ordered]@{}
foreach ($entry in $raw) {
    $cls = $entry.class
    if (-not $out.Contains($cls)) { $out[$cls] = [ordered]@{} }
    foreach ($f in $entry.features) {
        if (-not $out[$cls].Contains($f.original)) {
            $out[$cls][$f.original] = [ordered]@{ name = $f.name; description = $f.description }
        }
    }
}
$json = $out | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText("$b\class_features.json", $json, $noBom)
Write-Host "class_features.json OK ($($out.Count) classes)"
