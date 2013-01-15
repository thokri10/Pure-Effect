class AEMissionObjective extends Actor;

// Strcut for to hold all the mission objectives. This is created with a string parser in this class.
struct MissionObjectives
{
	var int MOEnemies;
};

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

// Initializes the missions wtih the string from server
function Initialize(string missionString)
{
	// For testing purposes. Sets how many enemies we should spawn
	AEObjectives.MOEnemies = 10;

	activateObjectives(AEObjectives);
}

// Activates all the objectives. Check through a list and adds all the active objectives. 
function activateObjectives(MissionObjectives objectives)
{
	// Saves the default variables.
	AEObjectives = objectives;

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

	loc.X = 300; loc.Y = 0; loc.Z = 400;

	`log("[MissionObjective] Spawned Enemies: " $enemyNumber);
	
	for(i = 0; i < enemyNumber; i++)
	{
		SpawnedBots[i] = Spawn(class'AEPawn_Bot',,, loc,,,true);
	}
}

DefaultProperties
{

}
