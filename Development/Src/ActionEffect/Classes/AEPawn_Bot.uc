class AEPawn_Bot extends AEPawn
	placeable;

var AEAIController      MyController;
var AEMissionObjective  spawnOwner;

function SpawnDefaultController()
{
	Super.SpawnDefaultController();
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetPhysics(PHYS_Walking);

	if(ControllerClass == none)
	{
		ControllerClass = class'AEAIController';

		if(MyController == none)
			MyController = AEAIController(Controller);

		spawnOwner = AEMissionObjective(Owner);

		if(spawnOwner == none)
			`log("[AEPawn_Bot] Owner does not exist. Or can't be casted to AEMissionObjective");
	}
	
	SetCharacterClassFromInfo(class'UTFamilyInfo_Liandri_Male');

	//super.PostBeginPlay();

	AddDefaultInventory();
}

function bool Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	if(spawnOwner == none)
		spawnOwner = AEMissionObjective(Owner);

	spawnOwner.botDied();

	return super.Died(Killer, damageType, HitLocation);
}

DefaultProperties
{
	ControllerClass=class'AEAIController'
}
