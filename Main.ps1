
Function Login($SubscripttionId)
{
    
    try{$Count = Get-AzureRmSubscription} catch{}
    $sub = $Count.Id
    if("$sub" -ne "$SubscriptionId")
    {
        
        #需要输入SubscriptionId
        Login-AzureRmAccount -Environment AzureChinaCloud -SubscriptionId $SubscriptionId
        #跳出输入框输入账号密码
    }
    else {
        Write-Host "`nYou have already login with Sub: $sub" -ForegroundColor Cyan
    }
    
}

Function checkZonematch
{
	
    param(
         #RequestZoneName
        [Parameter(Mandatory= $true)]
        [string]$RequestZoneName
    )
    
    #check if the zone contain the name
	Write-Host "Checking MC List" -ForegroundColor yellow
	$MClist = Get-azurermdnszone 
	$zonename = $MClist.name
    Write-Host "`nMClist showing below: " -ForegroundColor Cyan #For log
    Write-Host "========================" -ForegroundColor Cyan
    echo $zonename #For log
    #echo $zonename | out-file e:\zonenamelist.txt
    #$request = 
	$request = $RequestZoneName   #an example, seems can be replace by param
	$num = 0
	foreach ($line in $zonename)
    {
        $a = $request -eq $line #对比每行
        
        if($a) #$a is boolen
	    {
	 	    $num += 1
            Write-Host "`nMClist Exist this Zone Name,good to go continue" -ForegroundColor Green
	    }
	    
    }
    if($num -eq 0)
    {
        Write-Host "`nMClist doesn't contain the zone name, can't excute this script" -ForegroundColor Red; Break
    }
	 
}

Function checkrecordexist #($RNWZN,$ZN,$RGN,$RT)
{
	$t = @()
    Write-Host "`nplease type the recordSet info" -ForegroundColor Cyan
    
    $temp = show-command Get-AzureRmDnsRecordSet -PassThru
    Write-Host "`n$temp" -ForegroundColor Yellow
    $recordSet = Invoke-Expression $temp
    Write-Host "`n$recordSet" -ForegroundColor Yellow
   # $recordSet = show-command Get-AzureRmDnsRecordSet -ErrorPopup #chuangzi
	
	# $recordSet -eq $null #it return true/false.
						 #true means no record
						 #false means exist record
	#if return error. it means there is no such record on the zone. return Ture
	#if return result, give it to $recordSet. return False
	
	if($null -eq $recordSet)
	{
		Write-Host "`nNone record found, Go Add Method" -ForegroundColor Green
        $t = 0
	}
	else
	{
		Write-Host "`n$temp" -ForegroundColor Yellow #
        Write-Host "`n$recordSet" -ForegroundColor Yellow #
        Write-Host "`nFound record, Go Modify or Remove Method" -ForegroundColor Yellow
        $t = 1
	}
}

Function Add-CNAME
{
    ############CNAME ADD Logic##################################################################
    Write-Host "`nplesase carefully fill the window that you want to create the name of CNAME."
    # $recordSet = New-AzureRmDnsRecordSet -Name sha-dsts.jeff1.test -ZoneName chinacloudpai.cn -ResourceGroupName staticazuredns -RecordType CName
    # $recordSet = show-command New-AzureRmDnsRecordSet -ErrorPopup
    $tempaddcname = Show-Command New-AzureRmDnsRecordSet -PassThru
    Write-Host "$tempaddcname" -ForegroundColor Yellow
    $recordSet = Invoke-Expression $tempaddcname
    $recordSet
    #$record1 = New-AzureRmDnsRecordConfig -CName www.3-1.jeff.com
    Write-Host "please fill the window that you want to add in the CNAME you just created."
    $tempaddcname1 = Show-Command New-AzureRmDnsRecordConfig -PassThru
    Write-Host "$tempaddcname1" -ForegroundColor Yellow
    $Title = "Add Method"
    $Message1 = "Are you sure this Record is right for updating ?"
        #choose Yes/No
        #0Yes   $i = 1
        #1No    $i = 0
    $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
    $Decision = $Host.UI.PromptForChoice($Title, $Message1, $choices, 1)
    if($Decision -eq 0)
    {
        Write-Host "Updating the record to Azure"
        $record1 = Invoke-Expression $tempaddcname1
        $recordSet.Records = $record1
        $Title = "Add Method"
        $Message1 = "Are you sure this Record is right for updating ?"
        #choose Yes/No
        #0Yes   $i = 1
        #1No    $i = 0
        $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
        $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
        $Decision = $Host.UI.PromptForChoice($Title, $Message1, $choices, 1)
        if($Decision -eq 0)
        {
            Write-Host "You Choose Yes, Updating the record to Azure"
            Set-AzureRmDnsRecordSet -RecordSet $recordSet
        }
        else
        {
            Write-Host "You choose No, Nothing will update" Break;
        }
    }
    else
    {
        Write-Host "Nothing will update" Break;
    }
    
    
    #############################################################################################
}

