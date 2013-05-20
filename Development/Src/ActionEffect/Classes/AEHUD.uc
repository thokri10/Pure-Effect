/** Custom HUD for Action Effect. */
class AEHUD extends UTHUD;

/** Multipalyer info */
var HudLocalizedMessage         RedOwner;
var HudLocalizedMessage         RedScores;
var HudLocalizedMessage         BlueOwner;
var HudLocalizedMessage         BlueScores;

var HudLocalizedMessage         GameTimer;

/** Message that contains why an error occured. */
var HudLocalizedMessage         ErrorMessage;

/** Message that contains ordinary info (non-errors). */
var HudLocalizedMessage         Message;

/** An array of Messages that together represent the details of the mission. */
var array<HudLocalizedMessage>  MissionInfo;

/** An array of Messages that together represent the details of the user (player). */
var array<HudLocalizedMessage>  UserInfo;

/** Array of menu entries. */
var array<HudLocalizedMessage>  Menu;

/** Variable that holds the info of the current active menu entry. */
var int activeMenuSlot;

/** Not sure what this is used for... :p */
var int ErrorCounter;

/** The width of the HUD bar. */
var float barWidth;

/** The height of the HUD bar. */
var float barHeight;

/** Draws a message on the screen (can be part of the menu). */
function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
	super.DrawMessageText(LocalMessage, ScreenX, ScreenY);
}

/** Overrode this function even though it does nothing. */
event Tick(float DeltaTime)
{
	// Override if necessary.	
}

/** Draws the HUD for every frame. */
event PostRender()
{
	local int i;
	local HudLocalizedMessage menuTag;
	super.PostRender();

	Canvas.Font = GetFontSizeIndex(1);
	Canvas.DrawColor = WhiteColor;

	DrawMessageText(Message, Canvas.SizeX * 0.8f, 300);

	// Draws the mission info if needed (Length > 0).
	// Draws at about center top.
	for (i = 0; i < MissionInfo.Length; i++)
	{
		DrawMessageText(MissionInfo[i], Canvas.SizeX * 0.35f - 20, 20 * 1 * i);
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

	// Printing error message to screen
	if (ErrorCounter < 100)
	{
		DrawMessageText(ErrorMessage, Canvas.SizeX * 0.4f, Canvas.SizeY * 0.8f);
		++ErrorCounter;
	}

	// Draws the multiplayer info to screen
	DrawMessageText(RedOwner, Canvas.SizeX * 0.10f, 0);
	DrawMessageText(RedScores, Canvas.SizeX * 0.10f, 20);
	DrawMessageText(BlueOwner, Canvas.SizeX * 0.70f, 0);
	DrawMessageText(BlueScores, Canvas.SizeX * 0.70f, 20);
	DrawMessageText(GameTimer, Canvas.SizeX * 0.45f, 0);
}

/** Posts errors. */
function postError(string msg)
{
	ErrorMessage.StringMessage = msg;
	ErrorCounter = 0;
}

/** Adds menu entries (selections) to the menu. */
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

/** Adds entries to the HUD for mission info. */
function addMissionInfo(string msg, optional bool bNoAdd)
{
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "[MissionInfo] " $ msg;

	// Checks if we need to see the mission info (mission is active).
	if ( bNoAdd )
	{
		MissionInfo.Length = 0;
	}
		
	if (msg != "")
	{
		MissionInfo.AddItem(nullMsg);
	}
}

/** Set menu entry active with an "[>]". "Inactive" entries are marked with "[ ]". */
function setMenuActive(int slot)
{
	if (slot > menu.Length || menu.Length == 0)
	{
		return;
	}
	
	if (Menu.Length != 1)
	{
		Menu[activeMenuSlot].StringMessage = mid( Menu[activeMenuSlot].StringMessage, 3);
		Menu[activeMenuSlot].StringMessage = "[ ]" $ Menu[activeMenuSlot].StringMessage;
	}

	Menu[slot].StringMessage = mid( Menu[slot].StringMessage, 3);
	Menu[slot].StringMessage = "[>]" $ Menu[slot].StringMessage;
	activeMenuSlot = slot;
}

/** Adds entries to the HUD containing the player info. */
function addUserInfo(string msg)
{
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "[UserInfo] " $ msg;
	UserInfo.AddItem(nullMsg);
}

/** Resets all mission info. */
function resetMissionInfo()
{
	local array<HudLocalizedMessage> tmp;
	local HudLocalizedMessage nullMsg;

	nullMsg.StringMessage = "";
	tmp[0] = nullMsg;
	MissionInfo.Length = 0;

	MissionInfo = tmp;
}

function setObjectiveInfo(string RedEngineOwner, int RedScore, string BlueEngineOwner, int BlueScore)
{
	RedOwner.StringMessage = "Red Engine: " $ RedEngineOwner;
	RedScores.StringMessage = "Red Score: " $ RedScore;
	BlueOwner.StringMessage = "Blue Engine: " $ BlueEngineOwner;
	BlueScores.StringMessage = "Blue Score: " $ BlueScore;
}

function SetGameTimer(float timer)
{
	GameTimer.StringMessage = "" $ int(timer);
}

//-------------------------------
// HUD PAWN INFO

/** Draws a bar for HUD */
function DrawBar(String barTitle, float barValue, float barMaxValue,
	int x, int y, int textValueR, int textValueG, int textValueB, 
	optional float WidthToBar = 0)
{
    local int posX;
	local float barLengthFilled;
	
	// Where we should draw the next rectangle
    posX = x;

	barLengthFilled = barValue / barMaxValue;
	

	Canvas.SetPos(posX, y);
	Canvas.SetDrawColor(textValueR, textValueG, textValueB, 200);

	if(WidthToBar == 0)
		Canvas.DrawRect(barWidth * barLengthFilled, barHeight);
	else
		Canvas.DrawRect(WidthToBar * barLengthFilled, barHeight);

    /* Displays a title of the bar */
    Canvas.SetPos(posX + 5, y + 5);
    Canvas.SetDrawColor(255.0, 255.0, 255.0, 200);
    Canvas.Font = class'Engine'.static.GetMediumFont();
    Canvas.DrawText(barTitle);
}

/** Draws the health bar on the screen. */
function DrawHealthBar(float barValueR, float barValueG, float barValueB)
{
    if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating'))
    {
		Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX * 0.990f), Canvas.SizeY - (Canvas.SizeY * 0.050f));
		Canvas.SetDrawColor(barValueR + 20, barValueG, barValueB, 100);
		Canvas.DrawRect(barWidth, barHeight);

        DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax, 
        	Canvas.SizeX - (Canvas.SizeX * 0.990f), 
        	Canvas.SizeY - (Canvas.SizeY * 0.050f),
        	barValueR, barValueG, barValueB);
    }
}

