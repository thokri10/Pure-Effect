/** Main game class. */
class ActionEffectGame extends UTTeamGame;

var bool initialized;

function PostBeginPlay()
{
	super.PostBeginPlay();
}

event Tick(float DeltaTime)
{
	if(!initialized)
	{
		if(AEPlayerController( GetALocalPlayerController() ).myGame == none)
			AEPlayerController( GetALocalPlayerController() ).myGame = self;
	}
}

DefaultProperties
{
	// Initializations of various variables.
	PlayerControllerClass = class'ActionEffect.AEPlayerController';
	DefaultPawnClass = class'ActionEffect.AEPawn_Player';
	
	bDelayedStart = false;
	BotClass = class'AEAIController';
	bCustomBots = true;

	HUDType = class'AEHUD';
	bUseClassicHUD = true;

	bAutoNumBots = false
	DesiredPlayerCount = 0
	bTeamGame=true
}