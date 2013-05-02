class AEMainMenu extends GFxMoviePlayer
	dependson(AEMissionObjective);
/** Class is responsible for the main menu in the game. **/

var AEPlayerController  AEPC;
var UIInputKeyData      key;

// LOGIN MENU COMPONENTS
var GFxClikWidget       us_button_login_login;
var GFxClikWidget       us_button_login_createUser;
var GFxObject           us_inputText_login_username;
var GFxObject           us_inputText_login_password;
var GFxObject           us_dynamicText_login_loginFeedbackMessage;

// MAIN MENU COMPONENTS
var GFxClikWidget       us_button_mainMenu_missions;
var GFxClikWidget       us_button_mainMenu_profile;
var GFxClikWidget       us_button_mainMenu_shop;
var GFxClikWidget       us_button_mainMenu_exitGame;

// MISSION MENU COMPONENTS
var GFxClikWidget       us_button_missions_previousMission;
var GFxClikWidget       us_button_missions_nextMission;
var GFxClikWidget       us_button_missions_acceptMission;
var GFxClikWidget       us_button_missions_back;
var GFxObject           us_dynamicText_missions_missionSelected;
var GFxObject           us_dynamicText_missions_missionType;
var GFxObject           us_dynamicText_missions_missionName;
var GFxObject           us_dynamicText_missions_missionMap;
var GFxObject           us_dynamicText_missions_description;
var GFxObject           us_dynamicText_missions_rewards;

// PROFILE MENU COMPONENTS
var GFxClikWidget       us_button_profile_itemList;
var GFxClikWidget       us_button_profile_back;

// SHOP MENU COMPONENTS
var GFxClikWidget       us_button_shop_previousItem;
var GFxClikWidget       us_button_shop_nextItem;
var GFxClikWidget       us_button_shop_buy;
var GFxClikWidget       us_button_shop_back;
var GFxObject           us_dynamicText_shop_selectedItem;
var GFxObject           us_dynamicText_shop_name;
var GFxObject           us_dynamicText_shop_damage;
var GFxObject           us_dynamicText_shop_ammo;
var GFxObject           us_dynamicText_shop_firerate;
var GFxObject           us_dynamicText_shop_projectileSpeed;
var GFxObject           us_dynamicText_shop_reloadSpeed;
var GFxObject           us_dynamicText_shop_spread;

// ITEM LIST COMPONENTS
var GFxClikWidget       us_button_itemList_back;
var GFxClikWidget       us_button_itemList_scrollUpWeapon;
var GFxClikWidget       us_button_itemList_scrollDownWeapon;
var GFxClikWidget       us_button_itemList_weaponSlot1;
var GFxClikWidget       us_button_itemList_weaponSlot2;
var GFxClikWidget       us_button_itemList_weaponSlot3;
var GFxClikWidget       us_button_itemList_weaponSlot4;
var GFxClikWidget       us_button_itemList_weaponSlot5;
var GFxClikWidget       us_button_itemList_scrollUpItem;
var GFxClikWidget       us_button_itemList_scrollDownItem;
var GFxClikWidget       us_button_itemList_itemSlot1;
var GFxClikWidget       us_button_itemList_itemSlot2;
var GFxClikWidget       us_button_itemList_itemSlot3;
var GFxClikWidget       us_button_itemList_itemSlot4;
var GFxClikWidget       us_button_itemList_itemSlot5;
var GFxClikWidget       us_button_itemList_equippedWeaponPrimary;
var GFxClikWidget       us_button_itemList_equippedWeaponSecondary;
var GFxClikWidget       us_button_itemList_equippedItem1;
var GFxClikWidget       us_button_itemList_equippedItem2;
var GFxClikWidget       us_button_itemList_equippedItem3;
var GFxClikWidget       us_button_itemList_equippedItem4;

var private MissionObjectives myActiveMission;
var private int mySelectionID;
var private int mySelectionIDMax;

function bool Start( optional bool StartPaused = false )
{
	super.Start();
	Advance( 0 );

	mySelectionID = 0;
	mySelectionIDMax = 0;

	AEPC = AEPlayerController(GetPC());
	AEPC.myMainMenu = self;
	AddCaptureKey( 'Escape' );
	bCaptureInput = true;

	return true;
}

