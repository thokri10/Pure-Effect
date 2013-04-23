class AEDataStorage extends Object
	dependson(AEMissionObjective)
	dependson(AEInventory_Item);

var AEMissionObjective myMissionObjective;

var private array<MissionObjectives> m_missions;

var private array<AEInventory_Item> m_items;

function setMissions(const array<Array2D> Missions)
{
	local Array2D mission;

	foreach Missions( mission )
	{
		m_missions.AddItem( myMissionObjective.parseArrayToMission( mission.variables ) );
		`log("ADDING MISSION FUCK YEAH");
	}
}

function MissionObjectives getMission(const int missionID)
{
	return m_missions[missionID];
}

function int MissionLength()
{
	return m_missions.Length;
}

DefaultProperties
{
}
