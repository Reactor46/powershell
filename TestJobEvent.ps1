<#
$Event appears to end up as a PSEventArgs Class?
https://msdn.microsoft.com/en-us/library/system.management.automation.pseventargs(v=vs.85).aspx

$Event appears to be:
System.Management.Automation.PSEventArgs

$EventSubscriber appears to be:
System.Management.Automation.PSEventSubscriber

$Sender appears to be:
System.Management.Automation.PSRemotingJob

$sourceEventArgs
Fails with:
You cannot call a method on a null-valued expression

$sourceArgs
Fails with:
You cannot call a method on a null-valued expression

# -----
$Event appears to be:
System.Management.Automation.PSEventArgs


$eventargs appears to be:
System.Management.Automation.JobStateEventArgs


$eventargs.JobStateInfo appears to be:
System.Management.Automation.JobStateInfo


$Event.Sender appears to be:ge
System.Management.Automation.PSRemotingJob


$Event.SourceEventArgs appears to be:
System.Management.Automation.JobStateEventArgs

Use Asynchronous Event Handling in PowerShell
https://blogs.technet.microsoft.com/heyscriptingguy/2011/06/16/use-asynchronous-event-handling-in-powershell/

PowerShell Team Blog
https://blogs.msdn.microsoft.com/powershell/2008/06/10/powershell-eventing-quickstart/
# -----
PSBeginTime   : 07/01/2017 00:21:05
PSEndTime     : 07/01/2017 00:21:05


Get-job -id 99 |
     Format-Table -Property ID, PSBeginTime, PSEndTime,
     @{Label="Elapsed Time";Expression={$_.PsEndTime - $_.PSBeginTime}}


Last updated: 30 March 2018 23:21:42

#>

#
# Create a script block for use with the Start-Job cmdlet.
#
# See also:
# o System.Management.Automation.ScriptBlock
# o About Script Blocks
# https://msdn.microsoft.com/en-us/powershell/reference/5.0/microsoft.powershell.core/about/about_script_blocks
#
function Get-Scriptblock {
[CmdletBinding()]
[OutputType([System.Management.Automation.ScriptBlock])]
Param () #end param

BEGIN {

     [System.Management.Automation.ScriptBlock]$sblock = {
       BEGIN {
         $secs = 10;
       }

       PROCESS {
         Start-Sleep -Seconds $secs;
       }

       END {
         Write-Host "Hello world, we've been asleep for $secs seconds";
       }

     }#end of scriptblock
}

PROCESS {}

END {
     return $sblock;
}

}# end of function Get-Scriptblock

#------------------------------------------------------------------------------

#
# Create an action block (scriptblock) for use with the
# Register-ObjectEvent parameter 'Action'.
#
function Get-Actionblock {
[CmdletBinding()]
[OutputType([System.Management.Automation.ScriptBlock])]
Param () #end param

BEGIN {

    [System.Management.Automation.ScriptBlock]$ab={

          $kompleted = [System.Management.Automation.JobState]::Completed;
          Write-Host $Event.MessageData.foo;
          Write-Host $Event.MessageData.bar;


          if ($eventargs.JobStateInfo.State -eq $kompleted) {

            #System.Management.Automation.PSEventArgs
            $ev = $Event;
            Write-Host ("Job ID {0} ({1}) has changed from {2} to {3}" -f `
                $ev.Sender.id, `
                $ev.Sender.name, `
                $ev.SourceEventArgs.PreviousJobStateInfo.State, `
                $ev.SourceEventArgs.JobStateInfo.state);

          } else {
            Write-Host "Job state should have gone to complete";
          }

          # Action block cleanup
          $eventSubscriber | Unregister-Event -Force;
          $eventSubscriber.Action | Remove-job -Force;
    }# end of action block

}

PROCESS {}

END {
   return $ab;
}

}# end of function Get-Actionblock

#------------------------------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

# Create a job name which includes a random number so as
# to help make each job name unique.
$seed = (Get-Date).Millisecond;
$random = Get-Random -SetSeed $seed -Minimum 100 -Maximum 900;
$jobName = ("Testjob{0}" -f $random.ToString());

Write-Host 'Start of test';
Write-Host ("Submitting job name {0}" -f $jobName);
$sb = Get-Scriptblock;
$myjob=Start-Job -Name $jobName -ScriptBlock $sb;

# List what jobs we have.
Get-Job;

# This demonstrates how information can be passed to and
# written from the scriptblock which is used as the
# action block.
$ffoo='this is my foo';
$bbar='this is my bar';
$pso = New-Object PSObject -Property @{foo = $ffoo; bar = $bbar}


$ab = Get-Actionblock;
Register-ObjectEvent -InputObject $myjob `
        -EventName StateChanged `
        -SourceIdentifier 'friendlyName6' `
        -Action $ab `
        -MessageData $pso;

Write-Host 'End of test';

# ***** end of script *****
