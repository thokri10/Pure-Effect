/** Main game class. */
class ActionEffectGame extends UTTeamGame;

var bool initialized;

var bool bInitMission;
var int missionToStart;

var int AETeamID;

var AEPlayerController PC;

/** Replication info for multiplayer. Keeps track over the different objectives and time */
var AEReplicationInfo myReplicationInfo;

function PostBeginPlay()
{
	super.PostBeginPlay();

	myReplicationInfo = Spawn(class'AEReplicationInfo', self);
}

event InitGame(string Options, out string ErrorMessage)
{
	local string InOpt;

	super.InitGame(Options, ErrorMessage);

	InOpt = ParseOption(Options, "MissionID");
	if( InOpt != "" )
	{
		bInitMission = true;
		missionToStart = int(InOpt);
		`log("START MISSION : " $ InOpt );
	}
	InOpt = ParseOption(Options, "TeamID");
	if( InOpt != "" )
	{
		AETeamID = Int( InOpt );
		`log("SET TEAM : " $ AETeamID);
	}
}

function PlayerController SpawnPlayerController(vector SpawnLocation, rotator SpawnRotation)
{
	local PlayerController retPC;

	retPC = super.SpawnPlayerController(SpawnLocation, SpawnRotation);

	if(PC == None)
	{
		PC = AEPlayerController( retPC );

		if(PC != none)
		{
			PC.myGame = self;
			PC.myReplicationInfo = myReplicationInfo;

			if(bInitMission)
			{
				PC.InitMission(missionToStart);
			}
		}
	}

	return retPC;
}

event Tick(float DeltaTime)
{
	local AEVolume_BotSpawn target;
	if(!initialized)
	{
		// EMIL BOT SPAWN
		foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
		{
			target.spawnBot(class'AEPawn_BotDefensive', self);
			break;
		}

		initialized = true;
	}
}

DefaultProperties
{
	// Initializations of various variables.
	PlayerControllerClass = class'ActionEffect.AEPlayerController';
	DefaultPawnClass = class'ActionEffect.AEPawn_Player';
	
	bDelayedStart = false;
	bCustomBots = true;
	
	// EDIT: !!! FOR BOT TESTING REMOVE THIS WHEN DONE !!!
	bForceAllRed=false

	HUDType = class'AEHUD';
	bUseClassicHUD = true;

	bAutoNumBots = false
	DesiredPlayerCount = 0
	bTeamGame=true

	bPlayersBalanceTeams = false;	
}