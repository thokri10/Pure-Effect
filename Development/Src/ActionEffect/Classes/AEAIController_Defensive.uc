class AEAIController_Defensive extends AEAIController;

var UTDefensePoint defendingSpot;

var bool timerActive;

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);

	Pawn.SetMovementPhysics();
}

event Tick(float DeltaTime)
{
	

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
				AEAIController( bot.Controller ).Enemy = Enemy;
			}
		}
    }

	timerActive = false;
}

simulated function SetAttractionState()
{
	local UTDefensePoint def;
    
    if ( Enemy == None )
    {    
		if(GetStateName() != 'Defending' || defendingSpot == none)
		{
			foreach WorldInfo.AllNavigationPoints(class'UTDefensePoint', def)
			{
				if(def.CurrentUser == None)
				{
					def.CurrentUser = self;

					RouteGoal = def;
					defendingSpot = def;

					GotoState('Defending');
					break;
				}
			}
		}
 
    }
}

state Defending
{
	event Tick(float DeltaTime)
	{
		if(!IsDead())
		{
			if(Enemy != None)
			{
				if(defendingSpot != none)
				{
					defendingSpot.CurrentUser = None;
					defendingSpot = None;
				}

				if(!timerActive){
					timerActive = true;
					SetTimer(5, true, 'help');
				}
			}
		}
	}

Begin:
	if(ScriptedMoveTarget == None)
		if( ActorReachable( RouteGoal ) ){
			MoveToward(RouteGoal, RouteGoal);
		}
	
	WaitToSeeEnemy();

	GotoState('FallBack');
};

state FallBack
{
	function Actor FindFallingBackPosition()
	{
		
	}
begin:
	`log("Falling back");
	
	
}


DefaultProperties
{
	Squad=None
}
