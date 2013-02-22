class AEInventory_Item_Granade extends AEInventory_Item;

var UTProj_Grenade nade;

simulated function bool Use()
{
	local Vector Aim;
	local Vector spawnLocation;

	if( !super.Use() )
		return false;

	spawnLocation = PC.myPawn.Location;
	Aim = vector( PC.myPawn.GetViewRotation() );

	spawnLocation.X += 10.0 * Aim.X;
	spawnLocation.Y += 10.0 * Aim.Y;

	nade = Spawn(class'UTProj_Grenade', self,, spawnLocation);

	nade.Init(Aim);
	nade.TossZ += (frand() * 200 - 100);
	nade.LifeSpan = 3;

	return true;
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
}

DefaultProperties
{
	Cooldown=0.5
	UseCounter=10
}
