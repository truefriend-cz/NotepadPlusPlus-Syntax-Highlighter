Import-Module BitsTransfer

$Source = $args[0]
$Destination = $args[1]

$Job = Start-BitsTransfer -Source $Source -Destination $Destination -Asynchronous

While($Job.JobState.ToString() -eq 'Connecting')
{
	Clear-Host
	Write-Host "Connecting..."
	Start-Sleep -m 200
}

While($Job.JobState.ToString() -eq 'Error')
{
	Clear-Host
	Remove-BitsTransfer $Job
	Write-Host "Error connecting to download"
	Start-Sleep -s 4
	Exit
}

Clear-Host
While($Job.JobState.ToString() -eq 'Transferring')
{
	$pct = [int](($Job.BytesTransferred*100) / $Job.BytesTotal)
	Write-Progress -Activity "Downloading file..." -CurrentOperation "$pct% complete" -PercentComplete $pct
}

While($Job.JobState.ToString() -eq 'Transferred')
{
	Write-Progress "Done" "Done" -Completed | Out-Default
	Write-Host "Success"
	Complete-BitsTransfer -BitsJob $Job
	Start-Sleep -s 3
	Exit
}

Start-Sleep -s 3
