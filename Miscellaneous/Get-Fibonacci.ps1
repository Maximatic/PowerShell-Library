<#
.SYNOPSIS
    Generates Fibonacci numbers.
.DESCRIPTION
    This was just an exercise to see if I could write a simple and compact PowerShell script
    that would generate Fibonacci numbers. This was Kevin Mitnick's first assignment in his
    early Fortran programming class, but he never finished the assignment and instead wrote a
    program to capture his professor's passwords.

    The Fibonacci Sequence is a series of numbers, starting with 0 and 1, where the next
    number is found by adding up the last two numbers before it.

    e.g. 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...

    This script produces the first 25 numbers, but you can change this by modifying the $max variable.

.NOTES
    File Name      : Get-Fibonacci.ps1
    Prerequisites  : PowerShell 2.0+
    Date           : 2019-06-18
.LINK
    https://en.wikipedia.org/wiki/Fibonacci_number
#>
$max = 25

$array = @(0,1)

for($i=0; $i -le $max; $i++) {
    $sum = $array[-2] + $array[-1]
    $array += $sum    
}

$array
