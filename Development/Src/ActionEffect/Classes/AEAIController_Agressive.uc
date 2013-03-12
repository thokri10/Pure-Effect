class AEAIController_Agressive extends AEAIController;

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);

	Pawn.SetMovementPhysics();
}


/** Derived from bot class */
simulated function SetAttractionState()
{
        if ( Enemy != None )
        {         
            GotoState('Roaming');
        }
        else
        { //want to change this to whatever your default state is you   
               //want for your bot.
            GotoState('Hunting');
 
        }//close if
}


DefaultProperties
{
}
