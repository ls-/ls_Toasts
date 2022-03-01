Set-Location $PSScriptRoot

if (-Not (Test-Path "C:\PROGRA~1\7-Zip\7z.exe")) {
	Write-Host "7z.exe not found"

	return Read-Host
}

Set-Alias 7z "C:\PROGRA~1\7-Zip\7z.exe"

$name = (Get-Item .).Name

if (-Not (Test-Path (".\" + $name + ".toc"))) {
	Write-Host "Classic .toc not found"

	return Read-Host
}

if (Get-Content (".\" + $name + ".toc") | Where { $_ -match "(Version: +)([a-zA-Z0-9.-]+)" }) {
	$versionClassic = $matches[2]
} else {
	Write-Host "Bad Classic version format"

	return Read-Host
}

if (-Not (Test-Path (".\" + $name + "_TBC.toc"))) {
	Write-Host "TBC .toc not found"

	return Read-Host
}

if (Get-Content (".\" + $name + "_TBC.toc") | Where { $_ -match "(Version: +)([a-zA-Z0-9.-]+)" }) {
	$versionTBC = $matches[2]
} else {
	Write-Host "Bad TBC version format"

	return Read-Host
}

$includedFiles = @(
	".\init.lua",
	".\LICENSE.txt",
	".\ls_Toasts.toc",
	".\ls_Toasts_TBC.toc",
	".\assets\",
	".\core\",
	".\embeds\"
	".\locales\",
	".\skins\",
	".\systems\"
)

if (Test-Path ".\temp\") {
	Remove-Item ".\temp\" -Recurse -Force
}

New-Item -Path (".\temp\" + $name) -ItemType Directory | Out-Null
Copy-Item $includedFiles -Destination (".\temp\" + $name) -Recurse

Set-Location ".\temp\"

7z a -tzip -mx9 ($name + "-" + $versionClassic + "_" + $versionTBC + ".zip") (Get-ChildItem -Path "..\temp")

Set-Location "..\"

Move-Item ".\temp\*.zip" -Destination "..\" -Force
Remove-Item ".\temp" -Recurse -Force
