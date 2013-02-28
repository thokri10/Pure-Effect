class AENavigationPoint_Spawn extends AENavigationPoint
	placeable;

var bool bInUse;

/** What type of bot should spawn on this */
var(BotType) class<AEPawn_Bot> typeOfBot;

DefaultProperties
{
	bInUse=false
}
