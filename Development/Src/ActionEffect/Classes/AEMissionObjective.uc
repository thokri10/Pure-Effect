class AEMissionObjective extends Actor
	dependson(AEWeaponCreator);

// Strcut for to hold all the mission objectives. This is created with a string parser in this class.
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

struct RewardStruct
{
	var int Credit;
	var string Weapon;
};

// This is set trough AEtcpLink when the string is parsed.
// QuickFix find a better solution.
var string rewardString;
// Array that contains our rewards for our mission.
var array<string> rewardArray;

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

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

// Parses the array to a mission struct so we have controll over the objectives.
function MissionObjectives parseArrayToMissionStruct(array<string> missionArray)
{
	local array<string>     splitted;
	local MissionObjectives objectives;
	local int i;

	for(i = 0; i < missionArray.Length; i++)
	{
		splitted = SplitString(missionArray[i], ":");

		splitted[0] = mid( splitted[0], 1, len( splitted[0] ) - 2 );

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

// This is runned when the mission string is parsed to a struct.
// You should not use this
function addMissionReward( string itemString )
{
	rewardArray.AddItem( itemString );
}

// When missions is done this is runned with the mission ID to give you the correct reward
function getReward(int missionID)
{
	parseStringToReward( rewardArray[missionID - 1] );
}

// Gives the reward to player from reward string. You can only retrieve weapon at this time.
function parseStringToReward(string in)
{
	local array<string> reward;
	local WeaponStruct weap;

	in = in $ "}";

	reward = PC.myTcpLink.parseToArray( in );

	weap = PC.myWeaponCreator.parseArrayToWeaponStruct( reward );

	PC.addWeaponToInventory( PC.myWeaponCreator.CreateWeaponFromStruct( weap ) );
}

// Initializes the missions wtih the string from server
function Initialize(array<string> missionArray)
{
	AEObjectives = parseArrayToMissionStruct(missionArray);

	activateObjectives( AEObjectives );
}

// Activates all the objectives. Check through a list and adds all the active objectives. 
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

// Spawns an enemy at a set location in the map.
function SpawnEnemies(int enemyNumber)
{
	local AEVolume_BotSpawn spawnPoint; 
	local AEVolume_BotSpawn target;
	local int i;

	foreach WorldInfo.AllActors( class'AEVolume_BotSpawn', target )
	{
		`log("SpawnPoitnLAlskdalskd: " $ spawnPoint.spawnPoints.Length);
		spawnPoint = target;
	}

	for(i = 0; i < enemyNumber; i++)
	{
		SpawnedBots.AddItem( spawnPoint.spawnBot(class'AEPawn_Bot', self) );
	}
}

// When a bot dies he runs this method to update the bots killed.
function botDied()
{
	++botsKilled;

	if(botsKilled < AEObjectives.MOEnemies){
		printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ AEObjectives.MOEnemies);
	}else{
		printObjectiveMessage("", true);
		PC.mHUD.postError("Mission complete: Reward added to inventory");
		printObjectiveInfo("", true);
		getReward(AEObjectives.id);
	}
}

/**
 * Menu functions
 **/

// Print mission info to screen
function createObjectiveInfo()
{
	printObjectiveInfo( "Category: "    $   AEObjectives.category, true);
	printObjectiveInfo( "Title: "       $   AEObjectives.title);
	printObjectiveInfo( "Map: "         $   AEObjectives.mapName);
	printObjectiveInfo( "Reward: "      $   AEObjectives.reward);
	printObjectiveInfo( "Description: " $   AEObjectives.description);
}

// Prints the objective info to screen
function printObjectiveInfo(string message, optional bool bNoAddToMessage)
{
	if(bNoAddToMessage){
		PC.mHUD.resetMissionInfo();
	}else{
		PC.mHUD.addMissionInfo(message);
	}
}

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
