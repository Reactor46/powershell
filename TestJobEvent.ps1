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


Last updated: 04 August 2016 19:35:14

#>

# Create a script block for use with the Start-Job cmdlet.
$sb={
  $secs=7;
  Write-Host 'Hello world';
  Start-Sleep -Seconds $secs;
}

# Create a script block for use with the Register-ObjectEvent
# parameter 'Action'.
$ab={
    $kompleted = [System.Management.Automation.JobState]::Completed;
$fred = $eventargs.JobStateInfo.State;
Write-Host ('fred has type = {0}' -f $fred.gettype());


    if ($eventargs.JobStateInfo.State -eq $kompleted) {

    #System.Management.Automation.PSEventArgs
    $ev = $Event;
    Write-Host ("Job ID {0} ({1}) has changed from {2} to {3}" -f `
        $ev.Sender.id, `
        $ev.Sender.name, `
        $ev.SourceEventArgs.PreviousJobStateInfo.State, `
        $ev.SourceEventArgs.JobStateInfo.state);

    }

    $eventSubscriber | Unregister-Event -Force;
    $eventSubscriber.Action | Remove-job -Force;
write-host 'Action block cleanup';
}


[Int16]$num = Get-Random -Minimum 1 -Maximum 250;

Write-Host 'Start of test';

$myjob=Start-Job -Name "testjob$($num.ToString())" -ScriptBlock $sb;
Get-Job;

Register-ObjectEvent -InputObject $myjob -EventName StateChanged `
  -SourceIdentifier 'friendlyName3' `
  -Action $ab

Write-Host 'End of test';

