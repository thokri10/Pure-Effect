class AEPlayerInfo extends Object
	dependson(AEWeaponCreator);


//-----------------------------------------------------------------------------
// Player Inventory

var AETcpLinkClient     myTcpClient;
var AEWeaponCreator     myWeaponCreator;
var AEPawn_Player       myPawn;
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
	local ValueStruct        value;

	foreach itemArray( value )
	{
		if( value.type == "slot" )
		{
			if( value.value == "weapon" )
				weapons.AddItem( myWeaponCreator.parseToStruct( itemArray ) );
			else if( value.value == "item" )
				`log("Adding item");
			else if( value.value == "jetpack" )
				`log("JetPack");

			break;
		}
	}
}

DefaultProperties
{
}
