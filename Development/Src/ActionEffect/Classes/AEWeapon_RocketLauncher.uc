class AEWeapon_RocketLauncher extends UTWeap_RocketLauncher_Content;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

DefaultProperties
{
	WeaponColor=(R=255,G=255,B=255,A=255)

	MaxLoadCount = 20
	
	MaxAmmoCount=1000
	LockerAmmoCount=1000
}
