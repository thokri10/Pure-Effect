/** AIController for the Escort bot in the Escort gametype. */
class AEAIEscortBotController extends AEAIController;

// CHANGE VECTORS OUT WITH AENAVIGATIONPOINT_ESCORTENEMYBOTSPAWN LATER.
/** The goal (final path node) where the Escort bot is walking to. */
var vector NavGoalLocation;

/** The next path node the Escort bot needs to walk to, in order to reach
 *  the final location (the goal/final path node). */
var vector NextLocationToGoal;

/** Overrode the function. Doesn't have any additional functionality for now. */
function PostBeginPlay()
{
	super.PostBeginPlay();

	//GotoState('Attacking');
}

state Wandering
{
	// AI spots another pawn (potentially player)
	function SeePlayer(Pawn seenPlayer)
	{
		if (Enemy != none)
		{
			// Spotted enemy.
			if (seenPlayer.Controller.IsA('AEAIController'))
			{
				//if (!CheckForBlockingVolume(seenPlayer))
				//{
				//	Enemy = seenPlayer;
				//	// Probably doesn't work.
				//	GotoState('Attacking');
				//}
			}
		}
	}

	function GetNextPathNode()
	{
		 // Derp.
	}

	function GetNextRandomLocation()
	{
		class'NavMeshGoal_Random'.static.FindRandom(NavigationHandle, 256);
		class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, NextLocationToGoal);

		NavigationHandle.FindPath();

		NavGoalLocation = NavigationHandle.PathCache_GetGoalPoint();

		NavigationHandle.SetFinalDestination(NavGoalLocation);

		if (NavigationHandle.PointReachable(NavGoalLocation))
		{
			NextLocationToGoal = NavGoalLocation;
		}
		else
		{
			NavigationHandle.GetNextMoveLocation(NextLocationToGoal, 40);
		}
	}

	function SetNextLocationInPath()
	{
		NavigationHandle.GetNextMoveLocation(NextLocationToGoal, 40);
	}


}

DefaultProperties
{
}
