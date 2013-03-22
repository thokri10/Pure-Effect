class AEVolume_EngineRoom extends Actor
	placeable;

/** Trigger that needs to be activated to change team owners */
var(Objective) array<AEEngineTrigger> Triggers;

/** 0 : RedTeam || 1 : BlueTeam*/
var(Objective) int teamIDOwners;

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	CheckTriggers();
}

function CheckTriggers()
{
	local AEEngineTrigger trig;

	foreach Triggers(trig)
	{
		if(trig.bTriggerActivated)
			if(trig.teamOwner != -1){
				teamIDOwners = trig.teamOwner;
			}
	}
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
