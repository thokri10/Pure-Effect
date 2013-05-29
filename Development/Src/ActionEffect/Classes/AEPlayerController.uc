// THIS CLASS IS RESPONSIBLE FOR CONTROLLING THE PLAYER'S CHARACTER.
class AEPlayerController extends UTPlayerController
	dependson(AEJSONParser);

//-----------------------------------------------------------------------------
// Classes

var ActionEffectGame        myGame;

/** Character that the player controls. */
var AEPawn_Player           myPawn;

/** Holds our playerinfo to the server. This also changes playerpawn behavior when we get items. */
var class<AEPlayerInfo>     PlayerInfo;
var AEPlayerInfo            myPlayerInfo;

/** Network module used to gain weapon info from server. */
var AETcpLinkClient         myTcpLink;

/** All parsing goes trough this class */
var class<AEJSONParser>     Parser;
var AEJSONParser            myParser;

var class<AEJSONComposer>   Composer;
var AEJSONComposer          myJSONComposer;

/** HudMenu */
var AEHUDMenu               myMenu;

/** Graphical menu */
var AEMainMenu              myMainMenu;

/** Print out our textmenu on the screen */
var AEHUD                   mHUD;

/** Mission module that initialize mission and spawns it's objectives. */
var AEMissionObjective      myMissionObjective;

/** Inventory for different items we are using */
var AEInventory             myItemInventory;

/** Responsible for generating weapons. */
var AEWeaponCreator         myWeaponCreator;

/** Jetpack */
var AEJetpack               myJetpack;

/** Replication info for multiplayer. Keeps track over the different objectives and time */
var AEReplicationInfo       myReplicationInfo;

/** Contains all the information for missions, items and shop that the menu needs */
var class<AEDataStorage>    DataStorage;
var AEDataStorage           myDataStorage;


//-----------------------------------------------------------------------------
// Variables

var HudLocalizedMessage     message;
var int                     credits;

/** Changes to true if any objectives changes, so the client can get updates from the server. */
var bool                    bObjectivesUpdated;

/** True if we are in menu. To stop input to pawn and change input behavior */
var bool                    bInMenu;

/** Item loadout to equip when player spawns */
var string                  loadout;

var string test;


replication
{	
	if(bNetDirty)
		bObjectivesUpdated;
	if(bNetDirty && bNetOwner && Role == ROLE_Authority)
		myPawn, myReplicationInfo;
}

//-----------------------------------------------------------------------------
// Events 

