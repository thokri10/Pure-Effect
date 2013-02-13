/** A text-based HUD for the menu. */
class AEHUDMenu extends Actor
	dependson(AEMissionObjective)
	dependson(AEJSONparser);
 
/** Struct that represents the current active (selected) menu entry. */
struct SelectStruct
{
	var int     id;
	var string  name;
};

/** TODO: FILL IN. */
var int numberOfServerStrings;

/** TODO: FILL IN. */
var int ServerCounter;

/** Path of the menu. Set together by adding all the stringarray together. 
 *  Easy to remove the last path and go back in menu.
 */
var array<string>               menuPath;

/** Saves all the available missions in an array for us. */
var array<MissionObjectives>    menuMissions;
var array<SimpleMissionStruct>  missions;

/** Saves which menuselections we have. */
var array<SelectStruct>         menuSelections;

/** Controller for the player. */
var AEPlayerController          PC;

/** Currently selected menu slot. */
var int     selectedMenuSlot;

/** String (JSON) that we receive from the database. */
var string  DBSTRING;

/** TODO: FILL IN. */
var int     BACK;

/** Booleans to check what menu we are expecting to create on the next answer 
 *  from server. 
 */
var bool    bMenuSelection;
var bool    bMenuInfo;

/** Overrode base function of PostBeginPlay. Currently doesn't do
 *  anything special. 
 */
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

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

/** Functions that this class do not use. Often called from TCP */
function numberOfStringFromServer(int number)
{
	numberOfServerStrings = number;
	ServerCounter = 0;
}

/* Duplicate function FIX!
function parseMissionArrayToMenu(array<string> MenuArray)
{
	local MissionObjectives objective;
	local SelectStruct      selection;

	objective = PC.myMissionObjective.parseArrayToMissionStruct( MenuArray );

	selection.id = objective.id;
	selection.name = objective.title;

	menuSelections.AddItem(selection);

	menuMissions.AddItem(objective);
}
*/

function stringFromServer(string menuString)
{
	local SimpleMissionStruct asd;
	local ValueStruct           dsa;
	local SelectStruct      selection;
	local array<Array2D>    parsedArray;
	local Array2D           mission;
	local int id;
	
	resetMenuSelection();
	missions.Length = 0;

	parsedArray = PC.parser.fullParse( menuString );

	foreach parsedArray( mission )
	{
		missions.AddItem( PC.myMissionObjective.parseArrayToSimpleStruct( mission.variables ) );
	}

	foreach missions( asd )
	{
		foreach asd.information( dsa )
		{
			if( dsa.type == "title" )
			{
				selection.id = id++;
				selection.name = dsa.value;
				menuSelections.AddItem(selection);
			}
		}
	}

	bMenuSelection = false;
	initMenu();

	/*
	if( bMenuSelection )
	{
		parseMissionArrayToMenu( PC.myTcpLink.parseToArray( menuString ) );
		++ServerCounter;

		if(numberOfServerStrings == ServerCounter)
		{
			ServerCounter = 0;
			bMenuSelection = false;
			initMenu();
		}
	}
	else if( bMenuInfo )
	{
		return;
	}
	*/
}

/**
 * TEMP FUNCTION FOR TESTING PURPOSES
 */
exec function ppp()
{
	setMainMenu();
}

/** Jumps down in the menu. */
/**
 * MENU SELECT FUNCTIONS
 */

// Jumps down in the menu.
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
				bMenuSelection = true;
				UpdateMenuFromPath();
			}
		}
		// The second menu you get to. Should be splitted up after all the choices you have in main menu selections.
		else if ( menuPath.Length == 1 )
		{
			if( MenuPath[0] == "missions" )
			{
				`log(selectedMenuSlot);
				MenuPath[1] = string( selectedMenuSlot );

				//showMissionInfo(missions[selectedMenuSlot]);
			}
		}

		else if( menuPath.Length == 2 )
		{
			if( menuSelections[selectedMenuSlot].name == "Accept" )
			{
				PC.myMissionObjective.activateObjectives( menuMissions[ int(MenuPath[1]) ] );
				resetMenuSelection();
			}
		}
	}
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

/** Puts the mission info to the screen. */
function showMissionInfo(MissionObjectives objective)
{
	local SelectStruct selection;

	resetMenuSelection();

	PC.mHUD.addMissionInfo( "Name        : " $ objective.title, true );
	PC.mHUD.addMissionInfo( "Map         : " $ objective.mapName );
	PC.mHUD.addMissionInfo( "Reward      : " $ objective.reward );
	PC.mHUD.addMissionInfo( "description : " $ objective.description );

	selection.id = 0;
	selection.name = "Accept";

	menuSelections.AddItem( selection );

	initMenu();
}

/**
 * Parsing function: Receives an string array with mission info and uses
 * it to display it on the HUD.
 */

function parseMissionArrayToMenu(array<string> MenuArray)
{
	local MissionObjectives objective;
	local SelectStruct      selection;

	objective = PC.myMissionObjective.parseArrayToMissionStruct( MenuArray );

	selection.id = objective.id;
	selection.name = objective.title;

	menuSelections.AddItem(selection);

	menuMissions.AddItem(objective);
}

/** Parsing function: Receives the string and splits the elements neatly
 *  into a string array. 
 */
function array<string> parseStringForMenu(string menuString)
{
	local array<string> splitted;
	local int i;

	menuString = mid( menuString, 0 );

	splitted = SplitString(menuString, "{");

	for( i = 0; i < splitted.Length; i++)
	{
		// the { is needed because of the parseStringToArray or it will remove to much
		splitted[i] = "{" $ splitted[i];
		if( i > 0 && i < ( splitted.Length - 1 ) )
		{
			splitted[i] = mid( splitted[i], 0, len( splitted[i] ) - 2 );
		}
	}

	return splitted;
}

DefaultProperties
{
	MenuPath(0) = ""
	DBSTRING = "[{\"category\":\"Search and destroy\",\"city_name\":\"Yorik\",\"description\":\"Regain loot\",\"id\":1,\"title\":\"Marauders\"},{\"category\":\"Search and destroy\",\"city_name\":\"Gaupang\",\"description\":\"Kill the robbers\",\"id\":2,\"title\":\"Bank robbers\"},{\"category\":\"Search and destroy\",\"city_name\":\"Valhall\",\"description\":\"Regain loot\",\"id\":3,\"title\":\"Marauders\"\}]"
}
