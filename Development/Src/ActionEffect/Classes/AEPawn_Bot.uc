class AEPawn_Bot extends AEPawn
	placeable;

var AEAIController      MyController;
var AEMissionObjective  spawnOwner;

simulated function SpawnDefaultController()
{
	Super.SpawnDefaultController();
}

simulated event PostBeginPlay()
{
	//super.PostBeginPlay();
	SetPhysics(PHYS_Walking);

	if(Controller == none)
		SpawnDefaultController();

	if(MyController == none)
		MyController = AEAIController(Controller);
			
	`log("TEAM SET");
	AEAIController( Controller ).SetTeam(1);

	SetCharacterClassFromInfo(class'UTFamilyInfo_Liandri_Male');

	super.PostBeginPlay();

	AddDefaultInventory();

	//AEShield = Spawn(class'AEPlayerShield', self,, Location,,, true);
	//AEShield.PawnController = self;
}

function setSquad(UTSquadAI squad)
{
	AEAIController( Controller ).Squad = squad;
}

function bool Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	if (spawnOwner == none)
	{
		spawnOwner = AEMissionObjective(Owner);
	}

	// TODO: Fix it so the host (server) is the only one being used to check
	// for mission objectives. Right now it messes up if you get a player who
	// doesn't have ownership to any MissionObjective.
	AEPlayerController( GetALocalPlayerController() ).myMissionObjective.botDied( MyController );
		
	//spawnOwner.botDied();

	return super.Died(Killer, damageType, HitLocation);
}

DefaultProperties
{
	ControllerClass = class'AEAIController';
}
