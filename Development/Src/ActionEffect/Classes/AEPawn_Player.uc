class AEPawn_Player extends AEPawn;

var AEPlayerController EAPC;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	EAPC = AEPlayerController(GetALocalPlayerController());
	if (EAPC != None)
	{
		EAPC.myPawn = self;
		`log("[AEPawn_Player] Setting pawn");
	}
	else
	{
		`log("[AEPawn_Player] No controller to pawn");
	}
}

function AddWeaponToInventory(UTWeapon type)
{
	UTInventoryManager(InvManager).AddInventory(type);
}

function bool Dodge(eDoubleClickDir DoubleClickMove){return false;}

DefaultProperties
{
	InventoryManagerClass=class'ActionEffect.AEInventoryManager'

	bCanDoubleJump = false
	MaxMultiJump=0
	MultiJumpRemaining=0
	GroundSpeed = 600.0f;
}