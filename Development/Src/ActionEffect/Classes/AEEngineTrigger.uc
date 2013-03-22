class AEEngineTrigger extends Trigger_PawnsOnly;

var bool bTriggerActivated;

/** TeamID that triggered it */
var int teamOwner;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local AEPawn_Player collider;

	if (FindEventsOfClass(class'SeqEvent_Touch'))
	{
		NotifyTriggered();
	}

	collider = AEPawn_Player( Other );

	if( collider != None )
	{
		`log(AEPlayerController( collider.Controller ).IdentifiedTeam);

		teamOwner = int( AEPlayerController( collider.Controller ).IdentifiedTeam );	

		bTriggerActivated = true;
	}
}

DefaultProperties
{
	teamOwner = -1;
}
