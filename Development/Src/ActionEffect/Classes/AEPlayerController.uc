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
var class<AEJSONParser>     pars;
var AEJSONParser            parser;

/** HudMenu */
var AEHUDMenu               myMenu;

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


//-----------------------------------------------------------------------------
// Variables

var HudLocalizedMessage     message;
var int                     credits;

/** Changes to true if any objectives changes, so the client can get updates from the server. */
var bool                    bObjectivesUpdated;

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
	local AEInventory_Item item;
	local AEReplicationInfo GameObj;
	
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

	foreach WorldInfo.AllActors(class'AEReplicationInfo', GameObj){
		`log("DER");
		myReplicationInfo = GameObj;
		SetTimer(1, true, 'UpdateObjectives');
	}

	`log(IdentifiedTeam);

	
	myJetpack = Spawn(class'AEJetpack');
	myJetpack.PC = self;
	myJetpack.jetpackEnabled = true;
	

	`log("SETTING UP A NEW PLAYERCONTROLLER!!!!! : " $ self $ " : " $ WorldInfo.NetMode);

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

	arr = parser.fullParse(serverText);

	mHUD = AEHUD( myHUD );

	myMissionObjective.Initialize(arr[0].variables);
}

event Possess(Pawn inPawn, bool bVehicleTrasition)
{
	myPawn = AEPawn_Player( inPawn );
	super.Possess(inPawn, bVehicleTrasition);
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
	/*
	if(bObjectivesUpdated)
	{
		UpdateObjectives();
	}
	*/
}

//-----------------------------------------------------------------------------
// Inventory 

/** Puts a weapon to your inventory. */
function addWeaponToInventory(UTWeapon weap)
{
	myPawn.AddWeaponToInventory( weap );
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

//---------------------------------------
// Objective server code

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
	`log(redOwner $ " : " $ redScore);
	`log(blueOwner $ " : " $ blueScore);

	mHUD.setObjectiveInfo( redOwner == 0 ? "Red" : "Bue", redScore, 
							blueOwner >= 1 ? "Blue" : "Red", blueScore );
}

DefaultProperties
{
	PlayerInfo = class'AEPlayerInfo'
	InputClass = class'AEPlayerInput'
	pars = class'AEJSONParser'
	bObjectivesUpdated = true;
}