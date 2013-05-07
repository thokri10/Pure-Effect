class AEPlayerInput extends UTPlayerInput within AEPlayerController;

var input bool Fly;

exec function UseInventoryItem(int slot)
{
	UseItem(slot);
}

exec function SpeedIncrease()
{
	if(AEManta(Pawn) != None)
		AEManta(Pawn).IncreaseSpeed();
}

exec function SpeedDecrease()
{
	if(AEManta(Pawn) != None)
		AEManta(Pawn).DecreaseSpeed();
}

event PlayerInput(float DeltaTime)
{
	if(AEManta(Pawn) != None)
	{
		if(aBaseY < 0)
		{
			aBaseY = 0;
			aUp = -1;
		}
	}

	super.PlayerInput(DeltaTime);

	if(AEManta(Pawn) != None)
	{
		//aUp = 0;
		if(aBaseY > 0)
		{
			AEManta(Pawn).Fly(true);
		}else{
			AEManta(Pawn).Fly(false);
		}
	}
}

/*
exec function toggleShield()
{
	if(myPawn.AEShield.bBlockActors)
		myPawn.AEShield.bBlockActors=false;
	else
		myPawn.AEShield.bBlockActors=true;
}
*/

exec function MenuNext()
{
	myMenu.nextMenuSlot();
}

exec function MenuPre()
{
	myMenu.preMenuSlot();
}

exec function MenuEnter()
{
	myMenu.Select();
}

// Press LeftShift to sprint.
simulated exec function Sprint()
{
	myPawn.Sprint();
}

// Release LeftShift to stop sprinting.
simulated exec function StopSprinting()
{
	myPawn.StopSprint();
}

// Hold Space to use jetpack.
simulated exec function UseJetpack()
{
	if(AEManta(Pawn) != None)
		AEManta(Pawn).Fly(true);
	else
		useJetpacking();
}

// Release Space to stop using the jetpack.
simulated exec function StopUsingJetpack()
{
	if(AEManta(Pawn) != None)
		AEManta(Pawn).Fly(false);
	else
		stopJetpacking();
}

DefaultProperties
{
	
}
