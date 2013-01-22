class AEWeapon_ShockRifle extends UTWeap_ShockRifle;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

DefaultProperties
{
	MaxAmmoCount=1000
	LockerAmmoCount = 1000
	DrawScale = 3
}
