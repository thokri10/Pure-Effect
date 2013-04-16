class AEFactory_Manta extends UTVehicleFactory_Manta
	placeable;

var(AEVAR) int setTeam;

function Activate(byte T)
{
	if ( !bDisabled )
	{
		TeamNum = setTeam;
		GotoState('Active');
	}
}

DefaultProperties
{
	VehicleClassPath="ActionEffect.AEManta"
}