Function Add-OtherType
{
    $i = 1 #循环判断依据
    # $newRecords =@() #New-Object -TypeName System.Collections.ArrayList
    #$A = @()
    $count = 0
    Do
     {
        
        $tempadd = Show-Command New-AzureRmDnsRecordConfig -PassThru
        Write-Host "$tempadd" -ForegroundColor Yellow
        $A = Invoke-Expression $tempadd
        
        $newRecords += $A
        
        $count += 1
        Write-Host "You have input below record:"
        Write-Host "============================"
        foreach($line in $newRecords)
            {
                Write-Host $line
            }
        #
        Write-Host "Do you have any record need to add ?"
        $Title = "Add Method"
        $Message1 = "Need Add more records ?"
        #choose Yes/No
        #0Yes   $i = 1
        #1No    $i = 0
        $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
        $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
        
        $Decision = $Host.UI.PromptForChoice($Title, $Message1, $choices, 1)
        if ($Decision -eq 0)
        {
            if($count -eq 1)
            {
                $foramonoent = $newRecords
                $newRecords =@()
                $newRecords += $foramonoent
                $i = 0
            }
            else
            {
                $i = 0
            }
        }
        else
        {
            $i = 1
        }
    }while($i -eq 0)

    
        #
        Write-Host "Are you sure add below reords ?"
        Write-Host "==============================="
        foreach($line in $newRecords)
            {
                Write-Host $line
            }
        #
        $message = "Add Method"
        $question = "The Record is the right to Add ?"

        $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
        $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
        
        $Decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        if ($Decision -eq 0)
        {
            Write-Host "you type yes!" -ForegroundColor Green
            write-host "Create a Arecord to contain the result to Azure"
            $tempC = show-command New-AzureRmDnsRecordSet -PassThru
            Write-Host "$tempC" -ForegroundColor Yellow
            $Title = "Add Method"
            $Message1 = "Are you sure this Record is right for updating ?"
        #choose Yes/No
        #0Yes   $i = 1
        #1No    $i = 0
            $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
            $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
            $Decision = $Host.UI.PromptForChoice($Title, $Message1, $choices, 1)
            if($Decision -eq 0)
            {
                Write-Host "Updating the record to Azure"
                $recordSet = Invoke-Expression $tempC #
                $newRecordsT = $recordSet.Records
                $newRecordsT = $newRecords
                $recordSet.Records = $newRecordsT
                Set-AzureRmDnsRecordSet -RecordSet $recordSet
            }
            else
            {
                Write-Host "Nothing will update" Break;
            }
            
        }
        else
        {
            Write-Host "`nNo Record will be updated" -ForegroundColor Green
            Write-Host "`nReturn to Main Menu, Thank you" -ForegroundColor Cyan; Break

        }
}

