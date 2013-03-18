/** A bot that the player escorts during the Escort gametype. */
class AEPawn_BotEscort extends AEPawn_Bot
	placeable;

var AEAIController_Escort       MyCustomController;

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

	MyCustomController = Spawn(class'AEAIController_Escort');
	MyCustomController.Possess(self, false);

	SetPhysics(PHYS_Walking);

	ControllerClass = class'AEAIController_Escort';

	if (MyCustomController == none)
	{
		MyCustomController = AEAIController_Escort(Controller);
	}

	spawnOwner = AEMissionObjective(Owner);

	if (spawnOwner == None)
	{
		`log("[AEPawn_BotEscort] Owner does not exist. Or can't be casted to AEMissionObjective");
	}
	
	SetCharacterClassFromInfo(class'UTFamilyInfo_Liandri_Male');
	AEAIController_Escort( Controller ).SetTeam(0);
	
	MyCustomController.PlayerReplicationInfo.PlayerName = "ESCORT TARGET";
	GroundSpeed = 500.0f;
	Health = Health * 10.0f;
	
	AddDefaultInventory();
}

/** Makes sure the bot is on the ground upon possible possession. */
function Possess(Pawn aPawn, bool bVehicleTransition)
{
	MyCustomController.Possess(aPawn, bVehicleTransition);
}

simulated function SpawnDefaultController()
{
	Super.SpawnDefaultController();
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
	AEPlayerController( GetALocalPlayerController() ).myMissionObjective.escortBotDied();

	return super.Died(Killer, damageType, HitLocation);
}

DefaultProperties
{
	ControllerClass = class'AEAIController_Escort';
}

