/** Path nodes for the bot that player escorts in the Escort gametype. 
 *  The "escort bots" follows those path nodes to reach its goal. */
class AEPathNodeEscortBotFriendly extends PathNode
	placeable;

/** ID of the path node. An ID -1 means it won't be used. Valid values are 0 or higher. */
var() int pathNodeID;

/** Max amount of path nodes. */
var int amountOfMaxPathNodes;

/** Overrode this function. */
function PostBeginPlay()
{
	super.PostBeginPlay();

	bOneWayPath = true;
	bAlreadyVisited = false;
}

/** Sets the ID of the path node. */
function setPathNodeID(int ID)
{
	if (ID >= 0 && ID < amountOfMaxPathNodes)
	{
		pathNodeID = ID;
	}
	else
	{
		`Log("[AEPathNodeEscortBotFriendly] PathNodeID could not be set due to " $
			"an invalid value...");
	}
}

/** Set the max amount of path nodes. */
function setMaxAmountOfPathNodes(int maxAmount)
{
	amountOfMaxPathNodes = maxAmount;
}

DefaultProperties
{
	// Default value. Bot won't use this node ever if it's -1.
	// Valid values are 0 or higher.
	pathNodeID = -1;
}
