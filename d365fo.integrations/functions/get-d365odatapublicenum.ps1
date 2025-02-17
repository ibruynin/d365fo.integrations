﻿
<#
    .SYNOPSIS
        Get public enumerations (enums) and their metadata
        
    .DESCRIPTION
        Get a list with all the public available enumerations (enums), and their metadata, that are exposed through the OData endpoint of the Dynamics 365 Finance & Operations environment
        
        The cmdlet will search across the names for the enumerations (enums) and across the labelid
        
    .PARAMETER EnumName
        Name of the enumerations (enums) you are searching for
        
        The parameter is Case Insensitive, to make it easier for the user to locate the correct enumerations (enums)
        
    .PARAMETER EnumNameContains
        Name of the enumerations (enums) you are searching for, but instructing the cmdlet to use search logic
        
        Using this parameter enables you to supply only a portion of the name for the enumerations (enums) you are looking for, and still get a valid result back
        
        The parameter is Case Insensitive, to make it easier for the user to locate the correct enumerations (enums)
        
    .PARAMETER ODataQuery
        Valid OData query string that you want to pass onto the D365 OData endpoint while retrieving data
        
        Important note:
        If you are using -EnumName or -EnumNameContains along with the -ODataQuery, you need to understand that the "$filter" query is already started. Then you need to start with -ODataQuery ' and XYZ eq XYZ', e.g. -ODataQuery ' and IsReadOnly eq false'
        If you are using the -ODataQuery alone, you need to start the OData Query string correctly. -ODataQuery '$filter=IsReadOnly eq false'
        
        OData specific query options are:
        $filter
        $expand
        $select
        $orderby
        $top
        $skip
        
        Each option has different characteristics, which is well documented at: http://docs.oasis-open.org/odata/odata/v4.0/odata-v4.0-part2-url-conventions.html
        
    .PARAMETER Tenant
        Azure Active Directory (AAD) tenant id (Guid) that the D365FO environment is connected to, that you want to access through OData
        
    .PARAMETER Url
        URL / URI for the D365FO environment you want to access through MetaData
        
        If you are working against a D365FO instance, it will be the URL / URI for the instance itself
        
        If you are working against a D365 Talent / HR instance, this will have to be "http://hr.talent.dynamics.com"
        
    .PARAMETER SystemUrl
        URL / URI for the D365FO instance where the MetaData endpoint is available
        
        If you are working against a D365FO instance, it will be the URL / URI for the instance itself, which is the same as the Url parameter value
        
        If you are working against a D365 Talent / HR instance, this will to be full instance URL / URI like "https://aos-rts-sf-b1b468164ee-prod-northeurope.hr.talent.dynamics.com/namespaces/0ab49d18-6325-4597-97b3-c7f2321aa80c"
        
    .PARAMETER ClientId
        The ClientId obtained from the Azure Portal when you created a Registered Application
        
    .PARAMETER ClientSecret
        The ClientSecret obtained from the Azure Portal when you created a Registered Application
        
    .PARAMETER Token
        Pass a bearer token string that you want to use for while working against the endpoint
        
        This can improve performance if you are iterating over a large collection/array
        
    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions
        This is less user friendly, but allows catching exceptions in calling scripts
        
    .PARAMETER RawOutput
        Instructs the cmdlet to include the outer structure of the response received from MetaData endpoint
        
        The output will still be a PSCustomObject
        
    .PARAMETER OutputAsJson
        Instructs the cmdlet to convert the output to a Json string
        
    .EXAMPLE
        PS C:\> Get-D365ODataPublicEnum
        
        This will list all available enumerations (enums).
        
        It will use the default OData configuration details that are stored in the configuration store.
        
    .EXAMPLE
        PS C:\> Get-D365ODataPublicEnum -Tenant "e674da86-7ee5-40a7-b777-1111111111111" -Url "https://usnconeboxax1aos.cloud.onebox.dynamics.com" -ClientId "dea8d7a9-1602-4429-b138-111111111111" -ClientSecret "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522"
        
        This will list all available enumerations (enums).
        
        It will use "e674da86-7ee5-40a7-b777-1111111111111" as the Azure Active Directory guid.
        It will use "https://usnconeboxax1aos.cloud.onebox.dynamics.com" as the base D365FO environment url.
        It will use "dea8d7a9-1602-4429-b138-111111111111" as the ClientId.
        It will use "Vja/VmdxaLOPR+alkjfsadffelkjlfw234522" as ClientSecret.
        
    .EXAMPLE
        PS C:\> Get-D365ODataPublicEnum -EnumName VendRequestRoleType
        
        This will list the VendRequestRoleType enumerations (enums).
        
        It will use the default OData configuration details that are stored in the configuration store.
        
        Sample output:
        
        EnumName            EnumValueName EnumIntValue EnumValueLabelId
        --------            ------------- ------------ ----------------
        VendRequestRoleType None                     0 @SYS1369
        VendRequestRoleType Admin                    1 @SYS20515
        VendRequestRoleType Clerk                    2 @SYS130176
        
    .EXAMPLE
        PS C:\> Get-D365ODataPublicEnum -EnumNameContains VendRequestRole
        
        This will search for all enumerations (enums) that matches the VendRequestRole search pattern.
        
        It will use the default OData configuration details that are stored in the configuration store.
        
        Sample output:
        
        EnumName            EnumValueName EnumIntValue EnumValueLabelId
        --------            ------------- ------------ ----------------
        VendRequestRoleType None                     0 @SYS1369
        VendRequestRoleType Admin                    1 @SYS20515
        VendRequestRoleType Clerk                    2 @SYS130176
        
    .EXAMPLE
        PS C:\> $token = Get-D365ODataToken
        PS C:\> Get-D365ODataPublicEnum -Token $token
        
        This will list all available enumerations (enums).
        It will get a fresh token, saved it into the token variable and pass it to the cmdlet.
        
        It will use the default OData configuration details that are stored in the configuration store.
        
    .NOTES
        The OData standard is using the $ (dollar sign) for many functions and features, which in PowerShell is normally used for variables.
        
        Whenever you want to use the different query options, you need to take the $ sign and single quotes into consideration.
        
        Example of an execution where I want the top 1 result only, from a specific legal entity / company.
        This example is using single quotes, to help PowerShell not trying to convert the $ into a variable.
        Because the OData standard is using single quotes as text qualifiers, we need to escape them with multiple single quotes.
        
        -ODataQuery '$top=1&$filter=dataAreaId eq ''Comp1'''
        
        Tags: OData, MetaData, Enum, Enumerations
        
        Author: Mötz Jensen (@Splaxi)
