Set-Location $PSScriptRoot

$lua = ".luacheckrc"

$out = ""
foreach ($line in Get-Content $lua) {
	if ($line -match "read_globals") { break }

	$out += "$line`n"
}

Set-Content $lua -Value $out.TrimEnd()

$vars = @()
luacheck --no-color . | ForEach-Object {
	if ($_ -match "accessing undefined variable '(.+?)'") {
		if ($vars -notcontains $matches[1]) {
			$vars += $matches[1]
		}
	}
}

$out += "read_globals = {`n"

foreach ($var in $vars | Sort-Object) {
	$out += "`t`"$var`",`n"
}

$out += "}`n"

Set-Content $lua -Value $out.TrimEnd()
