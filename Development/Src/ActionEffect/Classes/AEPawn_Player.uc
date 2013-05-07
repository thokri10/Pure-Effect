class AEPawn_Player extends AEPawn;

var AEPlayerController AEPC;

// Various booleans for movement types.
var bool isUsingJetPack;
var bool isInTheAir;
var bool isSprinting;

// Sprint variables.
var float sprintEnergy;
var float maxSprintEnergy;
var float sprintEnergyLossPerSecond;
var bool regenerateSprintEnergy;

// Keeps track how much time has passed.
var float playerTimer;

// Desired FPS. Used to calculate how often we want to "update" the player.
// Used in conjunction with timeToUpdate (see below).
var float fps;

// How many seconds should pass before to check to "update" the player.
var float timeToUpdate;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		isSprinting, regenerateSprintEnergy, isUsingJetPack;
}

event Tick(float DeltaTime)
{
	playerTimer += DeltaTime;

	super.Tick(DeltaTime);

	if ( playerTimer >= timeToUpdate )
	{
		playerTimer -= timeToUpdate;

		StartSprinting(DeltaTime);
	}
}

function Sprint()
{
	if ( WorldInfo.NetMode == NM_Client )
	{
		ServerSprint();
	}
	else
	{
		isSprinting = true;
		regenerateSprintEnergy = false;
	}
}

function StopSprint()
{
	if ( WorldInfo.NetMode == NM_Client )
	{
		ServerStopSprint();
	}
	else
	{
		isSprinting = false;
		regenerateSprintEnergy = true;
	}
}

reliable server function ServerSprint()
{
	isSprinting = true;
	regenerateSprintEnergy = false;
}

reliable server function ServerStopSprint()
{
	isSprinting = false;
	regenerateSprintEnergy = true;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	timeToUpdate = 1.0f / fps;
}

/*
simulated function StartFire(byte FireModeNum)
{
	if(AEShield != none)
		AEShield.bBlockActors=false;

	super.StartFire(FireModeNum);
}

simulated function StopFire(byte FireModeNum)
{
	if(AEShield != none)
		AEShield.bBlockActors=true;

	super.StopFire(FireModeNum);
}
*/

function AddWeaponToInventory(UTWeapon type)
{
	UTInventoryManager(InvManager).AddInventory(type);
}

function bool Dodge(eDoubleClickDir DoubleClickMove) { return false; }

simulated function TakeFallingDamage()
{
	// No fall damage. Remove this function to regain fall damage.
}

function DoDoubleJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch )
	{
		if ( !IsLocallyControlled() || AIController(Controller) != None )
		{
			MultiJumpRemaining -= 1;
		}
		Velocity.Z = JumpZ + MultiJumpBoost;
		UTInventoryManager(InvManager).OwnerEvent('MultiJump');
		SetPhysics(PHYS_Falling);
		BaseEyeHeight = DoubleJumpEyeHeight;
		if (!bUpdating)
		{
			//SoundGroupClass.Static.PlayDoubleJumpSound(self);
		}
	}
}

function UpdateSprintEnergy(float DeltaTime)
{
	local int regeneratorFactor;
	regeneratorFactor = -1.0f;

	if (regenerateSprintEnergy)
	{
		regeneratorFactor = 1.0f;
	}

	sprintEnergy += regeneratorFactor * (sprintEnergyLossPerSecond * DeltaTime);

	if (sprintEnergy < 0.0f)
	{
		sprintEnergy = 0.0f;
		isSprinting = false;
	}
	else if (sprintEnergy > maxSprintEnergy)
	{
		sprintEnergy = maxSprintEnergy;
	}
}

function StartSprinting(float DeltaTime)
{
	UpdateSprintEnergy(DeltaTime);

	if (isSprinting)
	{
		GroundSpeed = 1000.0f;
	}
	else
	{
		GroundSpeed = 600.0f;
	}
}

function StartUsingTheJetpack(float DeltaTime)
{
	if (isUsingJetPack)
	{
		if (AEPlayerController(Controller).myJetpack.fuelEnergy > 0.0f)
		{
			CustomGravityScaling = -1.0f;
			// Commented out temporarily for debugging reasons.
			//fuelEnergy -= (fuelEnergyLossPerSecond * DeltaTime);
		}
		
		if (AEPlayerController(Controller).myJetpack.fuelEnergy < 0.0f)
		{
			AEPlayerController(Controller).myJetpack.fuelEnergy = 0.0f;
		}
	}
	else
	{
		CustomGravityScaling = 1.0f;
	}
}

/** Jetpack-use for the host (server). */
reliable server function ServerJetpacking()
{
	isUsingJetPack = true;
}

/** Jetpack-disuse for the host (server). */
reliable server function ServerStopJetpacking()
{
	isUsingJetPack = false;
}

DefaultProperties
{
	InventoryManagerClass = class'ActionEffect.AEInventoryManager';

	bCanDoubleJump = false;
	MaxMultiJump = 1;
	
	GroundSpeed = 600.0f;

	isUsingJetPack = false;
	isInTheAir = false;
	isSprinting = false;

	maxSprintEnergy = 100.0f;
	sprintEnergy = 100.0f;
	sprintEnergyLossPerSecond = 10.0f;
	regenerateSprintEnergy = true;

	playerTimer = 0.0f;
	fps = 60.0f;
}