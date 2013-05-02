class AEMenuShop extends Object
	dependson(AEJSONParser);

var AEPlayerController PC;

var private class<AEMenuShop_Item> m_Item;
var private array<AEMenuShop_Item> m_Items;

function addItems(const array<Array2D> items)
{
	local Array2D item;

	foreach items(item)
	{
		addEquipment(item.variables);
	}
}

function AEMenuShop_Item getItem(const int itemID)
{
	return m_Items[itemID];
}

private simulated function addEquipment(const array<ValueStruct> item)
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

private simulated function addWeapon(const array<ValueStruct> item)
{
	//local WeaponStruct weap;
	local AEMenuShop_Item weap;
	weap = new m_Item;

	weap.setWeapon( PC.myWeaponCreator.parseToStruct(item) );
	weap.setType("weapon");
	m_Items.AddItem(weap);
}

private simulated function addItem(const array<ValueStruct> item)
{
	local AEMenuShop_Item item_;
	item_ = new m_Item;

	item_.setItem( PC.myItemInventory.createItem( item ) );
	item_.setType("item");
	m_Items.AddItem(item_);
}

DefaultProperties
{
}
