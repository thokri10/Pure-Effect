class AEHUD extends UTHUD;

var HudLocalizedMessage         ErrorMessage;
var HudLocalizedMessage         Message;
var array<HudLocalizedMessage>  MissionInfo;
var array<HudLocalizedMessage>  UserInfo;

// Menu variables
var array<HudLocalizedMessage>  Menu;
var int activeMenuSlot;

var int ErrorCounter;

function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
	super.DrawMessageText(LocalMessage, ScreenX, ScreenY);
}

event PostRender()
{
	local int i;
	local HudLocalizedMessage menuTag;
	super.PostRender();

	Canvas.Font = GetFontSizeIndex(1);
	Canvas.DrawColor = WhiteColor;

	DrawMessageText(Message, 10, 300);

	for(i = 0; i < MissionInfo.Length; i++)
	{
		DrawMessageText(MissionInfo[i], 300, 20*i);
	}

	for(i = 0; i < UserInfo.Length; i++)
	{
		DrawMessageText(UserInfo[i], 20, 20+i);
	}

	for(i = 0; i < Menu.Length; i++)
	{
		menuTag.StringMessage = "MENU ";
		DrawMessageText(menuTag, 10, 280);
		DrawMessageText(Menu[i], 10, 300 + (i * 20));
	}

	if(ErrorCounter < 100){
		DrawMessageText(ErrorMessage, 350, 350);
		++ErrorCounter;
	}
}

function postError(string msg)
{
	ErrorMessage.StringMessage = msg;
	ErrorCounter=0;
}

function addToMenu(string msg, optional bool bNoAddToMenu)
{
	local HudLocalizedMessage nullMsg;
	local array<HudLocalizedMessage> temp;

	temp.AddItem(nullMsg);


	if(bNoAddToMenu)
		Menu = temp;

	nullMsg.StringMessage = "[ ] " $ msg;
	Menu.AddItem(nullMsg);
}

function setMenuActive(int slot)
{
	if(slot > menu.Length)
		return;

	Menu[activeMenuSlot].StringMessage = mid( Menu[activeMenuSlot].StringMessage, 3);
	Menu[activeMenuSlot].StringMessage = "[ ]" $ Menu[activeMenuSlot].StringMessage;

	Menu[slot].StringMessage = mid( Menu[slot].StringMessage, 3);
	Menu[slot].StringMessage = "[>]" $ Menu[slot].StringMessage;
	activeMenuSlot = slot;
}

function addUserInfo(string msg)
{
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "[UserInfo] " $ msg;
	UserInfo.AddItem(nullMsg);
}

function addMissionInfo(string msg)
{
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "[MissionInfo] " $ msg;
	MissionInfo.AddItem(nullMsg);
}

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
	ErrorCounter=0
}
