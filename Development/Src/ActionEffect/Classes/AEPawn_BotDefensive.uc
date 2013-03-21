class AEPawn_BotDefensive extends AEPawn_Bot;

simulated function AddDefaultInventory()
{
	local UTWeapon weap;

	//weap = AEPlayerController( GetALocalPlayerController() ).myWeaponCreator.CreateWeapon("rocket", 0, 1000, 0.1, 1, 500);
	//InvManager.AddInventory(weap);

	//weap = AEPlayerController( GetALocalPlayerController() ).myWeaponCreator.CreateWeapon("shockRifle", 0, 100, 0.1, 1, 500);
	//InvManager.AddInventory(weap);
}

DefaultProperties
{
	ControllerClass=class'AEAIController_Defensive'
}
