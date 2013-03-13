// THIS CLASS IS RESPONSIBLE FOR CONTROLLING THE PLAYER'S CHARACTER.
class AEPlayerController extends UTPlayerController
	dependson(AEJSONParser);

//-----------------------------------------------------------------------------
// Classes

var ActionEffectGame        myGame;

// Character that the player controls.
var AEPawn_Player           myPawn;

// Holds our playerinfo to the server. This also changes playerpawn behavior when we get items.
var class<AEPlayerInfo>     PlayerInfo;
var AEPlayerInfo            myPlayerInfo;

// Network module used to gain weapon info from server.
var AETcpLinkClient         myTcpLink;

// All parsing goes trough this class
var class<AEJSONParser>     pars;
var AEJSONParser            parser;

// HudMenu
var AEHUDMenu               myMenu;
// Print out our textmenu on the screen
var AEHUD                   mHUD;

// Mission module that initialize mission and spawns it's objectives.
var AEMissionObjective      myMissionObjective;

// Inventory for different items we are using
var AEInventory             myItemInventory;

// Responsible for generating weapons.
var AEWeaponCreator         myWeaponCreator;


//-----------------------------------------------------------------------------
// Variables

var HudLocalizedMessage     message;
var int                     credits;

var string test;

replication
{
	if(bNetDirty && bNetOwner && Role == ROLE_Authority)
		myPawn;
}

//-----------------------------------------------------------------------------
// Events 

/** Initializations before any pawns spawn on the map. */
simulated event PostBeginPlay()
{
	local AEInventory_Item item;

	// Initializations of various variables.
	super.PostBeginPlay();

	myTcpLink = Spawn(class'AETcpLinkClient');
	myTcpLink.PC = self;

	myWeaponCreator = Spawn(class'AEWeaponCreator');
	myWeaponCreator.PC = self; 

	myMissionObjective = Spawn(class'AEMissionObjective');
	myMissionObjective.PC = self;

	myItemInventory = Spawn(class'AEInventory');
	myItemInventory.PC = self;

	item = spawn(class'AEInventory_Item', self);
	item.delay = 10;
	item.Effects.AddItem(EFFECT_SHIELD);
	item.Cooldown = 10;
	item.StackCounter = 10;

	myItemInventory.AddItem(item);

	myMenu = Spawn(class'AEHUDMenu');
	myMenu.PC = self;

	parser = new pars;

	myPlayerInfo = new PlayerInfo;
	myPlayerInfo.PC = self;
	myPlayerInfo.myTcpClient = myTcpLink;
	myPlayerInfo.myWeaponCreator = myWeaponCreator;
	myPlayerInfo.myInventory = myItemInventory;

	`log("SETTING UP A NEW PLAYERCONTROLLER!!!!! : " $ self $ " : " $ WorldInfo.NetMode);

	// Connect to server.
	//myTcpLink.ResolveMe();

}

event Possess(Pawn inPawn, bool bVehicleTrasition)
{
	myPawn = AEPawn_Player( inPawn );
	super.Possess(inPawn, bVehicleTrasition);
}

function Tick(float DeltaTime)
{
	if (myHUD != none)
	{
		if (mHUD == none)
		{
			mHUD = AEHUD( myHUD );
		}
	}

	//StartSprinting(DeltaTime);
	//StartUsingTheJetpack(DeltaTime);
}

/*
function UpdateSprintEnergy(float DeltaTime)
{
	local int regeneratorFactor;
	regeneratorFactor = -1.0f;

	if (myPawn.regenerateSprintEnergy)
	{
		regeneratorFactor = 1.0f;
	}

	myPawn.sprintEnergy += regeneratorFactor * (myPawn.sprintEnergyLossPerSecond * DeltaTime);

	if (myPawn.sprintEnergy < 0.0f)
	{
		myPawn.sprintEnergy = 0.0f;
		myPawn.isSprinting = false;
	}
	else if (myPawn.sprintEnergy > myPawn.maxSprintEnergy)
	{
		myPawn.sprintEnergy = myPawn.maxSprintEnergy;
	}
}

function StartSprinting(float DeltaTime)
{
	UpdateSprintEnergy(DeltaTime);

	if (myPawn.isSprinting)
	{
		myPawn.GroundSpeed = 1000.0f;
	}
	else
	{
		myPawn.GroundSpeed = 600.0f;
	}
}

function StartUsingTheJetpack(float DeltaTime)
{
	if (isUsingJetPack)
	{
		if (fuelEnergy > 0.0f)
		{
			CustomGravityScaling = -1.0f;
			// Commented out temporarily for debugging reasons.
			//fuelEnergy -= (fuelEnergyLossPerSecond * DeltaTime);
		}
		
		if (fuelEnergy < 0.0f)
		{
			fuelEnergy = 0.0f;
		}
	}
	else
	{
		CustomGravityScaling = 1.0f;
	}
}
*/
//-----------------------------------------------------------------------------
// Inventory 

/** Puts a weapon to your intventory */
function addWeaponToInventory(UTWeapon weap)
{
	myPawn.AddWeaponToInventory( weap );
}


//-----------------------------------------------------------------------------
// Console commands

/** Temp menu command */
exec function ppp()
{
	mHUD = AEHUD( myHUD );
	myMenu.setMainMenu();

	`log("isSprinting: " $ myPawn.isSprinting $ " regenerateSprintEnergy: " $ myPawn.regenerateSprintEnergy);
}

/** Login with username and password */
exec function logIn(string user, optional string password)
{
	if (mHUD == none)
	{
		mHUD = AEHUD(myHUD);
	}

	myTcpLink.logIn(user, password);
	mHUD.postError("Logging in...");
}

/** Generates a weapon. */
exec function getWeapon(string type, float spread, int magazineSize, float reloadTime, float damage, float speed)
{
	local UTWeapon wep;
	wep = myWeaponCreator.CreateWeapon(type, spread, magazineSize, reloadTime, damage, speed);

	if (wep != none)
	{
		AddWeaponToInventory( wep );
	}
}

/** Generates a weapon generated by information from the server. */
exec function getServerWeapon(int id)
{
	myTcpLink.getWeapon(id);
}

/** Uses item with spesified inventory slot */
exec function UseItem(int slot)
{
	if (mHUD == none)
	{
		mHUD = AEHUD(myHUD);
	}

	if(WorldInfo.NetMode != NM_ListenServer)
	{
		//myItemInventory.Use(slot);
		// Runs antoher function on the server side. This will the use the item.
		serverUseItem(slot);
	}else{
		myItemInventory.Use(slot);
	}
}

/** This function is only runned on the server client. 
 *  It uses the item with a spesified slot */
reliable server function serverUseItem(int slot)
{
	myItemInventory.Use(slot);
}

DefaultProperties
{
	PlayerInfo = class'AEPlayerInfo'
	InputClass = class'AEPlayerInput'
	pars = class'AEJSONParser'
}