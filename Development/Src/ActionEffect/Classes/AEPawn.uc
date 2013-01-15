class AEPawn extends UTPawn;

function AddDefaultInventory()
{
	local UTWeap_ShockRifle shock;

	shock = Spawn(class'UTWeap_ShockRifle');
	InvManager.AddInventory(shock);
}

DefaultProperties
{
}