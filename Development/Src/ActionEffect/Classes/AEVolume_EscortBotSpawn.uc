/** Spawn point for your escort target in the Escort game type. */
class AEVolume_EscortBotSpawn extends Actor
	placeable;

/** Contains all the spawn points for the Escort bot. */
var(SpawnPoints) array<AENavigationPoint_EscortBotSpawn> spawnPoints;

/** Spawns an Escort bot for each spawnpoint for that type of unit. */
function AEPawn_BotEscort spawnBot(class<AEPawn_BotEscort> bot, AEMissionObjective spawnOwner)
{
	local AENavigationPoint_EscortBotSpawn point;
	
	foreach spawnPoints( point )
	{
		if (!point.bInUse) 
		{ 
			point.bInUse = true; 
			break; 
		}
	}

	return spawn(bot, spawnOwner,, point.Location, point.Rotation,, true);
}

/** Resets the spawn points so that they can be used again. */
function resetSpawnPoints()
{
	local AENavigationPoint_EscortBotSpawn point;

	foreach spawnPoints( point )
	{
		point.bInUse = false;
	}
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=PickupMesh
		StaticMesh = StaticMesh'UN_SimpleMeshes.TexPropCube_Dup'
		Scale3D = (X = 0.1, Y = 1.4, Z = 1.1)
		HiddenGame = true
	End Object

	Components.Add(PickupMesh)
}
