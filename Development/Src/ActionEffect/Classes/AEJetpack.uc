/** Jetpack for the player. */
class AEJetpack extends Actor;

/** Controller owner of the jetpack. */
var AEPlayerController PC;

/** Current fuel level. */
var float fuelEnergy;

/** Maximum fuel level. */
var float maxFuelEnergy;

/** Rate of fuel loss per second. */
var float fuelEnergyLossPerSecond;

/** Flag that checks if you auto-regenerate fuel energy. */
var bool regenerateFuelEnergy;

/** Flag that enables the use of jetpack. */
var bool jetpackEnabled;

/** Replication info for network purposes. */
replication
{
	if (bNetDirty && Role == ROLE_Authority)
		regenerateFuelEnergy;
}

/** Overrode this function to use it for jetpacking. */
event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(PC.myPawn != None)
		PC.myPawn.StartUsingTheJetpack(DeltaTime);
		//StartUsingTheJetpack(DeltaTime);
}

/** Player starts jetpacking. */
function StartJetpacking()
{
	if ( WorldInfo.NetMode == NM_Client )
	{
		PC.myPawn.ServerJetpacking();
	}
	else
	{
		PC.myPawn.isUsingJetPack = true;
	}
}

/** Player stops jetpacking. */
function StopJetpacking()
{
	if ( WorldInfo.NetMode == NM_Client )
	{
		PC.myPawn.ServerStopJetpacking();
	}
	else
	{
		PC.myPawn.isUsingJetPack = false;
	}
}

///** Jetpack-use for the host (server). */
//reliable server function ServerJetpacking()
//{
//	PC.myPawn.isUsingJetPack = true;
//}

///** Jetpack-disuse for the host (server). */
//reliable server function ServerStopJetpacking()
//{
//	PC.myPawn.isUsingJetPack = false;
//}

//function StartUsingTheJetpack(float DeltaTime)
//{
//	if (PC.myPawn.isUsingJetPack)
//	{
//		if (fuelEnergy > 0.0f)
//		{
//			PC.myPawn.CustomGravityScaling = -1.0f;
//			// Commented out temporarily for debugging reasons.
//			//fuelEnergy -= (fuelEnergyLossPerSecond * DeltaTime);
//		}
		
//		if (fuelEnergy < 0.0f)
//		{
//			fuelEnergy = 0.0f;
//		}
//	}
//	else
//	{
//		PC.myPawn.CustomGravityScaling = 1.0f;
//	}
//}

DefaultProperties
{
	maxFuelEnergy = 100.0f;
	fuelEnergy = 100.0f;
	fuelEnergyLossPerSecond = 30.0f;
	regenerateFuelEnergy = false;

	jetpackEnabled = true;
}
