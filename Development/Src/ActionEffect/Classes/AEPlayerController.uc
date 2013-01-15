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

	//myTcpLink.ResolveMe();
}

exec function getWeapon(string type, float spread, int magazineSize, float reloadTime)
{
	myPawn.AddWeaponToInventory( myWeaponCreator.CreateWeapon(type, spread, magazineSize, reloadTime) );
}

exec function getServerWeapon()
{
	myPawn.AddWeaponToInventory( myWeaponCreator.CreateWeaponFromStruct( 
											myTcpLink.parseStringToWeapon( 
												myTcpLink.returnedMessage ) ) );
}

DefaultProperties
{
}