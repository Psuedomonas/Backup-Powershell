## Boolean globals to direct backup script
$global:startTheBackup = $false
$global:shutdownComp = $false
$global:overwriteFolder = $false

## Make GUI
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Select Backup Directory'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true

$Lbl1 = New-Object System.Windows.Forms.Label
$Lbl1.Text = "Step 1: Run _ServerAdmin"
$Lbl1.Location  = New-Object System.Drawing.Point(0,10)
$Lbl1.AutoSize = $true
$main_form.Controls.Add($Lbl1)

$Lbl2 = New-Object System.Windows.Forms.Label
$Lbl2.Text = "Step 2: Select Export Backup Tab"
$Lbl2.Location  = New-Object System.Drawing.Point(0,30)
$Lbl2.AutoSize = $true
$main_form.Controls.Add($Lbl2)

$Lbl3 = New-Object System.Windows.Forms.Label
$Lbl3.Text = "Step 3: Press Export Backup Button"
$Lbl3.Location  = New-Object System.Drawing.Point(0,50)
$Lbl3.AutoSize = $true
$main_form.Controls.Add($Lbl3)

$Lbl4 = New-Object System.Windows.Forms.Label
$Lbl4.Text = "Step 4. Select whether to shut down computer below"
$Lbl4.Location  = New-Object System.Drawing.Point(0,70)
$Lbl4.AutoSize = $true
$main_form.Controls.Add($Lbl4)

$Lbl5 = New-Object System.Windows.Forms.Label
$Lbl5.Text = "Shutdown computer after backup?"
$Lbl5.Location  = New-Object System.Drawing.Point(0,100)
$Lbl5.AutoSize = $true
$main_form.Controls.Add($Lbl5)

$BtnYes = New-Object System.Windows.Forms.Button
$BtnYes.Location = New-Object System.Drawing.Size(10,120)
$BtnYes.Size = New-Object System.Drawing.Size(40,30)
$BtnYes.Text = "Yes"
$main_form.Controls.Add($BtnYes)

$BtnNo = New-Object System.Windows.Forms.Button
$BtnNo.Location = New-Object System.Drawing.Size(60,120)
$BtnNo.Size = New-Object System.Drawing.Size(40,30)
$BtnNo.Text = "No"
$main_form.Controls.Add($BtnNo)

$BtnCC = New-Object System.Windows.Forms.Button
$BtnCC.Location = New-Object System.Drawing.Size(110,120)
$BtnCC.Size = New-Object System.Drawing.Size(60,30)
$BtnCC.Text = "Cancel"
$main_form.Controls.Add($BtnCC)

$FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog


$BtnYes.Add_Click(
{
	[void] $FolderBrowserDialog.ShowDialog()
	if (!$FolderBrowserDialog.SelectedPath -eq "") 
	{
		$time = Get-Date -Format "MM.dd.yyyy"
		$testDir = $FolderBrowserDialog.SelectedPath + '\' + $time
		$alreadyThere = Test-Path $testDir -PathType Any
		if (!$alreadyThere)
		{
			$main_form.Close()
			$global:startTheBackup = $true
			$global:shutdownComp = $true
			$global:x = $FolderBrowserDialog.SelectedPath
		}
		else
		{
			$Return=[System.Windows.Forms.MessageBox]::Show('Click OK to overwrite, or Cancel','Folder Already Exists!','okcancel')
			if ($Return -eq 'OK')
			{
				$global:overwriteFolder = $true
				$main_form.Close()
				$global:startTheBackup = $true
				$global:shutdownComp = $true
				$global:x = $FolderBrowserDialog.SelectedPath
			}
		}
	}
}
)

$BtnNo.Add_Click(
{
	[void] $FolderBrowserDialog.ShowDialog()
	if (!$FolderBrowserDialog.SelectedPath -eq "") 
	{
		$time = Get-Date -Format "MM.dd.yyyy"
		$testDir = $FolderBrowserDialog.SelectedPath + '\' + $time
		$alreadyThere = Test-Path $testDir -PathType Any
		if (!$alreadyThere)
		{
			$main_form.Close()
			$global:startTheBackup = $true
			$global:shutdownComp = $false
			$global:x = $FolderBrowserDialog.SelectedPath
		}
		else
		{
			$Return=[System.Windows.Forms.MessageBox]::Show('Click OK to overwrite, or Cancel','Folder Already Exists!','okcancel')
			if ($Return -eq 'OK')
			{
				$global:overwriteFolder = $true
				$main_form.Close()
				$global:startTheBackup = $true
				$global:shutdownComp = $false
				$global:x = $FolderBrowserDialog.SelectedPath
			}
		}
	}
}
)
$BtnCC.Add_Click(
{
	$main_form.Close()
}
)

$main_form.ShowDialog()

## Backup Operations - Boolean to prevent backup without GUI instructions
if ($global:startTheBackup)
{
	## Overwrite backup directory ##
	$time = Get-Date -Format "MM.dd.yyyy"
	if ($global:overwriteFolder)
	{
		Write-Host "Overwriting backup at: " $global:x
		New-Item -Path $global:x -Name $time -ItemType "directory" -Force
		$backupDir = $global:x + '/' + $time
		
		## Perform Dentrix Backup ##
		Write-Host "Overwriting the Dentrix Backup..."
		Copy-Item "C:\Dentrix" -Destination $backupDir -Recurse -Force
		Write-Host "Dentrix Backup Complete!"

		## Perform Dexis Backup ##
		Write-Host "Overwriting the Dexis Backup..."
		Copy-Item "C:\Dexis" -Destination $backupDir -Recurse -Force
		Write-Host "Dexis Backup Complete!"
	}
	else
	{
		## Make backup directory ##
		Write-Host "Peforming backup to: " $global:x
		New-Item -Path $global:x -Name $time -ItemType "directory"
		$backupDir = $global:x + '/' + $time
		
		## Perform Backup ##
		Write-Host "Peforming the Dentrix Backup..."
		Copy-Item "C:\Dentrix" -Destination $backupDir -Recurse
		Write-Host "Dentrix Backup Complete!"

		## Perform Backup ##
		Write-Host "Peforming the Dexis Backup..."
		Copy-Item "C:\Dexis" -Destination $backupDir -Recurse
		Write-Host "Dexis Backup Complete!"
	}
	if ($global:shutdownComp)
	{
		Write-Host "Shutting down computer..."
		## When backup is complete, shut down computer ##
		#Stop-Computer
	}
}