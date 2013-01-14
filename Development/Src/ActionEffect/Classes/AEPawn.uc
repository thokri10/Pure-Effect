class AEPawn extends UTPawn;

var AEPlayerController EAPC;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	EAPC = AEPlayerController(GetALocalPlayerController());
	if (EAPC != None)
	{
		EAPC.myPawn = self;
		`log("Setting pawn");
	}
	else
	{
		`log("No controller to pawn");
	}
}

function AddDefaultInventory()
{
	local UTWeap_ShockRifle rocket;

	rocket = Spawn(class'UTWeap_ShockRifle');
	UTInventoryManager(InvManager).AddInventory(rocket);

	`log("adsasdjlksdjflksdjflk");
	//UTInventoryManager(InvManager).CreateInventory(class'UTWeap_RocketLauncher_Content');
}

function AddWeaponToInventory(UTWeapon type)
{
	UTInventoryManager(InvManager).AddInventory(type);
}

DefaultProperties
{
	InventoryManagerClass=class'ActionEffect.AEInventoryManager'
}
