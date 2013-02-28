class AEPawn_BotAgressive extends AEPawn_Bot;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

function AddDefaultInventory()
{
	local UTWeapon rocket;

	rocket = AEPlayerController( GetALocalPlayerController() ).myWeaponCreator.CreateWeapon("rocket", 0.1f, 100, 0.1f, 10, 2500.0f);

	InvManager.AddInventory(rocket);
}

DefaultProperties
{
	ControllerClass=class'AEAIController_Agressive'
}
