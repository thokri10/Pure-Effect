class AEHUDMenu extends Actor
	dependson(AEMissionObjective);

struct SelectStruct
{
	var int     id;
	var string  name;
};

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

/**
 * INITIALIZINGS!
 */

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

function initMenu()
{
	local int i;
	local bool reset;

	for( i = 0; i < menuSelections.Length; i++)
	{
		if(i == 0)
			reset = true;
		else
			reset = false;
		PC.mHUD.addMenuSelections(menuSelections[i].name, reset);
	}
	
	PC.mHUD.setMenuActive(0);
	selectedMenuSlot=0;

	setBack(menuSelections.Length);
}

function resetMenuSelection()
{
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

function stringFromServer(string menuString)
{

}

/**
 * TEMP FUNCTION FOR TESTING PURPOSES
 */
exec function ppp()
{
	//menuPath[0] = "Missions";
	//setMainMenu();
	parseMissionArrayToMenu( parseStringForMenu(DBSTRING) );
}


/**
 * MENU SELECT FUNCTIONS
 */

function nextMenuSlot()
{
	if(selectedMenuSlot >= menuSelections.Length)
		return;

	++selectedMenuSlot;

	PC.mHUD.setMenuActive(selectedMenuSlot);
}

function preMenuSlot()
{
	if( selectedMenuSlot < 1 )
		return;

	--selectedMenuSlot;

	PC.mHUD.setMenuActive(selectedMenuSlot);
}

function Select()
{
	if(selectedMenuSlot == BACK)
	{
		if( menuSelections[0].name == "Show missions" ){
			ConsoleCommand("quit");
		}
		else if(MenuPath[menuPath.Length] != "")
		{
			resetMenuSelection();
			MenuPath.Length = menuPath.Length - 1;
			ppp();
		}else{
			setMainMenu();
		}
	}
	else if( MenuPath[0] == "Missions" )
	{
		MenuPath[1] = String( menuSelections[selectedMenuSlot].id );
		resetMenuSelection();
		showMissionInfo(menuMissions[selectedMenuSlot]);
	}
	else if( menuSelections[selectedMenuSlot].name == "Show missions" )
	{
		resetMenuSelection();
		parseMissionArrayToMenu( parseStringForMenu(DBSTRING) );
		MenuPath[0] = "Missions";
	}
	else
	{
		setMainMenu();
	}
}

function setBack(int i)
{
	BACK = i;

	if(menuPath.Length != 0)
		PC.mHUD.addMenuSelections("BACK");
	else
		PC.mHUD.addMenuSelections("QUIT");
}

function showMissionInfo(MissionObjectives objective)
{
	local SelectStruct selection;

	PC.mHUD.addMissionInfo( "Name        : " $ objective.title, true );
	PC.mHUD.addMissionInfo( "Map         : " $ objective.mapName );
	PC.mHUD.addMissionInfo( "Reward      : " $ objective.reward );
	PC.mHUD.addMissionInfo( "description : " $ objective.description );

	selection.id = 0;
	selection.name = "Accept";

	menuSelections.Length = 0;
	menuSelections.AddItem(selection);
	MenuPath.AddItem( String(objective.id) );

	initMenu();
}


/**
 * Parsing functions
 */


function parseMissionArrayToMenu(array<string> MenuArray)
{
	local MissionObjectives objective;
	local SelectStruct      selection;
	local int i;

	for(i = 1; i < MenuArray.Length; i++)
	{
		objective = PC.myMissionObjective.parseArrayToMissionStruct( PC.myTcpLink.parseToArray( MenuArray[i] ) );

		selection.id = objective.id;
		selection.name = objective.title;
		menuSelections.AddItem(selection);

		menuMissions.InsertItem(objective.id - 1, objective);
	}

	initMenu();
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
