class AEAIController_Defensive extends AEAIController;

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);

	Pawn.SetMovementPhysics();

	GotoState('Defending');
}


/** Derived from bot class */
function SetAttractionState()
{
        if ( Enemy != None )
        {         
			StrafingAbility = 1;
			`log("Strafing");
            GotoState('Startled');
        }
        else
        { //want to change this to whatever your default state is you   
               //want for your bot.
            GotoState('Defending');
 
        }//close if
}


DefaultProperties
{
	BaseAggressiveness=-1
	Aggression=-1
	CombatStyle=-1
}
