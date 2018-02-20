$items = Get-ChildItem -Path "Cert:\LocalMachine\My"
$localThumbprint = $false
$localCentralPointNowThumbPrint = $false

foreach($item in $items)
{
    $name = $item.DnsNameList
    Write-Host $name

    if ($name -contains "Local Development Root Certificate Authority")
    {
        Write-Host "Found the Root Authority Certificate!"
        $localThumbprint = $item.Thumbprint
    }
    elseif ($name -contains "www.localwebsite.com")
    {
        Write-Host "Found the centralpoint certificate!"
        $localCentralPointNowThumbPrint = $item.Thumbprint
    }
}

if ($localThumbprint -eq $false)
{
    Write-Host "Creating the Local Development Root Certificate Authority"
    $rootcert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\my -DnsName "Local Development Root Certificate Authority" -NotAfter (Get-Date).AddYears(3) -KeyUsage CertSign
    $rootCertPwd = ConvertTo-SecureString -String "[[ReplaceMEEEEEEEEE!!!!!!!]]" -Force -AsPlainText
    $localThumbprint = $rootcert.Thumbprint
}

if ($localCentralPointNowThumbPrint -eq $false)
{   
    Write-Host "Creating the local central point now certificate" 
    $signer = (Get-ChildItem -Path "Cert:\Localmachine\my\$localThumbprint")
    $domainCert = New-SelfSignedCertificate -DnsName "www.localwebsite.com", "*.localwebsite.com", "localwebsite.com", "localhost" -CertStoreLocation "cert:\LocalMachine\My" -Signer $signer -NotAfter (Get-Date).AddYears(3) -KeyUsage DigitalSignature    
}

$rootItems = Get-ChildItem -Path Cert:\LocalMachine\Root
$localCAIsInRoot = $false

foreach ($rootItem in $rootItems)
{
    $rootItemName = $rootItem.DnsNameList    

    if ($rootItemName -contains "Local Development Root Certificate Authority")
    {
        Write-Host "Found the Root Authority Certificate!"
        $localCAIsInRoot = $true
    }
}

if ($localCAIsInRoot -eq $false)
{
    $myCertificates = Get-ChildItem -Path "Cert:\LocalMachine\My"

    $localRootCA = $false
    foreach ($cert in $myCertificates)
    {
        $certName = $cert.DnsNameList
        if ($certName -contains "Local Development Root Certificate Authority")
        {
            Write-Host "Found the Root Authority Certificate to Add!"
            $localRootCA = $cert
        }   
    }

    $DestStoreScope = 'LocalMachine'
    $DestStoreName = 'root'

    Write-Host "Adding Local Certificate To Root"
    $DestStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $DestStoreName, $DestStoreScope
    $DestStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $DestStore.Add($localRootCA)

    $DestStore.Close()
}