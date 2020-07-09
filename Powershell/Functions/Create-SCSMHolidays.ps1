param([string]$HolidayFile = "", [string]$CSVOutput = "", [string]$Country = "", [string]$CalendarName = "")

if ($HolidayFile -eq "" -or $CSVOutput -eq "" -or $Country -eq "" -or $CalendarName -eq "") {
    write-host "One or more parameters are missing!"
    write-host ""
    write-host "Parameters needed are:"
    write-host "-HolidayFile"
    write-host "Enter the complete path to the outlook holiday file you are using"
    write-host "-CSVOutput"
    write-host "Enter the complete path to the CSV file that the output is written to"
    write-host "-Country"
    write-host "Enter the name of the country which you want to retrive the holidays from"
    write-host "-CalendarName"
    write-host "Enter the name of the calendar in Service Manager in which you want to add these holidays to"
    write-host ""
    write-host "EXAMPLE:"
    write-host "Create-SCSMHolidays.ps1 -HolidayFile c:\temp\OUTLOOK.HOL -CSVOutput c:\temp\output.csv -Country sweden -CalendarName ""My calendar"""
    Exit
}
elseif ((Test-Path $CSVOutput) -eq $true)
{
    write-host "Warning: The file $CSVOutput does allready exist. Aborting script!"
    Exit
}
elseif ((Test-Path $HolidayFile) -eq $false)
{
    write-host "Warning: Couldn't find ""$HolidayFile"". Aborting script!"
    Exit
}

$Content = Get-Content $HolidayFile
$count = 0
$holidays = @()
$match = $false

Import-Module Smlets

$CalendarClass = Get-SCSMClass System.Calendar$
$Calendar = Get-SCSMObject $CalendarClass -Filter "DisplayName -eq '$CalendarName'"

    if ($calendar) {

    $Content | ForEach-Object{
        
        if ($Content[$count] -match '\['+$Country+'\]') {
            $match = $true
            do {$count++; $holidays += $Content[$count] } until ($Content[$count] -eq "")
        }
        $count++

    }

    if (!$match) {
        Write-host "Couldn't find ""$Country"" in ""$HolidayFile"". Script aborted!"
    }
    else
    {

        $file = New-Item -type file $CSVOutput

        foreach ($day in $holidays) {
            if ($day -ne $NULL -and $day -ne "") {
                $temp = $day.split(",")
                $name = $temp[0]
                $date = $temp[1]
                
                $guid = [guid]::NewGuid()
                
                $text = $calendar.id + ",""" + $calendar.timezone + """,SLACalendarHoliday_$guid,$name,$date 00:00:00.000,$date 00:00:00.000"
                add-content $file $text -encoding Unicode
            }
        }
    }
}
else {
    write-host "Couldn't find ""$CalendarName"" in Service Manager. Script aborted!"
}