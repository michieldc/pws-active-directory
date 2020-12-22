# pws-active-directory Version 1

## Beginning of the script

First we ask the user for the path to the CSV by prompting them for the filepath.

```ps1
$filepath = Read-Host -Prompt "Please enter the path to your CSV file"
```

We import the file into a variable called users.

```ps1
$users = Import-CSV $filepath -Delimiter ';'
```

We set our DC as a variable:

```ps1
$DC = "SynalcoMedics";
```

We create a group for every OU

```ps1
#Creating a group for every OU
New-ADGroup -Name "Manager" -GroupScope "Global" -Path "OU=Manager, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "IT" -GroupScope "Global" -Path "OU=IT, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "Boekhouding" -GroupScope "Global" -Path "OU=Boekhouding, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "Logistiek" -GroupScope "Global" -Path "OU=Logistiek, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "ImportExport" -GroupScope "Global" -Path "OU=ImportExport, OU=CMAfdelingen, DC=$DC, DC=local"

```

## The Foreach
Now we create a foreach. Here we check all Users by using:

```ps1
ForEach ($user in $users)
```

### Getting the User info

Here we get the user information from the colums. This all still happens in the foreach.

We are creating a User in AD by using New-ADUser.

```ps1
# Gather the user's information

    $naam = $user.'Naam'
    $voornaam = $user.'Voornaam'
    $account = $user.'Account'

    $fullname= "$voornaam$naam"

    $manager = $user.'Manager'
    
    $it = $user.'IT'
    
    $boekhouding = $user.'Boekhouding'
    
    $logistiek = $user.'Logistiek'
    
    $importexport = $user.'ImportExport' 

    #Creating a secure string for the password
    $secpasswd = ConvertTo-SecureString -String "CynalcoM3d1cs" -AsPlainText -Force

    #Create users in AD
    New-ADUser -Name "$voornaam $naam" -DisplayName "$voornaam $naam" -UserPrincipalName "CM_$fullname" -AccountPassword $secpasswd -GivenName "$voornaam" -Surname "$naam" -Enabled $true

```

### Checking OU

Now we will check which OU the user belongs to bij reading if the content of the variable contains an 'X' : 

```ps1
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
```

### Moving the user to the correct path

Next up we want to move the user to the correct path. We do this by using the `Move AD-Object` command :

```ps1
Move-ADObject -Identity "CN=$voornaam $naam, CN=Users, DC=$DC, DC=local" -TargetPath "OU=$OU, OU=CMAfdelingen, DC=$DC, DC=local"
```

### Adding to the correct group

Now all that needs to be done is adding the user to the correct group:

```ps1
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
```
