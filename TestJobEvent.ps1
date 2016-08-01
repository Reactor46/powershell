<#
$Event appears to end up as a PSEventArgs Class?
https://msdn.microsoft.com/en-us/library/system.management.automation.pseventargs(v=vs.85).aspx

#>

$sb={
$secs=10;
Write-Host 'Hello world';
Start-Sleep -Seconds $secs;
}

$num = Get-Random -Minimum 1 -Maximum 250;

Write-Host 'Start of test';

$myjob=Start-Job -Name "testjob$($num)" -ScriptBlock $sb;
Get-Job;

Register-ObjectEvent -InputObject $myjob -EventName StateChanged `
  -SourceIdentifier 'friendlyName' `
  -Action {
    $kompleted = [System.Management.Automation.JobState]::Completed;

    if ($eventargs.JobStateInfo.State -eq $kompleted) {

    #System.Management.Automation.PSEventArgs
    $ev = $Event;
    Write-Host ('Event var is: {0}' -f $Event.gettype());
    Write-Host ("Job ID {0} ({1}) has changed from {2} to {3}" -f `
        $ev.sender.id, `
        $ev.sender.name, `
        $ev.SourceEventArgs.PreviousJobStateInfo.State, `
        $ev.SourceEventArgs.JobStateInfo.state);

    }

    $eventSubscriber | Unregister-Event -Force;
    $eventSubscriber.Action | Remove-job -Force;

  }
Write-Host 'End of test';





