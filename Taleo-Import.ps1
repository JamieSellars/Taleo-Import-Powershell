<#

    @Title  Taleo REST API Functions

    @Description A collection of methods to extract TALEO Data
 
    @Author     Jamie Sellars
    @Date       10/05/2018

#>

Write-Host 'Taleo REST API Invoker'
Write-Host ''

$companycode = 'companycode';
$username = 'username' + '@' + $companycode;
$password = 'pass';

<#

  Authentication (BASIC)

  This method required that the username, company code and password be included within the header of a
  request – no need to login or log out explicity. The authentication is included in the header of each request
  as Username=username@<<COMPANY_CODE>> and Password=xxxxxxx
  
  Oracle recommends the use of Basic Authentication

#>

function Get-BasicAuthenticationToken {

    Write-Host 'Generating Authentication Header';

    $credentialpair = $username + ':' + $password;
    $tokenBytes = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credentialpair));
    $token = 'Basic ' + $tokenBytes;

    return $token
 
}

<#

    Get Endpoint

    Every request must be sent to a single specific Taleo Business Edition instance via a host URL. To find this
    URL, you must engage the Taleo Dispatcher Service

#>


function Get-EndpointURL() {


    $endpointDispatcherUrl = 'https://tbe.taleo.net/MANAGER/dispatcher/api/v1/serviceUrl/' + $companycode;
    
    Write-Host "Establishing Endpoint..."
    $endpointDispatcherRequest = Invoke-WebRequest -Uri $endpointDispatcherUrl -Method Get 

    $endpointDispatcherRequestObject = ConvertFrom-Json -InputObject $endpointDispatcherRequest

    if( $endpointDispatcherRequestObject.status.success -eq $false ) {
        Write-Host = 'Failed to get Dispatcher Endpoint';
        Exit;
    }

    $endpointUrl = $endpointDispatcherRequestObject.response.URL
    
    Write-Host 'Endpoint established. Using ' $endpointUrl;
    return $endpointUrl;

}


<# 

    Search Employees
    GET
    /object/employee?limit=200(MAX)
    @param MaxResults Limit of API results Single (number)
    @param Fields Pipe delimited fields to get from API

#>

function Get-Employees([single] $MaxResults = 10, [String] $Fields = '') {

    Write-Host 'Employees FETCH Started'
    
    $requestEndpoint = Get-EndpointURL
    $requestUrl = $requestEndpoint + 'object/employee/search?limit=' + $MaxResults + '&fields=' + $Fields  

    $token = Get-BasicAuthenticationToken
    $headers = @{
        Authorization = $token
    }

    Write-Host 'Executing: ' $requestUrl

    try {

        $request = Invoke-WebRequest -Uri $requestUrl -Headers $headers -Method Get
        
        $result = $request.Content
       
        return $result
        
    } catch {

        _HandleResponseError
        
    }   
}

function Get-Employee([string] $Id, [String] $Fields) {

    Write-Host 'Get Employee By ID FETCH Started'
    
    $requestEndpoint = Get-EndpointURL

    $requestUrl = $requestEndpoint + 'object/employee/search?employeeNumber=' + $Id
    
    if( $Fields ) {
         $requestUrl = $requestUrl + '&fields=' + $Fields
    }


    $token = Get-BasicAuthenticationToken

    $headers = @{
        Authorization = $token
    }

    Write-Host 'Executing: ' $requestUrl

    try {
    
        $request = Invoke-WebRequest -Uri $requestUrl -Headers $headers -Method Get
        
        $result = $request.Content
                
    

        return $result


     } catch {

         _HandleResponseError
        
    }
              
}


function Employee-Query([string] $Query, [string] $Fields, [single] $MaxResults = 200) {

    $limitIndex = $Query.IndexOf("limit=")

    if(  $limitIndex  > -1 ) {

        Write-Host ------------------------------------------------------
        Write-Warning 'Do not pass Limit with your query.'
        Write-Warning 'Use the method parameter MaxResults'
        Write-Host ------------------------------------------------------

    }
        

    Write-Host "Performing Query"
    Write-Host "Query: " $Query
    Write-Host "Returning Fields: " $Fields
    Write-Host "Paging Size: " $MaxResults

    $requestEndpoint = Get-EndpointURL

    $requestUrl = $requestEndpoint + 'object/employee/search?' + $Query + '&limit=' + $MaxResults
    
    if( $Fields ) {
         $requestUrl = $requestUrl + '&fields=' + $Fields
    }


    $token = Get-BasicAuthenticationToken

    $headers = @{
        Authorization = $token
    }

    Write-Host 'Executing: ' $requestUrl

    try {
    
        $request = Invoke-WebRequest -Uri $requestUrl -Headers $headers -Method Get
        
        $result = $request.Content
                
        return $result


     } catch {

         _HandleResponseError
        
    }

}

function Get-Employee([string] $Id, [String] $Fields) {

    Write-Host 'Get Employee By ID FETCH Started'
    
    $requestEndpoint = Get-EndpointURL

    $requestUrl = $requestEndpoint + 'object/employee/search?employeeNumber=' + $Id
    
    if( $Fields ) {
         $requestUrl = $requestUrl + '&fields=' + $Fields
    }


    $token = Get-BasicAuthenticationToken

    $headers = @{
        Authorization = $token
    }

    Write-Host 'Executing: ' $requestUrl

    try {
    
        $request = Invoke-WebRequest -Uri $requestUrl -Headers $headers -Method Get
        
        $result = $request.Content
                
        return $result


     } catch {

         _HandleResponseError
        
    }
              
}
        

function _HandleResponseError {
    
    Write-Host ------------------------------------------------------
    Write-Warning 'There was an error with this request'
    Write-Host ------------------------------------------------------
    Write-Host $_.Exception
    Write-Host $_.Exception.Response.StatusCode.value__
    Write-Host $_.Exception.Response.StatusDescription

}


