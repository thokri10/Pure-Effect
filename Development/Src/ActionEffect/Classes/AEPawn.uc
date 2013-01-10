class AEPawn extends UTPawn;

function AddDefaultInventory()
{

	InvManager.CreateInventory(class'ActionEffect.AEWeapon');
}

DefaultProperties
{
	InventoryManagerClass=class'AEInventoryManager'
}
