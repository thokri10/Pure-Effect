class AEManta extends UTVehicle_Manta_Content;

var bool bFly;
var bool bUpdateOnce;

var float Speed;

// Moving ship
var vector newVel;
var vector hitloc;
var TraceHitInfo inf;

function IncreaseSpeed()
{
	if(Role < ROLE_Authority)
		ServerIncreaseSpeed();
	else
	{
		SetPhysics(PHYS_Flying);
		Speed += 100.0f;
		if(Speed > 2000)
			Speed = 2000;
	}
}

reliable server function ServerIncreaseSpeed()
{
	SetPhysics(PHYS_Flying);
	Speed += 100.0f;
	if(Speed > 2000)
		Speed = 2000;
}

function DecreaseSpeed()
{
	if(Role < ROLE_Authority)
		serverDecreaseSpeed();
	else
	{
		SetPhysics(PHYS_Flying);
		Speed -= 100.0f;
		if(Speed < -2000)
			Speed = -2000;
	}
}

reliable server function serverDecreaseSpeed()
{
	SetPhysics(PHYS_Flying);
	Speed -= 100.0f;
	if(Speed < -2000)
		Speed = -2000;
	`log(Speed);
}

function Fly(bool fly)
{
	if(Role < ROLE_Authority)
		ServerFly(fly);
	else
	{
		bFly = fly;

		if(fly)
		{
			SetPhysics(PHYS_Flying);
			if(!bUpdateOnce)
			{
				bUpdateOnce = true;
				Speed -= 200;
				CustomGravityScaling = -1.0f;
			}
		}else{
			if(bUpdateOnce)
			{
				bUpdateOnce = false;
				Speed += 200;
				CustomGravityScaling = 0.05f;
			}
		}
	}
}

reliable server function ServerFly(bool fly)
{
	bFly = fly;

	if(fly)
	{
		SetPhysics(PHYS_Flying);
		if(!bUpdateOnce)
		{
			bUpdateOnce = true;
			Speed -= 200;
			CustomGravityScaling = -1.0f;
		}
	}else{
		if(bUpdateOnce)
		{
			bUpdateOnce = false;
			Speed += 200;
			CustomGravityScaling = 0.05f;
		}
	}
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	addTeamScore();
	Speed = 0;
	
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
	super.Tick(DeltaSeconds);

	Mesh.AddImpulse(Normal( Vector(Rotation) ) * Speed, hitloc);

	if(bFly)
		CustomGravityScaling -= 0.1;
}

DefaultProperties
{
	bCanFly = true;
	bNoZDampingInAir = false;

	Speed = 0;
}
