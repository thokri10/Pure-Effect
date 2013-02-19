/** A text-based HUD for the menu. */
class AEHUDMenu extends Actor
	dependson(AEMissionObjective)
	dependson(AEJSONparser);

//-----------------------------------------------------------------------------
// Structures & Enum
 
/** Struct that represents the current active (selected) menu entry. */
struct SelectStruct
{
	var int     id;
	var string  name;
};

var enum menuPosition
{
	MENU_MISSION,
	MENU_PROFILE
} position;

//-----------------------------------------------------------------------------
// Classes

/** Controller for the player. */
var AEPlayerController          PC;


//-----------------------------------------------------------------------------
// Variables

/** Path of the menu. Set together by adding all the stringarray together. 
 *  Easy to remove the last path and go back in menu.
 */
var array<string>               menuPath;

/** Saves all the available missions in an array for us. */
var array<MissionObjectives>    menuMissions;
var array<SimpleMissionStruct>  missions;
var MissionObjectives           activeMission;

/** Saves which menuselections we have. */
var array<SelectStruct>         menuSelections;

/** Currently selected menu slot. */
var int     selectedMenuSlot;

/** String (JSON) that we receive from the database. */
var string  DBSTRING;

/** posision of backButton in the menu */
var int     BACK;

/** Booleans to check what menu we are expecting to create on the next answer 
 *  from server. 
 */
var bool    bMenuSelection;
var bool    bMenuInfo;


//-----------------------------------------------------------------------------
// Events

/** Overrode base function of PostBeginPlay. Currently doesn't do
 *  anything special. 
 */
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}


//-----------------------------------------------------------------------------
// Init

/** Initializes the menu. */
function initMenu()
{
	local int i;
	local bool reset;

	reset = true;

	for( i = 0; i < menuSelections.Length; i++)
	{
		if( i == 1 )
			reset = false;

		PC.mHUD.addMenuSelections(menuSelections[i].name, reset);
	}
	
	PC.mHUD.setMenuActive(0);
	selectedMenuSlot = 0;

	setBack(menuSelections.Length);
}

/** Empties the menu for entries. */
function resetMenuSelection()
{
	PC.mHUD.addMenuSelections("", true);
	menuSelections.Length = 0;
	PC.mHUD.setMenuActive(0);
	selectedMenuSlot=0;
}

/**  Fills up the main menu with menu entries. */
function setMainMenu()
{
	local SelectStruct selection;

	resetMenuSelection();

	selection.id = 0;
	selection.name = "Show missions";
	menuSelections.AddItem(selection);
	
	selection.id = 1;
	selection.name = "Show profile";
	menuSelections.AddItem(selection);

	menuPath.Length = 0;

	initMenu();
}

/** Updates the menu with the menuPath variable in this class. */
function UpdateMenuFromPath()
{
	local int i;

	PC.myTcpLink.databasePath = "";

	for( i = 0; i < menuPath.Length; i++)
	{
		PC.myTcpLink.databasePath = PC.myTcpLink.databasePath $ menuPath[i];

		if(i != menuPath.Length - 1)
			PC.myTcpLink.databasePath = PC.myTcpLink.databasePath $ "/";
	}

	PC.myTcpLink.getMenuSelections();
}

/** Set the back (previous) button on the bottom of the selection. */
function setBack(int i)
{
	BACK = i;

	if(menuPath.Length != 0)
		PC.mHUD.addMenuSelections("BACK");
	else
		PC.mHUD.addMenuSelections("QUIT");
}


//-----------------------------------------------------------------------------
// Menu Selection

/** Jumps down in the menu. */
function nextMenuSlot()
{
	if(selectedMenuSlot >= menuSelections.Length)
		return;

	++selectedMenuSlot;

	PC.mHUD.setMenuActive(selectedMenuSlot);
}

/** Jumps up in the menu. */
function preMenuSlot()
{
	if( selectedMenuSlot < 1 )
		return;

	--selectedMenuSlot;

	PC.mHUD.setMenuActive(selectedMenuSlot);
}

