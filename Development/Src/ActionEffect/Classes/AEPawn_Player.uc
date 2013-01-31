class AEPawn_Player extends AEPawn;

var AEPlayerController AEPC;

var bool usingJetpack;
var bool isInTheAir;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetPhysics(PHYS_Interpolating);

	AEPC = AEPlayerController(GetALocalPlayerController());
	if (AEPC != None)
	{
		AEPC.myPawn = self;
		`log("[AEPawn_Player] Setting pawn");
	}
	else
	{
		`log("[AEPawn_Player] No controller to pawn");
	}
}

function AddWeaponToInventory(UTWeapon type)
{
	UTInventoryManager(InvManager).AddInventory(type);
}

function bool Dodge(eDoubleClickDir DoubleClickMove) { return false; }

function bool DoJump( bool bUpdating )
{
	// This extra jump allows a jumping or dodging pawn to jump again mid-air
	// (via thrusters). The pawn must be within +/- DoubleJumpThreshold velocity units of the
	// apex of the jump to do this special move.
	if ( !bUpdating && CanDoubleJump()&& (Abs(Velocity.Z) < DoubleJumpThreshold) && IsLocallyControlled() )
	{
		if ( PlayerController(Controller) != None )
			PlayerController(Controller).bDoubleJump = true;
		DoDoubleJump(bUpdating);
		MultiJumpRemaining -= 1;
		return true;
	}

	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
	{
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = 2000.0f;
			// Velocity.Z = JumpZ;
		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			if ( (WorldInfo.WorldGravityZ != WorldInfo.DefaultGravityZ) && (GetGravityZ() == WorldInfo.WorldGravityZ) )
			{
				Velocity.Z += Base.Velocity.Z * sqrt(GetGravityZ()/WorldInfo.DefaultGravityZ);
			}
			else
			{
				Velocity.Z += Base.Velocity.Z;
			}
		}
		SetPhysics(PHYS_Falling);
		bReadyToDoubleJump = true;
		bDodging = false;
		if ( !bUpdating )
		{
			PlayJumpingSound();
		}
		    
		return true;
	}
	return false;
}

event Landed(vector HitNormal, actor FloorActor)
{
	local vector Impulse;

	Super.Landed(HitNormal, FloorActor);

	// adds impulses to vehicles and dynamicSMActors (e.g. KActors)
	Impulse.Z = Velocity.Z * 4.0f; // 4.0f works well for landing on a Scorpion
	if (UTVehicle(FloorActor) != None)
	{
		UTVehicle(FloorActor).Mesh.AddImpulse(Impulse, Location);
	}
	else if (DynamicSMActor(FloorActor) != None)
	{
		DynamicSMActor(FloorActor).StaticMeshComponent.AddImpulse(Impulse, Location);
	}

	if ( Velocity.Z < -200 )
	{
		OldZ = Location.Z;
		bJustLanded = bUpdateEyeHeight && (Controller != None) && Controller.LandingShake();
	}

	if (UTInventoryManager(InvManager) != None)
	{
		UTInventoryManager(InvManager).OwnerEvent('Landed');
	}
	if ((MultiJumpRemaining < MaxMultiJump && bStopOnDoubleLanding) || bDodging || Velocity.Z < -2 * JumpZ)
	{
		// slow player down if double jump landing
		Velocity.X *= 0.1;
		Velocity.Y *= 0.1;
	}

	AirControl = DefaultAirControl;
	MultiJumpRemaining = MaxMultiJump;
	bDodging = false;
	bReadyToDoubleJump = false;
	if (UTBot(Controller) != None)
	{
		UTBot(Controller).ImpactVelocity = vect(0,0,0);
	}

	if(!bHidden)
	{
		PlayLandingSound();
	}
	if (Velocity.Z < -MaxFallSpeed)
	{
		SoundGroupClass.Static.PlayFallingDamageLandSound(self);
	}
	else if (Velocity.Z < MaxFallSpeed * -0.5)
	{
		SoundGroupClass.Static.PlayLandSound(self);
	}

	SetBaseEyeheight();
}

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

DefaultProperties
{
	InventoryManagerClass = class'ActionEffect.AEInventoryManager';

	bCanDoubleJump = true;
	MaxMultiJump = 1000;
	
	GroundSpeed = 600.0f;

	usingJetpack = false;
	isInTheAir = false;
}