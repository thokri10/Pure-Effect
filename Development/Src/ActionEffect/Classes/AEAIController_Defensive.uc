class AEAIController_Defensive extends AEAIController;

//--------------------------------
// Defending variables

struct DefendStruct
{
	/** Current defensive position */
	var AEDefensePoint defendingSpot;

	/** Distance from Objective.
	 *  To keep bot defending a spot farther away */
	var float Distance; 
};

/** Objective the bot currently are defending */
var AEGameObjective_Defend CurrentDefensePosition;

/** Current defense position */
var DefendStruct defendPosition;

/** The defense position our bot last defended */
var DefendStruct LastDefendedPosition;

/** True if bot should update its position in states */
var bool bUpdatePosition;

/** If bot are hiding behind cover. 
 *  Should not peek before this projectile stop living. */
var Projectile DodgingProjectile;

/** True if bot has changed position since last vision of bot.
 *  Stops the bot to change position more than once */
var bool bChangedPosition;
//----------------------------
// Timers
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

function ReceiveProjectileWarning(Projectile Proj)
{
	if( GetStateName() == 'Defending' )
	{
		DodgingProjectile = Proj;
		pawn.ShouldCrouch(true);
	}
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
		if(GetStateName() != 'Defending' || defendPosition.defendingSpot == none)
		{
			SetDefendingSpot();
		}
    }    
}

/** Finds a defensive objective and finds a defending positition at that point
 *  Tries this two times if no position are free at taht time. 
 *  If this fails it will change to state 'last stand' 
 *  @param IgnoreSpot Ignore this objective */
