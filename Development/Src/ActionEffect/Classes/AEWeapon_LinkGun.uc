class AEWeapon_LinkGun extends UTWeap_LinkGun;

// Variables for making custom projectiles.
var float customDamage;
var float customSpeed;
var string customProjectileType;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

simulated function FireAmmunition()
{
	// Use ammunition to fire
	ConsumeAmmo( CurrentFireMode );

	// Handle the different fire types
	switch( WeaponFireTypes[CurrentFireMode] )
	{
		case EWFT_InstantHit:
			InstantFire();
			break;

		case EWFT_Projectile:
			// TESTING. Make more dynamic.
			CustomProjectileFire();
			break;

		case EWFT_Custom:
			CustomFire();
			break;
	}

	NotifyWeaponFired( CurrentFireMode );
}

simulated function Projectile CustomProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			// Changes the projectile's properties.
			SpawnedProjectile.Damage = customDamage;
			SpawnedProjectile.Speed = customSpeed;

			switch (customProjectileType)
			{
				case "linkgun":
					SpawnedProjectile.MyDamageType = class'UTDmgType_LinkPlasma';
					WeaponProjectiles[0] = class'UTProj_LinkPlasma';
					break;

				case "rocket":
					SpawnedProjectile.MyDamageType = class'UTDmgType_Rocket';
					WeaponProjectiles[0] = class'UTProj_Rocket';
					break;

				case "shockRifle":
					SpawnedProjectile.MyDamageType = class'UTDmgType_ShockBall';
					WeaponProjectiles[0] = class'UTProj_ShockBall';
					break;

				default:
					`log("[AEWeapon_LinkGun] Linkgun projectileType failed to set!");
					break;
			}
			
			SpawnedProjectile.Init( AimDir );
		}
		
		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

DefaultProperties
{
	MaxAmmoCount = 1000;
	LockerAmmoCount = 1000;
	WeaponRange = 10000;
	WeaponLinkDistance = 10000;

	WeaponProjectiles(0)=class'UTProj_LinkPlasma';
	InstantHitDamageTypes(1)=class'UTDmgType_LinkPlasma';

	customDamage = 50.0f;
	customSpeed = 1000.0f;
	customProjectileType = "linkgun";
}
