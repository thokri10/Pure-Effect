/** Inventory that contains player items (NOT WEAPONS). */
class AEInventory extends Actor;
 
/** Inventory that can hold up to three items. */
var AEInventory_Item ItemList[3];

/** Controller for the player. */
var AEPlayerController PC;

/** Use an item. */
function Use(int itemSlot)
{
	if( !ItemList[itemSlot].Use() )
	{
	}
}

/** -Assigns- an item to a slot. */
function AddItemToSlot(int slot, AEInventory_Item item)
{
	ItemList[slot] = item;
}

/** -Adds- an item to the inventory. 
 *  If the item isn't already in the inventory
 *  or the inventory is full, then tough shit.
 *  It's not going to be added then.
 */
function AddItem(AEInventory_Item item)
{
	local int i;

	for(i = 0; i < 3; i++)
	{
		if( ItemList[i] == item )
		{
			ItemList[i].add();
			return;
		}
		else if( ItemList[i] == none )
		{
			ItemList[i] = item;
			return;
		}
	}
}

DefaultProperties
{
	ItemList(0) = none;
	ItemList(1) = none;
	ItemList(2) = none;
}
