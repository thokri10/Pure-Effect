// THIS CLASS IS RESPONSIBLE FOR CONTROLLING THE PLAYER'S CHARACTER.
class AEPlayerController extends UTPlayerController;

// Responsible for generating weapons.
var AEWeaponCreator         myWeaponCreator;

// Network module used to gain weapon info from server.
var AETcpLinkClient         myTcpLink;

// Character that the player controls.
var AEPawn                  myPawn;

// Initializations before any pawns spawn on the map.
simulated event PostBeginPlay()
{
	// Initializations of various variables.
	super.PostBeginPlay();

	myWeaponCreator = Spawn(class'AEWeaponCreator');
	myTcpLink = Spawn(class'AETcpLinkClient');
	myTcpLink.PC = self;

	// Connect to server.
}

// CONSOLE COMMAND: Generates a weapon.
exec function getWeapon(string type, float spread, int magazineSize, float reloadTime)
{
	myPawn.AddWeaponToInventory( myWeaponCreator.CreateWeapon(type, spread, magazineSize, reloadTime) );
}

// CONSOLE COMMAND: Generates a weapon generated by information from the server.
exec function getServerWeapon()
{
	myPawn.AddWeaponToInventory( myWeaponCreator.CreateWeaponFromStruct( 
											myTcpLink.parseStringToWeapon( 
												myTcpLink.returnedMessage ) ) );
}

DefaultProperties
{
}