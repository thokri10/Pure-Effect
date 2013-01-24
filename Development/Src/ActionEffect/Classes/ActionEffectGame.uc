// PURPOSE: Main game class.
class ActionEffectGame extends UTGame;

defaultproperties
{
	// Initializes the player and the belonging controller.
	PlayerControllerClass = class'ActionEffect.AEPlayerController';
	DefaultPawnClass = class'ActionEffect.AEPawn_Player';

	// Intializes the HUD.
	HUDType = class'AEHUD';
	bUseClassicHUD = true;
}