class AECicada extends UTVehicle_Cicada_Content;

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	addTeamScore();
	
	return super.Died(Killer, DamageType, HitLocation);
}

function addTeamScore()
{
	local AEReplicationInfo repInfo;

	foreach WorldInfo.AllActors(class'AEReplicationInfo', repInfo)
	{
		repInfo.addScore(team);
	}
}

DefaultProperties
{
}
