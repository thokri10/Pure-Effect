class AEMainMenu extends GFxMoviePlayer
	dependson(AEMissionObjective);
/** Class is responsible for the main menu in the game. **/

var AEPlayerController  AEPC;
var UIInputKeyData      key;

// All the buttons in Flash that you need to use.
var GFxClikWidget       us_button_login_login;
var GFxClikWidget       us_button_login_createUser;
var GFxClikWidget       us_button_mainMenu_missions;
var GFxClikWidget       us_button_mainMenu_shop;
var GFxClikWidget       us_button_mainMenu_exitGame;
var GFxClikWidget       us_button_missions_previousMission;
var GFxClikWidget       us_button_missions_nextMission;
var GFxClikWidget       us_button_missions_acceptMission;
var GFxClikWidget       us_button_shop_previousItem;
var GFxClikWidget       us_button_shop_nextItem;
var GFxClikWidget       us_button_shop_buy;

// Test buttons
var GFxClikWidget       us_mc_login_createUser;

// All the input texts in Flash that you need to check their string contents.
var GFxClikWidget       us_inputText_login_username;
var GFxClikWidget       us_inputText_login_password;

// All the dynamic texts in Flash that you need to change accordingly.
var GFxClikWidget       us_dynamicText_login_loginFeedbackMessage;
var GFxClikWidget       us_dynamicText_missions_missionSelected;
var GFxClikWidget       us_dynamicText_missions_missionType;
var GFxClikWidget       us_dynamicText_missions_missionName;
var GFxClikWidget       us_dynamicText_missions_missionMap;
var GFxClikWidget       us_dynamicText_missions_description;
var GFxClikWidget       us_dynamicText_missions_rewards;
var GFxClikWidget       us_dynamicText_shop_selectedItem;
var GFxClikWidget       us_dynamicText_shop_name;
var GFxClikWidget       us_dynamicText_shop_damage;
var GFxClikWidget       us_dynamicText_shop_ammo;
var GFxClikWidget       us_dynamicText_shop_firerate;
var GFxClikWidget       us_dynamicText_shop_projectileSpeed;
var GFxClikWidget       us_dynamicText_shop_reloadSpeed;
var GFxClikWidget       us_dynamicText_shop_spread;
var GFxClikWidget       us_dynamicText_itemList_weapons;
var GFxClikWidget       us_dynamicText_itemList_items;

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

	`Log("bWidgetsInitializedThisFrame: " $ bWidgetsInitializedThisFrame);
	`Log("bLogUnhandedWidgetInitializations: " $ bLogUnhandedWidgetInitializations);
	`Log("bAllowInput: " $ bAllowInput);
	`Log("bCaptureInput: " $ bCaptureInput);



	return true;
}

event bool WidgetInitialized( name WidgetName, name WidgetPath, GFxObject Widget )
{
	`log("NEGEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEER!");
	switch ( WidgetName )
	{
		case ( 'button_login_login' ):
			us_button_login_login = GFxClikWidget( Widget );
			us_button_login_login.AddEventListener( 'CLIK_click', login_onLoginButtonPress );
			break;

		// TEST
		case ( 'mc_login_createUser'):
			us_mc_login_createUser = GFxClikWidget( Widget );
			us_mc_login_createUser.AddEventListener( 'CLIK_click', login_onCreateUserButtonPress );
			break;

		case ( 'button_login_createUser' ):
			us_button_login_createUser = GFxClikWidget( Widget );
			us_button_login_createUser.AddEventListener( 'CLIK_click', login_onCreateUserButtonPress );
			break;

		case ( 'button_mainMenu_missions' ):
			us_button_mainMenu_missions = GFxClikWidget( Widget );
			us_button_mainMenu_missions.AddEventListener( 'CLIK_click', mainMenu_onMissionsButtonPress );
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
}

function login_onCreateUserButtonPress( GFxClikWidget.EventData ev )
{
	// TO-DO.

	/* 1. Open the browser and direct user to a page where you can
	 * create an user account.
	 
	 */

	class'Engine'.static.LaunchURL("http://www.db.no");
	`log("LOOOOOOOOOOOOOOOOOL");
}

function mainMenu_onMissionsButtonPress( GFxClikWidget.EventData ev)
{
	mySelectionID = 0;
	AEPC.myTcpLink.getMissions("missions/");
}

function mainMenu_onShopButtonPress( GFxClikWidget.EventData ev)
{
	// TO-DO.
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
	// Buttons in Flash.
	WidgetBindings.Add( ( WidgetName="button_login_login", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_login_createUser", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_mainMenu_exitGame", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_missions_previousMission", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_missions_nextMission", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_missions_acceptMission", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_shop_previousItem", WidgetClass=class'GFxClikWidget') )
	WidgetBindings.Add( ( WidgetName="button_shop_nextItem", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="button_shop_buy", WidgetClass=class'GFxClikWidget' ) )

	// Test buttons in Flash.
	WidgetBindings.Add( ( WidgetName="mc_login_createUser", WidgetClass=class'GFxClikWidget' ) )

	// Input texts in Flash.
	WidgetBindings.Add( ( WidgetName="inputText_login_username", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="inputText_login_password", WidgetClass=class'GFxClikWidget' ) )

	// Dynamic texts in Flash.
	WidgetBindings.Add( ( WidgetName="dynamicText_login_loginFeedbackMessage", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionSelected", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionType", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionName", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_missionMap", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_description", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_missions_rewards", WidgetClass=class'GFxClikWidget') )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_selectedItem", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_name", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_damage", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_ammo", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_firerate", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_projectileSpeed", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_reloadSpeed", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_shop_spread", WidgetClass=class'GFxClikWidget' ) )
	WidgetBindings.Add( ( WidgetName="dynamicText_itemList_weapons", WidgetClass=class'GFxClikWidget') )
	WidgetBindings.Add( ( WidgetName="dynamicText_itemList_items", WidgetClass=class'GFxClikWidget' ) )
}