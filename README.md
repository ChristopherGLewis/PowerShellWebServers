# PowerShellWebServers
Sample code for Powershell acting as a web server

Some simple powershell web servers.  Inspired by Jan Ka's https://github.com/Jan-Ka/coms, which is inspired by 
Ben Rady's https://github.com/benrady/shinatra - without the MS vs. Linux bagage :-).

Most of these are pretty silly, with no error handling.

## TCPListener-WebServer.ps1
10 lines of code.

The TCP Listener uses System.Net.Sockets.TcpListener and is similar to Jan Ka's, but uses a while loop to surround
the blocking $listener.AcceptTcpClient().

Note there's no way to close the connection, and PowerShell seems to hang on a ctrl-break.  
I ended up killing the PowerShell.exe process.

```
c:\GitHub\PowerShellWebServers>powershell -f TCPListener-WebServer.ps1 8001 test1
```

```
c:\>\cURL\bin\curl.exe http://localhost:8001 -v
* Rebuilt URL to: http://localhost:8001/
*   Trying ::1...
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 8001 (#0)
> GET / HTTP/1.1
> Host: localhost:8001
> User-Agent: curl/7.49.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Connection: keep-alive
* no chunk, no close, no size. Assume close to signal end
<
test1
* Recv failure: Connection was aborted
* Closing connection 0
curl: (56) Recv failure: Connection was aborted
```

Curl says that the connection closed ugly, but this certainly works.

## HTTPListener-WebServer1.ps1 
10 lines of code.

The HTTP Listener uses System.Net.HttpListener, which wraps the incomming connection in a request object.

As with the TCP Listener, there's no way to close the process gracefully.

```
c:\GitHub\PowerShellWebServers>powershell -f HTTPListener-WebServer1.ps1 8001 Test2
```

```
c:\>\cURL\bin\curl.exe http://localhost:8001 -v
* Rebuilt URL to: http://localhost:8001/
*   Trying ::1...
* Connected to localhost (::1) port 8001 (#0)
> GET / HTTP/1.1
> Host: localhost:8001
> User-Agent: curl/7.49.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Transfer-Encoding: chunked
< Server: Microsoft-HTTPAPI/2.0
< Date: Wed, 07 Dec 2016 15:47:30 GMT
<
Test2* Connection #0 to host localhost left intact
```

Note that the connection was left intact, and Curl likes this. 
  
## HTTPListener-WebServer2.ps1 
11 lines of code.

Same listener, with a single line added to close the server after a `/kill`

```
c:\GitHub\PowerShellWebServers>powershell -f HTTPListener-WebServer2.ps1 8001 Test3
```

```
c:\>\cURL\bin\curl.exe http://localhost:8001 -v
* Rebuilt URL to: http://localhost:8001/
*   Trying ::1...
* Connected to localhost (::1) port 8001 (#0)
> GET / HTTP/1.1
> Host: localhost:8001
> User-Agent: curl/7.49.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Transfer-Encoding: chunked
< Server: Microsoft-HTTPAPI/2.0
< Date: Wed, 07 Dec 2016 15:53:26 GMT
<
Test3* Connection #0 to host localhost left intact\

c:\>\cURL\bin\curl.exe http://localhost:8001/kill -v
*   Trying ::1...
* Connected to localhost (::1) port 8001 (#0)
> GET /kill HTTP/1.1
> Host: localhost:8001
> User-Agent: curl/7.49.1
> Accept: */*
>
* Recv failure: Connection was reset
* Closing connection 0
curl: (56) Recv failure: Connection was reset
```

This closes the connection and shuts down powershell.exe somewhat gracefully.


## Powershell-WebServer.ps1
This takes the HTTPListener to the extreme, and creates a moderately functioning web server.  

You pass a URL to listen on, and a path that's your root (has to end in a '\\'), 
and the script servers up http content.

It's not threaded, and currently doesn't handle mime types other then text, but that could be handled in the `Get-HTTPResponse` function.     
