class AEReplicationInfo extends ReplicationInfo;

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

simulated event ReplicatedEvent(name VarName)
{
	`log(VarName);
}

reliable server function bool ServerRedTeamFlee()
{
	if(HoldingRedEngine == 0)
		return true;
	return false;
}

reliable server function bool ServerBlueTeamFlee()
{
	if(HoldingBlueEngine == 1)
		return true;
	return false;
}

reliable server function ServerChangeBlueEngine(int teamID)
{
	HoldingBlueEngine = teamID;
}

reliable server function ServerChangeRedEngine(int teamID)
{
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

	redTeamScore = 40;
	blueTeamScore = 40;
}
