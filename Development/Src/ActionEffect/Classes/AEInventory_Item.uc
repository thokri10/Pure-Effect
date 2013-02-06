class AEInventory_Item extends Actor
	placeable;
 
var AEPlayerController PC;

var int StackCounter;
var int UseCounter;
var float CooldownTimer;
var float Cooldown;

var bool stillActive;

var string ItemInfo;

// 
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

// Here to initialize PlayerController and cooldownTimer
simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if(PC == none)
		PC = AEPlayerController( GetALocalPlayerController() );

	if(CooldownTimer < Cooldown)
	{
		CooldownTimer += DeltaTime;
		stillActive = true;
	}else
	{
		stillActive = false;
	}
}

// Adds an item of this type to the inventory. Can add more than a spesifed amount
simulated function Add()
{
	if(UseCounter < StackCounter)
		++UseCounter;

	PC.mHUD.postError("Inventory full of this type");
}

// Tries to use an item. Returns false if item has cooldown or no more of this type.
simulated function bool Use()
{
	if( UseCounter <= 0)
	{
		PC.mHUD.postError("No more of this ItemType");
		return false;
	}
	else if( CooldownTimer < Cooldown ){
		PC.mHUD.postError("Item still on cooldown");
		return false;
	}

	CooldownTimer = 0;
	--UseCounter;

	return true;
}

DefaultProperties
{
	StackCounter=0
	UseCounter=0
	CooldownTimer=100

	stillActive=false
}
