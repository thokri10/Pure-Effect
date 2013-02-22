/** AIController for the Escort bot in the Escort gametype. */
class AEAIEscortBotController extends AEAIController;

// CHANGE VECTORS OUT WITH AENAVIGATIONPOINT_ESCORTENEMYBOTSPAWN LATER.
/** The goal (final path node) where the Escort bot is walking to. */
var vector NavGoalLocation;

/** The next path node the Escort bot needs to walk to, in order to reach
 *  the final location (the goal/final path node). */
var vector NextLocationToGoal;

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

	//GotoState('Attacking');
	`Log("NIIIIIIIIIIIGGGGGGGGEEEEEEEEEEEERRR!");
	GotoState('FollowPath');
}

//state Wandering
//{
//	// AI spots another pawn (potentially player)
//	function SeePlayer(Pawn seenPlayer)
//	{
//		if (Enemy != none)
//		{
//			// Spotted enemy.
//			if (seenPlayer.Controller.IsA('AEAIController'))
//			{
//				//if (!CheckForBlockingVolume(seenPlayer))
//				//{
//				//	Enemy = seenPlayer;
//				//	// Probably doesn't work.
//				//	GotoState('Attacking');
//				//}
//			}
//		}
//	}

//	function GetNextPathNode()
//	{
//		 // Derp.
//	}

//	function GetNextRandomLocation()
//	{
//		// I have no idea... Think it finds a random spot to go to.
//		class'NavMeshGoal_Random'.static.FindRandom(NavigationHandle, 256);
//		class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, NextLocationToGoal);

//		// Create a path to the point.
//		NavigationHandle.FindPath();

//		// Get the goal (end point) of the path.
//		NavGoalLocation = NavigationHandle.PathCache_GetGoalPoint();

//		// Sets the newly goal location 
//		NavigationHandle.SetFinalDestination(NavGoalLocation);

//		// If the newly set goal location is possible to reach (nothing is
//		// blocking and such), then set it as the next path to go to.
//		if (NavigationHandle.PointReachable(NavGoalLocation))
//		{
//			NextLocationToGoal = NavGoalLocation;
//		}
//		else
//		{
//			// If not, try to find a node that can reach final destination.
//			NavigationHandle.GetNextMoveLocation(NextLocationToGoal, 40);
//		}
//	}

//	function SetNextLocationInPath()
//	{
//		NavigationHandle.GetNextMoveLocation(NextLocationToGoal, 40);
//	}
//}

auto state FollowPath
{
	//event SeePlayer(Pawn SeenPlayer)
	//{
	//	if( canSee )
	//	{
	//		playerPawn = SeenPlayer;
	//		distanceToPlayer = VSize(playerPawn.Location - Pawn.Location);
	//		if (distanceToPlayer < chaseMaxDistance)
	//		{ 
	//			`log("Chasing player");
	//			GotoState('ChasePlayer');
	//		} else if (distanceToPlayer < investigateMaxDistance)
	//		{
	//			if( lastPlayerSpot != none )
	//			{
	//				lastPlayerSpot.Destroy();
	//			}
	//			lastPlayerSpot = Spawn(class'HLastSeenSpot',,, playerPawn.Location,,, true);
	//			`log("Investigating spot");
	//			GotoState('GoToLastSeenPlayer');

	//		}
	//	}
 //   }

 Begin:
	// Starts following the path nodes.
	while (followingPath)
	{
		// Safefail: Checks if the pawn has any path nodes.
		if (MyNavigationPoints.Length <= 0)
		{
			followingPath = false;
			//GotoState('Idle');
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
				
				// Resets pathnode target to the very first one if goal
				// has been reached.
				if (actual_node >= MyNavigationPoints.Length)
				{
					//actual_node = 0;
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
    //investigateMaxDistance = 1300;
	//chaseMaxDistance = 900;
	
	AnimSetName = "ATTACK";
	actual_node = 0;
	last_node = 0;
	followingPath = true;
	IdleInterval = 2.5f;

	waitAtNode = 0.0f;
}
