class AEHUDMenu extends Actor
	dependson(AEMissionObjective);
 
struct SelectStruct
{
	var int     id;
	var string  name;
};

var int numberOfServerStrings;
var int ServerCounter;

// Path of the menu. Set together by adding all the stringarray together. 
// Easy to remove the last path and go back in menu
var array<string>               menuPath;

// Saves all the available missions in an array for us
var array<MissionObjectives>    menuMissions;

// Saves witch menuselections we have.
var array<SelectStruct>         menuSelections;

var AEPlayerController          PC;

// Used for navigate the text menu
var int     selectedMenuSlot;
var string  DBSTRING;
var int     BACK;

// Booleans to check what menu we are wxpecting to create on the next answer from server
var bool    bMenuSelection;
var bool    bMenuInfo;

/**
 * Initializing functions
 */

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

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
	selectedMenuSlot=0;

	setBack(menuSelections.Length);
}

function resetMenuSelection()
{
	PC.mHUD.addMenuSelections("", true);
	menuSelections.Length = 0;
	PC.mHUD.setMenuActive(0);
	selectedMenuSlot=0;
}

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

// Updates the menu with the menuPath variable in this class
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

/**
 * Functions that this class do not use. Often called from TCP
 **/
function numberOfStringFromServer(int number)
{
	numberOfServerStrings = number;
	ServerCounter = 0;
}

function stringFromServer(string menuString)
{
	if(ServerCounter == 0)
		resetMenuSelection();

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
}

/**
 * TEMP FUNCTION FOR TESTING PURPOSES
 */
exec function ppp()
{
	setMainMenu();
}

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

// Jumps up in the menu
function preMenuSlot()
{
	if( selectedMenuSlot < 1 )
		return;

	--selectedMenuSlot;

	PC.mHUD.setMenuActive(selectedMenuSlot);
}

// Selects the selected choice in the menu.
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

				showMissionInfo(menuMissions[selectedMenuSlot]);
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

// Set the back button on the bottom of the selection.
function setBack(int i)
{
	BACK = i;

	if(menuPath.Length != 0)
		PC.mHUD.addMenuSelections("BACK");
	else
		PC.mHUD.addMenuSelections("QUIT");
}

// Puts out the missions info to the screen
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
 * Parsing functions
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
	MenuPath(0)=""
	DBSTRING = "[{\"category\":\"Search and destroy\",\"city_name\":\"Yorik\",\"description\":\"Regain loot\",\"id\":1,\"title\":\"Marauders\"},{\"category\":\"Search and destroy\",\"city_name\":\"Gaupang\",\"description\":\"Kill the robbers\",\"id\":2,\"title\":\"Bank robbers\"},{\"category\":\"Search and destroy\",\"city_name\":\"Valhall\",\"description\":\"Regain loot\",\"id\":3,\"title\":\"Marauders\"\}]"
}
