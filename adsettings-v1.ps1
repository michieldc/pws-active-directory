# Import the required modules
Import-Module ActiveDirectory

# Prompt user for location of the csv file
$filepath = Read-Host -Prompt "Please enter the path to your CSV file"

# Import the file into the users variable
$users = Import-CSV $filepath -Delimiter ';'


$DC = "SynalcoMedics";


#Creating a group for every OU
New-ADGroup -Name "Manager" -GroupScope "Global" -Path "OU=Manager, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "IT" -GroupScope "Global" -Path "OU=IT, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "Boekhouding" -GroupScope "Global" -Path "OU=Boekhouding, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "Logistiek" -GroupScope "Global" -Path "OU=Logistiek, OU=CMAfdelingen, DC=$DC, DC=local"
New-ADGroup -Name "ImportExport" -GroupScope "Global" -Path "OU=ImportExport, OU=CMAfdelingen, DC=$DC, DC=local"

ForEach ($user in $users) {
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
    
    
    #Creating a directory for the user
    New-Item -ItemType Directory -Path "\\EARTH\CMData\Home"
    New-Item -ItemType Directory -Path "\\EARTH\CMData\Home\$fullname"

    New-Item -ItemType Directory -Path "\\EARTH\CMData\Profile"
    New-Item -ItemType Directory -Path "\\EARTH\CMData\Profile\$fullname"
    

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
    #Echo output for each user
    echo "Account created for $voornaam $naam in $ou"
    
   
}




