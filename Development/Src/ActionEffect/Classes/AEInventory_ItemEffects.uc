class AEInventory_ItemEffects extends Actor;

var AEPlayerShield      AEShield;

function heal(pawn target, int damage)
{
	`log("HEALING: " $ target.Name);
	if(target.Health + damage > 100)
		target.Health = 100;
	else
		target.Health += damage;
}

simulated function UTProj_Grenade granade(pawn target, float delay)
{
	local Vector Aim;
	local Vector spawnLocation;
	local UTProj_Grenade nade;

	spawnLocation = target.Location;
	Aim = vector( target.GetViewRotation() );

	spawnLocation.X += 10.0 * Aim.X;
	spawnLocation.Y += 10.0 * Aim.Y;

	nade = Spawn(class'UTProj_Grenade', self,, spawnLocation);

	nade.Init(Aim);
	nade.TossZ += (frand() * 200 - 100);
	nade.LifeSpan = delay;

	return nade;
}

function dealDamage(pawn target, actor item, int damage)
{
	// TODO: Fix this so that it won't bug in multiplayer.
	target.TakeDamage(damage, GetALocalPlayerController(), item.Location, vect(0,0,-3000), class'UTDmgType_Grenade');
}

simulated function AEPlayerShield shield(AEPawn target)
{
	local AEPlayerShield shield;

	shield = spawn(class'AEPlayerShield', target);
	shield.ControllerPawn = target;
	shield.bOwnedByPlayer = true;

	return shield;
}

DefaultProperties
{

}
