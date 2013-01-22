class AEInventory extends Actor;

var AEInventory_Item ItemList[3];

var AEPlayerController PC;

function Use(int itemSlot)
{
	if( !ItemList[itemSlot].Use() )
	{
	}
}

function AddItemToSlot(int slot, AEInventory_Item item)
{
	ItemList[slot] = item;
}

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
	ItemList(0)=none
	ItemList(1)=none
	ItemList(2)=none
}
