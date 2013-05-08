class AEMainMenu extends GFxMoviePlayer
	dependson(AEMissionObjective)
	dependson(AEWeaponCreator)
	dependson(AEInventory_Item);
/** Class is responsible for the main menu in the game. **/

struct ITEMLIST
{
	var WeaponStruct primary_;
	var WeaponStruct secondary_;
	var AEInventory_Item items_[4];
};

/* ACTIONSCRIPT FUNCTIONS YOU CAN CALL BY USING "ActionScriptVoid( "functionName" );"
- openLoginMenu
- openMainMenu
- openMissionMenu
- openProfileMenu
- openShopMenu
- openItemMenu
- previewMissionPicture_level1
- previewMissionPicture_level2
- previewMissionPicture_level3
- previewMissionPicture_ship
- previewShopItemPicture_linkgun
- previewShopItemPicture_rocketLauncher
- previewShopItemPicture_shockRifle
- previewShopItemPicture_jetpack
- previewShopItemPicture_shield
- previewItemListItemPicture_linkgun
- previewItemListItemPicture_rocketLauncher
- previewItemListItemPicture_shockRifle
- previewItemListItemPicture_jetpack
- previewItemListItemPicture_shield
* NB: The functions for previewing images of the weapons and items have to be
* called while the player is in their respective menus. Otherwise, it will NOT
* work!
*/

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

var private MissionObjectives   myActiveMission;

var private class<AEMenuList>   ItemList_;
var private AEMenuList          myItemList;
var private WeaponStruct        weapons_[5];
var private AEInventory_Item    items_[5];
var private WeaponStruct        activeWeapon_;
var private AEInventory_Item    activeItem_;
var private ITEMLIST            Equipments_;
var private int buttonPressed_;
var private int weaponPage_;
var private int weaponPageMax_;
var private int itemPage_;
var private int itemPageMax_;

var private class<AEMenuShop>   MenuShop_;
var private AEMenuShop          myMenuShop;

var private int mySelectionID;
var private int mySelectionIDMax;

function bool Start( optional bool StartPaused = false )
{
	super.Start();
	Advance( 0 );

	AEPC = AEPlayerController(GetPC());
	AEPC.myMainMenu = self;

	myItemList = new ItemList_;
	myItemList.PC = AEPC;

	AddCaptureKey( 'Escape' );
	bCaptureInput = true;

	return true;
}

event bool WidgetInitialized( name WidgetName, name WidgetPath, GFxObject Widget )
{
	// Remember to add for input and dynamic texts as well.
	//`log("NEGEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEER!");
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
			us_button_itemList_weaponSlot1.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress1 );
			break;

		case ( 'button_itemList_weaponSlot2' ):
			us_button_itemList_weaponSlot2 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot2.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress2 );
			break;

		case ( 'button_itemList_weaponSlot3' ):
			us_button_itemList_weaponSlot3 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot3.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress3 );
			break;

		case ( 'button_itemList_weaponSlot4' ):
			us_button_itemList_weaponSlot4 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot4.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress4 );
			break;

		case ( 'button_itemList_weaponSlot5' ):
			us_button_itemList_weaponSlot5 = GFxClikWidget( Widget );
			us_button_itemList_weaponSlot5.AddEventListener( 'CLIK_click', itemList_onWeaponSlotSelectedButtonPress5 );
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
			us_button_itemList_itemSlot1.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress1 );
			break;

		case ( 'button_itemList_itemSlot2' ):
			us_button_itemList_itemSlot2 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot2.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress2 );
			break;

		case ( 'button_itemList_itemSlot3' ):
			us_button_itemList_itemSlot3 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot3.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress3 );
			break;

		case ( 'button_itemList_itemSlot4' ):
			us_button_itemList_itemSlot4 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot4.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress4 );
			break;

		case ( 'button_itemList_itemSlot5' ):
			us_button_itemList_itemSlot5 = GFxClikWidget( Widget );
			us_button_itemList_itemSlot5.AddEventListener( 'CLIK_click', itemList_onItemSlotSelectedButtonPress5 );
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
			us_button_itemList_equippedItem1.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress1 );
			break;

		case ( 'button_itemList_equippedItem2' ):
			us_button_itemList_equippedItem2 = GFxClikWidget( Widget );
			us_button_itemList_equippedItem2.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress2 );
			break;

		case ( 'button_itemList_equippedItem3' ):
			us_button_itemList_equippedItem3 = GFxClikWidget( Widget );
			us_button_itemList_equippedItem3.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress3 );
			break;

		case ( 'button_itemList_equippedItem4' ):
			us_button_itemList_equippedItem4 = GFxClikWidget( Widget );
			us_button_itemList_equippedItem4.AddEventListener( 'CLIK_click', itemList_onEquippedItemButtonPress4 );
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
	AEPC.myDataStorage.Clear();
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
	decSelectionID();
	UpdateMissionMenu();

	`Log("The button \"<\" was pushed.");
}

function missions_onNextMissionButtonPress( GFxClikWidget.EventData ev )
{
	addSelectionID();
	UpdateMissionMenu();

	`Log("The button \">\" was pushed.");
}

