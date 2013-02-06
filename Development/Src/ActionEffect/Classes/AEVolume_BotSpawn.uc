class AEVolume_BotSpawn extends Actor
	placeable;

var(SpawnPoints) array<AENavigationPoint_Spawn> spawnPoints;

function AEPawn_Bot spawnBot(class<AEPawn_Bot> bot, AEMissionObjective spawnOwner)
{
	local AENavigationPoint_Spawn point;

	foreach spawnPoints( point )
	{
		`log("dereirjkljgksjdf"); 
		if(!point.bInUse){ point.bInUse=true; break; }
	}

	return spawn(bot, spawnOwner,, point.Location, point.Rotation,, true);
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
