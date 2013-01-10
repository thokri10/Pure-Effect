class AEPawn extends UTPawn;

function AddDefaultInventory()
{
	local UTWeap_ShockRifle rocket;

	rocket = Spawn(class'UTWeap_ShockRifle');
	UTInventoryManager(InvManager).AddInventory(rocket);
	//UTInventoryManager(InvManager).CreateInventory(class'UTWeap_RocketLauncher_Content');
}

DefaultProperties
{
	InventoryManagerClass=class'ActionEffect.AEInventoryManager'
}