event bool WidgetInitialized( name WidgetName, name WidgetPath, GFxObject Widget )
{
	// Remember to add for input and dynamic texts as well.
	`log("NEGEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEER!");
	switch ( WidgetName )
	{
		// CHECKS FOR INPUT AND DYNAMIC TEXT FIELDS.
		case ( 'dynamicText_login_username' ):
			us_inputText_login_username = Widget;
			break;

		case ( 'dynamicText_login_password' ):
			us_inputText_login_password = Widget;
			break;

		case ( 'dynamicText_login_loginFeedbackMessage' ):
			us_dynamicText_login_loginFeedbackMessage = Widget;
			break;

		case ( 'dynamicText_missions_missionSelected' ):
			us_dynamicText_missions_missionSelected = Widget;
			break;

		case ( 'dynamicText_missions_missionType' ):
			us_dynamicText_missions_missionType = Widget;
			break;

		case ( 'dynamicText_missions_missionName' ):
			us_dynamicText_missions_missionName = Widget;
			break;

		case ( 'dynamicText_missions_missionMap' ):
			us_dynamicText_missions_missionMap = Widget;
			break;

		case ( 'dynamicText_missions_description' ):
			us_dynamicText_missions_description = Widget;
			break;

		case ( 'dynamicText_missions_rewards' ):
			us_dynamicText_missions_rewards = Widget;
			break;

		case ( 'dynamicText_shop_selectedItem' ):
			us_dynamicText_shop_selectedItem = Widget;
			break;

		case ( 'dynamicText_shop_name' ):
			us_dynamicText_shop_name = Widget;
			break;

		case ( 'dynamicText_shop_damage' ):
			us_dynamicText_shop_damage = Widget;
			break;

		case ( 'dynamicText_shop_ammo' ):
			us_dynamicText_shop_ammo = Widget;
			break;

		case ( 'dynamicText_shop_firerate' ):
			us_dynamicText_shop_firerate = Widget;
			break;

		case ( 'dynamicText_shop_projectileSpeed' ):
			us_dynamicText_shop_projectileSpeed = Widget;
			break;

		case ( 'dynamicText_shop_reloadSpeed' ):
			us_dynamicText_shop_reloadSpeed = Widget;
			break;

		case ( 'dynamicText_shop_spread' ):
			us_dynamicText_shop_spread = Widget;
			break;

		// CHECKS FOR BUTTONS.
		case ( 'button_login_login' ):
			us_button_login_login = GFxClikWidget( Widget );
			us_button_login_login.AddEventListener( 'CLIK_click', login_onLoginButtonPress );
			break;

		case ( 'button_login_createUser' ):
			us_button_login_createUser = GFxClikWidget( Widget );
			us_button_login_createUser.AddEventListener( 'CLIK_click', login_onCreateUserButtonPress );
			break;

		case ( 'button_mainMenu_missions' ):
			us_button_mainMenu_missions = GFxClikWidget( Widget );
			us_button_mainMenu_missions.AddEventListener( 'CLIK_click', mainMenu_onMissionsButtonPress );
			break;

		case ( 'button_mainMenu_profile' ):
			us_button_mainMenu_profile = GFxClikWidget( Widget );
			us_button_mainMenu_profile.AddEventListener( 'CLIK_click', mainMenu_onProfileButtonPress );
			break;

		case ( 'button_mainMenu_shop' ):
			us_button_mainMenu_shop = GFxClikWidget( Widget );
			us_button_mainMenu_shop.AddEventListener( 'CLIK_click', mainMenu_onShopButtonPress );
			break;

		case ( 'button_mainMenu_exitGame' ):
			us_button_mainMenu_exitGame = GFxClikWidget( Widget );
			us_button_mainMenu_exitGame.AddEventListener( 'CLIK_click', mainMenu_onExitGameButtonPress );
			break;

		case ( 'button_missions_previousMission' ):
			us_button_missions_previousMission = GFxClikWidget( Widget );
			us_button_missions_previousMission.AddEventListener( 'CLIK_click', missions_onPreviousMissionButtonPress );
			break;

		case ( 'button_missions_nextMission' ):
			us_button_missions_nextMission = GFxClikWidget( Widget );
			us_button_missions_nextMission.AddEventListener( 'CLIK_click', missions_onNextMissionButtonPress );
			break;

		case ( 'button_missions_acceptMission' ):
			us_button_missions_acceptMission = GFxClikWidget( Widget );
			us_button_missions_acceptMission.AddEventListener( 'CLIK_click', missions_onAcceptMissionButtonPress );
			break;

		case ( 'button_missions_back' ):
			us_button_missions_back = GFxClikWidget( Widget );
			us_button_missions_back.AddEventListener( 'CLIK_click', mission_onBackButtonpress );
			break;

		case ( 'button_profile_itemList' ):
			us_button_profile_itemList = GFxClikWidget( Widget );
			us_button_profile_itemList.AddEventListener( 'CLIK_click', profile_onItemListButtonPress);
			break;

		case ( 'button_profile_back' ):
			us_button_profile_back = GFxClikWidget( Widget );
			us_button_profile_back.AddEventListener( 'CLIK_click', profile_onBackButtonPress);
			break;

		case ( 'button_shop_previousItem' ):
			us_button_shop_previousItem = GFxClikWidget( Widget );
			us_button_shop_previousItem.AddEventListener( 'CLIK_click', shop_onPreviousItemButtonPress );
			break;

		case ( 'button_shop_nextItem' ):
			us_button_shop_nextItem = GFxClikWidget( Widget );
			us_button_shop_nextItem.AddEventListener( 'CLIK_click', shop_onNextItemButtonPress );
			break;

		case ( 'button_shop_buy' ):
			us_button_shop_buy = GFxClikWidget( Widget );
			us_button_shop_buy.AddEventListener( 'CLIK_click', shop_onBuyButtonPress );
			break;

		case ( 'button_shop_back' ):
			us_button_shop_back = GFxClikWidget( Widget );
			us_button_shop_back.AddEventListener( 'CLIK_click', shop_onBackButtonPress );
			break;

		case ( 'button_itemList_back' ):
			us_button_itemList_back = GFxClikWidget( Widget );
			us_button_itemList_back.AddEventListener( 'CLIK_click', itemList_onBackButtonPress );
			break;

		case ( 'button_itemList_scrollUpWeapon' ):
			us_button_itemList_scrollUpWeapon = GFxClikWidget( Widget );
			us_button_itemList_scrollUpWeapon.AddEventListener( 'CLIK_click', itemList_onScrollUpWeaponButtonPress );
			break;

		case ( 'button_itemList_scrollDownWeapon' ):
			us_button_itemList_scrollDownWeapon = GFxClikWidget( Widget );
			us_button_itemList_scrollDownWeapon.AddEventListener( 'CLIK_click', itemList_onScrollDownWeaponButtonPress );
			break;

		case ( 'button_itemList_weaponSlot1' ):
			us_button_itemList_weaponSlot1 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot1.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_weaponSlot2' ):
			us_button_itemList_weaponSlot2 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot2.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_weaponSlot3' ):
			us_button_itemList_weaponSlot3 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot3.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_weaponSlot4' ):
			us_button_itemList_weaponSlot4 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot4.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_weaponSlot5' ):
			us_button_itemList_weaponSlot5 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot5.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_scrollUpItem' ):
			us_button_itemList_scrollUpItem = GFxClikWidget( Widget );
			us_button_itemList_scrollUpItem.AddEventListener( 'CLIK_click', itemList_onScrollUpItemButtonPress );
			break;

		case ( 'button_itemList_scrollDownItem' ):
			us_button_itemList_scrollDownItem = GFxClikWidget( Widget );
			us_button_itemList_scrollDownItem.AddEventListener( 'CLIK_click', itemList_onScrollDownItemButtonPress );
			break;

		case ( 'button_itemList_itemSlot1' ):
			us_button_itemList_itemSlot1 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot1.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_itemSlot2' ):
			us_button_itemList_itemSlot2 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot2.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_itemSlot3' ):
			us_button_itemList_itemSlot3 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot3.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_itemSlot4' ):
			us_button_itemList_itemSlot4 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot4.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_itemSlot5' ):
			us_button_itemList_itemSlot5 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot5.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress );
			break;

		case ( 'button_itemList_equippedWeaponPrimary' ):
			us_button_itemList_equippedWeaponPrimary = GFxClikWidget( Widget );
			us_button_itemList_equippedWeaponPrimary.AddEventListener( 'CLIK_click', itemList_onEquippedWeaponPrimaryButtonPress );
			break;

		case ( 'button_itemList_equippedWeaponSecondary' ):
			us_button_itemList_equippedWeaponSecondary = GFxClikWidget( Widget );
			us_button_itemList_equippedWeaponSecondary.AddEventListener( 'CLIK_click', itemList_onEquippedWeaponSecondaryButtonPress );
			break;

		case ( 'button_itemList_equippedItem1' ):
			us_button_itemList_equippedItem1 = GFxClikWidget( Widget );
			us_button_itemList_equippedItem1.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress );
			break;

		case ( 'button_itemList_equippedItem2' ):
			us_button_itemList_equippedItem2 = GFxClikWidget( Widget );
			us_button_itemList_equippedItem2.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress );
			break;

		case ( 'button_itemList_equippedItem3' ):
			us_button_itemList_equippedItem3 = GFxClikWidget( Widget );
			us_button_itemList_equippedItem3.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress );
			break;

		case ( 'button_itemList_equippedItem4' ):
			us_button_itemList_equippedItem4 = GFxClikWidget( Widget );
			us_button_itemList_equippedItem4.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress );
			break;

		default:
			break;
	}

	return true;
}

function login_onLoginButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	/* 1. Check input text fields "us_inputText_login_username" and
	 * "us_inputText_login_password".

	 * 2a. If they match up with an user in the database, go to main menu.
	 * Put dynamic text field "us_dynamicText_login_loginFeedbackMessage"
	 * to a success message.
	 
	 * 2b: If they do NOT match up, set the dynamic text field
	 * "us_dynamicText_login_loginFeedbackMessage" to a fail message.
	 
	 */

	// This runs if the login was successful.
	ActionScriptVoid( "openMainMenu" );

	`Log("The button \"login\" was pushed.");
}