Function NewAdd
{
    $TitleA = "method select"
    $MessageA = "Select Which Method Command to run"
    $ChoicesA = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $ChoicesA.Add((New-Object Management.Automation.Host.ChoiceDescription "&1.Add CNAME Record", "purly add CNAME record.")) 
    $ChoicesA.Add((New-Object Management.Automation.Host.ChoiceDescription "&2.Add OtherType Record", "Add Type records except CNAME."))
    $ChoicesA.Add((New-Object Management.Automation.Host.ChoiceDescription "&3.Exist script", "drop off this scrip"))
    $MenuA = $Host.UI.PromptForChoice($TitleA, $MessageA, $ChoicesA,1)
    switch($MenuA)
    {
        0 #Add CNAME
        {
            Add-CNAME
        }
        1 #Add OtherType
        {
            Add-OtherType
        }
        2 #Exist
        {
            break
        }
    }
}

Function Remove
{
    
    $Title = "Remove Method"
    $Message1 = "Want Remove All records ?"
        #choose Yes/No
        #0Yes   $i = 1
        #1No    $i = 0
    $Choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
    $Choices.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
        
    $Decision = $Host.UI.PromptForChoice($Title, $Message1, $choices, 1)
    if ($Decision -eq 0)
    {
        Write-Host "Excuting command" -ForegroundColor Yellow
        Write-Host "`nMake sure your know what kind of Record you want to remove!!"
        $tempremove = Show-Command Remove-AzureRmDnsRecordSet -PassThru
        Write-Host "$tempremove" -ForegroundColor Yellow
        Read-Host "Press Enter to continue"
        Invoke-Expression $tempremove
    }
    else
    {
        Write-Host "`nNo Record will be Removed" -ForegroundColor Green
        Write-Host "`nReturn to Main Menu, Thank you" -ForegroundColor Cyan; Break
    }
}

