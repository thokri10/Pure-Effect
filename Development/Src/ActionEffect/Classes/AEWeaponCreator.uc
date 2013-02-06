// THIS CLASS IS RESPONSIBLE FOR CREATING CUSTOM WEAPONS.
class AEWeaponCreator extends Actor;

// Our WeaponStruct that will contain all the variables for our weapon. 
// Default variables is now set by server.
struct WeaponStruct
{
	var int     id;
	var string  type;
	var float   spread;
	var float   reloadTime;
	var int     magSize;
	var float   damage;
	var float   speed;
};

// Variable to easy use playercontroller
var AEPlayerController PC;

function UTWeapon CrateWeaponFromString(string weap)
{
	`log("asdkjaklsdjklasjdlkasjdlkajslkd: " $ weap);
	return CreateWeaponFromStruct( parseArrayToWeaponStruct( PC.myTcpLink.parseToArray( weap ) ) );
}

// Creates a custom-made weapon from server (main function)
function UTWeapon CreateWeaponFromStruct(WeaponStruct weap)
{
	return CreateWeapon(weap.type, weap.spread, weap.magsize, weap.reloadTime, weap.damage, weap.speed);
}

// Creates a custom-made weapon from server (sub-function)
function UTWeapon CreateWeapon(string type, float spread, int magazineSize, float reloadSpeed, float damage, float speed)
{
	// Initializes a weapon.
	local UTWeapon returnWeapon;
	returnWeapon = SpawnWeaponType(type, damage, speed);

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
function WeaponStruct parseArrayToWeaponStruct(array<string> in)
{
	local WeaponStruct  Weap;
	local array<string> tempString2;
	local int i;
	local string weaponDebugLog;

	weaponDebugLog = "\n";

	for(i = 0; i < in.Length; i++)
	{
		// Now we split it one more time to get type and value 
		tempString2 = SplitString(in[i], ":");
		// Removes both the ' " ' from the string so we can read it properly
		tempString2[0] = mid( tempString2[0], 1, len( tempString2[0] ) - 2 );

		`log(tempString2[0] $ " : " $ tempString2[1] );

		// Now we check if any of the preset variables we have exist in this json
		if      (tempString2[0] == "id")            Weap.id         = int   ( tempString2[1] );         
		else if (tempString2[0] == "ammo_pool")     Weap.magSize    = int   ( tempString2[1] );
		else if (tempString2[0] == "fire_rate")     Weap.reloadTime = float ( tempString2[1] );
		else if (tempString2[0] == "spread")        Weap.spread     = float ( tempString2[1] );
		else if (tempString2[0] == "type")          Weap.type       = mid( tempString2[1], 1, len( tempString2[1] ) - 2 );   
		else if (tempString2[0] == "damage")        Weap.damage     = float ( tempString2[1] );
		else if (tempString2[0] == "speed")         Weap.speed      = float ( tempString2[1] );
		else `log("[WeaponStructCreator] No known variable of this type: " $ tempString2[0] );
	}

	// TESTING PURPOSES. Fix this later.
	//Weap.damage = 1337.0f;
	//Weap.speed = 1500.0f;

	weaponDebugLog = weaponDebugLog $ "Weapon ID: "                 $ Weap.id $             "\n"
									$ "Magazine size: "             $ Weap.magSize $        "\n"
									$ "Reload time (seconds): "     $ Weap.reloadTime $     "\n"
									$ "Spread: "                    $ Weap.spread $         "\n"
									$ "Weapon type: "               $ Weap.type $           "\n"
									$ "Damage: "                    $ Weap.damage $         "\n"
									$ "Speed: "                     $ Weap.speed $          "\n";

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
function UTWeapon SpawnWeaponType(string Type, float damage, float speed)
{
	// Declares weapons, where one will be returned depending on the Type.
	local AEWeapon_LinkGun linkgun;
	local AEWeapon_RocketLauncher rocketLauncher;
	local AEWeapon_ShockRifle shockRifle;

	switch(Type)
	{
		case "linkgun":
			linkgun = Spawn(class'AEWeapon_LinkGun');
			linkgun.customDamage = damage;
			linkgun.customSpeed = speed;
			linkgun.customProjectileType = Type;
			return linkgun;                   
			break;

		case "rocket" :     
			rocketLauncher = Spawn(class'AEWeapon_RocketLauncher');
			rocketLauncher.customDamage = damage;
			rocketLauncher.customSpeed = speed;
			rocketLauncher.customProjectileType = Type;
			return rocketLauncher;
			break;

		case "shockRifle":  
			shockRifle = Spawn(class'AEWeapon_ShockRifle'); 
			shockRifle.customDamage = damage;
			shockRifle.customSpeed = speed;
			shockRifle.customProjectileType = Type;
			return shockRifle;
			break;

		default:            
			`log("[WeaponSpawnError] No weapon of this type: " $ Type); 
			break;
	};

	return none;
}

DefaultProperties
{
	// Currently left empty.
}
