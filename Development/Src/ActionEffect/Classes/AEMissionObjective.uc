/** Mission objective contains information of your current mission. */
class AEMissionObjective extends Actor
	dependson(AEWeaponCreator)
	dependson(AEJSONParser)
	dependson(AEWeaponCreator);

//-----------------------------------------------------------------------------
// Structures

/** Struct for to hold all the mission objectives. 
    This is created with a string parser in this class. */
struct MissionObjectives
{
	var int id;
	var string category;
	var string mapName;
	var string title;
	var string description;
	var array<WeaponStruct> rewards;
	var array<AEInventory_Item> rewardItems;
	var int MOEnemies;
};

/** Easy access to all the information to a mission. */
struct SimpleMissionStruct
{
	/** Holds the info of the mission */
	var array<ValueStruct> information;

	/** Rewards. Length to check how many rewards.*/
	var array<Array2D> rewards;
};

/** Really not in use. Remove later if not in use */
struct RewardStruct
{
	var int Credit;
	var string Weapon;
};

/** Game types. */
enum AEGameType
{
	NO_GAMETYPE,
	SEARCH_AND_DESTROY,
	ESCORT
};

//-----------------------------------------------------------------------------
// Variables

/** This is set trough AEtcpLink when the string is parsed.
	QuickFix find a better solution. */
var string rewardString;

/** Array that contains our rewards for our mission. */
var array<string> rewardArray;

/** Array that contains the mission information. */
var array<SimpleMissionStruct> simpleMissionArray;

/** Number of bots killed. */
var int botsKilled;

/** Escort bot life condition. */
var bool escortbotIsAlive;

/** Escort bot has reached target destination. */
var bool escortBotHasReachedDestination;

/** Console client (press Tab ingame to access it). */
var Console consoleClient;

/** Player controller. */ 
var AEPlayerController  PC;

/** We want to have control over all the pawns we have spawned in this objective. 
	Now we have a easy way to check how many bots we have killed. */
var array<AEPawn_Bot>           SpawnedBots;

/** The escort bots that we spawn in the gametype Escort. */
var array<AEPawn_EscortBot>     SpawnedEscortBots;

/** The bots that will try to kill you and your Escort target. */
var array<AEPawn_BotAgressive> SpawnedEnemyEscortBots;

/** Initialize the struct to hold the default variables of our mission.
	Then we can easily restart our mission at any time. */
var MissionObjectives   AEObjectives;

/** Gametype of the mission. */
var AEGameType missionGameType;

/** Checks if a mission is in play. */
var bool missionIsActive;

/** Keeps track how much time has passed. */
var float playerTimer;

/** How many seconds should pass before to check to "update" the player. */
var float timeToUpdate;

/** Desired FPS. Used to calculate how often we want to "update" the player.
	Used in conjunction with timeToUpdate (see below). */
var float fps;

//-----------------------------------------------------------------------------
// Init

event Tick(float DeltaTime)
{
	playerTimer += DeltaTime;

	super.Tick(DeltaTime);

	if ( playerTimer >= timeToUpdate )
	{
		playerTimer -= timeToUpdate;

		CheckMissionProgress();
	}
}

/** Overrode this function. Currently doesn't do anything in particular. */
simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	timeToUpdate = 1.0f / fps;
	//missionGameType = NO_GAMETYPE;
}

/** Initializes the missions wtih the array from jsonParser*/
function Initialize(array<ValueStruct> missionArray)
{
	activateObjectives( MissionFromSimpleStruct( parseArrayToSimpleStruct( missionArray ) ) );
}


//-----------------------------------------------------------------------------
// Parsing

/** Parses the a mission array to a simple mission struct. 
	It sets the info and rewards for the mission. */
function SimpleMissionStruct parseArrayToSimpleStruct(array<ValueStruct> missionArray)
{
	local SimpleMissionStruct   mission;
	local Array2D               temp;
	local string                Type;
	local bool                  existingReward;
	local int                   numberOfRewards;
	local int                   i;

	for ( i = 0; i < missionArray.Length; i++ ) 
	{
		//`log(missionArray[i].type $ " : " $ missionArray[i].value );
		if ( missionArray[i].type == "category" )
		{
			Type = "info";
		}
		else if ( missionArray[i].type == "properties" )
		{
			Type = "reward";
			mission.rewards.AddItem( temp );
				
			if (!existingReward)
			{
				existingReward = true;
			}	
			else
			{
				++numberOfRewards;
			}
		}
		else if ( missionArray[i].type == "" )
		{
			`log("[MissionSimpleParsing] Type is blank.");
		}

		switch( Type )
		{
			case "info": 
				mission.information.AddItem( missionArray[i] ); 
				break;

			case "reward": 
				mission.rewards[numberOfRewards].variables.AddItem( missionArray[i] ); 
				break;

			default:
				`Log("[AEMissionObjective] failed to set Type in the function " $
					"parseArrayToSimpleStruct");
				break;
		}
	}

	return mission;
}

