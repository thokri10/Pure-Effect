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

var float barLength;
var float barHeight;

// Draws a message on the screen (can be part of the menu).
function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
	super.DrawMessageText(LocalMessage, ScreenX, ScreenY);
}

event Tick(float DeltaTime)
{
	// Override if necessary.
}

// Draws the HUD.
event PostRender()
{
	local int i;
	local HudLocalizedMessage menuTag;
	super.PostRender();

	Canvas.Font = GetFontSizeIndex(1);
	Canvas.DrawColor = WhiteColor;

	DrawMessageText(Message, 600, 300);

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

	if (msg != "")
	{
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

function DrawBar(String barTitle, float barValue, float barMaxValue,
	int x, int y, int textValueR, int textValueG, int textValueB)
{
    local int posX;
    local int numberOfBarSquares;
    local int i;
	local float barLengthFilled;
	

	// Where we should draw the next rectangle
    posX = x;

	// Number of active rectangles to draw
    numberOfBarSquares = 10 * barValue / barMaxValue;
    i = 0; // Number of rectangles already drawn

	barLengthFilled = barValue / barMaxValue;

    /* Displays active rectangles */
  //  while ( (i < numberOfBarSquares) && (i < 10) )
  //  {
  //      Canvas.SetPos(posX, y);
  //      Canvas.SetDrawColor(textValueR, textValueG, textValueB, 200);
  //      Canvas.DrawRect(16, 24);
		//// Canvas.DrawRect(8, 12);

  //      posX += 18;
  //      i++;
  //  }

	Canvas.SetPos(posX, y);
	Canvas.SetDrawColor(textValueR, textValueG, textValueB, 200);
	Canvas.DrawRect(barLength * barLengthFilled, 24);

    /* Displays unactive rectangles */
  //  while (i < 10)
  //  {
  //      Canvas.SetPos(posX, y);
  //      Canvas.SetDrawColor(255, 255, 255, 80);
  //      Canvas.DrawRect(16, 24);
		//// Canvas.DrawRect(8, 12);

  //      posX += 18;
  //      i++;
  //  }

    /* Displays a title of the bar */
    Canvas.SetPos(posX + 5, y);
    Canvas.SetDrawColor(255.0, 255.0, 255.0, 200);
    Canvas.Font = class'Engine'.static.GetMediumFont();
    Canvas.DrawText(barTitle);
}

function DrawHealthBar()
{
    if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating'))
    {
        DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax, 
        	Canvas.SizeX - (Canvas.SizeX * 0.990f), 
        	Canvas.SizeY - (Canvas.SizeY * 0.050f),
        	200, 80, 80);

		Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX * 0.990f), Canvas.SizeY - (Canvas.SizeY * 0.050f));
		Canvas.SetDrawColor(200, 80, 80, 200);
		Canvas.DrawBox(178, 24);
    }
}

function DrawAmmoBar()
{
	if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating'))
    {
		//DrawBar("Ammo", UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount ,20,40,80,80,200);
		DrawBar("Ammo", UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount ,
			Canvas.SizeX - (Canvas.SizeX * 0.990f),
			Canvas.SizeY - (Canvas.SizeY * 0.090f),
			80,80,200);
    }
}

// Overrode this function to make our custom HUD.
function DrawLivingHud()
{
	DisplayAmmo(UTWeapon(PawnOwner.Weapon));

	DrawHealthBar();
	//DrawAmmoBar();
}

DefaultProperties
{
	ErrorCounter = 0;
	barLength = 200.0f;
	barHeight = 25.0f;
}
