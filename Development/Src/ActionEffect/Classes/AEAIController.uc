/** Controller for AI-bots. */
class AEAIController extends UDKBot;

//-------------------------------
// Bot variables

var bool bCurrentlyOccupied;


//---------------------------------------
// Target Varaibles

var AEPawn_Player myEnemy;
var Vector EnemyLastPosition;

function PostBeginPlay()
{
	WorldInfo.NetMode = NM_ListenServer;
	super.PostBeginPlay();
	
	PlayerReplicationInfo.bOutOfLives=true;

	setTimer(2, true, 'CheckAttractionState');
}

function ReceiveProjectileWarning(Projectile Proj)
{
	`log("DODGE");
}

function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	`log("DODGE: " $ shooter);
}

event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	`log("Who's there? Oh its you: " $ NoiseMaker);
}

event SeePlayer(Pawn Seen)
{
	myEnemy = AEPawn_Player( Seen );

	// Will Only fire at player.
	if(myEnemy != none){
		SetFocalPoint( Seen.Location );
		Focus = Seen;	
		EnemyLastPosition = Seen.Location;

		if( FireWeaponAt( Seen ) ){}
	}

	myEnemy = none;
}

function CheckAttractionState()
{
	if(myEnemy == none){
		bFire = 0;
		StopFiring();
	}

	if(!bCurrentlyOccupied)
		SetAttractionState();
}

simulated function SetAttractionState()
{
	if(myEnemy == None)
	{
		/*
		if( EnemyLastPosition != Vector(0,0,0) )
		{
			MoveToLocation( EnemyLastPosition );
		}
		*/
	}
	else 
	{
		GoToState('Idle');
	}
}

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	PlayerReplicationInfo.bOutOfLives=true;

	super.Possess(aPawn, bVehicleTransition);
}

//----------------------------
// Other Functions

function MoveToLocation( Vector LastPosition )
{
	local Actor targetLocation;

	targetLocation = Spawn(class'Actor', self,, LastPosition);

	if( ActorReachable( targetLocation ) ){
		//MoveToward( targetLocation );
		bCurrentlyOccupied = true;
	}
}

//-----------------------------
// States

State Idle
{
Begin:
	`log("IDLE STATE");
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
	bFire = 1;

	if ( Pawn.Weapon != None )
		if ( Pawn.Weapon.HasAnyAmmo() )
			return Pawn.BotFire(true); // TRUE DONT DO SHIT
	else
		return Pawn.BotFire(true); // TRUE DONT DO SHIT

	return false;
}

