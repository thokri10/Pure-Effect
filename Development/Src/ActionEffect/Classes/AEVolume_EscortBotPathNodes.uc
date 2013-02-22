/** VOLUME for the path nodes that the Escort target will use. */
class AEVolume_EscortBotPathNodes extends AEVolume
	placeable;

/** Array of all the path nodes. */
//var(PathNodes) array<AEPathNodeEscortBotFriendly> pathNodes;
var(PathNodes) array <AENavigationPoint_EscortBotPathNode> pathNodes;

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=PickupMesh
		StaticMesh=StaticMesh'UN_SimpleMeshes.TexPropCube_Dup'
		Scale3D=(X=0.1,Y=1.4,Z=1.1)
		HiddenGame=true
	End Object

	Components.Add(PickupMesh)
}

