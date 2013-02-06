// PURPOSE: Main game class.
class ActionEffectGame extends UTGame;

/* Spawn and initialize a bot
*/   
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

defaultproperties
{
	// Initializes the player and the belonging controller.
	PlayerControllerClass = class'ActionEffect.AEPlayerController';
	DefaultPawnClass = class'ActionEffect.AEPawn_Player';
	
	
	BotClass=class'AEAIController'
	bCustomBots=true

	// Intializes the HUD.
	HUDType = class'AEHUD';
	bUseClassicHUD = true;
}