class AEAIController_Defensive extends AEAIController;

var AEGameObjective_Defend CurrentDefensePosition;
var AEDefensePoint defendingSpot;
var AEDefensePoint LastDefendedSpot;

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

/** Call for help to other bots in the vicinity. */
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

	if(Enemy != None){
		SetTimer(5, true, 'help');
	}else{
		timerActive = false;
	}
}

/** Check what state we want to change to when the bot has been inactive for a while */
simulated function SetAttractionState()
{    
    if ( Enemy == None )
    {    
		if(GetStateName() != 'Defending' || defendingSpot == none)
		{
			SetDefendingSpot();
		}
 
    }
}

/** Finds a defensive objective and finds a defending positition at that point
 *  Tries this two times if no position are free at taht time. 
 *  If this fails it will change to state 'last stand' */
function SetDefendingSpot(optional AEGameObjective_Defend IgnoreSpot = None)
{
	local AEGameObjective_Defend spot;

	foreach WorldInfo.AllNavigationPoints(class'AEGameObjective_Defend', spot)
	{
		if(spot != CurrentDefensePosition || spot != IgnoreSpot)
		{
			if(CurrentDefensePosition == None)
				CurrentDefensePosition = spot;
			else if(CurrentDefensePosition.DefensePriority <= spot.DefensePriority)
				CurrentDefensePosition = spot;
		}
	}

	if(CurrentDefensePosition != None)
	{
		defendingSpot = getDefensePointAtObjective( CurrentDefensePosition );

		if(defendingSpot != none){
			`log("DEFENDING: " $ defendingSpot);
			GotoState('Defending');
		}
		else
		{
			if(IgnoreSpot != None)
				SetDefendingSpot(CurrentDefensePosition);
			else{
				`log("FROM SET DEFEND SPOT");
				GotoState('LastStand');
			}
		}
	}
}

/** Returns a free defendpoint at spesified objective */
function AEDefensePoint getDefensePointAtObjective(AEGameObjective_Defend objective)
{
	local AEDefensePoint spot;
	local AEDefensePoint temp;

	foreach objective.DefenseSpots( spot )
	{
		if(spot.CurrentUser == None)
		{
			if(temp == None)
				temp = spot;
			else
			{
				if(temp.DefensePriority < spot.DefensePriority)
				{
					temp = spot;
				}
			}
		}
	}

	if(temp != None)
		return temp;
	else
		return none;
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
					help(); 
				}
			}
		}
	}

Begin:
	`log("DEFENDING: " $ defendingSpot);
	//if( ActorReachable( defendingSpot ) ){
	MoveToward(defendingSpot, LastDefendedSpot);
	//}
	
	WaitToSeeEnemy();

	//GotoState('FallBack');
};

state FallBack
{
	function AEDefensePoint FindFallingBackPosition(AEDefensePoint lastSpot)
	{
		local AEDefensePoint point;

		defendingSpot = lastSpot;

		foreach lastSpot.ClosePoints(point)
		{
			if(defendingSpot != point)
			{
				if( lastSpot.DefensePriority <= point.DefensePriority )
				{
					lastSpot = point;
				}
			}
		}

		if(lastSpot == defendingSpot){
			`log("FROM FALL BACK");
			GotoState('LastStand');
			return none;
		}
		
		defendingSpot = lastSpot;

		return lastSpot;
	}
begin:
	`log("Falling back");

	LastDefendedSpot = defendingSpot;
	
	if( FindFallingBackPosition( LastDefendedSpot ) != none )
		MoveToward( FindFallingBackPosition( LastDefendedSpot ), LastDefendedSpot );
	
}

state LastStand
{
begin:
	`log("Last Stand");
}


DefaultProperties
{
	Squad=None
}
