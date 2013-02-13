class AEMissionObjective extends Actor
	dependson(AEWeaponCreator)
	dependson(AEJSONParser);

// Struct for to hold all the mission objectives. This is created with a string parser in this class.
// Structs

/** Struct for to hold all the mission objectives. This is created with a string parser in this class. */
struct MissionObjectives
{
	var int id;
	var string category;
	var string mapName;
	var string title;
	var string description;
	var string reward;
	var int MOEnemies;
};

/** Easy access to all the information to a mission. */
struct SimpleMissionStruct
{
	/** Holds the info to the mission */
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

// We want to have controll over all the pawns we have spawned in this objective. 
// Now we have a easy way to check how many bots we have killed. 
var array<AEPawn_Bot>   SpawnedBots;

// Initilaize the strcut to hold the defualt variables of our mission.
// Then we can easily restart our mission at any time.
var MissionObjectives   AEObjectives;


//-----------------------------------------------------------------------------
// Init

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

/** Initializes the missions wtih the string from server */
function Initialize(string missionString)
{
	local array<Array2D>    missionArray;
	
	local Array2D           missions;

	//AEObjectives = parseArrayToMissionStruct(missionArray);
	//activateObjectives( AEObjectives );

	missionArray = PC.parser.fullParse( missionString );

	foreach missionArray( missions )
	{
		simpleMissionArray.AddItem( parseArrayToSimpleStruct( missions.variables ) );
	}
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

	`log("\n\nStarting Mission Parsing: \nLENGTH: " $ missionArray.Length );
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
		case "type": mission.rewards[numberOfRewards].variables.AddItem( missionArray[i] ); break;
		}
	}

	return mission;
}

/** Parses the array to a mission struct so we have controll over the objectives. */
function MissionObjectives parseArrayToMissionStruct(array<string> missionArray)
{
	local array<string>     splitted;
	local MissionObjectives objectives;
	local int i;

	for(i = 0; i < missionArray.Length; i++)
	{
		splitted = SplitString(missionArray[i], ":");

		if     (splitted[0] == "id")            objectives.id           = int( splitted[1] );
		else if(splitted[0] == "category")      objectives.category     = mid( splitted[1], 1, len( splitted[1] ) - 2 );
		else if(splitted[0] == "city_name")     objectives.mapName      = mid( splitted[1], 1, len( splitted[1] ) - 2 );
		else if(splitted[0] == "description" )  objectives.description  = mid( splitted[1], 1, len( splitted[1] ) - 2 );
		else if(splitted[0] == "reward")        objectives.reward       = mid( splitted[1], 1, len( splitted[1] ) - 2 );
		else if(splitted[0] == "title")         objectives.title        = mid( splitted[1], 1, len( splitted[1] ) - 2 );
		else if(splitted[0] == "items")         addMissionReward(rewardString);
		else `log("[MissionArrayParse] No known name of this type: " $ splitted[0]);
	}

	return objectives;
}

//-----------------------------------------------------------------------------
// Rewards

/** This is runned when the mission string is parsed to a struct.
  * You should not use this */
function addMissionReward( string itemString )
{
	rewardArray.AddItem( itemString );
}

/** When missions is done this is runned with the mission ID to give you the correct reward */
function getReward(int missionID)
{
	parseStringToReward( rewardArray[missionID - 1] );
}

/** Gives the reward to player from reward string. You can only retrieve weapon at this time. */
function parseStringToReward(string in)
{
	local array<string> reward;
	local WeaponStruct weap;

	in = in $ "}";

	reward = PC.myTcpLink.parseToArray( in );

	weap = PC.myWeaponCreator.parseArrayToWeaponStruct( reward );

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
}

/** When a bot dies he runs this method to update the bots killed. */
function botDied()
{
	local AEVolume_BotSpawn target;

	++botsKilled;

	if(botsKilled < AEObjectives.MOEnemies){
		printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ AEObjectives.MOEnemies);
	}else{
		printObjectiveMessage("", true);
		PC.mHUD.postError("Mission complete: Reward added to inventory");
		botsKilled=0;
		printObjectiveInfo("", true);
		getReward(AEObjectives.id);

		foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
		{
			target.resetSpawnPoints();
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
	printObjectiveInfo( "Reward: "      $   AEObjectives.reward);
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
