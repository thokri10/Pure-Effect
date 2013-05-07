/** Inventory that contains player items (NOT WEAPONS). */
class AEInventory extends Actor
	dependson(AEJSONParser);
 
/** Inventory that can hold up to three items. */
var private const int  itemListSize_;
var AEInventory_Item ItemList_[4];

/** Controller for the player. */
var AEPlayerController PC;

/** Use an item. */
function Use(int itemSlot)
{
	if( !ItemList_[itemSlot].use() )
	{
		`log("[Item] Failed to use item : Look above for error");
	}
}

/** -Assigns- an item to a slot. */
function AddItemToSlot(int slot, AEInventory_Item item)
{
	item.PC = PC;
	ItemList_[slot] = item;
}

/** Creates an item from parsed json string */
function AEInventory_Item createItem(array<ValueStruct> itemValues)
{
	local ValueStruct value;
	local AEInventory_Item item;

	item = spawn(class'AEInventory_Item', PC.myPawn,, PC.myPawn.Location,,, true);

	foreach itemValues( value )
	{
		if( value.type == "type" ) 
		{
			if( value.value == "healthpack" )   item.Effects.AddItem(EFFECT_HEAL);
			else if( value.value == "granade" ) item.Effects.AddItem(EFFECT_GRANADE);
			else if( value.value == "shield" ) item.Effects.AddItem(EFFECT_SHIELD);
		}
		else if( value.type == "name")      item.itemName       = value.value;
		else if( value.type == "damage")    item.damage         = int(value.value);
		else if( value.type == "cooldown")  item.Cooldown       = float(value.value);
		else if( value.type == "quantity")  item.StackCounter   = int(value.value);
		else if( value.type == "id")        item.id             = int(value.value);
	}

	return item;
}

/** -Adds- an item to the inventory. 
 *  If the item isn't already in the inventory
 *  or the inventory is full, then tough shit.
 *  It's not going to be added then.
 */
function AddItem(AEInventory_Item item)
{
	local int i;

	item.PC = PC;

	for(i = 0; i < itemListSize_; i++)
	{
		if( ItemList_[i].itemName == item.itemName )
		{
			ItemList_[i].add(item.StackCounter);
			return;
		}
	}

	for(i = 0; i < itemListSize_; i++)
	{
		if( ItemList_[i] == None )
		{
			item.PC = PC;
			ItemList_[i] = item;
			return;
		}
	}
}

DefaultProperties
{
	itemListSize_ = 4;
}
