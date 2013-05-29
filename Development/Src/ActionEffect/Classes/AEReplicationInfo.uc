class AEReplicationInfo extends ReplicationInfo
	placeable;

//---------------------------
// Game Info

var float GameTimer;

//---------------------------
// RED TEAM : TEAM ID 0
/** Team that controlls the red Engine room */
var private int HoldingRedEngine;

/** Score keeps track of how many sicadas has been destroyed */
var private int redTeamScore;

//---------------------------
// BLUE TEAM : TEAM ID 1
/** Team that controlls the red Engine room */
var private int HoldingBlueEngine;

/** Score keeps track of how many sicadas has been destroyed */
var private int blueTeamScore;

replication
{
	if(bNetDirty && Role == ROLE_Authority)
		GameTimer, HoldingRedEngine, redTeamScore, HoldingBlueEngine, blueTeamScore;
}

function addScore(int teamID)
{
	if(teamID == 0)
		--redTeamScore;
	else
		--blueTeamScore;

	if(redTeamScore <= 0)
	{
		///ConsoleCommand("open MenuMap");
		//ConsoleCommand("open AE-MenuMap");
		if(Flee(0)){
			`log("RED TEAM FLEE");
			//ConsoleCommand("open AE-MenuMap");
		}
	}
	if(blueTeamScore <= 0)
	{
		//ConsoleCommand("open MenuMap");
		//ConsoleCommand("open AE-MenuMap");
		if(Flee(1)){
			`log("BLUE TEAM FLEE");
			//ConsoleCommand("open AE-MenuMap");
		}
	}
}

function GetInfo(out int RedOwner, out int BlueOwner, out int redScore, out int blueScore)
{
	RedOwner = HoldingRedEngine;
	BlueOwner = HoldingBlueEngine;
	redScore = redTeamScore;
	blueScore = blueTeamScore;
}

function bool Flee(int team)
{
	if(team == 0){
		`log("RED TEAM");
		if(HoldingRedEngine == 0){
			`log("RED FLEE");
			return true;
		}
	}
	else{
		`log("BLUE TEAM");
		if(HoldingBlueEngine == 1){
		`log("BLUE FLEE");
			return true;
		}
	}
	return false;
}

function ChangeOwnerToEngine(const int TeamEngineOwner, int ChangeToOwner)
{
	if(ChangeToOwner > 1)
		ChangeToOwner = 1;

	if(TeamEngineOwner == 0)
		HoldingRedEngine = ChangeToOwner;
	else
		HoldingBlueEngine = ChangeToOwner;

	UpdateClients();
}

function Tick(float DeltaTime)
{
	if(GameTimer > 0)
		GameTimer -= DeltaTime;
	else{
		GameTimer = 0;
		`log("TIMER IS OVER");
	}
}

function float getGameTime()
{
	return GameTimer;
}

simulated function UpdateClients()
{
	local AEPlayerController C;

	foreach WorldInfo.AllControllers(class'AEPlayerController', C)
	{
		`log("Updated client: " $ C);
		C.bObjectivesUpdated = true;
	}
}

DefaultProperties
{
	HoldingRedEngine = 0;
	HoldingBlueEngine = 1;

	GameTimer = 300;

	redTeamScore = 10;
	blueTeamScore = 10;

	RemoteRole=ROLE_MAX
}
