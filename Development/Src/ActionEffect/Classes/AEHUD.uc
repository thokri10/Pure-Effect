class AEHUD extends UTHUD;

var HudLocalizedMessage         ErrorMessage;
var HudLocalizedMessage         Message;
var array<HudLocalizedMessage>  MissionInfo;
var array<HudLocalizedMessage>  UserInfo;

function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
	super.DrawMessageText(LocalMessage, ScreenX, ScreenY);
}

event PostRender()
{
	local int i;
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

	DrawMessageText(ErrorMessage, 350, 350);
}

function postError(string msg)
{
	ErrorMessage.StringMessage = msg;
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
	
}
