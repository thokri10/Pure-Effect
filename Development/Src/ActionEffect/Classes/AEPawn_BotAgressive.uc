class AEPawn_BotAgressive extends AEPawn_Bot;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

DefaultProperties
{
	ControllerClass=class'AEAIController_Agressive'
}
