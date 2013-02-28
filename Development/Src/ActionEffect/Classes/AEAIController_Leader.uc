class AEAIController_Leader extends AEAIController;

/** Derived from bot class */
function SetAttractionState()
{
        if ( Enemy != None )
        {         
			StrafingAbility = 1;
			`log("Strafing");
            GotoState('Defending');
        }
        else
        { //want to change this to whatever your default state is you   
               //want for your bot.
            GotoState('Defending');
 
        }//close if
}

DefaultProperties
{
}
