class AEAIController_Leader extends AEAIController;

/** Derived from bot class */
simulated function SetAttractionState()
{
    if ( Enemy != None )
    {         
        GotoState('RangedAttack');
    }
    else
    { //want to change this to whatever your default state is you   
            //want for your bot.
 
    }//close if
}

DefaultProperties
{
}
