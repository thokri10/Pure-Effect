class AEPawn_BotLeader extends AEPawn_Bot;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetCharacterClassFromInfo(class'AEAIFamilyInfo_Leader');
}


simulated function AddDefaultInventory()
{
	local UTWeapon weap;

	weap = AEPlayerController( GetALocalPlayerController() ).myWeaponCreator.CreateWeapon("rocket", 0, 1000, 0.05, 1, 500);

	InvManager.AddInventory(weap);
}

DefaultProperties
{
	ControllerClass=class'AEAIController_Leader'
}
