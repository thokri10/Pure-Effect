class AEPawn extends UTPawn;

var AEPlayerShield      AEShield;

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	AEShield.SetLocation( Location );
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	AEShield.Destroy();

	return super.Died(Killer, damageType, HitLocation);
}

function AddDefaultInventory()
{
	local UTWeap_ShockRifle shock;

	shock = Spawn(class'UTWeap_ShockRifle');

	InvManager.AddInventory(shock);
}

DefaultProperties
{
}