function missions_onAcceptMissionButtonPress( GFxClikWidget.EventData ev )
{
	local int i;
	local int slotAlteration;
	local int sizeOfArray;
	AEPC.myPlayerInfo.addItemToLoadout(0, Equipments_.primary_.id);
	AEPC.myPlayerInfo.addItemToLoadout(1, Equipments_.secondary_.id);
	
	slotAlteration = 2;
	sizeOfArray = 4;
	for(i = 0; i < sizeOfArray; ++i)
		AEPC.myPlayerInfo.addItemToLoadout(i + slotAlteration, Equipments_.items_[i].id);

	ConsoleCommand("open AE-level" $ myActiveMission.levelID $ 
					"?MissionID=" $ myActiveMission.id $ 
					"?TeamID=0" $ 
					"?Loadout=" $ AEPC.myPlayerInfo.getItemLoadout());
}

function mission_onBackButtonpress( GFxClikWidget.EventData ev )
{
	ActionScriptVoid( "openMainMenu" );

	`Log("The button \"back\" was pushed.");
}

function profile_onItemListButtonPress( GFxClikWidget.EventData ev )
{
	local int i;
	ActionScriptVoid( "openItemMenu" );

	myItemList.Clear();
	activeWeapon_.type = "";
	activeItem_ = None;
	
	for(i = 0; i < 5; ++i)
	{
		items_[i] = None;
		weapons_[i].type = "";
	}

	AEPC.myTcpLink.getItems();

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

	// Change preview picture.

	`Log("The button \"<\" was pushed.");
}

function shop_onNextItemButtonPress( GFxClikWidget.EventData ev)
{
	// TO-DO.

	// Change preview picture.

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
	--weaponPage_;

	if(weaponPage_ < 0)
		weaponPage_ = weaponPageMax_;
	
	UpdateItemList();
}

function itemList_onScrollDownWeaponButtonPress( GFxClikWidget.EventData ev )
{
	++weaponPage_;

	if(weaponPage_ >= weaponPageMax_)
		weaponPage_ = 0;

	UpdateItemList();
}

function itemList_onScrollUpItemButtonPress( GFxClikWidget.EventData ev )
{
	--itemPage_;

	if(itemPage_ < 0)
		itemPage_ = itemPageMax_;
	
	UpdateItemList();
}

function itemList_onScrollDownItemButtonPress( GFxClikWidget.EventData ev )
{
	++itemPage_;

	if(itemPage_ >= itemPageMax_)
		itemPage_ = 0;

	UpdateItemList();
}

function itemList_onItemSlotSelectedButtonPress1( GFxClikWidget.EventData ev ){ setActiveItem(0); }
function itemList_onItemSlotSelectedButtonPress2( GFxClikWidget.EventData ev ){ setActiveItem(1); }
function itemList_onItemSlotSelectedButtonPress3( GFxClikWidget.EventData ev ){ setActiveItem(2); }
function itemList_onItemSlotSelectedButtonPress4( GFxClikWidget.EventData ev ){ setActiveItem(3); }
function itemList_onItemSlotSelectedButtonPress5( GFxClikWidget.EventData ev ){ setActiveItem(4); }

private function setActiveItem(const int id)
{
	if( Items_[id] != None )
		activeItem_ = Items_[id];
}

function itemList_onEquippedItemButtonPress1( GFxClikWidget.EventData ev ){ Equipments_.items_[0] = activeItem_; UpdateList(); }
function itemList_onEquippedItemButtonPress2( GFxClikWidget.EventData ev ){ Equipments_.items_[1] = activeItem_; UpdateList(); }
function itemList_onEquippedItemButtonPress3( GFxClikWidget.EventData ev ){ Equipments_.items_[2] = activeItem_; UpdateList(); }
function itemList_onEquippedItemButtonPress4( GFxClikWidget.EventData ev ){ Equipments_.items_[3] = activeItem_; UpdateList(); }

function itemList_onWeaponSlotSelectedButtonPress1( GFxClikWidget.EventData ev ){ setActiveWeapon(0); }
function itemList_onWeaponSlotSelectedButtonPress2( GFxClikWidget.EventData ev ){ setActiveWeapon(1); }
function itemList_onWeaponSlotSelectedButtonPress3( GFxClikWidget.EventData ev ){ setActiveWeapon(2); }
function itemList_onWeaponSlotSelectedButtonPress4( GFxClikWidget.EventData ev ){ setActiveWeapon(3); }
function itemList_onWeaponSlotSelectedButtonPress5( GFxClikWidget.EventData ev ){ setActiveWeapon(4); }

private function setActiveWeapon(const int id)
{
	if(weapons_[id].type != "")
		activeWeapon_ = weapons_[id];
}

