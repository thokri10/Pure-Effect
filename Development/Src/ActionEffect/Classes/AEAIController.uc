// PURPOSE: Controller for AI-bots
class AEAIController extends UTBot;

//copied from bot class
function SetAttractionState()
{
        if ( Enemy != None )
        {         
                `log("New FallBack state");
                GotoState('FallBack');
        }
        else
        { //want to change this to whatever your default state is you   
               //want for your bot.
                `log("About to enter MyState");
                GotoState('MyState');
 
        }//close if
}
 
//the bot will never leave this state
//it will just output the message
//you must add your own content
state MyState
{
Begin:
      `log("In MyState");
DoneMyState:
}

DefaultProperties
{
	// Initialize the bots to be very aggressive against the player.
	// NOTE: Currently not working.
	Aggressiveness = 1.0;
	bHuntPlayer = true;
	bTacticalDoubleJump = true;


}
