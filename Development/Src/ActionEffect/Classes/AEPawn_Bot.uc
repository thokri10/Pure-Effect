class AEPawn_Bot extends AEPawn
	placeable;

var         UTBot        MyController;

simulated event PostBeginPlay()
{
	SetPhysics(PHYS_Walking);

	if(ControllerClass == none)
	{
		ControllerClass = class'UTBot';

		if(MyController == none)
			MyController = UTBot(Controller);
	}
	
	SetCharacterClassFromInfo(class'UTFamilyInfo_Liandri_Male');

	super.PostBeginPlay();
}

DefaultProperties
{
	Components.add(skel);

	ControllerClass=class'UTBot'
}
