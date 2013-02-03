class AEPlayerInput extends UTPlayerInput within AEPlayerController;

exec function UseInventoryItem(int slot)
{
	UseItem(slot);
}

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
	isSprinting = true;
	myPawn.GroundSpeed = 1000.0f;
}

// Release LeftShift to stop sprinting.
simulated exec function StopSprinting()
{
	isSprinting = false;
	myPawn.GroundSpeed = 600.0f;
}

// Hold Space to use jetpack.
simulated exec function UseJetpack()
{
	`Log("JETPACK: ON");
	myPawn.usingJetpack = true;
	myPawn.CustomGravityScaling = -1.0f;
}

// Release Space to stop using the jetpack.
simulated exec function StopUsingJetpack()
{
	`Log("JETPACK: OFF");
	myPawn.usingJetpack = false;
	myPawn.CustomGravityScaling = 1.0f;
}

DefaultProperties
{
	
}
