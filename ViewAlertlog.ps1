<#
The purpose of this script is to copy an alert log(s) from
either node in the cluster to a local directory on my desktop
for the purpose of being able to view them.

about_Functions_Advanced_Methods
http://technet.microsoft.com/en-us/library/hh847781.aspx
Input Processing Methods. For functions, these three methods
are represented by the Begin, Process, and End blocks of the
function. Each function must include one or more of these
blocks.

This program is in development.
26 January 2014
#>

[cmdletbinding()]
Param (
        [parameter(Mandatory=$false,
                   Position=0)]
        [ValidateRange(1,2)]
        [Int32]
        $NodeNumber,
        
        [parameter(Mandatory=$false,
                   Position=1)]
        [Switch]
        $ViewLog
      ) #end param

#region ********** function main_routine **********
##=============================================
## Function: main_routine
## Created: 2014-01-26
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: main helper function which calls other functions
##          as required by the program logic.
##
## Returns: N/A
##=============================================
function main_routine() {

Begin {
  [String]$dd=Check-Directory;
}

Process {
Write-Host "before copyalert logs, dd is now $dd";
$dd.gettype();
  Copy-Alertlogs $dd;
}

End {
  write-host "`nThe alert logs can be found at $dd";
}


}
#endregion ********** end of function main_routine **********

function Check-Directory
{

Begin {
  $drive="C:\";
  $dirname="AlertLogs";
  $alertlogDir=$drive + $dirname;
  Write-Host "drive is now $drive";
  Write-Host "dirname is now $dirname";
}

Process {
  if (Test-Path $alertlogDir) {
     Remove-Item -Path "$alertlogDir/alert*.log" -Force;
  } else {
     Write-Host "Creating directory $alertlogDir";
     New-Item -Path $drive -Name $dirname -ItemType directory -Force;
  }
}

End {
Write-Host "before leaving, alertlogdir is $alertlogDir";
  return [String]$alertlogDir;
}

}

function Copy-Alertlogs
{
[cmdletbinding()]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNull()]
        [String]
        $AlertlogDir
      ) #end param

Begin {
  $logpaths = @{
               "1"  = "C:\test_a\alertFRED1.log"; # node 1
               "2"  = "C:\test_a\alertFRED2.log"; # node 2
              }

}

Process {

  if ($NodeNumber) {
    $file=$logpaths.Get_Item($NodeNumber.ToString());
    Write-Host "file is now $file";
    Write-Host "node number is now $NodeNumber";
    Copy-Item -Path $file -Destination $AlertlogDir;
  } else {
    # Copy alert logs for all the nodes.
    foreach ($h in $logpaths.GetEnumerator()) {
     Write-Host "hash value is $($h.Value)";
       Copy-Item -Path $h.Value -Destination $AlertlogDir;
    }

  }
}

End {}

}

##=============================================
## SCRIPT BODY
## MAIN ROUTINE STARTS HERE
##=============================================
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    Write-Verbose -Message "Starting script $($MyInvocation.Mycommand)";

    # Loop through the parameters used.
    foreach ($item in $PSBoundParameters.GetEnumerator())
    {
         Write-Verbose -Message ("Key={0},     Value={1}" -f $item.Key, $item.Value);
    }
}

main_routine;
Write-Verbose -Message "All done now!";
##=============================================
## END OF SCRIPT: ViewAlertlog.ps1
##=============================================
