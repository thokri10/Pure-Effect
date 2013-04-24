/** Controller for AI-bots. */
class AEAIController extends UDKBot;

var float RunTime;

//-------------------------------
// Bot variables

var bool bCurrentlyOccupied;

var float shootBurstCounter;
var float shootDelay;

var bool bCanFire;

//---------------------------------
// Path variables

/** PathNode the bots standing on */
var PathNode currentNode;
/** The Pathnode the bot are moving from */
var PathNode lastDestinationtNode;
/** Pathnode the bot are moving towards */
var PathNode destinationNode;
/** The actor the bot should look at when moving around */ 
var Actor    viewNode;

//---------------------------------------
// Target Varaibles

var AEPawn_Player myEnemy;
var Vector EnemyLastPosition;

function PostBeginPlay()
{
	WorldInfo.NetMode = NM_ListenServer;
	super.PostBeginPlay();

	RunTime = 0;
	
	PlayerReplicationInfo.bOutOfLives=true;

	bCanFire = true;

	setTimer(3, true, 'CheckAttractionState');
}

function resetPosition()
{
	viewNode = None;
	destinationNode = none;
	lastDestinationtNode = None;
	currentNode = None;
}

function ReceiveProjectileWarning(Projectile Proj)
{
	`log("DODGE " $ Proj);
}

function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	`log("DODGE: " $ shooter);
}

event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	//`log("Who's there? Oh its you: " $ NoiseMaker);
}

event SeePlayer(Pawn Seen)
{
	
	myEnemy = AEPawn_Player( Seen );
	bEnemyAcquired = true;
	bEnemyIsVisible = true;

	// Will Only fire at player.
	if(myEnemy != none){
		SetFocalPoint( Seen.Location );

		Focus = Seen;	
		EnemyLastPosition = Seen.Location;

		if( !FireWeaponAt( Seen ) ){  }
	}	
}

function CheckAttractionState()
{
	if(myEnemy == none){
		bFire = 0;
		StopFiring();
	}
	else if( !LineOfSightTo( myEnemy ) && bEnemyIsVisible )
	{
		StopFiring();
		EnemyVisibilityTime = RunTime;
		bEnemyIsVisible = false;
	}else{
		if(bEnemyAcquired && bEnemyIsVisible)
			SaveEnemyPosition();
	}

	SetAttractionState();
}

simulated function SetAttractionState()
{
	`log(myEnemy);
	if(myEnemy == None)
	{
		GoToState('Patrol');
		/*
		if( EnemyLastPosition != Vector(0,0,0) )
		{
			MoveToLocation( EnemyLastPosition );
		}
		*/
	}else{
		SetEnemyAtraction();
	}
}

function SaveEnemyPosition()
{
	local EnemyPosition pos;

	EnemyVisibilityTime = RunTime;
	pos.Position = myEnemy.Location;
	pos.Time = RunTime;
	pos.Velocity = myEnemy.Velocity;

	SavedPositions.AddItem( pos );
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	RunTime += DeltaTime;

	if(bEnemyIsVisible)
		bEnemyIsVisible = LineOfSightTo(myEnemy);

}

function SetEnemyAtraction()
{
	if(!bEnemyIsVisible)
	{
		if( (RunTime - EnemyVisibilityTime) > 5 ){
			SavedPositions.Length = 0;
			bEnemyAcquired = false;
			myEnemy = None;
			resetPosition();
			Pawn.StopFiring();
			GotoState('Patrol');
		}else
		{
			GotoState('Investigate');
		}
	}
}

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	PlayerReplicationInfo.bOutOfLives=true;

	super.Possess(aPawn, bVehicleTransition);
}

//----------------------------
// Other Functions

/** Finds the best viewpoint for bot.
 *  @param desiredViewPoint . If there is no better option */
function setBestViewPoint(optional Actor desiredViewPoint)
{
	if(Enemy == None)
	{
		if(GetStateName() == 'Patrol')
			viewNode = desiredViewPoint;
	}else{
		viewNode = Enemy;
	}
}

/** Finds the closest pathnode and find the bots viewpoint */
function UpdateMovePosition()
{
	local Actor desiredView;

	lastDestinationtNode = currentNode;
	currentNode = destinationNode;

	if(GetStateName() == 'Patrol')
	{
		destinationNode = FindClosestPathNode( Pawn, true, currentNode );
		desiredView = FindClosestPathNode( destinationNode, true, currentNode );
		setBestViewPoint( desiredView );
	}

}

/** Finds and returns the closest pathnode
 *  @param obj Adjacent to this actor
 *  @param skipLastDestNode Skips the node the bot last visited
 *  @param ignoreNode Ignore this node
 *  @return Closest pathnode to param obj
 *  TODO: Update so it wont try to walk through walls */
function PathNode FindClosestPathNode(Actor obj, optional bool skipLastDestNode, optional PathNode ignoreNode)
{
	local PathNode targetNode;
	local PathNode node;
	local float    tempDistance;
	local float    distance;

	foreach WorldInfo.AllNavigationPoints(class'PathNode', node)
	{
		if(skipLastDestNode && node == lastDestinationtNode)
			node = PathNode( obj );
		if(node != ignoreNode && node != obj && LineOfSightTo(node) )
		{
			tempDistance = getDistance( node, obj );

			if(targetNode == None){
				distance = tempDistance;
				targetNode = node;
			}else
			{
				if(tempDistance < distance)
				{
					distance = tempDistance;
					targetNode = node;
				}
			}
		}
	}

	return targetNode;
}

function float getDistance(Actor from, Actor to)
{
	if(from == None || to == none)
		return 0;

	return VSizeSq(from.Location - to.Location);
}

//-----------------------------
// States

State Patrol
{
Begin:
	if( Sqrt( getDistance( pawn, destinationNode ) ) < 150)
	{
		UpdateMovePosition();
		MoveToward(destinationNode, viewNode,,, true);
		//MoveTo(destinationNode.Location, viewNode,, true);
	}
};

State Investigate
{
Begin:
	MoveToDirectNonPathPos( SavedPositions[ SavedPositions.Length - 1 ].Position, myEnemy );
}

State Idle
{
Begin:
	WaitToSeeEnemy();

	GotoState('Combat');
};

State Combat
{
begin:
	`log("In Combat State: ADD MORE CODE =)");
	
};


//--------------------------------
// Overrided code

event bool MoverFinished()
{
	`log("Finished to move to target");
	return super.MoverFinished();
}

/** Gets player Location. Used for aiming at a target */ 
simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_rotation )
{
	if(pawn != None)
	{
		out_Location = pawn.Location;
		out_Rotation = Rotation;
	}
	else
	{
		 super.GetPlayerViewPoint(out_Location, out_rotation);
	}
	
}

/** Fires the equiped weapon at Actor A */
function bool FireWeaponAt(Actor A)
{
	if( bCanFire )
	{
		bFire = 1;
		bCanFire = false;
		SetTimer( 3, false, 'burstFire' );

		if ( Pawn.Weapon != None )
			if ( Pawn.Weapon.HasAnyAmmo() )
				return Pawn.BotFire(true); // TRUE DONT DO SHIT
		else
			return Pawn.BotFire(true); // TRUE DONT DO SHIT

		Pawn.StopFiring();
	}

	return false;
}

event burstFire()
{
	bCanFire = true;
}

