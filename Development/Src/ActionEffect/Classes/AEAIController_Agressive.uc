class AEAIController_Agressive extends AEAIController;

var Pawn Target;

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);

	Pawn.SetMovementPhysics();
	
	GotoState('Hunting');
}

/*
/** Derived from bot class */
function SetAttractionState()
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
*/

DefaultProperties
{
}
