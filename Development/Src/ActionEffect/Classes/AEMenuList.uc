class AEMenuList extends AEMenuShop;

var private array<AEInventory_Item> m_items;
var private array<WeaponStruct> m_weapons;

function array<AEInventory_Item> getItems()
{
	return m_items;
}

function array<WeaponStruct> getWeapons()
{
	return m_weapons;
}

private function addWeapon(const array<ValueStruct> item)
{
	m_weapons.AddItem( PC.myWeaponCreator.parseToStruct( item ) );
}

private function addItem(const array<ValueStruct> item)
{
	m_items.AddItem( PC.myItemInventory.createItem( item ) );
}

DefaultProperties
{
}