/** Create a missionObjective struct from our simple struct */
function MissionObjectives MissionFromSimpleStruct(SimpleMissionStruct simpleMission)
{
	local MissionObjectives objective;
	local ValueStruct       values;
	local Array2D           reward;
	
	foreach simpleMission.information(values)
	{
		if     (values.type == "id")            objective.id           = int( values.value );
		else if(values.type == "category")      objective.category     = values.value;
		else if(values.type == "city_name")     objective.mapName      = values.value;
		else if(values.type == "description" )  objective.description  = values.value;
		else if(values.type == "title")         objective.title        = values.value;
		//else `log("[SimpleMissionParse] No known name of this type: " $ values.type);
	}

	foreach simpleMission.rewards( reward )
	{
		foreach reward.variables( values )
		{
			if (values.type == "slot")
			{
				`log(values.type $ " : " $ values.value );
				if (values.value == "weapon")
				{
					objective.rewards.AddItem( PC.myWeaponCreator.parseToStruct( reward.variables ) );
				}
				else if ( values.value == "item")
				{
					objective.rewardItems.AddItem( 
						PC.myItemInventory.createItem( 
						reward.variables ) );
				}
				break;
			}
		}		
	}
	
	return objective;
}

//-----------------------------------------------------------------------------
// Rewards

/** Gets the reward from mission and puts them into player inventory */
function getMissionRewards()
{
	local WeaponStruct weap;
	local AEInventory_Item item;

	foreach AEObjectives.rewards( weap )
	{
		PC.addWeaponToInventory( PC.myWeaponCreator.CreateWeaponFromStruct( weap ) );
	}
		
	foreach AEObjectives.rewardItems( item )
	{
		PC.myItemInventory.AddItem( item );
	}
}

//-----------------------------------------------------------------------------
// Objectives

/** Activates all the objectives. Check through a list and adds all the active objectives. */ 
function activateObjectives(MissionObjectives objectives)
{
	if (objectives != AEObjectives)
	{
		AEObjectives = objectives;
	}

	//// For testing purposes. Sets how many enemies we should spawn
	//objectives.MOEnemies = 5;
	//AEObjectives.MOEnemies = 5;

	//printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ objectives.MOEnemies);
	createObjectiveInfo();

	switch (AEObjectives.category)
	{
		case "Search and destroy":
			missionGameType = SEARCH_AND_DESTROY;
			missionIsActive = true;
			break;

		case "Escort":
			missionGameType = ESCORT;
			missionIsActive = true;
			break;

		default:
			`Log("[AEMissionObjective] failed to set gametype enum.");
			missionGameType = NO_GAMETYPE;
			break;
	}

	// long "if section" for all the objectives. 

	if (missionGameType == SEARCH_AND_DESTROY)
	{
		// For testing purposes. Sets how many enemies we should spawn
		objectives.MOEnemies = 5;
		AEObjectives.MOEnemies = 5;

		printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ objectives.MOEnemies);

		SpawnEnemyBots(objectives.MOEnemies);
	}
	else if (missionGameType == ESCORT)
	{
		SpawnEscortBot();
		SpawnEnemyEscortBots();
		printObjectiveMessage("Escort target.");
	}
	
	//SpawnEnemies(objectives.MOEnemies);
}

/** Spawns an enemy at a set location in the map */
function SpawnEnemies(int enemyNumber)
{
	// Spawn bots accordingly to gametype.
	if (missionGameType == SEARCH_AND_DESTROY)
	{
		SpawnEnemyBots(enemyNumber);
	}
	else if (missionGameType == ESCORT)
	{
		SpawnEscortBot();
	}
	else
	{
		`Log("[AEMissionObjective] Well, this is awkward. Mission couldn't start "
			$ "due to gametype not being set properly.");
	}
}

/** Spawns enemy bots on the map. */
function SpawnEnemyBots(int enemyNumber)
{
	local AEVolume_BotSpawn spawnPoint; 
	local AEVolume_BotSpawn target;
	local int i;

	foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
	{
		spawnPoint = target;
	}

	for (i = 0; i < enemyNumber; i++)
	{
		SpawnedBots.AddItem( spawnPoint.spawnBot(class'AEPawn_BotAgressive', self) );
	}
}

/** Spawn the bot that the player is going to escort in the Escort gametype. */
function SpawnEscortBot()
{
	local AEVolume_EscortBotSpawn escortSpawnPoint; 
	local AEVolume_EscortBotSpawn target;

	// Finds the spawn point for the escort bot and spawns one there.
	foreach WorldInfo.AllActors( class'AEVolume_EscortBotSpawn', target)
	{
		escortSpawnPoint = target;
		SpawnedEscortBots.AddItem(escortSpawnPoint.spawnBot(class'AEPawn_EscortBot', self));
	}
}

function SpawnEnemyEscortBots()
{
	local AEVolume_EscortEnemyBotSpawn enemySpawnPoint;
	local AEVolume_EscortEnemyBotSpawn target;
	local AEVolume_BotSpawn spawnPoint; 
	//local AEVolume_BotSpawn target;
	local int i;

	//foreach WorldInfo.AllActors( class'AEVolume_EscortEnemyBotSpawn', target)
	//{
	//	enemySpawnPoint = target;
	//	SpawnedEnemyEscortBots.AddItem(enemySpawnPoint.spawnBot(class'AEPawn_BotAgressive', self));
	//}

	foreach WorldInfo.AllActors( class'AEVolume_EscortEnemyBotSpawn', target )
	{
		enemySpawnPoint = target;
	}

	for (i = 0; i < 7; i++)
	{
		SpawnedEnemyEscortBots.AddItem( enemySpawnPoint.spawnBot(class'AEPawn_BotAgressive', self) );
	}
}

/** When a bot dies he runs this method to update the bots killed. */
function botDied()
{
	// CheckMissionProgress();
	//local AEVolume_BotSpawn target;

	++botsKilled;

	//if (botsKilled < AEObjectives.MOEnemies)
	//{
	//	printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ AEObjectives.MOEnemies);
	//}
	//else
	//{
	//	MissionComplete();

	//	foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
	//	{
	//		target.resetSpawnPoints();
	//	}
	//}
}

/** When an Escort target dies, this stuff runs. */
function escortBotDied()
{
	escortbotIsAlive = false;

	//foreach WorldInfo.AllActors( class'AEVolume_EscortBotSpawn', target )
	//{
	//	target.resetSpawnPoints();
	//}
}

/** Complete and reset all variables and gives the reward to player. */
function MissionComplete()
{
	PC.mHUD.postError("Mission complete: Reward added to inventory");
	printObjectiveMessage("", true);
	printObjectiveInfo("", true);

	botsKilled = 0;
	escortbotIsAlive = true;
	escortBotHasReachedDestination = false;

	getMissionRewards();
}

function CheckMissionProgress()
{
	local AEVolume_BotSpawn targetBotSpawn;
	local AEVolume_EscortBotSpawn targetEscortBotSpawn;
	local bool victory;

	victory = false;

	if (missionIsActive)
	{
		if (missionGameType == SEARCH_AND_DESTROY)
		{
			if (botsKilled < AEObjectives.MOEnemies)
			{
				printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ AEObjectives.MOEnemies);
			}
			else
			{
				victory = true;

				foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', targetBotSpawn )
				{
					targetBotSpawn.resetSpawnPoints();
				}
			}
		}
		else if (missionGameType == ESCORT)
		{
			if (escortBotHasReachedDestination)
			{
				victory = true;
			}
			else if (!escortbotIsAlive)
			{
				// Played failed to protect Escort bot and it died.
				// So now the spawns for the Escort bots are reset to be used again.
				foreach WorldInfo.AllActors( class'AEVolume_EscortBotSpawn', targetEscortBotSpawn )
				{
					targetEscortBotSpawn.resetSpawnPoints();
				}
			}
		}
	
		if (victory)
		{
			`Log("VICTORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRY");
			MissionComplete();
		}
	}
}