/** Selects the selected choice in the menu. */
function Select()
{
	if(selectedMenuSlot == BACK)
	{
		if( menuPath.Length == 0 ){
			ConsoleCommand("quit");
		}
		if(menuPath.Length == 1){
			MenuPath.Length = menuPath.Length - 1;
			setMainMenu();
		}
		else if(MenuPath[menuPath.Length - 1] != "")
		{
			MenuPath.Length = menuPath.Length - 1;
			bMenuSelection = true;
			UpdateMenuFromPath();
		}
	}
	else
	{
		// Main menu choices. Add more under here when you add more.
		if( menuPath.Length == 0 )
		{
			if( menuSelections[selectedMenuSlot].name == "Show missions" )
			{
				MenuPath[0] = "missions";
				position = MENU_MISSION;
				bMenuSelection = true;
				UpdateMenuFromPath();
			}
			else if( menuSelections[selectedMenuSlot].name == "Show profile" )
			{
				// soldiers is the folder where the server saves to profile info.
				// Returns the profile with set username and password
				menuPath[0] = "soldiers"; 
				position = MENU_PROFILE;
				bMenuSelection = true;
				UpdateMenuFromPath();
			}
		}
		// The second menu you get to. 
		// Should be splitted up after all the choices you have in main menu selections.
		else if ( menuPath.Length == 1 )
		{
			if( MenuPath[0] == "missions" )
			{
				MenuPath[1] = string( selectedMenuSlot );

				showMissionInfo(missions[selectedMenuSlot]);
			}
		}

		else if( menuPath.Length == 2 )
		{
			if( menuSelections[selectedMenuSlot].name == "Accept" )
			{
				PC.myMissionObjective.activateObjectives( activeMission );
				resetMenuSelection();
			}
		}
	}
}


//-----------------------------------------------------------------------------
// Menu Selection Init

/** Gets a string from server that get parsed to a menu selection */
function stringFromServer(string menuString)
{
	local SimpleMissionStruct selectedMission;
	local ValueStruct           value;
	local SelectStruct      selection;
	local array<Array2D>    parsedArray;
	local Array2D           mission;
	local int id;
	
	resetMenuSelection();
	missions.Length = 0;

	parsedArray = PC.parser.fullParse( menuString );

	switch( position )
	{
	case MENU_MISSION:
		foreach parsedArray( mission )
		{
			missions.AddItem( PC.myMissionObjective.parseArrayToSimpleStruct( mission.variables ) );
		}

		foreach missions( selectedMission )
		{
			foreach selectedMission.information( value )
			{
				if( value.type == "title" )
				{
					selection.id = id++;
					selection.name = value.value;
					menuSelections.AddItem(selection);
				}
			}
		}
	case MENU_PROFILE:
		foreach parsedArray( mission )
			showProfileInfo( mission.variables );
	}

	bMenuSelection = false;

	initMenu();
}

/** Puts the mission info to the screen. */
function showMissionInfo(SimpleMissionStruct objective)
{
	local SelectStruct      selection;

	activeMission = PC.myMissionObjective.MissionFromSimpleStruct( objective );

	resetMenuSelection();

	PC.mHUD.addMissionInfo( "Category    : " $ activeMission.category, true );
	PC.mHUD.addMissionInfo( "Name        : " $ activeMission.title );
	PC.mHUD.addMissionInfo( "Map         : " $ activeMission.mapName );
	PC.mHUD.addMissionInfo( "description : " $ activeMission.description );

	selection.id = 0;
	selection.name = "Accept";

	menuSelections.AddItem( selection );

	initMenu();
}

/** Puts the profile info to screen */
function showProfileInfo(array<ValueStruct> information)
{
	local ValueStruct   value;
	local SelectStruct  selection;

	PC.mHUD.addMissionInfo( "", true );
	foreach information( value )
	{
		if      ( value.type == "id" )      PC.mHUD.addMissionInfo( "ID   : " $ value.value );
		else if ( value.type == "name" )    PC.mHUD.addMissionInfo( "Name : " $ value.value );
	}

	selection.id = 0;
	selection.name = "Itemlist";

	menuSelections.AddItem( selection );
}

DefaultProperties
{
	MenuPath(0) = ""
	DBSTRING = "[{\"category\":\"Search and destroy\",\"city_name\":\"Yorik\",\"description\":\"Regain loot\",\"id\":1,\"title\":\"Marauders\"},{\"category\":\"Search and destroy\",\"city_name\":\"Gaupang\",\"description\":\"Kill the robbers\",\"id\":2,\"title\":\"Bank robbers\"},{\"category\":\"Search and destroy\",\"city_name\":\"Valhall\",\"description\":\"Regain loot\",\"id\":3,\"title\":\"Marauders\"\}]"
}
