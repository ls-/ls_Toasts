Set-Location $PSScriptRoot

$token = (Test-Path "../Keys/CF") ? (Get-Content "../Keys/CF") : (Out-Null)
if (-not $token) {
	Write-Host "No Token!" -ForegroundColor Red

	Exit
}

$name = (Get-Item .).Name

if (Get-Content ("./$name/$name.toc") | Where-Object { $_ -match "X-Curse-Project-ID:\s*([0-9.-]+)" }) {
	$id = $matches[1]
} else {
	Write-Host "No ID!" -ForegroundColor Red

	Exit
}

$params = @{
	Uri = "https://wow.curseforge.com/api/projects/$id/localization/export"
	Method = "GET"
	Headers = @{
		"X-Api-Token" = $token
	}
	Body = @{
		unlocalized = "Ignore"
	}
}

$langs = @(
	"deDE"
	"esES"
	"esMX"
	"frFR"
	"itIT"
	"koKR"
	"ptBR"
	"ruRU"
	"zhCN"
	"zhTW"
)

foreach ($lang in $langs) {
	Write-Host "Fetching `e[1m$lang`e[0m`:"
	$params.Body.lang = $lang

	try
	{
		$response = Invoke-WebRequest @params
	}
	catch
	{
		Write-Host "  Failed!" -ForegroundColor Red

		continue
	}

	# do it here to differentiate between failures and empty payloads
	$response = $response | ForEach-Object {
		$_.Content.Split("`n")
	} | Where-Object {
		$_ -notmatch "L = L or {}"
	}

	$lua = "./$name/locales/$lang.lua"
	$out = ""

	foreach ($line in Get-Content $lua) {
		$out += "$line`n"

		if ($line -match "if GetLocale().*") {
			$out += "`n"

			break
		}
	}

	if ($response) {
		foreach($line in $response) {
			$out += "$line`n"
		}

		Write-Host "  Done!" -ForegroundColor Green
	} else {
		Write-Host "  Empty!" -ForegroundColor Yellow
	}

	Set-Content $lua -Value $out.TrimEnd() -Encoding utf8BOM
}
