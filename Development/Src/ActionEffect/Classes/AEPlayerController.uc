class AEPlayerController extends UTPlayerController;

var AEWeaponCreator         myWeaponCreator;
var AETcpLinkClient         myTcpLink;
var AEPawn                  myPawn;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	myWeaponCreator = Spawn(class'AEWeaponCreator');
	myTcpLink = Spawn(class'AETcpLinkClient');
	myTcpLink.PC = self;

	myTcpLink.ResolveMe();
}

exec function getWeapon(string type, float spread, int magazineSize)
{
	myPawn.AddWeaponToInventory( myWeaponCreator.CreateWeapon(type, spread, magazineSize) );
}

DefaultProperties
{
}