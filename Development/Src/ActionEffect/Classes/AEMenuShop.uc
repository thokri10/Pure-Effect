class AEMenuShop extends Object
	dependson(AEJSONParser);

var AEPlayerController PC;

var private class<AEMenuShop_Item> ShopItem;
var private array<AEMenuShop_Item> m_shopItems;

function setItems(const array<Array2D> items)
{
	local Array2D item;

	foreach items(item)
	{
		addEquipment(item.variables);
	}
}

function AEMenuShop_Item getItem(const int itemID)
{
	return m_shopItems[itemID];
}

private function addEquipment(const array<ValueStruct> item)
{
	local ValueStruct value;

	foreach item( value )
	{
		if( value.type == "type" )
		{
			if( value.value == "weapon" ){
				addWeapon(item); break;
			}else if( value.value == "item" ){
				addItem(item); break;		
			}
		}
	}
}

private function addWeapon(const array<ValueStruct> item)
{
	//local WeaponStruct weap;
	local AEMenuShop_Item weap;
	weap = new ShopItem;

	weap.setWeapon( PC.myWeaponCreator.parseToStruct(item) );
	weap.setType("weapon");
	m_shopItems.AddItem(weap);
}

private function addItem(const array<ValueStruct> item)
{
	local AEMenuShop_Item shpItem;
	shpItem = new ShopItem;

	shpItem.setItem( PC.myItemInventory.createItem( item ) );
	shpItem.setType("item");
	m_shopItems.AddItem(shpItem);
}

DefaultProperties
{
}
