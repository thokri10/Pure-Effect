// THIS CLASS IS RESPONSIBLE FOR SERVER COMMUNICATION.
class AETcpLinkClient extends TcpLink;

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

struct PlayerStruct
{
	var string name;
	var string mail;
	var int id;
};

// Reference to the player controller.
var AEPlayerController  PC;

// Server (hostname/IP-address)
var string  TargetHost;

// Server's port used for game communication.
var int     TargetPort;

// Database path to the info needed to generate a weapon.
var string  get;
var string  databasePath;

// Message that the player sends to the server.
var string  requestText;

// The score the player has.
var int     score;

// Variable that checks if the player is ready to communicate with the server.
var bool    send;

// Information that the player receives from the server.
var string          returnedMessage;
var array<string>   returnedArray;

// Token we use to connect to server.
var PlayerStruct    playerInfo;
var bool            bLogedIn;
var bool            bHavePlayerInfo;
var string          token;

var bool            bWaitingForMission;
var bool            bWaitingForWeapon;
var bool            bWaitingForReward;

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
	`Log("[TcpLinkClient] Event opened.");

	if(bLogedIn)
	{
		// A connection was established
		`Log("[TcpLinkClient] Sending simple HTTP query.");

		if(!send)
		{
			`log("Path::::::::::: " $ get $ databasePath );
			SendText( get $ databasePath );
			CarriageReturn();

			SendText("Connection: Close");
			CarriageReturn(); CarriageReturn();
			//The HTTP GET request
			//char(13) and char(10) are Carriage returns and new lines
		}
		else if ( send && score > 0)
		{
			/*
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
			*/

		}

		`Log("[TcpLinkClient] end HTTP query");
	}else{
		`log("[TcpLinkClient] Please log in");
	}
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
	
	if(bLogedIn)
	{
		returnedMessage = Text;
		returnedArray = parseToArray(Text);

		//we dont want the header info, so we split the string after two new lines
		//Text = Split(Text, "chr(13)$chr(10)chr(13)$chr(10)", true);
		//`log("[TcpLinkClient] SplitText:: " $Text);
		
		if(bWaitingForMission)
		{
			PC.myMissionObjective.Initialize(returnedArray);
			bWaitingForMission = false;
		}else if(bWaitingForWeapon)
		{
			PC.serverWeaponCreator(Text);
			bWaitingForWeapon = false;
		}else if(bWaitingForReward)
		{
			PC.mHUD.postError(Text);
			bWaitingForReward = false;
		}
	}else{
		setUserInfo(Text);
	}
}

function logIn(string user, string password)
{
	SendText( "GET /api/accounts/" $ user $ ".json" );
	CarriageReturn(); CarriageReturn();
}

function getMission(int id)
{
	if(bLogedIn)
	{
		databasePath = "missions/" $ id $ ".json";
		bWaitingForMission = true;

		ResolveMe();
	}
}

function getWeapon(int id)
{
	if(bLogedIn)
	{
		databasePath = "weapons/" $ id $ ".json";
		bWaitingForWeapon = true;

		ResolveMe();
	}
}

function getReward(int id)
{
	if(bLogedIn)
	{
		databasePath = "rewards/" $ id $ ".json";
		bWaitingForReward = true;

		ResolveMe();
	}
}

function array<string> parseToArray(string jsonString)
{
	local array<string> returnString;
	local int i;

	jsonString = mid( jsonString, 1, len( jsonString ) - 1 );
	// Splits the string to set categories
	returnString = SplitString(jsonString, ",");

	for(i = 0; i < returnString.Length; i++)
	{
		`log("[Parsing] " $returnString[i]);
	}

	return returnString;
}

function setUserInfo(string info)
{
	local array<string> userInfo;
	local array<string> splitted;
	local int i;

	userInfo = parseToArray(info);

	for( i = 0; i < userInfo.Length; i++)
	{
		splitted = SplitString(userInfo[i], ":");

		splitted[0] = mid(splitted[0], 1, len(splitted[0]) - 2 );

		if(splitted[0] == "clan_name"){  playerInfo.name = mid( splitted[1], 1, len(splitted[1]) - 3); bLogedIn = true; }
		else if(splitted[0] == "id")    playerInfo.id =   int( splitted[1] );
		else if(splitted[0] == "email") playerInfo.mail = mid( splitted[1], 1, len(splitted[1]) - 2);
	}

	if(!bLogedIn){
		`log("[TcpLinkClient] Log in failed");
		ResolveMe();
	}else{
		`log("[TcpLinkClient] Log in accepted");
		PC.mHUD.addUserInfo("Name : " $ playerInfo.name);
	}

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

	databasePath = ""
	get = "GET /api/"

	returnedMessage = "";//"{\"created_at\":\"2013-01-12T00:16:44Z\",\"id\":1,\"magsize\":\"20\",\"reload_time\":\"0.1\",\"spread\":\"0.5\",\"updated_at\":\"2013-01-12T00:16:44Z\",\"weapon_type\":\"rocket\"}";

	token = "Authorization: Basic 0d9cc5ab64b8e3d2edbc616ef255cc28=";
	score = 1;
	send = false;
}
