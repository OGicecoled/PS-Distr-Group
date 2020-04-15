# Import CSV from All2 Report in ADF
$all2CSV = Import-csv -path C:\users\ceverett\desktop\All2.csv


# Import All2 group, ignores the users in the group without an external email address (All, BHorn)
$all2group = Get-DistributionGroupMember -identity all2 | Where-Object {$_.ExternalEmailAddress -ne $null}

$Compare = Compare-Object $all2CSV $all2group -property ExternalEmailAddress -IncludeEqual

# Identifies which users should be added, removed, kept. Automatically removes the users who should be removed.
$Compare | foreach {
    if ($_.sideindicator -eq '<=')
        {$_.sideindicator = 'Add'}

    if ($_.sideindicator -eq '==')
        {$_.sideindicator = 'Keep'}

    if ($_.sideindicator -eq '=>')
        {
        $_.ExternalEmailAddress = $_.ExternalEmailAddress -replace ".*:"
        Remove-DistributionGroupMember -identity "All2" -member $_.ExternalEmailAddress
        }
}

write-output $Compare