// PURPOSE: Controller for AI-bots
class AEAIController extends UTBot;

function PostBeginPlay()
{
	super.PostBeginPlay();
}

/** Derived from bot class */
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

/** The bot will never leave this state. 
 *  It will just output the message.
 *  You must add your own content. 
 *  */
state MyState
{
	Begin:
		`log("In MyState");

	DoneMyState:
}

