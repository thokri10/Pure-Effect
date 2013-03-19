class AEPlayerInput extends UTPlayerInput within AEPlayerController;

exec function UseInventoryItem(int slot)
{
	UseItem(slot);
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
	useJetpacking();
}

// Release Space to stop using the jetpack.
simulated exec function StopUsingJetpack()
{
	stopJetpacking();
}

DefaultProperties
{
	
}
