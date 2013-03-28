class AEVolume_EngineRoom extends Actor
	placeable;

var(Objective) const int TeamEngineOwner;

/** Objective on the map to update when the objective changes owners */
var AEReplicationInfo ObjectiveInfo; 

/** Trigger that needs to be activated to change team owners */
var(Objective) array<AEEngineTrigger> Triggers;

/** 0 : RedTeam || 1 : BlueTeam*/
var int teamIDOwners;

/** Sets objective in the triggers and gets the replicationInfo class for updating to all connected players */
function PostBeginPlay()
{
	local AEEngineTrigger trig;
	local AEReplicationInfo repinf;

	super.PostBeginPlay();

	foreach Triggers(trig)
	{
		trig.objective = self;
	}

	foreach WorldInfo.AllActors(class'AEReplicationInfo', repinf)
		ObjectiveInfo = repinf;
}

/** When a triggers gets touched or activeted it runs this function to check if the objective 
 *  changes team. */
function eventTriggered(AEEngineTrigger trigger, AEPawn_Player player)
{
	local AEEngineTrigger trig;
	local bool bChangeTeamOwners;

	
	`log("BEFORE TRIGGERED : " $ teamIDOwners);

	foreach Triggers(trig)
	{
		if(trig == trigger)
		{
			trigger.teamOwner = AEPlayerController( player.Controller ).IdentifiedTeam;
		}
	}

	foreach Triggers(trig)
	{   
		if( teamIDOwners != trig.teamOwner )
		{
			bChangeTeamOwners = true;
		}else{
			bChangeTeamOwners = false;
			break;
		}
	}

	if(bChangeTeamOwners == true){
		teamIDOwners = triggers[0].teamOwner;
		ObjectiveInfo.ChangeOwnerToEngine( TeamEngineOwner, teamIDOwners );
	}

	`log("TRIGGERED : " $ teamIDOwners);
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Trigger'
		HiddenGame=False
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Triggers"
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
		CollideActors=true
		CollisionRadius=+0040.000000
		CollisionHeight=+0040.000000
		bAlwaysRenderIfSelected=true
	End Object
	Components.Add(CollisionCylinder)
}
