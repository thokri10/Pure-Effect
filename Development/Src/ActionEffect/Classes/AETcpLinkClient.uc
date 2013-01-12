class AETcpLinkClient extends TcpLink;

var AEPlayerController  PC;

var string  TargetHost;
var int     TargetPort;

var string  path;
var string  requestText;
var int     score;
var bool    send;

var string  returnedMessage;

// Our WeaponStruct that will contain all the variables for our weapon. 
// Default variables is now set by server.
struct WeaponStruct
{
	var int     id;
	var string  type;
	var float   spread;
	var float   reloadTime;
	var int     magsize;
};

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
		SendText( "GET /" $ path);
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

// Receives the text from server. Runs automaticly when server send info to us.
event ReceivedText( string Text )
{
	// receiving some text, note that the text includes line breaks
	`log("[TcpLinkClient] ReceivedText:: " $Text);

	returnedMessage = Text;

	//we dont want the header info, so we split the string after two new lines
	//Text = Split(Text, "chr(13)$chr(10)chr(13)$chr(10)", true);
	//`log("[TcpLinkClient] SplitText:: " $Text);

	if(!send)
	{
		send = true;
	}
}

// Returns a weaponStruct from a json message from server
function WeaponStruct parseStringToWeapon(string in)
{
	local WeaponStruct  Weap;
	local array<string> tempString;
	local array<string> tempString2;
	local int i;

	// Splits the string to set categories
	tempString = SplitString(in, ",");

	for(i = 0; i < tempString.Length; i++)
	{
		// Now we split it one more time to get type and value 
		tempString2 = SplitString(tempString[i], ":");
		// Removes both the ' " ' from the string so we can read it properly
		tempString2[0] = mid( tempString2[0], 1, len( tempString2[0] ) - 2 );

		// Now we check if any of the preset variables we have exist in this json
		if     (tempString2[0] == "id")             Weap.id         = int   (       tempString2[1] );
		else if(tempString2[0] == "magsize")        Weap.magsize    = int   (  mid( tempString2[1], 1, len( tempString2[1] ) - 1 ) );
		else if(tempString2[0] == "reload_time")    Weap.reloadTime = float (  mid( tempString2[1], 1, len( tempString2[1] ) - 1 ) );
		else if(tempString2[0] == "spread")         Weap.spread     = float (  mid( tempString2[1], 1, len( tempString2[1] ) - 1 ) );
		else if(tempString2[0] == "weapon_type")    Weap.type       =          mid( tempString2[1], 1, len( tempString2[1] ) - 3 );

		/* Some problems with switch did not work as intended
		switch(tempString2[0])
		{
		case "id": Weap.id = int( tempString2[1] ); break;
		case "magsize": `log( "asdasdasdasdasd " $ mid( tempString2[1], 1, len( tempString2[1] ) - 1 ) ); break; //Weap.magsize = int( mid( tempString2[1], 1, len( tempString2[1] ) - 1 ) ); break;
		case "reload_time": Weap.reloadTime = int( mid( tempString2[1], 1, len( tempString2[1] ) - 1 ) ); break;
		case "spread": Weap.spread = int( mid( tempString2[1], 1, len( tempString2[1] ) - 1 ) ); break;
		case "weapon_type": Weap.type = tempString2[1];  break; //mid( tempString2[1], 1, len( tempString2[1] ) - 1 ); break;
		}
		*/
	}

	return Weap;
}

// return "space newline"
function CarrageReturn()
{
	SendText(chr(13)$chr(10));
}

DefaultProperties
{
	TargetHost = "www.geirhilmersen.com";
	TargetPort = 8080;

	path = "weapons/1.json";

	returnedMessage = ""; //"{\"created_at\":\"2013-01-12T00:16:44Z\",\"id\":1,\"magsize\":\"20\",\"reload_time\":\"0.1\",\"spread\":\"0.5\",\"updated_at\":\"2013-01-12T00:16:44Z\",\"weapon_type\":\"rocket\"}"

	score = 1;
	send = false;
}