function itemList_onEquippedWeaponPrimaryButtonPress( GFxClikWidget.EventData ev )
{
	if(activeWeapon_.type != ""){
		Equipments_.primary_ = activeWeapon_;
		UpdateList();		
	}
}

function itemList_onEquippedWeaponSecondaryButtonPress( GFxClikWidget.EventData ev )
{
	if(activeWeapon_.type != ""){
		Equipments_.secondary_ = activeWeapon_;
		UpdateList();
	}
}

private function UpdateList()
{
	if(Equipments_.primary_.type != "")
		us_button_itemList_equippedWeaponPrimary.SetString("label", Equipments_.primary_.type );
	if(Equipments_.secondary_.type != "")
		us_button_itemList_equippedWeaponSecondary.SetString("label", Equipments_.secondary_.type );
	if(Equipments_.items_[0] != None)
		us_button_itemList_equippedItem1.SetString("label", Equipments_.items_[0].itemName );
	if(Equipments_.items_[1] != None)
		us_button_itemList_equippedItem2.SetString("label", Equipments_.items_[1].itemName );
	if(Equipments_.items_[2] != None)
		us_button_itemList_equippedItem3.SetString("label", Equipments_.items_[2].itemName );
	if(Equipments_.items_[3] != None)
		us_button_itemList_equippedItem4.SetString("label", Equipments_.items_[3].itemName );
}

function UpdateItems( const array<Array2D> items )
{
	myItemList.addItems( items );
	UpdateItemList();
}

function UpdateShop( const array<Array2D> items )
{
	myMenuShop.addItems( items );
}

private function UpdateItemList()
{
	local array<WeaponStruct> weaps;
	local array<AEInventory_Item> items;
	local int counter;
	local int i;
	local int start;
	local int end;

	counter = 0;

	weaps.Length = 0;
	items.Length = 0;

	weaps = myItemList.getWeapons();
	items = myItemList.getItems();

	weaponPageMax_ = weaps.Length / 5;
	if( float(weaps.Length / 5) > weaponPageMax_ )
		++weaponPageMax_;

	itemPageMax_ = items.Length / 5;
	if( float(items.Length / 5) > itemPageMax_ )
		++itemPageMax_;

	start = weaponPage_ * 5;
	end = start + 5;
	for( i = start; i < end; ++i )
	{
		if( i < weaps.Length )
		{
			switch( counter )
			{
			case 0:
					us_button_itemList_weaponSlot1.SetString("label", weaps[i].type );
					weapons_[0] = weaps[i];				
				break;
			case 1:
					us_button_itemList_weaponSlot2.SetString("label", weaps[i].type );
					weapons_[1] = weaps[i];				
				break;
			case 2:
					us_button_itemList_weaponSlot2.SetString("label", weaps[i].type );
					weapons_[2] = weaps[i];				
				break;
			case 3:
					us_button_itemList_weaponSlot2.SetString("label", weaps[i].type );
					weapons_[3] = weaps[i];				
				break;
			case 4:
					us_button_itemList_weaponSlot2.SetString("label", weaps[i].type );
					weapons_[4] = weaps[i];
				break;
			}
			++counter;
		}
	}

	counter = 0;
	start = itemPage_ * 5;
	end = start + 5;
	for( i = itemPage_ * 5; i < (itemPage_ * 5 + 5); ++i )
	{
		if( i < items.Length )
		{
			switch( counter )
			{
			case 0: 
					us_button_itemList_itemSlot1.SetString("label", items[i].itemName );
					items_[0] = items[i];
				break;
			case 1:
					us_button_itemList_itemSlot2.SetString("label", items[i].itemName );
					items_[1] = items[i];
				break;
			case 2:
					us_button_itemList_itemSlot2.SetString("label", items[i].itemName );
					items_[2] = items[i];
				break;
			case 3:
					us_button_itemList_itemSlot2.SetString("label", items[i].itemName );
					items_[3] = items[i];
				break;
			case 4:
					us_button_itemList_itemSlot2.SetString("label", items[i].itemName );
					items_[4] = items[i];				
				break;
			}
			++counter;
		}
	}
	
	UpdateList();
}

function UpdateShopList()
{

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
	us_dynamicText_missions_missionSelected.SetText("" $ mySelectionID $ " / " $ AEPC.myDataStorage.MissionLength() - 1);
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

	// Previews mission image. Hard-coded.
	switch (mission.levelID)
	{
		case 1:
			ActionScriptVoid( "previewMissionPicture_level1" );
			break;
		case 2:
			ActionScriptVoid( "previewMissionPicture_level2" );
			break;
		case 3:
			ActionScriptVoid( "previewMissionPicture_level3" ); 
			break;
	}
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
	ItemList_ = class'AEMenuList'
	MenuShop_ = class'AEMenuShop'
	mySelectionID = 0;
	mySelectionIDMax = 0;

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