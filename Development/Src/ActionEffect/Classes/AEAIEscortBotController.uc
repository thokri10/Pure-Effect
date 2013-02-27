/** AIController for the Escort bot in the Escort gametype. */
class AEAIEscortBotController extends AEAIController;

/** Navigation points (path nodes). */
var () array<AENavigationPoint_EscortBotPathNode> MyNavigationPoints;

var AEPawn_EscortBot aiPawn;

var     int         actual_node;
var     int         last_node;

var ()  float       waitAtNode;
var     float       waitCounter;

var float           perceptionDistance;

var float           distanceToPlayer;
var float           distanceToTargetNodeNearPlayer;

var Name AnimSetName;

var bool Attacking;
var float attackDistance;
var bool followingPath;
var Float IdleInterval;

/** Overrode the function. Doesn't have any additional functionality for now. */
function PostBeginPlay()
{
	super.PostBeginPlay();
}
state Idle
{

}

auto state FollowPath
{
 Begin:
	// Starts following the path nodes.
	while (followingPath)
	{
		// Safefail: Checks if the pawn has any path nodes.
		if (MyNavigationPoints.Length <= 0)
		{
			followingPath = false;
			GotoState('Idle');
			break;
		}

		// Set the desired pathnode target.
		MoveTarget = MyNavigationPoints[actual_node];

		// Checks if the pawn has reached the current pathnode target.
		if (Pawn.ReachedDestination(MoveTarget))
		{
			// Checks if the required waiting time for each node is reached
			// so it can move on to next path node.
			if (waitCounter >= waitAtNode)
			{
				// Increment to next pathnode target to the next one.
				actual_node++;
				
				// Makes sure the last node will remain the same.
				if (actual_node >= MyNavigationPoints.Length)
				{
					//actual_node = 0;
					//actual_node = MyNavigationPoints.Length - 1;
					// Stops following his path.
					followingPath = false;
					break;
				}
				last_node = actual_node;

				// Set current path node to move to. Again.
				MoveTarget = MyNavigationPoints[actual_node];
				
				//aiPawn.SetAnimState(MS_Walk);
				//SetWalkAnimSpeed();

				// Resets the wait counter because it is now moving on
				// to next path node.
				waitCounter = 0.0f;
			} 
			else 
			{
				//aiPawn.SetAnimState(MS_Idle);
				//SetIdleAnimSpeed();

				// Increment the wait counter. The wait counter contains
				// the time you're currently spending at a path node.
				// Wait counter is used to make the bots wait a bit at each
				// path node before moving on to next path node.
				waitCounter += 0.1f;
			}
		}	

		// Checks if the target is reachable (not blocked by stuff and shit).
		if (ActorReachable(MoveTarget)) 
		{
			// Move towards the target if it is reachable.
			MoveToward(MoveTarget, MoveTarget,,false);	
		}
		else
		{
			// ... move anyways even if it is blocked.
			MoveTo( MoveTarget.Location );
			
			/*`log("Finding path towards");
			MoveTarget = FindPathToward(MyNavigationPoints[actual_node]);
			if (MoveTarget != none)
			{

				SetRotation(RInterpTo(Rotation,Rotator(MoveTarget.Location),1,90000,true));

				MoveToward(MoveTarget, MoveTarget);
			}*/
		}
		Sleep(0.1);
	}
}

function Possess(Pawn aPawn, bool bVehicleTransition)
{
    if (aPawn.bDeleteMe)
	{
		`Warn(self @ GetHumanReadableName() @ "attempted to possess destroyed Pawn" @ aPawn);
		 ScriptTrace();
		 GotoState('Dead');
    }
	else
	{
		Super.Possess(aPawn, bVehicleTransition);

		aiPawn = AEPawn_EscortBot(Pawn);
		MyNavigationPoints = aiPawn.MyNavigationPoints;
		waitAtNode = aiPawn.waitAtNode;
		Pawn.SetMovementPhysics();

		if (Pawn.Physics == PHYS_Walking)
		{
			Pawn.SetPhysics(PHYS_Falling);
	    }
    }

	GotoState('FollowPath');
}

DefaultProperties
{
	attackDistance = 50;
	
	AnimSetName = "ATTACK";
	actual_node = 0;
	last_node = 0;
	followingPath = true;
	IdleInterval = 2.5f;

	waitAtNode = 0.0f;
}
