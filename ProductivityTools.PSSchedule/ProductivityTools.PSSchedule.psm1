function GetSchedulePath()
{
	return "D:\GitHub\ProductivityTools.PSSchedule\ProductivityTools.PSSchedule\Schedules.xml"
}

function CreateNewJob([string]$name,[string]$description,[string[]]$triggerConfigurations,[string]$command)
{
	$triggers=@()
	foreach($triggerConfiguration in $triggerConfigurations)
	{
		$triggerScriptBlock = [Scriptblock]::Create("New-ScheduledTaskTrigger "+$triggerConfiguration) 	
		$trigger=Invoke-Command -ScriptBlock $triggerScriptBlock
		$triggers+=$trigger
	}
	
	$commandCombined="-NoProfile -WindowStyle Hidden -command &{$command}"
	$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $commandCombined
	
	Register-ScheduledTask -Action $action -Trigger $triggers -TaskName "$name" -Description "$description" -Force
}

function Schedule-Jobs {
	$schedulesPath=GetSchedulePath;
	[xml]$file =Get-Content -Path $schedulesPath
	foreach($schedule in $file.Schedules.Schedule)
	{
		$name=$schedule.Name
		$description=$schedule.Description
		$triggers=@()
		foreach($trigger in $schedule.Triggers)
		{
			$triggers+=$trigger.Trigger
		}
		$command=$schedule.Command
		CreateNewJob $name $description $triggers $command	
	}
}