Function Modify # recordSet already exist
{
################################################################################
	
write-host "`nPlease input recordset info" -ForegroundColor cyan
# $recordSet = Show-Command Get-AzureRmDnsRecordSet -ErrorPopup #may no need

# $newRecordsU = @()
$newRecordsU = $recordSet.Records #将recordSet中的records部分赋值给变量newRecordsU

write-host "`nnow, the records contain as below:" -ForegroundColor cyan
################################################
# write-host "====================================" -ForegroundColor cyan
# foreach($line in $newRecordsU)
# {
#    Write-Host $line -ForegroundColor Yellow
# }
##################################################
$recordSet.Records
$tempNum = 0
$p = 1  #add循环依据
$U = @()
  Do #循环控制$p
    {
    
    #
    # Write-Host "`nDo you have any record need to add ?"
    $TitleA = "Modify Method-Update"
    $MessageA = "Do you have any record need to add ?"
    #choose Yes/No
    #0Yes   $p = 1
    #1No    $p = 0
    $ChoicesA = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $ChoicesA.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
    $ChoicesA.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
        
    $DecisionA = $Host.UI.PromptForChoice($TitleA, $MessageA, $choicesA, 1)
        if ($DecisionA -eq 0)
        {
             Write-Host "`nplease input the records you want add (if not choose cancel)" -ForegroundColor Cyan    
             $tempU = Show-Command New-AzureRmDnsRecordConfig -PassThru
             Write-Host "$tempU" -ForegroundColor Yellow
             try{ $U = Invoke-Expression $tempU} catch{}
             # $U = Show-Command New-AzureRmDnsRecordConfig -ErrorPopup
        
             $newRecordsU += $U
             Write-Host "`nAfter Your input, records showing below record:" -ForegroundColor Yellow
             Write-Host "================================================="
             foreach($line in $newRecordsU)              #直接write-host显示的是一行，为了纵列显示，循环
             {
                 Write-Host $line -ForegroundColor Yellow
             }
             $p = 0
             $tempNum += 1
        }
        else
        {
             
             $p = 1
        }
    }while($p -eq 0)
####test####

##########private

$k = 1 #循环判断依据
$tempNum2 = 0
# $newRecordsD = @()
$newRecordsD = $newRecordsU
#
write-host "`nnow, the records contain as below:" -ForegroundColor cyan
write-host "====================================" -ForegroundColor cyan
foreach($line in $newRecordsD)
{
    Write-Host $line -ForegroundColor Yellow
}
#$B = @()
#$newRecordsL = @()


Do #循环控制$k
    {
    
    
    #直接write-host显示的是一行，为了纵列显示，循环
    Write-Host "`nDo you have any record need to Delete ?"
    $TitleD = "Modify Method-Delete"
    $MessageD = "Need Delete more records ?"
    #choose Yes/No
    #0Yes   $k = 1
    #1No    $k = 0
    $ChoicesD = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $ChoicesD.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
    $ChoicesD.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
        
    $DecisionD = $Host.UI.PromptForChoice($TitleD, $MessageD, $choicesD, 1)
        if ($DecisionD -eq 0)
        {
             write-host "`nplease input the record you want to delete" -ForegroundColor Cyan   
             $tempD = Show-Command New-AzureRmDnsRecordConfig -PassThru
             Write-Host "$tempD" -ForegroundColor Yellow
     
             #$B = Show-Command New-AzureRmDnsRecordConfig -ErrorPopup
             try{ $B = Invoke-Expression $tempD } catch{}
             # Write-Host "$newRecordsD"
             foreach($line in $newRecordsD)
             {
                 Write-Host $line -ForegroundColor Yellow
             }
        
             #$newRecordsD += $U

            $newRecordsL = @()
            #$null
            #$nullA
                
            foreach($line in $newRecordsD)  #对比每行
            { 
                  if("$B" -ne "$line") # boolen
	                  {
                                 $newRecordsL += $line
	                  }
            }
	        
               

             
                #if ()
             $newRecordsD = $null
             $newRecordsD = $newRecordsL
             $newRecordsL = $nullA
    
             ############################
             Write-Host "`nAfter Your input, records showing below record:" -ForegroundColor Yellow
             Write-Host "================================================="
             foreach($line in $newRecordsD)              
             {
                 write-host $line -ForegroundColor Yellow
             }
             $k = 0
             $tempNum2 += 1
        }
        else
        {
             $k = 1
        }
    }while($k -eq 0)

####test####
    Write-Host "After all your operation, the result showing below:"
    Write-Host "==================================================="
    foreach($line in $newRecordsD)              #直接write-host显示的是一行，为了纵列显示，循环
    {
        Write-Host $line -ForegroundColor Yellow
    }
############上传$newRecordsD即可
if($tempNum2 -ne 0)
{ 
    write-host "update the result to Azure"
    if($newRecordsD.count -eq 1)
    {
        $recordSet.Records = $newRecordsD[0]
    }
    else
    {
        $recordSet.Records = $newRecordsD
    }
    #++++++++
    $TitleD = "Modify Method"
    $MessageD = "Are you sure updating the result ?"
    #choose Yes/No
    #0Yes   $k = 1
    #1No    $k = 0
    $ChoicesD = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $ChoicesD.Add((New-Object Management.Automation.Host.ChoiceDescription '&Yes'))
    $ChoicesD.Add((New-Object Management.Automation.Host.ChoiceDescription '&No'))
        
    $DecisionD = $Host.UI.PromptForChoice($TitleD, $MessageD, $choicesD, 1)
    if ($DecisionD -eq 0)
        {
            Set-AzureRmDnsRecordSet -RecordSet $recordSet
        }
    else 
        {
            Break;##可能传值至上一层而造成逻辑错误，待测试
        }
    
}
elseif($tempNum -ne 0)
{ 
    Write-Host "update the Add result to Azure"
    $recordSet.Records = $newRecordsU
    Set-AzureRmDnsRecordSet -RecordSet $recordSet
}
else
{
    write-host "You type Nothing, No action will be perform" -ForegroundColor Cyan; Break
}

}

