class AEAIController_Defensive extends AEAIController;

var UTDefensePoint defendingSpot;
var int oldHealth;
var bool timerActive;

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);

	Pawn.SetMovementPhysics();
	oldHealth = pawn.Health;

	CampTime = 10;
	
	//GotoState('Defending', 'Pausing'); 
}

event Tick(float DeltaTime)
{
	if(!timerActive){
		//`log("HELP");
		timerActive = true;
		SetTimer(5, true, 'help');
	}

	super.Tick(DeltaTime);
}

function help()
{
	local AEPawn_Bot bot;

	if ( Enemy != None )
    {
		foreach WorldInfo.AllPawns(class'AEPawn_Bot', bot, pawn.Location, 2000)
		{
			if(AEAIController( bot.Controller ).Enemy == none)
			{
				`log("Setting enemy : " $ bot $ " : " $ Enemy);
				AEAIController( bot.Controller ).Enemy = Enemy;
				AEAIController( bot.Controller ).SetEnemyInfo(true);
			}
		}
		GotoState('RangedAttack');
    }

	timerActive = false;
}

/** Derived from bot class */
function SetAttractionState()
{
	local UTDefensePoint def;
	local int defCounter;
	
    
    if ( Enemy == None )
    {    
		if(GetStateName() != 'Defending' || defendingSpot == none){
			CampTime = 10;

			foreach WorldInfo.AllNavigationPoints(class'UTDefensePoint', def)
			{
				if( def.HigherPriorityThan(defendingSpot, self, true, false, defCounter) )
				{
					defendingSpot = def;
					break;
				}
			}

			DefensePoint = defendingSpot;
			MoveToDefensePoint();
		}

		if(oldHealth < pawn.Health){
			GotoState('Startle');
		}
 
    }//close if

	oldHealth = pawn.Health;
}


DefaultProperties
{
	StrafingAbility=+1
	BaseAggressiveness=-1
	Aggression=-1
	CombatStyle=-1
	CampTime=10

	Squad=None
}
