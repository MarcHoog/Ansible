#!powershell


    $module = [Ansible.Basic.AnsibleModule]::Create($args,$spec)

    $sqlserver = $module.spec.sqlserver
    $database = $module.spec.database
    $query = $module.spec.query
    $action = $module.spec.action
    $SQLusername = $module.spec.variables.username
    $SQLfirstname = $module.spec.variables.firstname
    $SQLLastname = $module.spec.variables.lastname
    $SQLcompany = $module.spec.variables.company
    $SQLOUpath = $module.spec.variables.OUpath
    $SQLenabled = $module.spec.variables.enabled
    $SQLuserprofile = $module.spec.userprofile

    function Get-RandomCharacters($length, $characters) {
        $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
        $private:ofs=""
        return [String]$characters[$random]
    }
    
    function Scramble-String([string]$inputString){     
        $characterArray = $inputString.ToCharArray()   
        $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
        $outputString = -join $scrambledStringArray
        return $outputString 
    }

    function Generate-Password([int]$lengthLetters,[int]$lengthCapsLetters,[int]$lengthNummers,[int]$LengthSpecialCharacters){
        
        $Password = Get-RandomCharacters -length $lengthLetters -characters 'abcdefghiklmnoprstuvwxyz'
        $Password += Get-RandomCharacters -length $lengthCapsLetters -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
        $Password += Get-RandomCharacters -length $lengthNummers -characters '1234567890'
        $Password += Get-RandomCharacters -length $LengthSpecialCharacters -characters '!"§$%&/()=?}][{@#*+'

        $Password = ConvertTo-SecureString $Password –asplaintext –force 

        return $Password
    }


    try {

    $checkAD = Get-ADDomainController -ErrorAction SilentlyContinue
    if(!$checkAD){
        $module.failjson("Active Directory Functions Cannot be Reached.")
    }

    $checkSQLModule = get-module Simplysql
    if(!$CheckSQLModule){
        $module.failjson("The SimplySQL Module Does not seem to be installed on this Machine ")
    }
    
    try {
    Open-MySqlConnection -Server $sqlserver -Database $database
    $SQLdata = -InvokeQuery $query 
    close-sqlConnection
    }Catch{
        $errormsg = $_.exception.message
        $module.FailJson("there was an error message while connecting to the SQL server: $errormsg")
    }


    if(!$SQLdata){
        $module.failjson("SQL Data is Empty, `Was the Querry right?` ")
    }
       

    if($action -eq 'Create'){
        foreach($SQLentity in $SQLdata ){

            $New_aduser_cmd = "New-ADUser "

            if($SQLentity.$SQLusername){

                $Username = $SQLentity.$SQLusername

                [int] $inc = 0
                if (Get-ADuser -Filter {SamAccountName -eq "$Username"}) 
                {    
                    do 
                    {
                        $inc ++
                        $Username = $Username + [string]$inc
                    } 
                    until (-not (Get-ADuser -Filter {SamAccountName -eq "$Username"}))
                
                    $New_aduser_cmd += "-samaccountname $Username "
                }
            }else{
                $module.warningjson('$Username was empty user will be skipped from Creation')
                return
            }


            if ($SQLentity.$SQLfirstname) { 
                $Firstname = $SQLentity.$SQLfirstname
                $New_aduser_cmd += "-Name $Firstname "
            }

            if ($SQLentity.$SQLLastname) {
                $lastname = $SQLentity.$SQLLastname
                $New_aduser_cmd += "-Lastname $lastname "
            }

            if ($SQLentity.$SQLcompany){
                $Company = $SQLentity.$SQLcompany
                $New_aduser_cmd += "-Company $company "
            }
            
            if ($SQLentity.$SQLOUpath){
                $OUpath =  Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $SQLentity.$SQLOUpath}
                if (!$OUPath) {
                    $module.warningjson("The SQL OU Path Coudln't be found, $Username will be skipped from creation")   
                }
                $New_aduser_cmd += "-Path $OUPath "
            }

            if ($SQLentity.$SQLenabled -eq $true){
                $password = Generate-Password -lengthLetters 7 -lengthCapsLetters 1  -lengthNummers 1 -LengthSpecialCharacters 1
                $New_aduser_cmd += "-Enabled $True -AccountPassword $Password -ChangePasswordAtLogon $True "

            }else {
                $New_aduser_cmd += "-Enabled $False"
            }

            #EVEN NAAR KIJKEN NOG TEST SHARE AANMAKEN
            if ($SQLentity.$SQLuserprofile){

                $Userprofilepath = Get-ChildItem -Path $SQLentity.$SQLuserprofile | Select-Object FullName

                $New_aduser_cmd += "-ProfilePath $Userprofilepath\%SAMACCOUNTNAME%"
            }
        }
    }

    elseif ($action -eq 'Disabled') {
    }

    Invoke-Expression -Command 

    }catch {
        $errormsg = $_.exception.message
        $module.FailJson("there was an error message: $errormsg")
    }
