[cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
param(
  #Listening Endpoint
  [Parameter(Mandatory=$false,ValueFromPipeline=$false)] $HTTPEndPoint = 'http://localhost:8080/'
  ,
  # LocalPath
  [Parameter(Mandatory=$true,ValueFromPipeline=$false)] $LocalRoot = 'c:\wwwroot\'
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

function Get-HTTPResponse  {  
  param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)] $Response,
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)] $Path    
  )

  try {
    Write-Verbose "Determine MimeType of  $path ..."
    $mimetype = [System.Web.MimeMapping]::GetMimeMapping($path)
    Write-Verbose " - $mimetype"
    
    # Generate Response
    $content = ( Get-Content -Path $path -Raw )  
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)   
  }
  catch [System.Exception] {
    Write-Verbose "ERROR: $($_)"
    return ""
  }
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add( $HTTPEndPoint )
$listener.Start()
Write-Verbose "Listening at $HTTPEndPoint..."

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $requestUrl = $context.Request.Url
  $response = $context.Response

  try {    
    $localPath = $requestUrl.LocalPath
    #Close server
    if ($localPath -eq '/kill') {
      Write-Verbose "Killing ...";
      $response.StatusCode = 200; 
      $response.Close();
      $listener.Close(); 
      break; 
    }
    $FullPath = join-path -Path $LocalRoot -ChildPath $LocalPath
    if ( Test-Path $FullPath )  {
      Write-Verbose "Querying $requestUrl ..."
      Get-HTTPResponse -Response $response -Path  $FullPath         
    } else {
      $response.StatusCode = 404
    }
  } catch {
    $response.StatusCode = 500
  }
  $response.Close()
}