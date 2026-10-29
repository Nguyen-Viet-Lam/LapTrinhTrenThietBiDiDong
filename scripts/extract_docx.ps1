param([string]$DocxPath)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($DocxPath)
$entry = $zip.GetEntry('word/document.xml')
$stream = $entry.Open()
$reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8)
[xml]$xml = $reader.ReadToEnd()
$stream.Close()
$zip.Dispose()
$xml.document.body.p | ForEach-Object {
    $t = $_.InnerText.Trim()
    if ($t) { Write-Output $t }
}
