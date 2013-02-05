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
var Console consolClient;

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
function addMissionReward( string itemString )
{
	rewardArray.AddItem( itemString );
}

function WeaponStruct parseStringToRewardStruct(string rewardArray)
{
	local WeaponStruct weap;

	weap = PC.myWeaponCreator.parseStringToWeaponStruct(rewardArray);

	return weap;
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
	objectives.MOEnemies = 1;

	printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ AEObjectives.MOEnemies);
	createObjectiveInfo();

	// Long "if section" for all the objectives. 
	if(objectives.MOEnemies > 0)
	{
		SpawnEnemies(objectives.MOEnemies);
	}
}

// Spawns an enemy at a set location.
function SpawnEnemies(int enemyNumber)
{
	local int i;
	local vector loc;

	loc.X = 300; loc.Y = 400; loc.Z = 200;
	
	for(i = 0; i < enemyNumber; i++)
	{
		if(i == 1)
			loc.X += 100;
		else if(i == 2)
			loc.X -= 200;
		else if(i == 3){
			loc.X -= 100;
			loc.Y += 300;
		}else{
			loc.X += 50;
		}
		SpawnedBots[i] = Spawn(class'AEPawn_Bot', self,, loc,,,true);
	}
}

function botDied()
{
	++botsKilled;

	if(botsKilled < AEObjectives.MOEnemies){
		printObjectiveMessage("BotsKilled: " $ botsKilled $ " / " $ AEObjectives.MOEnemies);
	}else{
		printObjectiveMessage("Mission Complete");
		getReward(AEObjectives.id);
	}
}

function createObjectiveInfo()
{
	printObjectiveInfo( "Category: "    $   AEObjectives.category, true);
	printObjectiveInfo( "Title: "       $   AEObjectives.title);
	printObjectiveInfo( "Map: "         $   AEObjectives.mapName);
	printObjectiveInfo( "Reward: "      $   AEObjectives.reward);
	printObjectiveInfo( "Description: " $   AEObjectives.description);
}

function printObjectiveInfo(string message, optional bool bNoAddToMessage)
{
	if(bNoAddToMessage){
		PC.mHUD.resetMissionInfo();
	}else{
		PC.mHUD.addMissionInfo(message);
	}
}

function getReward(int missionID)
{
	local WeaponStruct weap;

	weap = parseStringToRewardStruct( rewardArray[missionID] );

	PC.addWeaponToInventory( PC.myWeaponCreator.CreateWeaponFromStruct( weap ) );
}

function printObjectiveMessage(string message)
{
	local HudLocalizedMessage msg;

	msg.StringMessage = "[Objectives] " $ message;

	PC.mHUD.Message = msg;
}

DefaultProperties
{

}
