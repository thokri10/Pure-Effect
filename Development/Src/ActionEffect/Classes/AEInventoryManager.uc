class AEInventoryManager extends UTInventoryManager;

var Weapon weapon1;
var Weapon weapon2;

simulated function SwitchWeapon(byte NewGroup)
{
	local AEPlayerController PC;

	PC = AEPlayerController( GetALocalPlayerController() );

	`log(int(NewGroup));

	if(PC.bInMenu)
		PC.myMenu.NumberInput(int(NewGroup));
	else
		if(NewGroup == 1)
			SetCurrentWeapon(weapon1);
		else if(NewGroup == 2)
			SetCurrentWeapon(weapon2);
}

simulated function bool AddInventory( Inventory NewItem, optional bool bDoNotActivate )
{
	if(weapon1 == None)
		weapon1 = Weapon(NewItem);
	else if(weapon2 == None)
		weapon2 = Weapon(NewItem);

	super.AddInventory(NewItem, bDoNotActivate);
}

function bool addWeaponToInventory(Inventory NewItem, int slot)
{
	if(UTWeapon(NewItem) == None)
		return false;


	return true;
}
 
defaultproperties
{
}