param([int]$port=8080, [string]$message="OK")
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:$Port/")
$listener.Start()
while ($listener.IsListening)  {
    $context = $listener.GetContext()  #Blocks
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($message )
    $context.response.OutputStream.Write($buffer, 0, $buffer.Length)   
    $context.response.Close();
}