function login_onCreateUserButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO: Change to a page where one can create a user.
	class'Engine'.static.LaunchURL("http://www.google.com");

	`Log("The button \"create user\" was pushed.");
}

function mainMenu_onMissionsButtonPress( GFxClikWidget.EventData ev)
{
	mySelectionID = 0;
	AEPC.myTcpLink.getMissions("missions/");

	ActionScriptVoid( "openMissionMenu" );

	`Log("The button \"missions\" was pushed.");
}

function mainMenu_onProfileButtonPress( GFxClikWidget.EventData ev)
{
	ActionScriptVoid ( "openProfileMenu" );

	`Log("The button \"profile\" was pushed.");
}

function mainMenu_onShopButtonPress( GFxClikWidget.EventData ev)
{
	ActionScriptVoid( "openShopMenu" );

	`Log("The button \"shop\" was pushed.");
}

function mainMenu_onExitGameButtonPress( GFxClikWidget.EventData ev )
{
	ConsoleCommand( "quit" );

	`Log("The button \"exit game\" was pushed.");
}

function missions_onPreviousMissionButtonPress( GFxClikWidget.EventData ev )
{
	`log("-derp");
	decSelectionID();
	UpdateMissionMenu();

	`Log("The button \"<\" was pushed.");
}

function missions_onNextMissionButtonPress( GFxClikWidget.EventData ev )
{
	`log("+derp");
	addSelectionID();
	UpdateMissionMenu();

	`Log("The button \">\" was pushed.");
}

function missions_onAcceptMissionButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.
	`log("aølksjdlkajsdkljasd");
	ConsoleCommand("open AE-level" $ myActiveMission.levelID $ 
					"?MissionID=" $ myActiveMission.id $ 
					"?TeamID=0" $ 
					"?Loadout=" $ AEPC.myPlayerInfo.getItemLoadout());

	`Log("The button \"accept mission\" was pushed.");
}

function mission_onBackButtonpress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openMainMenu" );

	`Log("The button \"back\" was pushed.");
}

