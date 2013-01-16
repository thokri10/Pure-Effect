// THIS CLASS IS RESPONSIBLE FOR CREATING CUSTOM WEAPONS.
class AEWeaponCreator extends Actor;

// Variable to easy use playercontroller
var AEPlayerController PC;

function UTWeapon CrateWeaponFromString(string weap)
{
	return CreateWeaponFromStruct( parseStringToWeaponStruct( weap ) );
}

// Creates a custom-made weapon from server (main function)
function UTWeapon CreateWeaponFromStruct(WeaponStruct weap)
{
	return CreateWeapon(weap.type, weap.spread, weap.magsize, weap.reloadTime);
}

// Creates a custom-made weapon from server (sub-function)
function UTWeapon CreateWeapon(string type, float spread, int magazineSize, float reloadSpeed)
{
	// Initializes a weapon.
	local UTWeapon returnWeapon;
	returnWeapon = SpawnWeaponType(type);

	if(returnWeapon != none)
	{
		// Changes the weapon's stats.
		returnWeapon = ChangeSpread(returnWeapon, spread);
		returnWeapon = ChangeMagazineSize(returnWeapon, magazineSize);
		returnWeapon = ChangeFiringSpeed(returnWeapon, reloadSpeed);
	}

	return returnWeapon;
}

// Returns a weaponStruct from a json message from server
function WeaponStruct parseStringToWeaponStruct(string in)
{
	local WeaponStruct  Weap;
	local array<string> tempString;
	local array<string> tempString2;
	local int i;
	local string weaponDebugLog;

	weaponDebugLog = "\n";

	in = mid( in, 1, len( in ) - 1 );
	// Splits the string to set categories
	tempString = SplitString(in, ",");
	for(i = 0; i < tempString.Length; i++)
	{
		// Now we split it one more time to get type and value 
		tempString2 = SplitString(tempString[i], ":");
		// Removes both the ' " ' from the string so we can read it properly
		tempString2[0] = mid( tempString2[0], 1, len( tempString2[0] ) - 2 );

		// Now we check if any of the preset variables we have exist in this json
		if      (tempString2[0] == "id")            Weap.id         = int   ( tempString2[1] );         
		else if (tempString2[0] == "mag_size")      Weap.magSize    = int   ( tempString2[1] );
		else if (tempString2[0] == "reload_time")   Weap.reloadTime = float ( tempString2[1] );
		else if (tempString2[0] == "spread")        Weap.spread     = float ( tempString2[1] );
		else if (tempString2[0] == "name")          Weap.type       = mid( tempString2[1], 1, len( tempString2[1] ) - 2 );    
	}

	weaponDebugLog = weaponDebugLog $ "Weapon ID: "                 $ Weap.id $             "\n"
									$ "Magazine size: "             $ Weap.magSize $        "\n"
									$ "Reload time (seconds): "     $ Weap.reloadTime $     "\n"
									$ "Spread: "                    $ Weap.spread $         "\n"
									$ "Weapon type: "               $ Weap.type $           "\n";

	`Log("Weapon generated:" $ weaponDebugLog);

	return Weap;
}

// Changes a weapon's firing speed.
function UTWeapon ChangeFiringSpeed(UTWeapon weap, float firingSpeed)
{
	weap.FireInterval[0] = firingSpeed;

	return weap;
}

// Changes a weapon's magazine size.
function UTWeapon ChangeMagazineSize(UTWeapon weap, int size)
{
	weap.AddAmmo(size);

	return weap;
}

// Changes a weapon's projectile spread.
function UTWeapon ChangeSpread(UTWeapon weap, float spread)
{
	// The higher spread value, the wider spread.
	weap.Spread[weap.CurrentFireMode] = spread;

	return weap;
}

// Sets a weapon to be a specific type.
function UTWeapon SpawnWeaponType(string Type)
{
	switch(Type)
	{
		case "linkgun":     return Spawn(class'AEWeapon_LinkGun');                      break;
		case "Rocket" :     return Spawn(class'AEWeapon_RocketLauncher');               break;
		case "shockRifle":  return Spawn(class'AEWeapon_ShockRifle');                   break;
		default:            `log("[WeaponSpawnError] No weapon of this type: " $Type);  break;
	};

	return none;
}

DefaultProperties
{
	// Currently left empty.
}
