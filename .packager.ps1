Set-Location $PSScriptRoot

if (-Not (Test-Path "C:\PROGRA~1\7-Zip\7z.exe")) {
	throw "7z.exe not found"
}

Set-Alias 7z "C:\PROGRA~1\7-Zip\7z.exe"

$name = (Get-Item .).Name

if (-Not (Test-Path (".\" + $name + ".toc"))) {
	throw ".toc not found"
}

$version = if ((Get-Content (".\" + $name + ".toc") | Where {
	$_ -match "Version: ([0-9]+\.[0-9]+)"
}) -match "([0-9]+\.[0-9]+)") {
	$matches[1]
}

if (-Not $version) {
	throw "Bad version format"
}

$includedFiles = @(
	".\LICENSE.txt",
	".\ls_Toasts.lua",
	".\ls_Toasts.toc",
    ".\locales\",
	".\media\"
)

if (Test-Path ".\temp\") {
	Remove-Item ".\temp\" -Recurse -Force
}

New-Item -Path (".\temp\" + $name) -ItemType Directory | Out-Null
Copy-Item $includedFiles -Destination (".\temp\" + $name) -Recurse

Set-Location ".\temp\"

7z a -tzip -mx9 ($name + "-" + $version + ".zip") (Get-ChildItem -Path "..\temp")

Set-Location "..\"

Move-Item ".\temp\*.zip" -Destination "..\" -Force
Remove-Item ".\temp" -Recurse -Force
