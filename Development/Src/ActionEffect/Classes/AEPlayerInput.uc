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

// Press O to sprint, cuz why not, lulz.
simulated exec function Sprint()
{
	isSprinting = true;
	`log("Yo brah, I'm SPRINTING!!!!!!");
}

DefaultProperties
{
	
}