#>
function Get-D365ODataPublicEnum {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType()]
    param (

        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Alias('LabelId')]
        [string] $EnumName,

        [Parameter(Mandatory = $true, ParameterSetName = "NameContains")]
        [string] $EnumNameContains,

        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Parameter(Mandatory = $false, ParameterSetName = "NameContains")]
        [Parameter(Mandatory = $true, ParameterSetName = "Query")]
        [string] $ODataQuery,

        [Alias('$AADGuid')]
        [string] $Tenant = $Script:ODataTenant,

        [Alias('Uri')]
        [Alias('AuthenticationUrl')]
        [string] $Url = $Script:ODataUrl,

        [string] $SystemUrl = $Script:ODataSystemUrl,

        [string] $ClientId = $Script:ODataClientId,

        [string] $ClientSecret = $Script:ODataClientSecret,

        [string] $Token,
        
        [switch] $EnableException,

        [switch] $RawOutput,

        [switch] $OutputAsJson
    )


    begin {
        if ([System.String]::IsNullOrEmpty($SystemUrl)) {
            Write-PSFMessage -Level Verbose -Message "The SystemUrl parameter was empty, using the Url parameter as the OData endpoint base address." -Target $SystemUrl
            $SystemUrl = $Url
        }

        if ([System.String]::IsNullOrEmpty($Url) -or [System.String]::IsNullOrEmpty($SystemUrl)) {
            $messageString = "It seems that you didn't supply a valid value for the Url parameter. You need specify the Url parameter or add a configuration with the <c='em'>Add-D365ODataConfig</c> cmdlet."
            Write-PSFMessage -Level Host -Message $messageString -Exception $PSItem.Exception -Target $EnumName
            Stop-PSFFunction -Message "Stopping because of errors." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', ''))) -ErrorRecord $_
            return
        }
        
        if ($Url.Substring($Url.Length - 1) -eq "/") {
            Write-PSFMessage -Level Verbose -Message "The Url parameter had a tailing slash, which shouldn't be there. Removing the tailling slash." -Target $Url
            $Url = $Url.Substring(0, $Url.Length - 1)
        }
    
        if ($SystemUrl.Substring($SystemUrl.Length - 1) -eq "/") {
            Write-PSFMessage -Level Verbose -Message "The SystemUrl parameter had a tailing slash, which shouldn't be there. Removing the tailling slash." -Target $Url
            $SystemUrl = $SystemUrl.Substring(0, $SystemUrl.Length - 1)
        }
        
        if (-not $Token) {
            $bearerParms = @{
                Url          = $Url
                ClientId     = $ClientId
                ClientSecret = $ClientSecret
                Tenant       = $Tenant
            }

            $bearer = New-BearerToken @bearerParms
        }
        else {
            $bearer = $Token
        }
        
        $headerParms = @{
            URL         = $Url
            BearerToken = $bearer
        }

        $headers = New-AuthorizationHeaderBearerToken @headerParms

        [System.UriBuilder] $odataEndpoint = $SystemUrl
        
        if ($odataEndpoint.Path -eq "/") {
            $odataEndpoint.Path = "metadata/PublicEnumerations"
        }
        else {
            $odataEndpoint.Path += "/metadata/PublicEnumerations"
        }
    }

    process {
        if (Test-PSFFunctionInterrupt) { return }

        Invoke-TimeSignal -Start

        $odataEndpoint.Query = ""
        
        if (-not ([string]::IsNullOrEmpty($EnumName))) {
            Write-PSFMessage -Level Verbose -Message "Building request for the Metadata OData endpoint for enum named: $EnumName." -Target $EnumName

            $searchEnumName = $EnumName
            $odataEndpoint.Query = "`$filter=(tolower(Name) eq tolower('$EnumName') or tolower(LabelId) eq tolower('$EnumName'))"
        }
        elseif (-not ([string]::IsNullOrEmpty($EnumNameContains))) {
            Write-PSFMessage -Level Verbose -Message "Building request for the Metadata OData endpoint for enum that contains: $EnumNameContains." -Target $EnumNameContains

            $searchEnumName = $EnumNameContains
            $odataEndpoint.Query = "`$filter=(contains(tolower(Name), tolower('$EnumNameContains')) or contains(tolower(LabelId), tolower('$EnumNameContains')))"
        }

        if (-not ([string]::IsNullOrEmpty($ODataQuery))) {
            $odataEndpoint.Query = $($odataEndpoint.Query + "$ODataQuery").Replace("?", "")
        }

        try {
            Write-PSFMessage -Level Verbose -Message "Executing http request against the Metadata OData endpoint." -Target $($odataEndpoint.Uri.AbsoluteUri)
            $res = Invoke-RestMethod -Method Get -Uri $odataEndpoint.Uri.AbsoluteUri -Headers $headers -ContentType 'application/json'

            if (-not ($RawOutput)) {
                $res = $res.Value | Sort-Object -Property Name
            }

            if ($OutputAsJson) {
                $res | ConvertTo-Json -Depth 10
            }
            else {
                foreach ($item in $res) {
                    $item.Members | Sort-Object Value | Select-PSFObject @{Name = "EnumName"; Expression = { $item.Name } }, "Name as EnumValueName", "Value as EnumIntValue", "LabelId as EnumValueLabelId"
                }
            }
        }
        catch {
            $messageString = "Something went wrong while searching the Metadata OData endpoint for the entity: $searchEnumName"
            Write-PSFMessage -Level Host -Message $messageString -Exception $PSItem.Exception -Target $EnumName
            Stop-PSFFunction -Message "Stopping because of errors." -Exception $([System.Exception]::new($($messageString -replace '<[^>]+>', ''))) -ErrorRecord $_
            return
        }

        Invoke-TimeSignal -End
    }
}