function SetDefendingSpot(optional AEGameObjective_Defend IgnoreSpot = None)
{
	local AEGameObjective_Defend spot;

	foreach WorldInfo.AllNavigationPoints(class'AEGameObjective_Defend', spot)
	{
		if(spot != CurrentDefensePosition || spot != IgnoreSpot)
		{
			if(CurrentDefensePosition == None)
				CurrentDefensePosition = spot;
			else if(CurrentDefensePosition.DefensePriority < spot.DefensePriority)
				CurrentDefensePosition = spot;
		}
	}

	if(CurrentDefensePosition != None)
	{
		defendPosition = getDefensePointAtObjective( CurrentDefensePosition );

		if(defendPosition.defendingSpot != none){
			bUpdatePosition = true;
			GotoState('Defending');
		}
		else
		{
			if(IgnoreSpot != None)
				SetDefendingSpot(CurrentDefensePosition);
			else{
				//`log("FROM SET DEFEND SPOT");
				GotoState('LastStand');
			}
		}
	}else{
		`log("[AIControllerDef] No defense positions in this map");
		GotoState('Patrol');
	}
}

/** Returns the first free defendpoint at spesified objective. The returned point are the farthest off 
 *  @param objective Objective that contains the defend position 
 *  @return A free point farthest away form our objective */
function DefendStruct getDefensePointAtObjective(AEGameObjective_Defend objective)
{
	local DefendStruct def;
	local AEDefensePoint spot;

	foreach objective.DefenseSpots( spot )
	{
		if(spot.CurrentUser == None)
		{
			if(def.defendingSpot == None){
				def.defendingSpot = spot;
				def.distance = getDistance( objective, spot );
			}else
			{
				if( getDistance( objective, spot ) > def.distance )
				{
					if(def.defendingSpot.CurrentUser == None)
					{
						def.defendingSpot = spot;
						def.distance = getDistance( objective, spot );
					}
				}
			}
		}
	}

	if(def.defendingSpot != None){
		def.defendingSpot.CurrentUser = self;
		return def;
	}else
		return def;
}

state Defending
{
	event Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);
		if(!IsDead())
		{
			if(Enemy != None)
			{
				if(defendPosition.defendingSpot != none)
				{
					defendPosition.defendingSpot.CurrentUser = None;
					defendPosition.defendingSpot = None;
				}

				if(!timerActive){
					timerActive = true;
					help(); 
				}
			}
		}
	}

	simulated function SetAttractionState()
	{
		if(bCurrentlyOccupied)
		{
			if( Sqrt( getDistance( pawn, defendPosition.defendingSpot ) ) < 50 ){
				bCurrentlyOccupied = false;
			}
		}

		if(myEnemy != None)
		{
			if(!bCurrentlyOccupied){
				if( (RunTime - EnemyVisibilityTime) > 4 ){
				bChangedPosition = false;
				}
			}
			if( (RunTime - EnemyVisibilityTime) > 7 ){
				myEnemy = None;
			}
		}

		if(!bCurrentlyOccupied)
			CheckDefensiveBehavior();
	}

	function CheckDefensiveBehavior()
	{
		if(DodgingProjectile != None)
		{
			if(VSize( DodgingProjectile.Velocity ) == 0)
			{
				if(Pawn.bIsCrouched){
					DodgingProjectile = None;
					`log("UNCROUCH");
					Pawn.ShouldCrouch(false);
				}
			}
		}

		if(myEnemy != None)
		{
			if(DodgingProjectile == None && !bCurrentlyOccupied)
			{
				if( Sqrt( getDistance( pawn, myEnemy ) ) < 1000 ){
					//GotoState('AEFallBack');
				}
				else
				{
					if(!bChangedPosition)
					{
						bEnemyIsVisible = LineOfSightTo(myEnemy);

						if(!bEnemyIsVisible){
							defendPosition = changeDefensivePosition( defendPosition );
							bUpdatePosition = true;
							bChangedPosition = true;
							bCurrentlyOccupied = true;
							GotoState('Defending');
						}
					}
				}
			}
		}
	}
	
	/** Finds the closest defensive position to this point. 
	 *  User is set and reset at last point
	 *  @param lastSpot The defensive spot we want to move from. */
	function DefendStruct changeDefensivePosition(DefendStruct lastSpot)
	{
		local Array<DefendStruct> possiblePositions;
		local AEDefensePoint point;
		local DefendStruct possible;
		local DefendStruct defend;
		local float tempDistance;
		local float distance;

		foreach WorldInfo.AllNavigationPoints(class'AEDefensePoint', point)
		{
			if( point != lastSpot.defendingSpot )
			{
				distance = getDistance(lastSpot.defendingSpot, point);

				if( distance < 2000**2 ) 
				{
					if( point.CurrentUser == None )
					{
						`log("ADDED DEFENSE POS: " $ point);
						defend.defendingSpot = point;
						defend.Distance = distance;
						possiblePositions.AddItem(defend);
					}
				}
			}
		}

		distance = 2000**2;

		foreach possiblePositions(possible)
		{
			tempDistance = getDistance( lastSpot.defendingSpot, possible.defendingSpot );

			if(tempDistance < distance)
			{
				distance = tempDistance;
				defend.defendingSpot = possible.defendingSpot;
				defend.Distance = distance;
			}
		}

		if(defend.defendingSpot == None){
			defend.defendingSpot = lastSpot.defendingSpot;
			defend.Distance = lastSpot.Distance;
		}

		if(defend.defendingSpot != None)
		{
			lastSpot.defendingSpot.CurrentUser = None;
			defend.defendingSpot.CurrentUser = self;
			return defend;
		}
		return defend;
	}

	function EndState(name NextStateName)
	{
		defendPosition.defendingSpot.CurrentUser = None;
	}


Begin:
	//`log("DEFENDING: " $ defendingSpot);
	//if( ActorReachable( defendingSpot ) ){

	if(bUpdatePosition)
	{
		MoveToward(defendPosition.defendingSpot , LastDefendedPosition.defendingSpot);
		bCurrentlyOccupied = true;
		bUpdatePosition = false;
	}else{
		CheckDefensiveBehavior();
	}
	//}
	
	WaitToSeeEnemy();

	//GotoState('AEFallBack');


};

state AEFallBack
{
	function DefendStruct FindFallingBackPosition(DefendStruct lastSpot)
	{
		//local AEDefensePoint point;

		defendPosition.defendingSpot = lastSpot.defendingSpot;
		defendPosition.Distance = lastSpot.Distance;

		/*
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
		*/

		/*
		if(lastSpot.defendingSpot == defendPosition.defendingSpot){
			//`log("FROM FALL BACK");
			GotoState('LastStand');
			return none;
		}
		
		defendingSpot = lastSpot;
		*/
		`log("FIND FALLING BACK FUNCTION! SHOULD NOT BE HERE!");
		return lastSpot;
	}
begin:
	`log("Falling back");

	/*
	LastDefendedPosition.defendingSpot = defendPosition.defendingSpot;
	
	if( FindFallingBackPosition( lastDestinationtNode ).defendingSpot != none )
		MoveToward( FindFallingBackPosition( LastDefendedSpot ), LastDefendedSpot );
		*/
	
}

state LastStand
{
begin:
	//`log("Last Stand");
}


DefaultProperties
{
	Squad=None
}
