// THIS CLASS IS RESPONSIBLE FOR SERVER COMMUNICATION.
class AETcpLinkClient extends TcpLink
	dependson(AEJSONParser);

//-----------------------------------------------------------------------------
// Structures

/** PlayerStruct holds various information about the player from server. */
struct PlayerStruct
{
	var string name;
	var string mail;
	var int id;
};

//-----------------------------------------------------------------------------
// Varialbes

/** Reference to the player controller. */
var AEPlayerController  PC;

var WebRequest Request;

/** Player information */
var string UserName;
var string Password;
var string UserNameAndPassword;
var string AuthenticationKey;

/** Server (hostname/IP-address) */
var string  TargetHost;

/** Server's port used for game communication. */
var int     TargetPort;

/** Database path to the info needed to generate a weapon. */
var string  get;
var string  databasePath;

/** Message that the player sends to the server. */
var string  requestText;

/** The score the player has. */
var int     score;

/** Variable that checks if the player is ready to communicate with the server. */
var bool    send;

/** Information that the player receives from the server. */
var string          returnedMessage;
var array<string>   returnedArray;

/** Token we use to connect to server. */
var PlayerStruct    playerInfo;
var bool            bLogedIn;
var bool            bHavePlayerInfo;
var string          token;

/** Booleans needed to not spam the server for requests. */
var bool            bWaitingForMissions;
var bool            bWaitingForMission;
var bool            bWaitingForWeapon;
var bool            bWaitingForReward;
var bool            bWaitingForPath;


//-----------------------------------------------------------------------------
// Init

/** Initializations before any pawns spawn on the map. */
simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	//CreateResponseObject();

	Request = new(None) class'WebRequest';
}


//-----------------------------------------------------------------------------
// Connection

/** Connect to server with preset path and command. */
function ResolveMe()
{
	PC.mHUD.postError(databasePath);
	Resolve(TargetHost);
}

/** Successfully connected to a server. */
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

/** Failed to connect to the server. */
event ResolvedFailed()
{
	`Log("[TcpLinkClient] Unable to resolve "$TargetHost);
    // You could retry resolving here if you have an alternative
    // remote host.
}

/** Established a connection with the server's port. */
event Opened()
{
	`Log("[TcpLinkClient] Event opened.");

	// A connection was established
	`Log("[TcpLinkClient] Sending simple HTTP query.");

	if (!send)
	{
		SendText(get $ databasePath $ "?username=" $ UserName $ "&password=" $ Password );
		CarriageReturn(); 

		SendText( "Connection: close" );
		CarriageReturn(); CarriageReturn();
		
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
		*/
	}

	`Log("[TcpLinkClient] end HTTP query");
}

/** Closed connection to server */
event Closed()
{
	// In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
	`Log("[TcpLickClient] event closed");

	// After the connection was closed we could establish a new
    // connection using the same TcpLink instance.
}

event ReceivedLine(string Line)
{
	`log("dsaasddsa: " $ Line);
}

/** Receives the text from server. Runs automaticly when server send info to us. */
event ReceivedText(string Text)
{
	local string tempString;
	// receiving some text, note that the text includes line breaks
	//`log("[TcpLinkClient] ReceivedText:: " $Text);

	tempString = Text;

	if (Text == "HTTP Basic: Access denied.\n")
	{
		`log("[TcpLinkClient] Wrong username or password");
		return;
	}
	else
	{
		ReadText( Text );

		// To removed double sendings and pick up seperated packages
		if(len(Text) != 0)
		{
			if(Text != tempString)
				Text = tempString $ Text;
			else
				Text = tempString;
		}
		else
			Text = tempString;

		returnedMessage = Text;
		
		if (bWaitingForMission)
		{
			PC.InitializeMission( Text );
			bWaitingForMission = false;
		}
		else if (bWaitingForWeapon)
		{
			PC.EquipLoadout(Text);
			bWaitingForWeapon = false;
		}
		else if (bWaitingForReward)
		{
			`log("[TCP] NEED CODE OR REMOVE");
			bWaitingForReward = false;
		}
		else if (bWaitingForPath)
		{
			//parseString(Text);
			PC.myMenu.stringFromServer( Text );
			bWaitingForPath = false;
		}
		else if (bWaitingForMissions)
		{
			PC.myDataStorage.setMissions(PC.parser.fullParse(Text));
			PC.myMainMenu.UpdateMissionMenu();
			bWaitingForMissions = false;
		}
	}
}

