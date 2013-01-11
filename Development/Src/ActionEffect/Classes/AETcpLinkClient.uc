class AETcpLinkClient extends TcpLink;

var AEPlayerController  PC;

var string  TargetHost;
var int     TargetPort;

var string  path;
var string  requestText;
var int     score;
var bool    send;

event PostBeginPlay()
{
	super.PostBeginPlay();
}

function ResolveMe()
{
	Resolve(TargetHost);
}

event Resolved( IpAddr Addr )
{
	// The hostname was resolved succefully
	`Log("[TcpClient] " $TargetHost$ " resolved to " $IpAddrToString(Addr));

	// Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
	Addr.Port = TargetPort;

	//dont comment out this log because it rungs the function bindport
	`Log("[TcpLinkClient] Bound to port: " $BindPort(TargetPort) );
	if(!Open(Addr))
	{
		`Log("[TcpLinkClient] Open Failed");
	}
}

event ResolvedFailed()
{
	`Log("[TcpLinkClient] Unable to resolve "$TargetHost);
    // You could retry resolving here if you have an alternative
    // remote host.
}

event Opened()
{
	// A connection was established
    `Log("[TcpLinkClient] event opened");
    `Log("[TcpLinkClient] Sending simple HTTP query");
     
    //The HTTP GET request
    //char(13) and char(10) are carrage returns and new lines
	if(!send)
	{
		//SendText(1);
		//SendText("GET" $path);
		SendText( "GET /" $ path $ " HTTP/1.1" );
		SendText( chr(13)$chr(10) );

		//SendText( "Host: " $ TargetHost );
		//SendText( chr(13)$chr(10) );

		SendText( "end" );
		SendText(chr(13)$chr(10) $ chr(13)$chr(10));
	}
	else if ( send && score > 0)
	{
		`log("fhaldkjfhglkjadhfgkljhadflkhglakdfg");
		requestText = "value="$score$"&submit=10987";
		
		SendText("POST /"$path$" HTTP/1.0"); CarrageReturn();
		SendText("Host: "$TargetHost); CarrageReturn();
		SendText("User-Agent: HTTPTool/1.0"); CarrageReturn();
		SendText("Content-Type: application/x-www-form-urlencoded"); CarrageReturn();
		
		SendText("Content-Length: "$len(requestText)); CarrageReturn();
		CarrageReturn();
		SendText(requestText);
		CarrageReturn();
		SendText("Connection: Close");
		CarrageReturn(); CarrageReturn();

	}

	`Log("[TcpLinkClient] end HTTP query");
}

event Closed()
{
	// In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
	`Log("[TcpLickClient] event closed");

	// After the connection was closed we could establish a new
    // connection using the same TcpLink instance.
}

event ReceivedText( string Text )
{
	// receiving some text, note that the text includes line breaks
	`log("[TcpLinkClient] ReceivedText:: " $Text);

	//we dont want the header info, so we split the string after two new lines
	Text = Split(Text, "chr(13)$chr(10)chr(13)$chr(10)", true);
	`log("[TcpLinkClient] SplitText:: " $Text);

	if(!send)
	{
		send = true;
	}
}

function CarrageReturn()
{
	SendText(chr(13)$chr(10));
}

DefaultProperties
{
	TargetHost = "www.geirhilmersen.com";
	TargetPort = 8080;

	path = "missions";
	score = 1;
	send = false;
}
