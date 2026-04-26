Set-Location $PSScriptRoot

$name = (Get-Item .).Name

if (-Not (Test-Path (".\" + $name + "\" + $name + ".toc"))) {
	Write-Host ".toc not found"

	return Read-Host
}

if (Get-Content (".\" + $name + "\" + $name + ".toc") | Where-Object { $_ -match "Version:\s*([a-zA-Z0-9.-]+)" }) {
	$version = $matches[1]
} else {
	Write-Host "Bad version format"

	return Read-Host
}

$foldersToInclude = @(
	".\$name"
)

$filesToExclude = @(
	"*.doc*"
	"*.editorconfig"
	"*.git*"
	"*.luacheck*"
	"*.pkg*"
	"*.ps1"
	"*.yml"
	"*.sh"
	"README*"
)

$foldersToRemove = @(
	".git"
	".github"
	"tests"
	"utils"
)

$temp = ".\temp\"

if (Test-Path $temp) {
	Remove-Item $temp -Recurse -Force
}

New-Item -Path $temp -ItemType Directory | Out-Null
Copy-Item $foldersToInclude -Destination $temp -Exclude $filesToExclude -Recurse
Get-ChildItem "$temp\$name\embeds\" -Recurse | Where-Object { $_.PSIsContainer -and $_.Name -cin $foldersToRemove } | Remove-Item -Recurse -Force
7zz a -tzip -mx9 "$name-$version.zip" (Get-ChildItem $temp)
Move-Item "$name-$version.zip" -Destination .. -Force
Remove-Item $temp -Recurse -Force
