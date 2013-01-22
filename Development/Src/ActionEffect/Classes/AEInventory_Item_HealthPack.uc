class AEInventory_Item_HealthPack extends AEInventory_Item;

var int HealAmount;

simulated function bool Use()
{
	if( !super.Use() )
		return false;

	PC.myPawn.Health += HealAmount;

	return true;
}

DefaultProperties
{
	HealAmount=25
	UseCounter=2
	Cooldown=10

	ItemInfo="Heals the player for X amount of HP"
}
