class AEMissionObjective extends Actor
	dependson(AEWeaponCreator)
	dependson(AEJSONParser)
	dependson(AEWeaponCreator);

//-----------------------------------------------------------------------------
// Structures

/** Struct for to hold all the mission objectives. This is created with a string parser in this class. */
struct MissionObjectives
{
	var int id;
	var string category;
	var string mapName;
	var string title;
	var string description;
	var array<WeaponStruct> rewards;
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

//-----------------------------------------------------------------------------
// Variables

// This is set trough AEtcpLink when the string is parsed.
// QuickFix find a better solution.
var string rewardString;

// Array that contains our rewards for our mission.
var array<string> rewardArray;
var array<SimpleMissionStruct> simpleMissionArray;

var int botsKilled;
var Console consoleClient;

// Player controller 
var AEPlayerController  PC;

// We want to have control over all the pawns we have spawned in this objective. 
// Now we have a easy way to check how many bots we have killed. 
var array<AEPawn_Bot>   SpawnedBots;

// Initialize the struct to hold the default variables of our mission.
// Then we can easily restart our mission at any time.
var MissionObjectives   AEObjectives;


//-----------------------------------------------------------------------------
// Init

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

/** Initializes the missions wtih the array from jsonParser*/
function Initialize(array<ValueStruct> missionArray)
{
	activateObjectives( MissionFromSimpleStruct( parseArrayToSimpleStruct( missionArray ) ) );
}


//-----------------------------------------------------------------------------
// Parsing

/** Parses the a mission array to a simple mission struct. 
 *  It sets the info and rewars for the mission.*/
function SimpleMissionStruct parseArrayToSimpleStruct(array<ValueStruct> missionArray)
{
	local SimpleMissionStruct   mission;
	local Array2D               temp;
	local string                Type;
	local bool  existingReward;
	local int   numberOfRewards;
	local int   i;

	//`log("\n\nStarting Mission Parsing: \nLENGTH: " $ missionArray.Length );
	for( i = 0; i < missionArray.Length; i++) 
	{
		//`log(missionArray[i].type $ " : " $ missionArray[i].value );
		if( missionArray[i].type == "category" )
		{
			Type = "info";
		}
		else if( missionArray[i].type == "type" )
		{
			Type = "reward";
			mission.rewards.AddItem( temp );
				
			if(!existingReward)
				existingReward=true;
			else
				++numberOfRewards;
		}
		else if( missionArray[i].type == "" )
		{
			`log("[MissionSimpleParsing] Type is blank");
		}

		switch( Type )
		{
		case "info": mission.information.AddItem( missionArray[i] ); break;
		case "reward": mission.rewards[numberOfRewards].variables.AddItem( missionArray[i] ); break;
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
		else `log("[SimpleMissionParse] No known name of this type: " $ values.type);
	}

	foreach simpleMission.rewards( reward )
	{
		`log("Adding reward: " $ reward.variables.Length);
		
		objective.rewards.AddItem( PC.myWeaponCreator.parseToStruct( reward.variables ) );
	}
	
	return objective;
}

//-----------------------------------------------------------------------------
// Rewards

/** Gets the reward from mission and puts them into player inventory */
function getMissionRewards()
{
	local WeaponStruct weap;

	foreach AEObjectives.rewards( weap )
		PC.addWeaponToInventory( PC.myWeaponCreator.CreateWeaponFromStruct( weap ) );
}

//-----------------------------------------------------------------------------
// Objectives

/** Activates all the objectives. Check through a list and adds all the active objectives. */ 
function activateObjectives(MissionObjectives objectives)
{
	if(objectives != AEObjectives)
		AEObjectives = objectives;

	// For testing purposes. Sets how many enemies we should spawn
	objectives.MOEnemies = 5;
	AEObjectives.MOEnemies = 5;

	printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ objectives.MOEnemies);
	createObjectiveInfo();

	// long "if section" for all the objectives. 

	SpawnEnemies(objectives.MOEnemies);
}

/** Spawns an enemy at a set location in the map */
function SpawnEnemies(int enemyNumber)
{
	local AEVolume_BotSpawn spawnPoint; 
	local AEVolume_BotSpawn target;
	local int i;

	foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
	{
		spawnPoint = target;
	}

	for(i = 0; i < enemyNumber; i++)
	{
		SpawnedBots.AddItem( spawnPoint.spawnBot(class'AEPawn_Bot', self) );
	}

	for (i = 0; i < enemyNumber; i++)
	{
		//SpawnedBots[i].MyController.GotoState('Attacking');
		//`Log(" LOOOOOOOOOOOOL " $ SpawnedBots[i].GetStateName());
	}
}

/** When a bot dies he runs this method to update the bots killed. */
function botDied()
{
	local AEVolume_BotSpawn target;

	++botsKilled;

	if(botsKilled < AEObjectives.MOEnemies){
		printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ AEObjectives.MOEnemies);
	}else{
		MissionComplete();

		foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
		{
			target.resetSpawnPoints();
		}
	}
}

/** Complete and reset all vaiables and gives the reward to player. */
function MissionComplete()
{
	PC.mHUD.postError("Mission complete: Reward added to inventory");
	printObjectiveMessage("", true);
	printObjectiveInfo("", true);

	botsKilled=0;

	getMissionRewards();
}

//-----------------------------------------------------------------------------
// MENU / HUD

/** Print mission info to screen */
function createObjectiveInfo()
{
	printObjectiveInfo( "Category: "    $   AEObjectives.category, true);
	printObjectiveInfo( "Title: "       $   AEObjectives.title);
	printObjectiveInfo( "Map: "         $   AEObjectives.mapName);
	//printObjectiveInfo( "Reward: "      $   AEObjectives.reward);
	printObjectiveInfo( "Description: " $   AEObjectives.description);
}

/** Prints the objective info to screen * if bNoAddToMessage is true it clears screen */
function printObjectiveInfo(string message, optional bool bNoAddToMessage)
{
	if(bNoAddToMessage){
		PC.mHUD.resetMissionInfo();
	}else{
		PC.mHUD.addMissionInfo(message);
	}
}

/** Print objectives to the screen * Reset clears the screen first. 
 *  if message == "" it clears screen completly */
function printObjectiveMessage(string message, optional bool bReset)
{
	local HudLocalizedMessage msg;

	if(bReset)
		msg.StringMessage = "";
	else
		msg.StringMessage = "[Objectives] " $ message;

	PC.mHUD.Message = msg;
}

DefaultProperties
{

}