Function ModifyTTLOnly
{
        param(
         #NewTTLValue
        [Parameter(Mandatory= $true)]
        [string]$NewTTLValue
    )
    Write-Host "`nThe new TTL shwoing below:"
    Write-Host "============================"
    $NewTTLValue
    Write-Host "`nPlease fill the window to get RecordSet"
    # $recordSetTTL = show-command Get-AzureRmDnsRecordSet -ErrorPopup
    $tempTTL = Show-Command Get-AzureRmDnsRecordSet -PassThru
    Write-Host "$tempTTL" -ForegroundColor Yellow
    $recordSetTTL = Invoke-Expression $tempTTL
    
    $recordSetTTL.ttl = $NewTTLValue
    $recordSetTTL
    $Title1 = "ModifyTTLOnly"
    $Message1 = "Are you sure to change the TTL to $NewTTLValue ?"
    $Choices1 = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $Choices1.Add((New-Object Management.Automation.Host.ChoiceDescription "&Yes", "will update new TTL to Azure."))
    $Choices1.Add((New-Object Management.Automation.Host.ChoiceDescription "&No", "will do nothing.")) 
    $DecisionD = $Host.UI.PromptForChoice($Title1, $Message1, $choices1, 1)
        if ($DecisionD -eq 0)
        {
             Set-AzureRmDnsRecordSet -RecordSet $recordSetTTL
        }
        else
        {
            Write-Host "TTL record will not change, back to main menu" -ForegroundColor Cyan; break
        }
    
}

Function MAIN
{
    
    param(
        #Subscription Id
        [Parameter(Mandatory = $true)] 
        [string]$SubscriptionId
        )

    BEGIN
    {
        Start-Transcript -path .\MainlogK.txt -Force -Append –NoClobber
        
        Login($SubscriptionId)
    }
    PROCESS
    {
    
        checkZonematch
       ###########check if the record exist######## 
       
        
        $t = @()
        Write-Host "`nplease type the recordSet info" -ForegroundColor Cyan
    
        $temp = show-command Get-AzureRmDnsRecordSet -PassThru
        Write-Host "`n$temp" -ForegroundColor Yellow
        $recordSet = Invoke-Expression $temp
        $recordSet

       # $recordSet = show-command Get-AzureRmDnsRecordSet -ErrorPopup #chuangzi
	
	    # $recordSet -eq $null #it return true/false.
						 #true means no record
						 #false means exist record
	    #if return error. it means there is no such record on the zone. return Ture
	    #if return result, give it to $recordSet. return False
	
	    if($null -eq $recordSet)
	    {
		    Write-Host "`nNone record found, Go Add Method" -ForegroundColor Green
            $t = 0
	    }
	    else
	    {
		    Write-Host "`nFound record, Go Modify or Remove Method, if you want change TTL Value, Choose ModifyTTLOnly " -ForegroundColor Yellow
            $t = 1
	    }
       ####################     
        switch ($t)
            {
                0 #ADD
                {
                    NewAdd
                    Stop-Transcript
                }
                1 #Rmove/Modify
                {
                    $Title1 = "method select"
                    $Message1 = "Select Which Method Command to run"
                    $Choices1 = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
                    $Choices1.Add((New-Object Management.Automation.Host.ChoiceDescription "&1.RemoveAll records", "purly add record.")) 
                    $Choices1.Add((New-Object Management.Automation.Host.ChoiceDescription "&2.Modify", "Add or delete from mutiple records."))
                    $Choices1.Add((New-Object Management.Automation.Host.ChoiceDescription "&3.ModifyTTLOnly", "Use to Modify TTL without Add or Delete"))
                    $Choices1.Add((New-Object Management.Automation.Host.ChoiceDescription "&4.Exist script", ""))
                    $Menu1 = $Host.UI.PromptForChoice($Title1, $Message1, $Choices1,1)
                    switch($Menu1)
                    {
                        0 #remove
                        {
                            Remove
                            Stop-Transcript
                        }
                        1 #Modify
                        {
                            Modify
                            Stop-Transcript
                        }
                        2 #ModifyTTLOnly
                        {
                            ModifyTTLOnly
                            Stop-Transcript
                        }
                        3 #Exist
                        {
                            Write-Host "`nExiting the Script, Thank you" -ForegroundColor Cyan; Break
                            Stop-Transcript
                        }
                    }
                }
                2 #Exist
                {
                    Write-Host "`nExiting the Script, Thank you" -ForegroundColor Cyan; Break
                    Stop-Transcript
                }
            }

}
}
MAIN