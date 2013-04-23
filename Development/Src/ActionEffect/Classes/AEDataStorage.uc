class AEDataStorage extends Object
	dependson(AEMissionObjective)
	dependson(AEInventory_Item);

var AEMissionObjective  myMissionObjective;
var AEPlayerInfo        myPlayerInfo;

var private array<MissionObjectives> m_missions;

function setMissions(const array<Array2D> Missions)
{
	local Array2D mission;

	foreach Missions( mission )
	{
		m_missions.AddItem( myMissionObjective.parseArrayToMission( mission.variables ) );
	}
}

function setItems(const array<Array2D> Items)
{
	local Array2D item;

	foreach Items( item )
	{
		myPlayerInfo.addItems( item.variables );
	}
}

function MissionObjectives getMission(const int missionID)
{
	return m_missions[missionID];
}

function WeaponStruct getWeapon(const int weaponID)
{
	return myPlayerInfo.getWeapon(weaponID);
}

function AEInventory_Item getItem(const int itemID)
{
	return myPlayerInfo.getItems(itemID);
}

function int MissionLength()
{
	return m_missions.Length;
}

DefaultProperties
{
}
