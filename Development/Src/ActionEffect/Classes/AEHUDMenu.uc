class AEHUDMenu extends Actor
	dependson(AEMissionObjective);

struct SelectStruct
{
	var int     id;
	var string  name;
};


// Saves all the available missions in an array for us
var array<MissionObjectives> menuMissions;

// Saves witch menuselections we have.
var array<SelectStruct> menuSelections;

var AEPlayerController  PC;

// Used for navigate the text menu
var int     ActiveMenuSlot;
var string  backPath;
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

	for( i = 0; i < menuSelections.Length; i++)
	{
		PC.mHUD.addToMenu(menuSelections[i].name);
	}

	PC.mHUD.setMenuActive(0);
	setBack(menuSelections.Length);
}

/**
 * TEMP FUNCTION FOR TESTING PURPOSES
 */
exec function ppp()
{
	parseMissionArrayToMenu( parseStringForMenu(DBSTRING) );
}


/**
 * MENU SELECT FUNCTIONS
 */

function nextMenuSlot()
{
	if(ActiveMenuSlot < 1)
		return;

	--ActiveMenuSlot;

	PC.mHUD.setMenuActive(ActiveMenuSlot);
}

function preMenuSlot()
{
	if( (ActiveMenuSlot + 1) > menuMissions.Length )
		return;

	++ActiveMenuSlot;

	PC.mHUD.setMenuActive(ActiveMenuSlot);
}

function Select()
{
	if(ActiveMenuSlot == BACK){
		`log("BACK");
	}

	
}

function setBack(int i)
{
	BACK = i;

	PC.mHUD.addToMenu("BACK");
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

	`log(menuString);

	menuString = mid( menuString, 0 );

	splitted = SplitString(menuString, "{");

	for( i = 0; i < splitted.Length; i++)
	{
		// the { is needed because of the parseStringToArray
		splitted[i] = "{" $ splitted[i];
		if( i > 0 && i < ( splitted.Length - 1 ) )
		{
			splitted[i] = mid( splitted[i], 0, len( splitted[i] ) - 2 );
		}
		`log(i $ " : " $ splitted[i]);
	}

	return splitted;
}

DefaultProperties
{
	ActiveMenuSlot=0
	backPath=""
	DBSTRING = "[{\"category\":\"Search and destroy\",\"city_name\":\"Yorik\",\"description\":\"Regain loot\",\"id\":1,\"title\":\"Marauders\"},{\"category\":\"Search and destroy\",\"city_name\":\"Gaupang\",\"description\":\"Kill the robbers\",\"id\":2,\"title\":\"Bank robbers\"},{\"category\":\"Search and destroy\",\"city_name\":\"Valhall\",\"description\":\"Regain loot\",\"id\":3,\"title\":\"Marauders\"\}]"
}
