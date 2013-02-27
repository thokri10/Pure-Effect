/** Main game class. */
class ActionEffectGame extends UTTeamGame;

//var class<AEAIEscortBotController> dasdassa;
//var AEAIEscortBotController doasdpas;

/** Overrode this function. Currently doesn't do anything special. */
function PostBeginPlay()
{
	super.PostBeginPlay();
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

	//bPlayersVsBots = true
	bAutoNumBots = false
	DesiredPlayerCount = 0
	bTeamGame=true
	
	//dasdassa = class'AEAIEscortBotController';
}