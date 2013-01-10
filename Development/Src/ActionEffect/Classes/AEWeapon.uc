class AEWeapon extends UDKWeapon;


simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	`Log("Mode: " $FiringMode $ " Impact: " $Impact.HitActor $ " NumHits: " $NumHits);
}

DefaultProperties
{
	Begin Object class=SkeletalMesh Name=GunMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		HiddenGame=False
		HiddenEditor=False
	End Object

	Mesh=GunMesh

	Components.add(GunMesh);

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_InstantHit
	FireInterval(0)=0.1
	Spread(0)=0
}
