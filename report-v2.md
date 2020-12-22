# pws-active-directory Version 1

This is a further build on adsettings-v2. In hindsight its kind of stupid that I didn't simply merge the 2 script into one. But this makes it easier to create different readme files.

If you don't understand things that aren't explained in this v2, make sure to check the report for [v1](report-v1.md).

## Try catching the group creation process

When we run the script again, we don't want to be bombarded with multiple lines of red code which say the ADGroups we created in v1 already exist. Thats why we use a try-catch.

```ps1
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
```

This helps alot with our powershell output.

## Update OU function.

Obviously when Users exist in a company they will often move branches. So we need to be able to update the users when they change to another branch of the company. Thats why the updateOU function exists. It checks if the user changed jobs during the time the script hasn't run. We do this similarly like we did with assigning the original OU.

```ps1
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
```

## UserCheck function

This function primarly acts as a way to check if the User already exits in AD. We don't want multiple accounts for one person. A try-catch was used to catch the errors if the user already exists. 

```ps1
function UserCheck {
    try{
    $ADaccount = Get-ADUser -Identity "$account"
    }catch{
        Write-Host "No User with name $account exists, Creating one now"
    }finally{
    $error.Clear()
    }
```

This function does a little more than just check if the user exists in AD. It also creates a new user if he doesn't exist. This is practically the same code as in v1, but it also uses the function UpdateOU.

```ps1
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
    
```

We also added the creation of a sharedFolder. 

```ps1
# adding the sharedfolder to the user
    Write-Host "adding a sharedfolder for $($account)"
    $Path = "\\EARTH\SharedFolders\$account"
    set-aduser -identity $account -HomeDirectory "$Path" -HomeDrive "L:"


    if (!(Test-Path -path "$Path")) {
        New-Item -ItemType directory -Path "\\EARTH\SharedFolders" -Name "$account"
    }else{
        Write-Host ""
    }

```

Afterwards we do the same as in v1. For that information - check [v1](report-v1.md)