function profile_onItemListButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openItemMenu" );

	`Log("The button \"item list\" was pushed.");
}

function profile_onBackButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openMainMenu" );

	`Log("The button \"back\" was pushed.");
}

function shop_onPreviousItemButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button \"<\" was pushed.");
}

function shop_onNextItemButtonPress( GFxClikWidget.EventData ev)
{
	// TO-DO.

	`Log("The button \">\" was pushed.");
}

function shop_onBuyButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button \"buy\" was pushed.");
}

function shop_onBackButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openMainMenu" );

	`Log("The button \"back\" was pushed.");
}

function itemList_onBackButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openProfileMenu" );

	`Log("The button \"back\" was pushed.");
}

function itemList_onScrollUpWeaponButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button \"^\" was pushed.");
}

function itemList_onScrollDownWeaponButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button \"v\" was pushed.");
}

function itemList_onWeaponSlotSelectedButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	// This method is used with all the weapon slots under the Weapon menu.

	`Log("The button representing a weapon in the Weapon menu was pushed.");
}

function itemList_onScrollUpItemButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button \"^\" was pushed.");
}

function itemList_onScrollDownItemButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button \"v\" was pushed.");
}

function itemList_onItemSlotSelectedButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	// This method is used with all the weapon slots under the Item menu.

	`Log("The button representing an item under the Item menu was pushed.");
}

function itemList_onEquippedWeaponPrimaryButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button representing the player's current primary weapon was pushed.");
}

function itemList_onEquippedWeaponSecondaryButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	`Log("The button representing the player's current secondary weapon was pushed.");
}

