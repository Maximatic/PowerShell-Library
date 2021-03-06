<#
.SYNOPSIS
    Molecular Weight Calculator
.DESCRIPTION
    Calculates the molecular weight (amu) of a user specified molecular formula.
    For example, if you enter "C2H5OH", the result will be "46.07 amu."
.NOTES
    File Name      : MWCalculator.ps1
    Prerequisite   : PowerShell 3.0+
    Date           : 2018-07-14
#>

# Download elements file containing atomic weights (if it doesn't already exist)
function DownloadCSV() {    
    $Path = Get-Location
    $ElementsFile = "$Path\elements.csv"
    
    If (-Not (Test-Path $ElementsFile)) {
    
        Write-Host "Downloading elements.csv from the web. Please wait..."; Write-Host
    
        $URL = "https://raw.githubusercontent.com/Maximatic/PowerShell-Library/master/Science/elements.csv"
    
        # Download elements.csv file from GitHub repository
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($URL,$ElementsFile)

        # If the above doesn't work, the code to download the elements.csv file should work with PowerShell 3.0.
        #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #Invoke-WebRequest -Uri $URL -OutFile $ElementsFile
    }
}

# Determine UPPERCASE, lowercase, or Number
function CheckCharType($x) {
    $uchar = $x.ToUpper()
    if ($x -match '\d$') {   # [0-9] or '\d$'
        Return 3
        }
    if ($x -ceq $uchar) { 
        Return 1
        }
    else { Return 2 }
}

# Split up molecular formula into its individual elements
function SplitFormula() {
    $CsvString = ""
    for($i = 0; $i -le $formula.length -1; $i++) {
        $char = $formula.substring($i,1)
        Switch(CheckCharType($char)) {
            1 { if ($i -eq 0) { $CsvString = "$CsvString$char" }
                else { $CsvString = "$CsvString,$char" } }
            2 { $CsvString = "$CsvString$char" }
            3 { $CsvString = "$CsvString$char" }
        }
    }
    return $CsvString
}

# Split the elements up by the element and the number of atoms
function SplitElement($x) {
    $CsvString = ""
    $num = 0
    for($i = 0; $i -le $x.length -1; $i++) {
        $char = $x.substring($i,1)
        Switch(CheckCharType($char)) {
            1 { if ($x.length -eq 1) { $CsvString = "$CsvString$char,1" } else { $CsvString = "$CsvString$char" } }
            2 { $CsvString = "$CsvString$char,1" }
            3 { if ($i -eq 0) { $CsvString = "$CsvString$char" }
                else { if ($num -eq 0) { $CsvString = "$CsvString,$char";$num++ } 
                    else { $CsvString = "$CsvString$char" } }
                }
        }
    }
    return $CsvString
}

# ------------------------------ Main Script Block ------------------------------

Clear-Host

# Initialize variables
$TotalMass = 0

DownloadCSV

# Load elements into array
$ElementsArray = Import-Csv elements.csv

# Prompt for chemical formula
$Formula = Read-Host "Enter chemical formula"

# Separate the individual elements from the chemical formula
$CsvString = SplitFormula

foreach ($Item in $CsvString.split(",")) {  # E.g. "Na,H,C,O3"
    $a = SplitElement($Item)
    $c = $a.Split(",")
    foreach ($char in $a.split(",")) {      # E.g. "Na,1"
        [Double]$Mass = $ElementsArray | Where-Object { $_.Symbol -eq "$char" } | Select-Object -ExpandProperty Mass
        $Mass = $Mass * $c[1]
        $TotalMass = $TotalMass + $Mass
    }
}

Write-Host "Molecular Formula: $Formula"
Write-Host "Molecular Weight: $TotalMass amu"