/** Returns "space newline" * So we can send new command to server */
function CarriageReturn()
{
	SendText(chr(13)$chr(10));
}


//-----------------------------------------------------------------------------
// User Commands

/** Player logs in to the server to be able to get list of items and info to player. */
function logIn(string user, string pw)
{
	// The clan name "McDonald" is hardcoded, and this bit of code
	// should be more dynamic to allow players from other clans
	// to also log in.
	databasePath = "soldiers";
	Username = user;
	Password = pw;

	UserNameAndPassword = user $ ":" $ password;
	AuthenticationKey = Request.EncodeBase64(UserNameAndPassword);

	ResolveMe();
}

/** Gets mission with set ID */
function getMission(int id)
{
	databasePath = "missions/" $ id;
	bWaitingForMission = true;

	ResolveMe();
}

/** Get Missons to graphical menu */
function getMissions(string path)
{
	databasePath = path;
	bWaitingForMissions = true;

	ResolveMe();
}

/** Get weapon from server with set ID */
function getWeapon()
{
	databasePath = "soldiers/1/items";
	bWaitingForWeapon = true;

	ResolveMe();
}

/** Get reward from server with set ID */
function getReward(int id)
{
	databasePath = "rewards/" $ id;
	bWaitingForReward = true;

	ResolveMe();
}

/** Get menu list from preset Path */
function getMenuSelections()
{
	bWaitingForPath = true;

	ResolveMe();
}


//-----------------------------------------------------------------------------
// Parsing

function array<string> parseToArray(string jsonString)
{
	local array<string> returnString;

	// Removes the first character of the text and keeps the rest.
	jsonString = mid( jsonString, 0, len( jsonString ) - 1 );

	// Splits the string to set categories
	returnString = SplitString(jsonString, ",");

	return returnString;
}

//-----------------------------------------------------------------------------
// User properties

/** Set player info with the string from server */
function setUserInfo(string info)
{
	local array<string> userInfo;
	local array<string> splitted;
	local int i;

	// Parses the properties of the JSON objects into elements in an array.
	userInfo = parseToArray(info);

	for( i = 0; i < userInfo.Length; i++)
	{
		// Parses each element into two sub-elements.
		// EXAMPLE: name: McLeod
		// splitted[0] = name, splitted[1] = McLeod
		splitted = SplitString(userInfo[i], ":");

		// Gets the first sub-element, such as "name" from "name: "
		splitted[0] = mid(splitted[0], 1, len(splitted[0]) - 2 );

		if          (splitted[0] == "name")         {  playerInfo.name =    mid( splitted[1], 1, len(splitted[1]) - 3); bLogedIn = true; }
		else if     (splitted[0] == "account_id")   {  playerInfo.id   =    int( splitted[1] ); }
		else if     (splitted[0] == "email")        {  playerInfo.mail =    mid( splitted[1], 1, len(splitted[1]) - 2); }
	}

	if (!bLogedIn)
	{
		`log("[TcpLinkClient] Log in failed");
		ResolveMe();
	}
	else
	{
		`log("[TcpLinkClient] Log in accepted");
		PC.mHUD.addUserInfo("Name : " $ playerInfo.name);
	}
}

DefaultProperties
{
	UserName="McDonald"
	Password="secret"
	UserNameAndPassword = "McDonald:secret";
	AuthenticationKey = "";

	LinkMode = MODE_Line;
	
	//TargetHost = "pure-effect.herokuapp.com" // Other host
	//TargetPort = 80
	TargetHost = "www.geirhilmersen.com";
	TargetPort = 8080;

	databasePath = "[{\"category\":\"Search and destroy\",\"city_id\":1,\"created_at\":\"2013-01-25T13:30:34Z\",\"description\":\"Regain loot\",\"id\":1,\"title\":\"Marauders\",\"updated_at\":\"2013-01-25T13:30:34Z\",\"items\":[{\"created_at\":\"2013-01-25T13:30:34Z\",\"id\":1,\"name\":\"Rocket launcher\",\"owner_id\":1,\"owner_type\":\"Mission\",\"properties\":{\"damage\":150,\"speed\":400,\"range\":1000,\"spread\":1.5,\"fire_rate\":3,\"clip_size\":1,\"reload_speed\":3,\"ammo_pool\":8},\"slot\":\"weapon\",\"updated_at\":\"2013-01-25T13:30:34Z\"}]},"
	get = "GET /api/"

	returnedMessage = "";

	token = "Authorization: Basic 0d9cc5ab64b8e3d2edbc616ef255cc28=";
	score = 1;
	send = false;
}
