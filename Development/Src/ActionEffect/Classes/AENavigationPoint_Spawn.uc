class AENavigationPoint_Spawn extends Actor
	placeable;

var bool bInUse;

/** What type of bot should spawn on this */
var(BotType) class<AEPawn_Bot> typeOfBot;

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Crowd.T_Crowd_Spawn'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object

	Components.Add(Sprite)
	bInUse=false
}
