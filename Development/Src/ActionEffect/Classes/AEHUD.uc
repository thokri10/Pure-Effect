// PURPOSE: Custom HUD (based on an old HUD from UDK).
class AEHUD extends UTHUD;

// Varibles that hold various HUD information.
var HudLocalizedMessage         ErrorMessage;
var HudLocalizedMessage         Message;
var array<HudLocalizedMessage>  MissionInfo;
var array<HudLocalizedMessage>  UserInfo;

// Menu variables that show what choices you can browse and current "active"
// choice.
var array<HudLocalizedMessage>  Menu;
var int activeMenuSlot;

// Not sure what this is used for... :p
var int ErrorCounter;

// Draws a message on the screen (can be part of the menu).
function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
	super.DrawMessageText(LocalMessage, ScreenX, ScreenY);
}

// Draws the HUD.
event PostRender()
{
	local int i;
	local HudLocalizedMessage menuTag;
	super.PostRender();

	Canvas.Font = GetFontSizeIndex(1);
	Canvas.DrawColor = WhiteColor;

	DrawMessageText(Message, 10, 300);

	// Draws the mission info if needed (Length > 0).
	// Draws at about center top.
	for (i = 0; i < MissionInfo.Length; i++)
	{
		DrawMessageText(MissionInfo[i], 300, 20 * i);
	}

	// Draws the user info if needed (Length > 0).
	// Draws in the upper-left corner.
	for (i = 0; i < UserInfo.Length; i++)
	{
		DrawMessageText(UserInfo[i], 20, 20 + i);
	}

	// Draws the menu items if needed (Length > 0).
	// Draws at center-left.
	for (i = 0; i < Menu.Length; i++)
	{
		menuTag.StringMessage = "MENU ";
		DrawMessageText(menuTag, 10, 280);
		DrawMessageText(Menu[i], 10, 300 + (i * 20));
	}

	// Unsure... :p
	if (ErrorCounter < 100)
	{
		DrawMessageText(ErrorMessage, 350, 350);
		++ErrorCounter;
	}
}


// Posts errors.
function postError(string msg)
{
	ErrorMessage.StringMessage = msg;
	ErrorCounter = 0;
}

// Adds menu entries (selections) to the menu.
function addMenuSelections(string msg, optional bool bNoAdd)
{
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "[ ] " $ msg;

	// Checks if we need to see the menu.
	if ( bNoAdd )
	{
		Menu.Length = 0;
	}
	if(msg != ""){
		Menu.AddItem(nullMsg);
	}
}

// Adds entries to the HUD for mission info.
function addMissionInfo(string msg, optional bool bNoAdd)
{
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "[MissionInfo] " $ msg;

	// Checks if we need to see the mission info (mission is active).
	if ( bNoAdd )
	{
		MissionInfo.Length = 0;
	}
		
	MissionInfo.AddItem(nullMsg);
}

// Set menu entry active with an "[>]". "Inactive" entries are marked with "[ ]". 
function setMenuActive(int slot)
{
	if (slot > menu.Length || menu.Length == 0)
	{
		return;
	}
	
	if(Menu.Length != 1){
		Menu[activeMenuSlot].StringMessage = mid( Menu[activeMenuSlot].StringMessage, 3);
		Menu[activeMenuSlot].StringMessage = "[ ]" $ Menu[activeMenuSlot].StringMessage;
	}

	Menu[slot].StringMessage = mid( Menu[slot].StringMessage, 3);
	Menu[slot].StringMessage = "[>]" $ Menu[slot].StringMessage;
	activeMenuSlot = slot;
}

// Adds entries to the HUD containing the player info.
function addUserInfo(string msg)
{
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "[UserInfo] " $ msg;
	UserInfo.AddItem(nullMsg);
}

// Resets all mission info.
function resetMissionInfo()
{
	local array<HudLocalizedMessage> tmp;
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "";
	tmp[0] = nullMsg;

	MissionInfo = tmp;
}

DefaultProperties
{
	ErrorCounter = 0;
}
