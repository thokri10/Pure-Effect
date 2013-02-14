/** Spawn point for enemy bots that try to kill you and your escort target
 *  in the Escort game type. */
class AENavigationPoint_EscortEnemyBotSpawn extends AENavigationPoint
	placeable;

/** Variable that checks if a bot has used it already. */
var bool bInUse;

DefaultProperties
{
	bInUse = false;
}
