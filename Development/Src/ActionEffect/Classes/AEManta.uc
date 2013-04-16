class AEManta extends UTVehicle_Manta_Content;

function bool DoJump(bool bUpdating)
{
	Velocity.Z = JumpZ * Floor;

	CustomGravityScaling = 0;
	SetPhysics(PHYS_Flying);

	return true;
}

DefaultProperties
{
	bCanFly = true;
	bNoZDampingInAir = false;
}
