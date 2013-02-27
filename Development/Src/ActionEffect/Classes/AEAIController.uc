/** Controller for AI-bots. */
class AEAIController extends UTBot;

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	PlayerReplicationInfo.bOutOfLives=true;
}

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	PlayerReplicationInfo.bOutOfLives=true;

	super.Possess(aPawn, bVehicleTransition);
}