/** Initializations before any pawns spawn on the map. */
simulated event PostBeginPlay()
{
	local AEReplicationInfo GameObj;
	local AEInventory_Item i1;
	local AEInventory_Item i2;
	local AEInventory_Item i3;

	i1 = spawn(class'AEInventory_Item');
	i1.StackCounter = 2;
	i1.itemName = "Shield";
	i1.damage = 50;
	i1.delay = 4;
	i1.Cooldown = 10;
	i1.radius = 500;
	i1.Effects.AddItem(EFFECT_SHIELD);

	i2 = spawn(class'AEInventory_Item');
	i2.StackCounter = 5;
	i2.itemName = "Granade";
	i2.damage = 50;
	i2.delay = 4;
	i2.Cooldown = 2;
	i2.radius = 500;
	i2.Effects.AddItem(EFFECT_GRANADE);
	
	i3 = spawn(class'AEInventory_Item');
	i3.StackCounter = 1;
	i3.itemName = "Heal";
	i3.damage = 25;
	i3.delay = 0;
	i3.Cooldown = 10;
	i3.radius = 500;
	i3.Effects.AddItem(EFFECT_HEAL);
	
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

	myItemInventory.AddItemToSlot(0, i1);
	myItemInventory.AddItemToSlot(1, i2);
	myItemInventory.AddItemToSlot(2, i3);

	myMenu = Spawn(class'AEHUDMenu');
	myMenu.PC = self;

	myParser = new Parser;

	myPlayerInfo = new PlayerInfo;
	myPlayerInfo.PC = self;
	myPlayerInfo.myTcpClient = myTcpLink;
	myPlayerInfo.myWeaponCreator = myWeaponCreator;
	myPlayerInfo.myInventory = myItemInventory;
	myPlayerInfo.inits();

	myDataStorage = new DataStorage;
	myDataStorage.myMissionObjective = myMissionObjective;
	myDataStorage.myPlayerInfo = myPlayerInfo;

	foreach WorldInfo.AllActors(class'AEReplicationInfo', GameObj){
		`log("ReplicationInfo in map");
		myReplicationInfo = GameObj;
		SetTimer(1, true, 'UpdateObjectives');
	}

	if(myReplicationInfo == None)
	{
		myJetpack = Spawn(class'AEJetpack');
		myJetpack.PC = self;
		myJetpack.jetpackEnabled = true;
	}

	myJSONComposer = new Composer;

	//myTcpLink.sendString( myComposer.ComposeString() );

	// Connect to server.
	//myTcpLink.ResolveMe();

}

/** Function that is used from ActionGameEffect to activate our desired mission after a map change */
function InitMission(int MissionID)
{
	myTcpLink.getMission(MissionID);
}

/** Initializes a mission from server string */
function InitializeMission(string serverText)
{
	local array<array2D> arr;

	arr = myParser.fullParse(serverText);

	mHUD = AEHUD( myHUD );

	myMissionObjective.Initialize(arr[0].variables);

	myTcpLink.getWeapon();
}

event Possess(Pawn inPawn, bool bVehicleTrasition)
{
	myPawn = AEPawn_Player( inPawn );
	myPawn.AEPC = self;
	super.Possess(inPawn, bVehicleTrasition);

	if(myPawn != None)
	{
		SetTimer(6,, 'getMyLoadOut');
	}
}

event PlayerTick(float DeltaTime)
{
	super.PlayerTick(DeltaTime);

	if (myHUD != none)
	{
		if (mHUD == none)
		{
			mHUD = AEHUD( myHUD );
		}
	}
	
	//if(mHUD != None)
		//mHUD.SetGameTimer(myReplicationInfo.getGameTime());
	/*
	if(bObjectivesUpdated)
	{
		UpdateObjectives();
	}
	*/
}

exec function GoToMenu()
{
	ConsoleCommand("open AE-MainMenu");
}

exec function StartMissionE()
{
	myMissionObjective.InitializEscort();
}

exec function StartMissionKill()
{
	myMissionObjective.InitializKill();
}

//-----------------------------------------------------------------------------
// Inventory 

/** Puts a weapon to your inventory. */
function addWeaponToInventory(UTWeapon weap)
{
	myPawn.AddWeaponToInventory( weap );
}

function EquipLoadout(String in)
{
	local array<Array2D> items;
	local Array2D item;
	local int i;

	myPlayerInfo.setItemLoadout(loadout);
	items = myParser.fullParse(in);
	foreach items(item)
	{
		myPlayerInfo.addItems(item.variables);
	}

	for(i = 0; i < myPlayerInfo.loadoutLength; ++i)
	{
		myPlayerInfo.getItem(i, myPlayerInfo.itemLoadout[i]);
	}
}

//-----------------------------------------------------------------------------
// Jetpack

/** Uses the motherfuckin' jetpack. */
function useJetpacking()
{
	myJetpack.StartJetpacking();
}

/** Stops using that motheruckin' jetpack. */
function stopJetpacking()
{
	myJetpack.StopJetpacking();
}

//-----------------------------------------------------------------------------
// Console commands

/** Temp menu command */
exec function ppp()
{
	if(Role < ROLE_Authority)
		return;

	mHUD = AEHUD( myHUD );
	myMenu.setMainMenu();
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

function getMyLoadOut()
{
	if(loadout != "")
		myTcpLink.getWeapon();
}

/** Generates a weapon generated by information from the server. */
exec function getServerWeapon(int id)
{
	myTcpLink.getWeapon();
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

//---------------------------------------
// Objective server code

exec function Flee()
{
	if(Role < ROLE_Authority)
	{
		ServerFlee(IdentifiedTeam);
	}else{
		if(myReplicationInfo.Flee(IdentifiedTeam)){
			//ConsoleCommand("quit");
		}
	}
}

reliable server function ServerFlee(int team)
{
	if(AEPlayerController(GetALocalPlayerController()).myReplicationInfo.Flee(team))
	{
		//ConsoleCommand("quit");
	}
}

simulated function UpdateObjectives()
{
	bObjectivesUpdated = false;

	ServerResetObjectiveUpdate();

	UpdateMultiplayerHud();
}

reliable server function ServerResetObjectiveUpdate()
{
	bObjectivesUpdated = false;
}

simulated function AddToScore(int teamID)
{
	if(myReplicationInfo != None)
	{
		myReplicationInfo.addScore(teamID);

		if(Role < ROLE_Authority)
			ServerAddToRedScore(teamID);
	}
}

reliable server function ServerAddToRedScore(int teamID)
{
	if(Role < ROLE_Authority)
		return;

	myReplicationInfo.addScore(teamID);
}

/** Updates the objective info to the HUD */
function UpdateMultiplayerHud()
{
	local int redOwner;
	local int blueOwner;
	local int redScore;
	local int blueScore;

	myReplicationInfo.GetInfo(redOwner, blueOwner, redScore, blueScore);

	if(mHUD != None)
		mHUD.setObjectiveInfo( redOwner == 0 ? "Red" : "Blue", redScore, 
								blueOwner >= 1 ? "Blue" : "Red", blueScore );
}

DefaultProperties
{
	PlayerInfo = class'AEPlayerInfo'
	InputClass = class'AEPlayerInput'
	DataStorage = class'AEDataStorage'
	Parser = class'AEJSONParser'
	Composer = class'AEJSONComposer'
	bObjectivesUpdated = true;
}