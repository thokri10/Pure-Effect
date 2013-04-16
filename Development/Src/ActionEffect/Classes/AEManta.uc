class AEManta extends UTVehicle_Manta_Content;

var bool bFly;
var float Speed;

// Moving ship
var vector newVel;
var vector hitloc;
var TraceHitInfo inf;

function IncreaseSpeed()
{
	SetPhysics(PHYS_Falling);
	Speed += 100.0f;
	if(Speed > 2000)
		Speed = 2000;
	`log(Speed);
}

function DecreaseSpeed()
{
	SetPhysics(PHYS_Falling);
	Speed -= 100.0f;
	if(Speed < -2000)
		Speed = -2000;
	`log(Speed);
}

function Fly(bool fly)
{
	bFly = fly;

	if(fly)
	{
		SetPhysics(PHYS_Flying);
		CustomGravityScaling -= 1;
	}else{
		CustomGravityScaling = 0;
	}
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	addTeamScore();
	
	return super.Died(Killer, DamageType, HitLocation);
}

function addTeamScore()
{
	local AEReplicationInfo repInfo;

	foreach WorldInfo.AllActors(class'AEReplicationInfo', repInfo)
	{
		repInfo.addScore(team);
	}
}

function bool DoJump(bool bUpdating)
{
	return false;
}
function Tick(float DeltaSeconds)
{
	local vector derp;
	super.Tick(DeltaSeconds);

	derp = Vector(Rotation);
	derp = Normal(derp);

	newVel = derp * Speed;
	Mesh.AddImpulse(newVel, hitloc);

	if(bFly)
		CustomGravityScaling -= 0.25;
}

DefaultProperties
{
	bCanFly = true;
	bNoZDampingInAir = false;

	Speed = 0;
}