/** Draws the stamina bar on the screen. */
function DrawStaminaBar(float barValueR, float barValueG, float barValueB)
{
	// TODO: Fix so that it works for multiplayer.
	local AEPlayerController playerPC;
	playerPC = AEPlayerController(GetALocalPlayerController());

	if(playerPC.myPawn != None)
	{
		if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating'))
		{
			Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX * 0.990f), Canvas.SizeY - (Canvas.SizeY * 0.100f));
			Canvas.SetDrawColor(barValueR, barValueG + 20, barValueB, 100);
			Canvas.DrawRect(barWidth, barHeight);

			DrawBar("Stamina", playerPC.myPawn.sprintEnergy, playerPC.myPawn.maxSprintEnergy,
				Canvas.SizeX - (Canvas.SizeX * 0.990f),
				Canvas.SizeY - (Canvas.SizeY * 0.100f),
				barValueR, barValueG, barValueB);
		}
	}
}

/** Draws the fuel bar on the screen. */
function DrawFuelBar(float barValueR, float barValueG, float barValueB)
{
	local AEPlayerController playerPC;
	local float fuelRatio;

	// // TODO: Fix so that it works for multiplayer.
	playerPC = AEPlayerController(GetALocalPlayerController());
	fuelRatio = playerPC.myJetpack.fuelEnergy / playerPC.myJetpack.maxFuelEnergy;
	//fuelRatio = playerPC.myPawn.fuelEnergy / playerPC.myPawn.maxFuelEnergy;

	
	if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating') && playerPC.myPawn.isUsingJetPack)
    {
		DrawBar("", playerPC.myJetpack.fuelEnergy, playerPC.myJetpack.maxFuelEnergy,
			(Canvas.SizeX / 2) - ((barWidth * fuelRatio) / 2),
			(Canvas.SizeY / 2) + (barHeight * 4),
			barValueR, barValueG, barValueB);
		
		if (playerPC.myJetpack.fuelEnergy <= 0.0f)
		{
			Canvas.SetPos((Canvas.SizeX / 2) - 55.0f, (Canvas.SizeY / 2) + (barHeight * 2));
			Canvas.DrawText("OUT OF FUEL");
		}
    }
}

function DrawItemInfo(const float R, const float G, const float B)
{
	local AEPlayerController playerPC;
	local AEInventory_Item itemList[4];
	local float timer;
	local int i;

	playerPC = AEPlayerController( GetALocalPlayerController() );
	for( i = 0; i < 4; ++i)
	{
		if(playerPC.myItemInventory.ItemList_[i] != None)
			itemList[i] = playerPC.myItemInventory.ItemList_[i];
	}

	if( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating') )
	{
		// Item 1
		for( i = 0; i < 4; ++i)
		{
			if(itemList[i] != None)
			{
				timer = itemList[i].GetTimerCount('resetCooldown');
				if(timer == -1){
					Canvas.SetPos( Canvas.SizeX - (Canvas.SizeX * 0.990f), Canvas.SizeY / 2 + (barHeight * i));
					Canvas.DrawText(itemList[i].itemName $ " Counter: " $ itemList[i].StackCounter);
				}else{
					DrawBar("", itemList[i].Cooldown - timer, itemList[i].Cooldown, 
								Canvas.SizeX - (Canvas.SizeX * 0.990f), Canvas.SizeY / 2 + (barHeight * i), 
								R, G, B, 100.0f);
				}
			}
		}
	}
}

/** Overrode this function to make our custom HUD. */
function DrawLivingHud()
{
	//DisplayAmmo(UTWeapon(PawnOwner.Weapon));

	DrawHealthBar(200.0f, 80.0f, 80.0f);
	DrawStaminaBar(80.0f, 200.0f, 80.0f);
	DrawItemInfo(80.0f, 80.0f, 200.0f);
	// Uncommented for debugging purposes.
	//DrawFuelBar(200.0f, 200.0f, 200.0f);
}

DefaultProperties
{
	// Initializations of various variables.
	ErrorCounter = 0;
	barWidth = 300.0f;
	barHeight = 30.0f;
}
