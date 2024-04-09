Set-Location $PSScriptRoot

$csv = Invoke-WebRequest "https://wago.tools/db2/CurrencyTypes/csv" | ConvertFrom-Csv

$currenciesToBlacklist = @(
	2032 # Trader's Tender
)

$currenciesToWhitelist = @(
	1540, # Wood
	1541, # Iron
	1559  # Essence of Storms
)

$categoriesToBlacklist = @(
	3,   # Unused
	41,  # Test
	82,  # Archaeology
	89,  # Meta
	142, # Hidden
	144, # Virtual
	246, # Debug
	248, # Torghast UI (Hidden)
	251, # Dragon Racing UI (Hidden)
	252  # Tuskarr - Fishing Nets (Hidden)
)

# convert IDs to int because sorting strings sucks ass
$ID = @{ l = "ID"; e = { $_.ID -as [int] } }

$blackist = $csv |
	Where-Object {
		($currenciesToBlacklist -contains $_.ID -or $categoriesToBlacklist -contains $_.CategoryID) -and $currenciesToWhitelist -notcontains $_.ID
	} |
	Select-Object $ID, Name_lang |
	Sort-Object ID
# $blackist | ForEach-Object {
# 	Write-Host "[$($_.ID.ToString().PadLeft(4))] = true, -- $($_.Name_lang)"
# }

# 0x8 - 1/100 scalar for display
$mult = $csv |
	Where-Object {
		$_.Flags_0 -band 8 -and -not (($currenciesToBlacklist -contains $_.ID -or $categoriesToBlacklist -contains $_.CategoryID) -and $currenciesToWhitelist -notcontains $_.ID)
	} |
	Select-Object $ID, Name_lang |
	Sort-Object ID
# $mult | ForEach-Object {
# 	Write-Host "[$($_.ID.ToString().PadLeft(4))] = 0.01, -- $($_.Name_lang)"
# }

$lua = ".\ls_Toasts\systems\loot_currency.lua"

$out = ""

foreach ($line in Get-Content $lua) {
	$out += "$($line)`n"

	if ($line -match "GENERATED-DATA-START") { break }
}

$out += "local BLACKLIST = {`n"

$blackist | ForEach-Object {
	$out += "`t[$($_.ID.ToString().PadLeft(4))] = true, -- $($_.Name_lang)`n"
}

$out += "}`n`n"

$out += "local MULT = {`n"

$mult | ForEach-Object {
	$out += "`t[$($_.ID.ToString().PadLeft(4))] = 0.01, -- $($_.Name_lang)`n"
}

$out += "}`n"

$canWrite = $false

foreach ($line in Get-Content $lua) {
	if ($line -match "GENERATED-DATA-END") {
		$canWrite = $true
	}

	if ($canWrite) {
		$out += "$($line)`n"
	}
}

Set-Content $lua -Value $out.TrimEnd()
