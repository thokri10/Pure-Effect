class AEWeapon_LinkGun extends UTWeap_LinkGun;

DefaultProperties
{
	MaxAmmoCount=1000
	LockerAmmoCount = 1000
	WeaponRange = 10000
	WeaponLinkDistance = 10000

	WeaponProjectiles(0)=class'UTProj_ShockBall'

	InstantHitDamageTypes(1)=class'UTDmgType_ShockPrimary'
}
