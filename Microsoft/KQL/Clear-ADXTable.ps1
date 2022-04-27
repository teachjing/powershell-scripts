function Clear-ADXTableData {
    <#
    .SYNOPSIS
        A PowerShell function to clear the table data, including streaming ingestion data.
    .DESCRIPTION
        A PowerShell function to clear the table data, including streaming ingestion data.
    .EXAMPLE
        PS C:\> Clear-ADXTableData -ClusterUrl '' -DatabaseName '' -TableName '' -ApplicationClientID '' -ApplicationClientKey '' -Authority ''
        Clears the table data.
    .NOTES
        Author: Chendrayan Venkatesan
    #>
    [CmdletBinding()]
    param (
        [System.String]
        $ClusterUrl,

        [System.String]
        $DatabaseName,

        [System.String]
        $TableName,

        [System.Guid]
        $ApplicationClientID,

        [system.String]
        $ApplicationClientKey,

        [System.Guid]
        $Authority
    )
    
    try {
        $KustoConnectionStringBuilder = [Kusto.Data.KustoConnectionStringBuilder]::new($ClusterUrl).WithAadApplicationKeyAuthentication(
            $ApplicationClientID,
            $ApplicationClientKey,
            $Authority
        )
        $QueryProvider = [Kusto.Data.Net.Client.KustoClientFactory]::CreateCslQueryProvider(
            $KustoConnectionStringBuilder
        )
        $ClientRequestProperties = [Kusto.Data.Common.ClientRequestProperties]::new()
        $ClientRequestProperties.ClientRequestId = "PowerShell.ExecuteQuery." + [Guid]::NewGuid().ToString()
        $ClientRequestProperties.SetOption([Kusto.Data.Common.ClientRequestProperties]::OptionServerTimeout, [TimeSpan]::FromSeconds(30))
        $Query = ".clear table $($TableName) data"
        $QueryProvider.ExecuteControlCommand($DatabaseName, $Query, $ClientRequestProperties)
    }
    catch {
        Write-Error $($Exception)
    }
}