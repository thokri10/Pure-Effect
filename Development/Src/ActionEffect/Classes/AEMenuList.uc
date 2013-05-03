class AEMenuList extends Object
	dependson(AEJSONParser);

var AEPlayerController PC;

var private array<AEInventory_Item> items_;
var private array<WeaponStruct> weapons_;

function addItems(const array<Array2D> items)
{
	local Array2D item;

	foreach items(item)
	{
		addEquipment(item.variables);
	}
}

function array<AEInventory_Item> getItems()
{
	return items_;
}

function array<WeaponStruct> getWeapons()
{
	return weapons_;
}

function Clear()
{
	items_.Length = 0;
	weapons_.Length = 0;
}

private function addEquipment(const array<ValueStruct> item)
{
	local ValueStruct value;

	foreach item( value )
	{
		if( value.type == "slot" )
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
	weapons_.AddItem( PC.myWeaponCreator.parseToStruct( item ) );
}

private function addItem(const array<ValueStruct> item)
{
	items_.AddItem( PC.myItemInventory.createItem( item ) );
}

DefaultProperties
{
}
