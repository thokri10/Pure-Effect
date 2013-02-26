/** A bot that the player escorts during the Escort gametype. */
class AEPawn_EscortBot extends AEPawn
	placeable;

var AEAIEscortBotController     MyController;
var AEMissionObjective          spawnOwner;

var () array<AENavigationPoint_EscortBotPathNode> MyNavigationPoints;

var ()  float       waitAtNode;

simulated function PostBeginPlay()
{
	local AENavigationPoint_EscortBotPathNode escortPathNode;
	local AENavigationPoint_EscortBotPathNode target;

	super.PostBeginPlay();

	foreach WorldINfo.AllNavigationPoints(class'AENavigationPoint_EscortBotPathNode', target)
	{
		escortPathNode = target;
		MyNavigationPoints.AddItem(escortPathNode);
	}

	MyController = Spawn(class'AEAIEscortBotController');
	MyController.Possess(self, false);

	SetPhysics(PHYS_Walking);

	if (ControllerClass == none)
	{
		ControllerClass = class'AEAIEscortBotController';

		if (MyController == none)
		{
			MyController = AEAIEscortBotController(Controller);
		}

		spawnOwner = AEMissionObjective(Owner);

		if (spawnOwner == none)
		{
			`log("[AEPawn_EscortBot] Owner does not exist. Or can't be casted to AEMissionObjective");
		}
	}
	
	SetCharacterClassFromInfo(class'UTFamilyInfo_Liandri_Male');

	AddDefaultInventory();
}

/** Makes sure the bot is on the ground upon possible possession. */
function Possess(Pawn aPawn, bool bVehicleTransition)
{
	MyController.Possess(aPawn, bVehicleTransition);
}

function SpawnDefaultController()
{
	Super.SpawnDefaultController();
}

function bool Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	if (spawnOwner == none)
	{
		spawnOwner = AEMissionObjective(Owner);
	}
		
	// Remove later?
	spawnOwner.botDied();

	spawnOwner.escortBotDied();

	return super.Died(Killer, damageType, HitLocation);
}

DefaultProperties
{
	ControllerClass = class'AEAIEscortBotController';
}

