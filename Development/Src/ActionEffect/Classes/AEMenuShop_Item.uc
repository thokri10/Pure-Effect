class AEMenuShop_Item extends Object
	dependson(AEWeaponCreator)
	dependson(AEInventory_Item);

var int Cost;

var private string m_type;

var private WeaponStruct m_weapon;
var private AEInventory_Item m_item;

function bool setItem(const AEInventory_Item item)
{
	if(item != None)
	{
		if(m_weapon.type != "")
			m_weapon.type = "";

		m_type = "item";
		m_item = item;

		return true;
	}

	return false;
}

function bool setWeapon(const WeaponStruct weap)
{
	if(weap.type != "")
	{
		if(m_item != None)
			m_item = None;

		m_type = "weapon";
		m_weapon = weap;

		return true;
	}

	return false;
}

function AEInventory_Item getItem() 
{
	return m_item;
}

function WeaponStruct getWeapon() 
{
	return m_weapon;
}

function setType(string type)
{
	if( type == "weapon" || type == "item" )
		m_type = type;
	else
		`log("[ShopItem] Type specifier is wrong");
}

function String getType()
{
	return m_type;
}

DefaultProperties
{
}
