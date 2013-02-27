class AEInventory_Item extends Actor
	placeable;

enum ItemEffects
{
	EFFECT_HEAL,
	EFFECT_GRANADE
};

var Actor item; 

var array<ItemEffects> Effects;
var AEInventory_ItemEffects selectEffect;
 
var AEPlayerController PC;

var int StackCounter;
var int UseCounter;

var float Cooldown;
var bool  bCanUse;

var string ItemInfo;
var string itemName;
var int damage;
var int radius;
var float delay;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	selectEffect = spawn(class'AEInventory_ItemEffects', self);
	bCanUse = true;
}

/** Here to initialize PlayerController and cooldownTimer */
simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if(PC == none)
		PC = AEPlayerController( GetALocalPlayerController() );
}

/** Adds an item of this type to the inventory. Can add more than a spesifed amount */
simulated function Add(int add)
{
	StackCounter += add;
}

/** Tries to use an item. Returns false if item has cooldown or no more of this type. */
simulated function bool Use()
{
	local ItemEffects effect;

	if( !bCanUse || StackCounter <= 0)
		return false;

	foreach Effects( effect )
	{
		if( effect == EFFECT_GRANADE )
			item = selectEffect.granade(PC.myPawn, delay);
		else if( effect == EFFECT_HEAL ){
			//item = self;
		}
	}

	SetTimer(delay, false, 'explode');
	SetTimer(Cooldown, false, 'resetCooldown');

	bCanUse = false;
	--StackCounter;

	return true;
}

/** Timer function * reset cooldowns */
function resetCooldown()
{
	bCanUse = true;
}

/** Timer function * Actives after item delay */
function explode()
{
	local AEPawn target;
	local ItemEffects effect;

	if(Item == none) return;

	foreach WorldInfo.AllPawns(class'AEPawn', target, item.Location, radius)
	{
		foreach Effects( effect )
		{
			if( effect == EFFECT_HEAL )
				selectEffect.heal(target, damage);
			if( effect == EFFECT_GRANADE )
				selectEffect.dealDamage( target, item, damage );
		}
	}	
}

DefaultProperties
{
	StackCounter=0
	UseCounter=0
	Cooldown=1
	delay=3
	radius=500
}
