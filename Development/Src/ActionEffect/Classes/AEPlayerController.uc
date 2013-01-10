class AEPlayerController extends UTPlayerController;

var AETcpLinkClient myTcpLink;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	myTcpLink = Spawn(class'AETcpLinkClient');
	myTcpLink.PC = self;

	//myTcpLink.ResolveMe();
}

DefaultProperties
{

}