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

var enum MENUPATHSTRUCT
{
	MENUPATH_MAIN,
	MENUPATH_MISSION,
	MENUPATH_MISSIONINFO,
	MENUPATH_PROFILE,
	MENUPATH_PROFILEINFO
} Path;

//-----------------------------------------------------------------------------
// Classes

/** Controller for the player. */
var AEPlayerController  PC;
/** Player information */
var AEPlayerInfo        playerInfo;


//-----------------------------------------------------------------------------
// Variables

/** Path of the menu. Set together by adding all the stringarray together. 
 *  Easy to remove the last path and go back in menu.
 */
var array<string>               menuPath;
var array<MENUPATHSTRUCT>       pathList;

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
var bool    bWatingForServer;


//-----------------------------------------------------------------------------
// Events

/** Overrode base function of PostBeginPlay. Currently doesn't do
 *  anything special. 
 */
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Path = MENUPATH_MAIN;
	pathList.AddItem( Path );
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
	PC.mHUD.addMissionInfo("", true);
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

	bWatingForServer = true;

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
	if( !bWatingForServer )
	{
		if(selectedMenuSlot >= menuSelections.Length)
			return;

		++selectedMenuSlot;

		PC.mHUD.setMenuActive(selectedMenuSlot);

		printInfoAutomatic();
	}
}

/** Jumps up in the menu. */
function preMenuSlot()
{
	if( !bWatingForServer )
	{
		if( selectedMenuSlot < 1 )
			return;

		--selectedMenuSlot;

		PC.mHUD.setMenuActive(selectedMenuSlot);

		printInfoAutomatic();
	}
}

/** Check if the menu should print anything onto screen when we have menu selection */
function printInfoAutomatic()
{
	local int index;

	if( selectedMenuSlot != BACK )
	{
		if( Path == MENUPATH_PROFILEINFO )
		{
			showAutomaticItemInfo(selectedMenuSlot);
		}
		else if( Path == MENUPATH_MISSIONINFO )
		{
			if(selectedMenuSlot == 0){
				index = selectedMenuSlot;
				showAutomaticMissionInfo();
			}else if(selectedMenuSlot > 1){
				index = selectedMenuSlot - 2;
				showAutomaticMissionItemInfo(index);
			}else
				PC.mHUD.addMissionInfo("", true);
		}
	}
}

/** Selects the selected choice in the menu. */
function Select()
{
	if( !bWatingForServer )
	{
		if(selectedMenuSlot == BACK)
		{
			pathList.Length = pathList.Length - 1;
			Path = pathList[pathList.Length - 1];

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
					Path = MENUPATH_MISSION;
					bMenuSelection = true;
					UpdateMenuFromPath();
				}
				else if( menuSelections[selectedMenuSlot].name == "Show profile" )
				{
					// soldiers is the folder where the server saves to profile info.
					// Returns the profile with set username and password
					menuPath[0] = "soldiers"; 
					Path = MENUPATH_PROFILE;
					bMenuSelection = true;
					UpdateMenuFromPath();
				}
			}
			// The second menu you get to. 
			// Should be splitted up after all the choices you have in main menu selections.
			else if ( menuPath.Length == 1 )
			{
				if( Path == MENUPATH_MISSION )
				{
					MenuPath[1] = string( selectedMenuSlot );

					Path = MENUPATH_MISSIONINFO;

					showMissionInfo(missions[selectedMenuSlot]);
				}
				else if( Path == MENUPATH_PROFILE )
				{
					menuPath[1] = playerInfo.ID $ "/items";

					Path = MENUPATH_PROFILEINFO;
				
					UpdateMenuFromPath();
				}
			}

			else if( menuPath.Length == 2 )
			{
				if( menuSelections[selectedMenuSlot].name == "Accept" )
				{
					//PC.myMissionObjective.activateObjectives( activeMission );
					SetUpForMapChange(activeMission.id, activeMission.levelID);
					//resetMenuSelection();
				} 
			}
		}

		if(pathList[pathList.Length - 1] != Path)
		{
			pathList.AddItem( Path );
		}

		// Prints out any info that should be printed to screen automaticly
		printInfoAutomatic();
	}
}


