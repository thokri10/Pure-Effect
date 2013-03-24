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
		++redTeamScore;
	else
		++blueTeamScore;
}

function bool RedTeamFlee()
{
	if(HoldingRedEngine == 0)
		return true;
	return false;
}

function bool BlueTeamFlee()
{
	if(HoldingBlueEngine == 1)
		return true;
	return false;
}

function ChangeOwnerToEngine(const int TeamEngineOwner, int ChangeToOwner)
{
	if(TeamEngineOwner == 0)
		HoldingRedEngine = ChangeToOwner;
	else
		HoldingBlueEngine = ChangeToOwner;

	UpdateClients();
}

function Tick(float DeltaTime)
{
	GameTimer += DeltaTime;
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

	redTeamScore = 0;
	blueTeamScore = 0;

	RemoteRole=ROLE_MAX
}
