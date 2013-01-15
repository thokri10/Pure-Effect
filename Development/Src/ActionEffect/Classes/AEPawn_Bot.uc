class AEPawn_Bot extends AEPawn
	placeable;

var AEAIController MyController;

simulated event PostBeginPlay()
{
	SetPhysics(PHYS_Walking);

	if(ControllerClass == none)
	{
		ControllerClass = class'AEAIController';

		if(MyController == none)
			MyController = AEAIController(Controller);
	}
	
	SetCharacterClassFromInfo(class'UTFamilyInfo_Liandri_Male');

	super.PostBeginPlay();

	AddDefaultInventory();
}

DefaultProperties
{

	ControllerClass=class'AEAIController'
}
