class AEPlayerInfo extends Object
	dependson(AEWeaponCreator);


//-----------------------------------------------------------------------------
// Player Inventory

var AETcpLinkClient     myTcpClient;
var AEWeaponCreator     myWeaponCreator;
var AEPawn_Player       myPawn;
var AEInventory         myInventory;
var AEPlayerController  PC;


//-----------------------------------------------------------------------------
// Player Info

var int     ID;
var string  playerName;
var string  clan;


//-----------------------------------------------------------------------------
// Player Inventory

var array<WeaponStruct>     weapons;
var array<AEInventory_Item> items;

// Items that should equip when loading the game. 
// These are put into a string splitted with ';' into command line
// so we can get it at the start of the game. This will contain six numbers. -1 is no item.
var int                     loadoutLength;
var int                     itemLoadout[6];

function inits()
{
	local int i;
	for( i = 0; i < loadoutLength; ++i)
	{
		itemLoadout[i] = -1;
	}
}

function AEPlayerInfo Initialize(array<ValueStruct> inf)
{
	local ValueStruct value;
	
	foreach inf( value )
	{
		if      ( value.type == "id" )      ID = int(value.value);
		else if ( value.type == "name" )    playerName = value.value;
	}

	return self;
}

function addItems(array<ValueStruct> itemArray)
{          
	local ValueStruct   value;

	foreach itemArray( value )
	{
		if( value.type == "slot" )
		{
			if( value.value == "weapon" )
				weapons.AddItem( myWeaponCreator.parseToStruct( itemArray ) );
			else if( value.value == "item") {
				items.AddItem( myInventory.createItem( itemArray ) );
			}else if( value.value == "jetpack" )
				`log("JetPack");

			break;
		}
	}
}

function addItemToLoadout(int slot, int itemID)
{
	`log(slot $ " : " $ itemID);
	itemLoadout[slot] = itemID;
	`log(itemLoadout[slot]);
}

/** Returns a string fith all the item id with each slot seperated with ';' */
function string getItemLoadout()
{
	local string str;
	local int i;

	for(i = 0; i < loadoutLength; i++)
	{
		if(str == "")
			str = "" $ itemLoadout[i];
		else
			str = str $ ";" $ itemLoadout[i];
	}

	`log("STRING: " $ str);
	
	return str;
}

function setItemLoadout(string in)
{
	local int i;
	local array<string> str;

	str = SplitString(in, ";");

	for(i = 0; i < loadoutLength; ++i)
	{
		itemLoadout[i] = int(str[i]);
	}
}

function getItem(int slot, int itemID)
{
	local int i;

	for(i = 0; i < weapons.Length; ++i)
	{
		`log("WEAPONS!!! : " $ weapons[i].id $ " : " $ itemID);
		if(weapons[i].id == itemID){
			`log("ADDING WEAPONS");
			PC.addWeaponToInventory( PC.myWeaponCreator.CreateWeaponFromStruct( weapons[i] ) );
		}
	}

	for(i = 0; i < items.Length; ++i)
	{
		if(items[i].id == itemID)
			PC.myItemInventory.AddItemToSlot( slot, items[i] );
	}
}

function WeaponStruct getWeapon(const int weaponID)
{
	return weapons[weaponID];
}

function AEInventory_Item getItems(const int itemID)
{
	return items[itemID];
}

DefaultProperties
{
	loadoutLength = 6;
}
