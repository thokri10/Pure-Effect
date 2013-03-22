class AEReplicationInfo extends ReplicationInfo
	placeable;

//---------------------------
// Game Info

var float GameTimer;

//---------------------------
// RED TEAM : TEAM ID 0
/** Team that controlls the red Engine room */
var int HoldingRedEngine;

/** Score keeps track of how many sicadas has been destroyed */
var int redTeamScore;

//---------------------------
// BLUE TEAM : TEAM ID 1
/** Team that controlls the red Engine room */
var int HoldingBlueEngine;

/** Score keeps track of how many sicadas has been destroyed */
var int blueTeamScore;

replication
{
	if(bNetDirty)
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

function changeBlueEngine(int teamID)
{
	HoldingBlueEngine = teamID;
	if(Role < ROLE_Authority)
		ServerChangeBlueEngine(teamID);
}

reliable server function ServerChangeBlueEngine(int teamID)
{
	if(Role < ROLE_Authority)
		return;

	HoldingBlueEngine = teamID;
}

function changeRedEngine(int teamID)
{
	HoldingRedEngine = teamID;

	if(Role < ROLE_Authority)
		ServerChangeRedEngine(teamID);
}

reliable server function ServerChangeRedEngine(int teamID)
{
	if(Role < ROLE_Authority)
		return;

	HoldingRedEngine = teamID;
}

function Tick(float DeltaTime)
{
	GameTimer += DeltaTime;
}

DefaultProperties
{
	HoldingRedEngine = 0;
	HoldingBlueEngine = 1;

	redTeamScore = 0;
	blueTeamScore = 0;

	RemoteRole=ROLE_MAX
}
