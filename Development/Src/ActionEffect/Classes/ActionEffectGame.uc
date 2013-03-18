/** Main game class. */
class ActionEffectGame extends UTTeamGame;

var bool initialized;

var bool bInitMission;
var int missionToStart;


function PostBeginPlay()
{
	super.PostBeginPlay();
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
}

event Tick(float DeltaTime)
{
	local AEVolume_BotSpawn target;
	if(!initialized)
	{
		// TODO: Fix so that it works for multiplayer.
		if(AEPlayerController( GetALocalPlayerController() ).myGame == none){
			initialized = true;
			AEPlayerController( GetALocalPlayerController() ).myGame = self;

			if(bInitMission)
				AEPlayerController( GetALocalPlayerController() ).InitMission(missionToStart);
		}

		/* EMIL BOT SPAWN
		foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
		{
			target.spawnBot(class'AEPawn_BotDefensive', self);
			break;
		}
		*/
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
	bForceAllRed=true

	HUDType = class'AEHUD';
	bUseClassicHUD = true;

	bAutoNumBots = false
	DesiredPlayerCount = 0
	bTeamGame=true
	
}