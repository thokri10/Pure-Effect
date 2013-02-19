/** Main game class. */
class ActionEffectGame extends UTGame;

function PostBeginPlay()
{
	//local AENavigationPoint_EscortBotSpawn spawnPoint; 
	//local AENavigationPoint_EscortBotSpawn target;

	super.PostBeginPlay();
	
	`Log("CUNTSAAAAAAAAAAAAAAAAAAACK!");

	//foreach WorldInfo.AllActors( class'AENavigationPoint_EscortBotSpawn', target )
	//{
	//	spawnPoint = target;
	//	//spawnPoint.Spawn('AEPawn_Bot');
	//	`Log("LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOL");
	//}
}

/** Spawn and initialize a bot. */   
function UTBot SpawnBot(optional string botName,optional bool bUseTeamIndex, optional int TeamIndex)
{
	local UTBot NewBot;
	local UTTeamInfo BotTeam;
	local CharacterInfo BotInfo; 
 
	BotTeam = GetBotTeam(,bUseTeamIndex,TeamIndex);
	BotInfo = BotTeam.GetBotInfo(botName);
 
    //JTC - the below two lines are the only line changes from the original for our version of the function
    LogInternal("New SpawnBot");
	NewBot = Spawn(class'AEAIController');
 
	if ( NewBot != None )
	{
		InitializeBot(NewBot, BotTeam, BotInfo);
 
		if (BaseMutator != None)
		{
			BaseMutator.NotifyLogin(NewBot);
		}
	}
 
	return NewBot;
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
}