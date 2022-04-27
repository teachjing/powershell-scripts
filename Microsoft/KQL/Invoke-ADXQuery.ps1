function Invoke-ADXQuery {
    <#
    .SYNOPSIS
        A PowerShell function to invoke kusto query against the data explorer table.
    .DESCRIPTION
        A PowerShell function to invoke kusto query against the data explorer table.
        This cmdlet can be used for executing the control commands (the command that starts with '.')
    .EXAMPLE
        PS C:\> Invoke-ADXQuery -ClusterUrl '' -DatabaseName '' -ApplicationClientID '' -ApplicationClientKey '' -Authority '' -Query ''
        Execute any valid Kusto query remotely.
    .NOTES
        Author: Chendrayan Venkatesan
    #>
    [CmdletBinding()]
    param (

        [System.String]
        $ClusterUrl,

        [System.String]
        $DatabaseName,

        [System.Guid]
        $ApplicationClientID,

        [system.String]
        $ApplicationClientKey,

        [System.Guid]
        $Authority,

        [System.String]
        $Query
    )
    
    $KustoConnectionStringBuilder = [Kusto.Data.KustoConnectionStringBuilder]::new($ClusterUrl).WithAadApplicationKeyAuthentication(
        $ApplicationclientID,
        $ApplicationclientKey,
        $Authority
    )
    $QueryProvider = [Kusto.Data.Net.Client.KustoClientFactory]::CreateCslQueryProvider(
        $KustoConnectionStringBuilder
    )
    $ClientRequestProperties = [Kusto.Data.Common.ClientRequestProperties]::new()
    $ClientRequestProperties.ClientRequestId = "PowerShell.ExecuteQuery." + [Guid]::NewGuid().ToString()
    $ClientRequestProperties.SetOption([Kusto.Data.Common.ClientRequestProperties]::OptionServerTimeout, [TimeSpan]::FromSeconds(30))
    if ($Query.StartsWith('.')) {
        $QueryProvider.ExecuteControlCommand($databaseName, $Query, $ClientRequestProperties)
    }
    else {
        $Reader = $QueryProvider.ExecuteQuery($databaseName, $Query, $ClientRequestProperties)
        try {
            $Reader = $QueryProvider.ExecuteQuery($databaseName, $Query, $ClientRequestProperties)
            $DataTable = [Kusto.Cloud.Platform.Data.ExtendedDataReader]::ToDataSet($reader).Tables[0]
            $DataView = [System.Data.DataView]::new($DataTable)
            $DataView
        }
        catch {
            $_.Exception
        }
    }
    
}