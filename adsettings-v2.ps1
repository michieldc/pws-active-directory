# Import the required modules
Import-Module ActiveDirectory

# Prompt user for location of the csv file
$filepath = Read-Host -Prompt "Please enter the path to your CSV file"

# Import the file into the users variable
$users = Import-CSV $filepath -Delimiter ';'


$DC = "SynalcoMedics";

$ADUsersArray = @();


#Creating a group for every OU
try{
    New-ADGroup -Name "Manager" -GroupScope "Global" -Path "OU=Manager, OU=CMAfdelingen, DC=$DC, DC=local"
    New-ADGroup -Name "IT" -GroupScope "Global" -Path "OU=IT, OU=CMAfdelingen, DC=$DC, DC=local"
    New-ADGroup -Name "Boekhouding" -GroupScope "Global" -Path "OU=Boekhouding, OU=CMAfdelingen, DC=$DC, DC=local"
    New-ADGroup -Name "Logistiek" -GroupScope "Global" -Path "OU=Logistiek, OU=CMAfdelingen, DC=$DC, DC=local"
    New-ADGroup -Name "ImportExport" -GroupScope "Global" -Path "OU=ImportExport, OU=CMAfdelingen, DC=$DC, DC=local"
}
catch {
    Write-Host $error -ForegroundColor RED;
}finally{
    $error.Clear();
}

function setUserInfo($user) {
     
}

function updateOU(){
    
    $activeUser = $ADaccount
    $DistinguishedName = $activeUser.DistinguishedName
    $substring = $DistinguishedName.split(",")[($activeUser.Name -split ',').count..($DistinguishedName.split(",").Length+1)] -join(",");
    $activeOU = $substring.split("{,}")[0].split(",")[0].split("=")[1];

    if($OU -eq $activeOU){
        Write-Host "No changes in OU needed"
    }else{
        Write-Host "Moving user to correct OU"
        Move-ADObject -Identity "CN=$voornaam $naam, OU=$activeOU, OU=CMAfdelingen, DC=$DC, DC=local" -TargetPath "OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local"

        Remove-ADGroupMember -Identity $activeOU -Members "$voornaam $naam"
        Write-Host "Adding to correct group"
        If($it.ToString() -eq 'X'){
        Add-ADGroupMember -Identity IT -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
        }
        If($boekhouding.ToString() -eq 'X'){
            Add-ADGroupMember -Identity Boekhouding -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
        }
        If($logistiek.ToString() -eq 'X'){
            Add-ADGroupMember -Identity Logistiek -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
        }
        If($importexport.ToString() -eq 'X'){
            Add-ADGroupMember -Identity ImportExport -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
            
        }
        If($manager.ToString() -eq 'X'){
            Add-ADGroupMember -Identity Manager -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
        }
    }
}


function UserCheck {
    try{
    $ADaccount = Get-ADUser -Identity "$account"
    }catch{
        Write-Host "No User with name $account exists, Creating one now"
    }finally{
    $error.Clear()
    }
   
   
    if($ADaccount -eq ""){
        Write-Host "$voornaam $naam Bestaat al."
        If($it.ToString() -eq 'X'){
            $OU = 'IT'
        }
        If($boekhouding.ToString() -eq 'X'){
            $OU = 'Boekhouding'
        }
        If($logistiek.ToString() -eq 'X'){
            $OU = 'Logistiek'
        }
        If($importexport.ToString() -eq 'X'){
            $OU = 'ImportExport'
          
        }
        If($manager.ToString() -eq 'X'){
            $OU = 'Manager';
        }
        updateOU;
    }else{
        #Create users in AD
    New-ADUser -Name "$voornaam $naam" -SamAccountName $account -DisplayName "$voornaam $naam" -UserPrincipalName "$account" -AccountPassword $secpasswd -GivenName "$voornaam" -Surname "$naam" -Enabled $true -HomeDrive "L:"
    
    # adding the sharedfolder to the user
    Write-Host "adding a sharedfolder for $($account)"
    $Path = "\\EARTH\SharedFolders\$account"
    set-aduser -identity $account -HomeDirectory "$Path" -HomeDrive "L:"


    if (!(Test-Path -path "$Path")) {
        New-Item -ItemType directory -Path "\\EARTH\SharedFolders" -Name "$account"
    }else{
        Write-Host ""
    }

    #Check which OU the user belongs to
        If($it.ToString() -eq 'X'){
            $OU = 'IT'
        }
        If($boekhouding.ToString() -eq 'X'){
            $OU = 'Boekhouding'
        }
        If($logistiek.ToString() -eq 'X'){
            $OU = 'Logistiek'
        }
        If($importexport.ToString() -eq 'X'){
            $OU = 'ImportExport'
          
        }
        If($manager.ToString() -eq 'X'){
            $OU = 'Manager';
        }
    
    # #Creating a directory for the user
    # New-Item -ItemType Directory -Path "\\EARTH\CMData\Home"
    # New-Item -ItemType Directory -Path "\\EARTH\CMData\Home\$fullname"
    # New-Item -ItemType Directory -Path "\\CMS1\CMDATA\HOME\$($user.'Account')"



    # New-Item -ItemTypex Directory -Path "\\EARTH\CMData\Profile"
    # New-Item -ItemType Directory -Path "\\EARTH\CMData\Profile\$fullname"
    

    #Moving the user to the correct path
    Move-ADObject -Identity "CN=$voornaam $naam, CN=Users, DC=$DC, DC=local" -TargetPath "OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local"

    # adding to the groups
    If($it.ToString() -eq 'X'){
        Add-ADGroupMember -Identity IT -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
    }
    If($boekhouding.ToString() -eq 'X'){
        Add-ADGroupMember -Identity Boekhouding -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
    }
    If($logistiek.ToString() -eq 'X'){
        Add-ADGroupMember -Identity Logistiek -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
    }
    If($importexport.ToString() -eq 'X'){
        Add-ADGroupMember -Identity ImportExport -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
          
    }
    If($manager.ToString() -eq 'X'){
        Add-ADGroupMember -Identity Manager -Members "CN=$voornaam $naam, OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local";
    }
    #Write-Host output for each user
    Write-Host "Account created for $voornaam $naam in $ou"
    }
}


ForEach ($user in $users) {
    # Gather the user's information
    $naam = $user.'Naam'
    $voornaam = $user.'Voornaam'
    $account = $user.'Account'
    $fullname= "$voornaam $naam"
    $accountname = $user.'Account'
    $manager = $user.'Manager'
    $it = $user.'IT'
    $boekhouding = $user.'Boekhouding'
    $logistiek = $user.'Logistiek'
    $importexport = $user.'ImportExport'
    
   
    UserCheck;
   

    $ADUsersArray += @($user.'Account');

    #Creating a secure string for the password
    $secpasswd = ConvertTo-SecureString -String "Chang31t" -AsPlainText -Force
    
}

function checkForDisable($thisuser){
    if( $users.'Account'-Contains $thisuser.'SamAccountName'){
        Write-Host $thisuser.'SamAccountName'
        Enable-ADAccount -Identity $thisuser.'SamAccountName'
        Write-Host "This user exists in the csv, no need to disable"
    }else{
        Write-Host $thisuser.'SamAccountName'
        Write-Host "this user is now disabled"
        Disable-ADAccount -Identity $thisuser.'SamAccountName'
    }
}

$adusers = Get-ADUser -Filter * -SearchBase "OU=CMAfdelingen, DC=$DC, DC=local"

ForEach($aduser in $adusers){
    checkForDisable($aduser);
}