function itemList_onEquippedItemButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	// This method is used with all the -equipped- item slots under the
	// Equipped Items menu.

	`Log("The button representing an item under the Equipped items menu was pushed.");
}

/** Runs automaticly with TCPclient or in this class */
function UpdateMissionMenu()
{
	local MissionObjectives mission;
	local string rewards;
	local int i;

	mySelectionIDMax = AEPC.myDataStorage.MissionLength();

	rewards = "";

	mission = AEPC.myDataStorage.getMission(mySelectionID);
	myActiveMission = mission;

	us_dynamicText_missions_missionName.SetText(mission.title);
	us_dynamicText_missions_missionSelected.SetText("" $ mySelectionID);
	us_dynamicText_missions_missionMap.SetText( mission.mapName );
	us_dynamicText_missions_missionType.SetText(mission.category);
	us_dynamicText_missions_description.SetText(mission.description);

	for( i = 0; i < mission.rewards.Length; ++i)
	{
		rewards $= mission.rewards[i].type $ " : ";
	}
	for( i = 0; i < mission.rewardItems.Length; ++i)
	{
		rewards $= mission.rewardItems[i].itemName $ " : ";
	}

	us_dynamicText_missions_rewards.SetText( rewards );

	// TO-DO
}

private function addSelectionID()
{
	++mySelectionID;

	if(mySelectionID >= mySelectionIDMax)
		mySelectionID = 0;
}

private function decSelectionID()
{
	--mySelectionID;

	if(mySelectionID <= 0)
		mySelectionID = mySelectionIDMax - 1;
}

DefaultProperties
{
	// LOGIN MENU COMPONENTS - INITIALIZATION
	WidgetBindings.Add( ( WidgetName="button_login_login", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_login_createUser", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="inputText_login_username", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="inputText_login_password", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_login_loginFeedbackMessage", WidgetClass=class'GFxObject' ) )

	// MAIN MENU COMPONENTS - INITIALIZATION
	WidgetBindings.Add( ( WidgetName="button_mainMenu_missions", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_mainMenu_profile", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_mainMenu_shop", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_mainMenu_exitGame", WidgetClass=class'GFxClikWidget' ) )

	// MISSION MENU COMPONENTS - INITIALIZATION
	WidgetBindings.Add( ( WidgetName="button_missions_previousMission", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_missions_nextMission", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_missions_acceptMission", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_missions_back", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionSelected", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionType", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionName", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionMap", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_description", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_rewards", WidgetClass=class'GFxObject' ) )

	// PROFILE MENU COMPONENTS - INITIALIZATION
	WidgetBindings.Add( ( WidgetName="button_profile_itemList", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_profile_back", WidgetClass=class'GFxClikWidget' ) )

	// SHOP MENU COMPONENTS - INITIALIZATION
	WidgetBindings.Add( ( WidgetName="button_shop_previousItem", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_shop_nextItem", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_shop_buy", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_shop_back", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_selectedItem", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_name", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_damage", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_ammo", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_firerate", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_projectileSpeed", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_reloadSpeed", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_spread", WidgetClass=class'GFxObject' ) )

	// ITEM LIST COMPONENTS - INITIAZALITON
	WidgetBindings.Add( ( WidgetName="button_itemList_back", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_scrollUpWeapon", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_scrollDownWeapon", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_weaponSlot1", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_weaponSlot2", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_weaponSlot3", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_weaponSlot4", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_weaponSlot5", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_scrollUpItem", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_scrollDownItem", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_itemSlot1", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_itemSlot2", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_itemSlot3", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_itemSlot4", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_itemSlot5", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_equippedWeaponPrimary", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_equippedWeaponSecondary", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_equippedItem1", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_equippedItem2", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_equippedItem3", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_itemList_equippedItem4", WidgetClass=class'GFxClikWidget' ) )
}