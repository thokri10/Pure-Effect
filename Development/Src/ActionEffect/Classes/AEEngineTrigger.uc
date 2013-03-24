class AEEngineTrigger extends Trigger_PawnsOnly;

/** TeamID that triggered it */
var int teamOwner;

/** Objective for our trigger */
var AEVolume_EngineRoom objective;

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
		objective.eventTriggered(self, collider);
	}
}

event UnTouch(Actor Other)
{
	super.UnTouch(Other);
}

DefaultProperties
{
	teamOwner = -1;
}