//-----------------------------------------------------------------------------
// MENU / HUD

/** Print mission info to screen */
function createObjectiveInfo()
{
	printObjectiveInfo( "Category: "    $   AEObjectives.category, true);
	printObjectiveInfo( "Title: "       $   AEObjectives.title);
	printObjectiveInfo( "Map: "         $   AEObjectives.mapName);
	printObjectiveInfo( "Description: " $   AEObjectives.description);
	//printObjectiveInfo( "Reward: "      $   AEObjectives.reward);
}

/** Prints the objective info to screen * if bNoAddToMessage is true it clears screen */
function printObjectiveInfo(string message, optional bool bNoAddToMessage)
{
	if (bNoAddToMessage)
	{
		PC.mHUD.resetMissionInfo();
	}
	else
	{
		PC.mHUD.addMissionInfo(message);
	}
}

/** Print objectives to the screen * Reset clears the screen first. 
 *  if message == "" it clears screen completly */
function printObjectiveMessage(string message, optional bool bReset)
{
	local HudLocalizedMessage msg;

	if (bReset)
	{
		msg.StringMessage = "";
	}
	else
	{
		msg.StringMessage = "[Objectives] " $ message;
	}
		
	PC.mHUD.Message = msg;
}

DefaultProperties
{
	escortbotIsAlive = true;
	escortBotHasReachedDestination = false;

	playerTimer = 0.0f;
	fps = 60.0f;

	missionIsActive = false;
}
