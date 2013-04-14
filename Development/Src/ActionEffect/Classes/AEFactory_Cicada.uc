class AEFactory_Cicada extends UTVehicleFactory_Cicada
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
	VehicleClassPath="ActionEffect.AECicada"
}
