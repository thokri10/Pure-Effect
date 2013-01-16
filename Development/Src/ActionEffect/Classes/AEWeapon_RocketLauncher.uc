class AEWeapon_RocketLauncher extends UTWeap_RocketLauncher_Content;

DefaultProperties
{
	WeaponColor=(R=0,G=255,B=0,A=255)

	MaxLoadCount = 20

	LoadedFireMode = RFM_Spiral
	
	AltFireQueueTimes(3)=0.96
	AltFireQueueTimes(4)=0.96
	AltFireQueueTimes(5)=0.96

	AltFireLaunchTimes(3)= 0.51
	AltFireLaunchTimes(4)= 0.51
	AltFireLaunchTimes(5)= 0.51
	
	AltFireEndTimes(3)=0.44
	AltFireEndTimes(4)=0.44
	AltFireEndTimes(5)=0.44
	
	MaxAmmoCount=1000
	LockerAmmoCount = 1000
}
