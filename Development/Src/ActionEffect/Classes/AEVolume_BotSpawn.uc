class AEVolume_BotSpawn extends Actor
	placeable;

var(SpawnPoints) array<AENavigationPoint_Spawn> spawnPoints;

function AEPawn_Bot spawnBot(class<AEPawn_Bot> bot, AEMissionObjective spawnOwner)
{
	local AENavigationPoint_Spawn point;

	foreach spawnPoints( point )
	{
		if (!point.bInUse)
		{ 
			if(bot == point.typeOfBot)
			{
				point.bInUse = true; 
				break; 
			}
		}
	}

	if( point != none ) 
		return spawn(bot, spawnOwner,, point.Location, point.Rotation,, true);

	`Log("[AEVolume_BotSpawn] Could not spawn bot. No more free spawns or no type for this bot");
	return none;
}

function resetSpawnPoints()
{
	local AENavigationPoint_Spawn point;

	foreach spawnPoints( point )
	{
		point.bInUse = false;
	}
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=PickupMesh
		StaticMesh=StaticMesh'UN_SimpleMeshes.TexPropCube_Dup'
		Scale3D=(X=0.1,Y=1.4,Z=1.1)
		HiddenGame=true
	End Object

	Components.Add(PickupMesh)
}
