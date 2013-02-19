/** A bot that the player escorts during the Escort gametype. */
class AEPawn_EscortBot extends AEPawn_Bot;

// CHANGE VECTORS OUT WITH AENAVIGATIONPOINT_ESCORTENEMYBOTSPAWN LATER.
/** The goal (final path node) where the Escort bot is walking to. */
var vector NavGoalLocation;

/** The next path node the Escort bot needs to walk to, in order to reach
 *  the final location (the goal/final path node). */
var vector NextLocationToGoal;

var array<AEPathNodeEscortBotFriendly> pathNodes;

simulated function PostBeginPlay()
{
	local AEPathNodeEscortBotFriendly escortPathNode;
	local AEPathNodeEscortBotFriendly target;

	super.PostBeginPlay();

	foreach WorldInfo.AllNavigationPoints(class'AEPathNodeEscortBotFriendly', target)
	{
		escortPathNode = target;
		pathNodes.AddItem(escortPathNode);
		`Log("LOOOOOOOOOOOODFOJISDFHIFSKS");
	}
}

/** Makes sure the bot is on the ground upon possible possession. */
function Possess(Pawn aPawn, bool bVehicleTransition)
{
	MyController.Possess(aPawn, bVehicleTransition);
}

//state MoveToGoal 
//{
// niggdsfds
//}

DefaultProperties
{

}
