class AEAIController_Leader extends AEAIController;

/** Derived from bot class */
function SetAttractionState()
{
    if ( Enemy != None )
    {         
		StrafingAbility = 1;
        GotoState('RangedAttack');
    }
    else
    { //want to change this to whatever your default state is you   
            //want for your bot.

		if(GetStateName() != 'Defending')
			GotoState('Defending');
 
    }//close if
}

DefaultProperties
{
	ReTaskTime = 5
	Skill=10
}
