#========================================================================================
# 
#Run Powershell as Administrator for the Extraction of Log files 
#
#========================================================================================

param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'running with full privileges'

#========================================================================================
# 
#Connect Powershell to Google Cloud Platform 
#
#========================================================================================

gcloud auth login jericagra0923@gmail.com


#========================================================================================
# 
# Set the path and file name for PowerShell transcripts (logs) to be written to.
#
#========================================================================================

$LogPath = "C:\gcp-logs\"
$LogFile = Get-Date -Format FileDateTimeUniversal
$TranscriptFileName = $LogPath + $LogFile +".txt"
 
#========================================================================================
# 
# Start the transcript.
#
#========================================================================================
Start-Transcript -Path $TranscriptFileName
 

#========================================================================================
# 
#Set the GCP project.
#
#========================================================================================
$Project = "evident-ocean-315608"

#========================================================================================
# 
#Set the zone(s) where the disks are that you would like to take snapshots of.
#
#================================================================================

$Zones = "asia-northeast1-b"
 

#========================================================================================
# 
#Record the date that the snapshots started.
#
#================================================================================
$StartTime = Get-Date

#========================================================================================
# 
#Do snapshot all of the disks in the zones as well as confirm
#
#================================================================================
foreach ($Zone in $Zones) {
$DisksInZone = Get-GceDisk -Project $Project -zone $Zone | foreach { $_.Name }

    foreach ($Disk in $DisksInZone) {
        Write-Output "=========================================="
        Write-Output "$Zone "-" $Disk"
        Write-Output "=========================================="
        Add-GceSnapshot -project $Project -zone $Zone $Disk
        }
}


#========================================================================================
#
##-Check the number of snapshots generated
#
#========================================================================================

Write-Host "=========================================="
$snapshotM = Get-GceSnapshot | Measure-Object
Write-Host "total Number of Snapshots:" $snapshotM.Count
Write-Host "=========================================="

#========================================================================================
#
##Check the number of snapshots
#
#
#========================================================================================
If ($snapshotM.Count -gt 8){

#========================================================================================
#
#Delete the 9th or more snapshot generated
#
Write-Host "Delete snapshot"
#========================================================================================
	while($snapshotM.Count -gt 8){
		$SS =  Get-GceSnapshot|Select-Object Name, TimeCreated | Sort-Object  TimeCreated -Descending | select -last 1
		Remove-GceSnapshot $SS.NAME
		$CHECK = $?

		If (!($CHECK)){
		       	Remove-GceSnapshot $SS.NAME
			$CHECK = $?

			If (!($CHECK)){
				Write-Host "4: Abnormal termination (snapshot deletion failed twice)"
				Write-EventLog -LogName Application -EntryType Error -Source DataBackup -EventId 4 -Message $Message4
				exit 4
			}
		}
		$snapshotM.Count -=1
	}
}

#========================================================================================
#
##-Check again the number of snapshots generated
#
#========================================================================================

Write-Host "=========================================="
$snapshotM = Get-GceSnapshot | Measure-Object
Write-Host "total Number of Snapshots:" $snapshotM.Count
Write-Host "=========================================="

#========================================================================================
#
#Record the date that the snapshots ended.
#
#========================================================================================

$EndTime = Get-Date

#========================================================================================
# 
#Logout GCP in Powershell
#
#========================================================================================

#gcloud auth revoke jericagra0923@gmail.com



#========================================================================================
# 
#Stop the transcript.
Stop-Transcript
#
#======================================================================================== 
