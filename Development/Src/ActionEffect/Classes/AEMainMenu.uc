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
var GFxObject           us_dynamicText_itemList_weapons;
var GFxObject           us_dynamicText_itemList_items;

var private int mySelectionID;
var private int mySelectionIDMax;

function bool Start( optional bool StartPaused = false )
{
	super.Start();
	Advance( 0 );

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
}

function login_onCreateUserButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO: Change to a page where one can create a user.
	class'Engine'.static.LaunchURL("http://www.google.com");
}

function mainMenu_onMissionsButtonPress( GFxClikWidget.EventData ev)
{
	mySelectionID = 0;
	AEPC.myTcpLink.getMissions("missions/");

	ActionScriptVoid( "openMissionMenu" );
}

function mainMenu_onProfileButtonPress( GFxClikWidget.EventData ev)
{
	ActionScriptVoid ( "openProfileMenu" );
}

function mainMenu_onShopButtonPress( GFxClikWidget.EventData ev)
{
	ActionScriptVoid( "openShopMenu" );
}

function mainMenu_onExitGameButtonPress( GFxClikWidget.EventData ev )
{
	ConsoleCommand( "quit" );
}

function missions_onPreviousMissionButtonPress( GFxClikWidget.EventData ev )
{
	decSelectionID(1);
	UpdateMissionMenu();
}

function missions_onNextMissionButtonPress( GFxClikWidget.EventData ev )
{
	addSelectionID(1);
	UpdateMissionMenu();
}

function missions_onAcceptMissionButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.
}

function mission_onBackButtonpress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openMainMenu" );
}

function profile_onItemListButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openItemMenu" );
}

function profile_onBackButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openMainMenu" );
}

function shop_onPreviousItemButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.
}

function shop_onNextItemButtonPress( GFxClikWidget.EventData ev)
{
	// TO-DO.
}

function shop_onBuyButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.
}

function shop_onBackButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openMainMenu" );
}

function itemList_onBackButtonPress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openProfileMenu" );
}

/** Runs automaticly with TCPclient or in this class */
function UpdateMissionMenu()
{
	local MissionObjectives mission;

	mission = AEPC.myDataStorage.getMission(mySelectionID);

	// TO-DO
}

private function addSelectionID(int add)
{
	if(mySelectionID <= mySelectionIDMax)
		mySelectionID += add;
	else
		mySelectionID = 0;
}

private function decSelectionID(int dec)
{
	if(mySelectionID > 0)
		mySelectionID -= dec;
	else
		mySelectionID = mySelectionIDMax;
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
	WidgetBindings.Add( ( WidgetName="dynamicText_itemList_weapons", WidgetClass=class'GFxObject' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_itemList_items", WidgetClass=class'GFxObject' ) )
}