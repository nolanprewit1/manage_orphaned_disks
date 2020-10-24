#===========================================================================
# PARAMETERS 
#===========================================================================

param(
	[Parameter(Mandatory=$true)]
    [string]$vcenter_url,
    [Parameter(Mandatory=$true)]
    [string]$vcenter_username,
    [Parameter(Mandatory=$true)]
    [string]$vcenter_password
)

#===========================================================================
# VARIABLES 
#===========================================================================

$current_date = Get-Date -Format ("MM-dd-yyyy_h.mm.ss")
$transcript_path = ".\transcripts\configmanage_orphaned_disks" + $current_date + ".txt"

#===========================================================================
# code 
#===========================================================================

# CHECK FOR TRANSCRIPTS FOLDER AND CREATE IF IT DOES NOT EXIST
$test = Test-Path .\transcripts
if($test -eq $false){
    Write-Host "Creating transcripts folder...."
    New-Item -ItemType Directory -Name transcripts | Out-Null
}
else{
    Write-Host "Transcripts folder checked..."
}

# START SCRIPT TRANSCRIPTION
Write-Host "Starting transcript..."
Start-Transcript -Path $transcript_path | Out-Null

# CHECK FOR POWERCLI MODULE 
if (Get-Module -ListAvailable -Name VMware.PowerCLI) {
   Write-Host "Powercli module exists..."
} 
else {
   Write-Host "Installing Powercli module..."
   Install-Module -Name VMware.PowerCLI -RequiredVersion 11.1.0.11289667 -Force
   Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
   Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
}

# CONNECT TO VCENTER
try {
   Write-Host "Connecting to vCenter..."
   Connect-VIServer $vcenter_url -User $vcenter_username -Password $vcenter_password -ErrorAction stop | out-null
}
catch {
   Write-Host "ERROR: Connecting to vCenter..."
   Write-Host $PSItem.exception.message -ForegroundColor RED
   Read-Host -Prompt "Press any key to exit..."
   exit
}

# DISCONNECT FROM VCENTER
Write-Host "Disconnecting from vCenter..."
Disconnect-VIServer -Confirm:$false

# PROMPT TO CLOSE THE SHELL
# Read-Host -Prompt "Press any key to exit..."
# exit