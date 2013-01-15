// THIS CLASS IS RESPONSIBLE FOR SERVER COMMUNICATION.
class AETcpLinkClient extends TcpLink;

// Reference to the player controller.
var AEPlayerController  PC;

// Server (hostname/IP-address)
var string  TargetHost;

// Server's port used for game communication.
var int     TargetPort;

// Database path to the info needed to generate a weapon.
var string  databasePath;

// Message that the player sends to the server.
var string  requestText;

// The score the player has.
var int     score;

// Variable that checks if the player is ready to communicate with the server.
var bool    send;

// Information that the player receives from the server.
var string  returnedMessage;

// Our WeaponStruct that will contain all the variables for our weapon. 
// Default variables is now set by server.
struct WeaponStruct
{
	var int     id;
	var string  type;
	var float   spread;
	var float   reloadTime;
	var int     magSize;
};

// Initializations before any pawns spawn on the map.
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

// Connect to server.
function ResolveMe()
{
	Resolve(TargetHost);
}

// Successfully connected to a server.
event Resolved( IpAddr Addr )
{
	// Log that the hostname was resolved successfully.
	`Log("[TcpClient] " $TargetHost$ " resolved to " $IpAddrToString(Addr));

	// Make sure the correct remote port is set. Resolving doesn't set
    // the port value of the IpAddr structure.
	Addr.Port = TargetPort;

	// Connects to a designated port (see DefaultProperties for which port)
	// DO NOT comment out this log because it rungs the function bindport.
	`Log("[TcpLinkClient] Bound to port: " $BindPort(TargetPort) );
	
	// Logs if player cannot connect to a server port.
	if(!Open(Addr))
	{
		`Log("[TcpLinkClient] Open Failed");
	}
}

// Failed to connect to the server.
event ResolvedFailed()
{
	`Log("[TcpLinkClient] Unable to resolve "$TargetHost);
    // You could retry resolving here if you have an alternative
    // remote host.
}

// Established a connection with the server's port.
event Opened()
{
	// A connection was established
    `Log("[TcpLinkClient] Event opened.");
    `Log("[TcpLinkClient] Sending simple HTTP query.");
     
    //The HTTP GET request
    //char(13) and char(10) are Carriage returns and new lines
	if(!send)
	{
		//SendText(1);
		//SendText("GET" $databasePath);
		SendText( "GET /" $ databasePath);
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
		
		SendText("POST /"$databasePath$" HTTP/1.0"); CarriageReturn();
		SendText("Host: "$TargetHost); CarriageReturn();
		SendText("User-Agent: HTTPTool/1.0"); CarriageReturn();
		SendText("Content-Type: application/x-www-form-urlencoded"); CarriageReturn();
		
		SendText("Content-Length: "$len(requestText)); CarriageReturn();
		CarriageReturn();
		SendText(requestText);
		CarriageReturn();
		SendText("Connection: Close");
		CarriageReturn(); CarriageReturn();

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
	local string weaponDebugLog;

	weaponDebugLog = "\n";

	in = mid( in, 1, len( in ) - 1 );
	// Splits the string to set categories
	tempString = SplitString(in, ",");
	for(i = 0; i < tempString.Length; i++)
	{
		// Now we split it one more time to get type and value 
		tempString2 = SplitString(tempString[i], ":");
		// Removes both the ' " ' from the string so we can read it properly
		tempString2[0] = mid( tempString2[0], 1, len( tempString2[0] ) - 2 );

		// Now we check if any of the preset variables we have exist in this json
		if      (tempString2[0] == "id")            Weap.id         = int   ( tempString2[1] );         
		else if (tempString2[0] == "mag_size")      Weap.magSize    = int   ( tempString2[1] );
		else if (tempString2[0] == "reload_time")   Weap.reloadTime = float ( tempString2[1] );
		else if (tempString2[0] == "spread")        Weap.spread     = float ( tempString2[1] );
		else if (tempString2[0] == "name")          Weap.type       = mid( tempString2[1], 1, len( tempString2[1] ) - 2 );    
	}

	weaponDebugLog = weaponDebugLog $ "Weapon ID: "                 $ Weap.id $             "\n"
									$ "Magazine size: "             $ Weap.magSize $        "\n"
									$ "Reload time (seconds): "     $ Weap.reloadTime $     "\n"
									$ "Spread: "                    $ Weap.spread $         "\n"
									$ "Weapon type: "               $ Weap.type $           "\n";

	`Log("Weapon generated:" $ weaponDebugLog);

	return Weap;
}

// return "space newline"
function CarriageReturn()
{
	SendText(chr(13)$chr(10));
}

DefaultProperties
{
	TargetHost = "www.geirhilmersen.com";
	TargetPort = 8080;

	databasePath = "api/weapons/1.json";

	returnedMessage = "{\"created_at\":\"2013-01-12T00:16:44Z\",\"id\":1,\"magsize\":\"20\",\"reload_time\":\"0.1\",\"spread\":\"0.5\",\"updated_at\":\"2013-01-12T00:16:44Z\",\"weapon_type\":\"rocket\"}";

	score = 1;
	send = false;
}
