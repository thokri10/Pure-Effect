class AEVolume_EngineRoom extends Actor
	placeable;

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
