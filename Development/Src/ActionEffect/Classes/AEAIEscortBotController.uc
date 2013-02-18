/** AIController for the Escort bot in the Escort gametype. */
class AEAIEscortBotController extends AEAIController;

/** Overrode the function. Doesn't have any additional functionality for now. */
function PostBeginPlay()
{
	super.PostBeginPlay();
}

state Wandering
{
	function SeePlayer(Pawn seenPlayer)
	{
		if (Enemy != none)
		{
			// Spotted enemy.
			if (seenPlayer.Controller.IsA('AEAIController'))
			{
				// Probably doesn't work.
				//GotoState('Attacking');
			}
		}
	}

	function GetNextPathNode()
	{
		 // Derp.
	}
}

DefaultProperties
{
}
