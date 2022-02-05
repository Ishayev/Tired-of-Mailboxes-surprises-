Import-Module Exchangeonlinemanagement

Connect-ExchangeOnline 
Connect-MsolService
Connect-AzureAD

## Intergers ##
## 1.ArchiveQuota 2.WindowsEmailAddress 3.Id 4.ProhibitSendQuota ##
 
$b=Get-Mailbox | select WindowsEmailAddress, Id, ProhibitSendQuota, `
  @{name=”ArchiveQuota (GB)”; expression={[math]::Round( `
  ($_.ArchiveQuota.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB),2)}}, `
ItemCount

## 1.ArchiveQuota 2.WindowsEmailAddress 3.Id 4.ProhibitSendQuota ##

 
## Total Usage ##
$c=Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Select DisplayName,StorageLimitStatus, `
  @{name=”TotalItemSize (GB)”; expression={[math]::Round( `
  ($_.TotalItemSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB),2)}}, `
ItemCount

##########################

$365list = New-Object PSObject

$365list= @()

for($i=0;$i -lt $b.count;$i++){

## License ##
$g=get-azureaduser -ObjectId $b.WindowsEmailAddress[$i]
$E=Get-AzureADUserLicenseDetail -ObjectId $b.WindowsEmailAddress[$i] | select SkuPartNumber

## MFA ##
$User = Get-MSolUser -userprincipalname $b.WindowsEmailAddress[$i]
$MFA=$User.StrongAuthenticationMethods | select IsDefault, MethodType

$365list+= @{Email= $b.WindowsEmailAddress[$i];UserName = $b.Id[$i];MailBox = $a.'ProhibitSendQuota (GB)'[$i];Archive = $b.'ArchiveQuota (GB)'[$i];TotalUsage = $c.'TotalItemSize (GB)'[$i];SpaceLeft = "%" + (100-($c.'TotalItemSize (GB)'[$i]/$a.'ProhibitSendQuota (GB)'[$i])*100);License = $E;MFA=$MFA}

}

$checking=$365list| % { new-object PSObject -Property $_} |export-csv c:\mfa.csv

#########################


 
