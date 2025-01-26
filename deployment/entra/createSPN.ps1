 <#
 Name:       AvwSolutions / AzureBuddy Online
 Description: Snippet to create Service Principal for Authentication, which expires are 30 days. A creation of a Client Secret is included.  
  #>
$AppName = "nuclei-security-scanner"
$startDate = (get-date)
$endDate =  (get-date).Date.AddDays(30)
New-AzADServicePrincipal -DisplayName $appName -StartDate $startDate -EndDate $endDate
Get-AzADServicePrincipal -DisplayName $appName | New-AzADSpCredential