function SetUpForMapChange(int missionID, int LevelID)
{
	//`log("open AE-level" $ LevelID $ "?MissionID=" $ missionID);
	ConsoleCommand("open AE-level" $ LevelID $ "?MissionID=" $ missionID $ "?TeamID=0"); // TODO: CHANGE SO IT JOINS CORRECT TEAM
}

//-----------------------------------------------------------------------------
// Menu Selection Init

/** Gets a string from server that get parsed to the correct menu */
function stringFromServer(string menuString)
{
	local SimpleMissionStruct   selectedMission;
	local ValueStruct           value;
	local SelectStruct          selection;
	local array<Array2D>        parsedArray;
	local Array2D               values;
	local int id;
	
	resetMenuSelection();
	missions.Length = 0;
	bWatingForServer = false;

	parsedArray = PC.parser.fullParse( menuString );

	switch( Path )
	{
		case MENUPATH_MISSION:
			foreach parsedArray( values )
			{
				missions.AddItem( PC.myMissionObjective.parseArrayToSimpleStruct( values.variables ) );
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
			break;
		case MENUPATH_PROFILE:
			foreach parsedArray( values )
				showProfileInfo( values.variables );
			break;
		case MENUPATH_PROFILEINFO:
			showItemList(parsedArray);
			break;
	}

	bMenuSelection = false;

	initMenu();
}

/** Puts the mission info to the screen. */
function showMissionInfo(SimpleMissionStruct objective)
{
	local SelectStruct      selection;
	local WeaponStruct      weaponReward;
	local AEInventory_Item  itemReward;
	local int i;

	activeMission = PC.myMissionObjective.MissionFromSimpleStruct( objective );

	resetMenuSelection();

	showAutomaticMissionInfo();

	selection.id = i++;
	selection.name = "Accept";

	menuSelections.AddItem( selection );
	
	selection.id = i++;
	selection.name = "Reward(s): ";

	menuSelections.AddItem( selection );

	foreach activeMission.rewards( weaponReward )
	{
		selection.id = i++;
		selection.name = weaponReward.type;
		menuSelections.AddItem( selection );
	}

	foreach activeMission.rewardItems( itemReward )
	{
		selection.id = i++;
		selection.name = itemReward.itemName;
		menuSelections.AddItem( selection );
	}

	initMenu();
}

/** Puts the profile info to screen */
function showProfileInfo(array<ValueStruct> information)
{
	local SelectStruct  selection;
	
	playerInfo = PC.myPlayerInfo.Initialize( information );

	PC.mHUD.addMissionInfo( "ID   : " $ playerInfo.ID, true );
	PC.mHUD.addMissionInfo( "Name : " $ playerInfo.playerName );

	selection.id = 0;
	selection.name = "Itemlist";

	menuSelections.AddItem( selection );

	initMenu();
}

/** Shows the items to screen and adds them to playerinfo class for later use. */
function showItemList(array<Array2D> menuString)
{
	local Array2D values;
	local WeaponStruct weap;
	local AEInventory_Item item;
	local SelectStruct selection;
	local int i;

	playerInfo.weapons.Length = 0;
	playerInfo.items.Length = 0;

	`log("MENUSTRINGLENGTH: " $ menuString.Length);

	foreach menuString( values )
	{
		playerInfo.addItems( values.variables );
		//playerInfo.weapons.AddItem( PC.myWeaponCreator.parseToStruct( values.variables ) );
	}

	foreach playerInfo.weapons( weap )
	{
		selection.id = i++;
		selection.name = weap.type;

		menuSelections.AddItem( selection );
	}

	foreach playerInfo.items( item )
	{
		selection.id = i++;
		selection.name = item.itemName;

		menuSelections.AddItem( selection );
	}

	initMenu();

	showAutomaticItemInfo(selectedMenuSlot);
}

/** Show the mission info to screen */
function showAutomaticMissionInfo()
{
	PC.mHUD.addMissionInfo( "Category    : " $ activeMission.category, true );
	PC.mHUD.addMissionInfo( "Name        : " $ activeMission.title );
	PC.mHUD.addMissionInfo( "Map         : " $ activeMission.mapName );
	PC.mHUD.addMissionInfo( "description : " $ activeMission.description );
}

/** Show information for the item you have targeted in itemlist */ 
function showAutomaticItemInfo(int index)
{
	if(index < playerInfo.weapons.Length )
	{
		PC.mHUD.addMissionInfo("Type       : " $ playerInfo.weapons[ index ].type, true);
		PC.mHUD.addMissionInfo("MagSize    : " $ playerInfo.weapons[ index ].magSize);
		PC.mHUD.addMissionInfo("ReloadTime : " $ playerInfo.weapons[ index ].reloadTime);
		PC.mHUD.addMissionInfo("Speed      : " $ playerInfo.weapons[ index ].speed);
		PC.mHUD.addMissionInfo("Spread     : " $ playerInfo.weapons[ index ].spread);
		PC.mHUD.addMissionInfo("Damage     : " $ playerInfo.weapons[ index ].damage);
		PC.mHUD.addMissionInfo("Slot       : " $ playerInfo.weapons[ index ].slot);
	}
	else
	{
		index = index + playerInfo.weapons.Length - 2;
		PC.mHUD.addMissionInfo("Name     : " $ playerInfo.items[ index ].itemName, true);
		PC.mHUD.addMissionInfo("Delay    : " $ playerInfo.items[ index ].delay);
		PC.mHUD.addMissionInfo("Cooldown : " $ playerInfo.items[ index ].Cooldown);
		PC.mHUD.addMissionInfo("Damage   : " $ playerInfo.items[ index ].damage);
	}
}

/** Show targeted mission item in list. */
function showAutomaticMissionItemInfo(int index)
{
	if(index < activeMission.rewards.Length )
	{
		PC.mHUD.addMissionInfo("Type       : " $ activeMission.rewards[ index ].type, true);
		PC.mHUD.addMissionInfo("MagSize    : " $ activeMission.rewards[ index ].magSize);
		PC.mHUD.addMissionInfo("ReloadTime : " $ activeMission.rewards[ index ].reloadTime);
		PC.mHUD.addMissionInfo("Speed      : " $ activeMission.rewards[ index ].speed);
		PC.mHUD.addMissionInfo("Spread     : " $ activeMission.rewards[ index ].spread);
		PC.mHUD.addMissionInfo("Damage     : " $ activeMission.rewards[ index ].damage);
		PC.mHUD.addMissionInfo("Slot       : " $ activeMission.rewards[ index ].slot);
	}
	else
	{
		index = index + activeMission.rewards.Length - 2;
		PC.mHUD.addMissionInfo("Name     : " $ activeMission.rewardItems[ index ].itemName, true);
		PC.mHUD.addMissionInfo("Delay    : " $ activeMission.rewardItems[ index ].delay);
		PC.mHUD.addMissionInfo("Cooldown : " $ activeMission.rewardItems[ index ].Cooldown);
		PC.mHUD.addMissionInfo("Damage   : " $ activeMission.rewardItems[ index ].damage);
	}
}

DefaultProperties
{
	MenuPath(0) = ""
	DBSTRING = "[{\"category\":\"Search and destroy\",\"city_name\":\"Yorik\",\"description\":\"Regain loot\",\"id\":1,\"title\":\"Marauders\"},{\"category\":\"Search and destroy\",\"city_name\":\"Gaupang\",\"description\":\"Kill the robbers\",\"id\":2,\"title\":\"Bank robbers\"},{\"category\":\"Search and destroy\",\"city_name\":\"Valhall\",\"description\":\"Regain loot\",\"id\":3,\"title\":\"Marauders\"\}]"
}
