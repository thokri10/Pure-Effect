/** THIS CLASS IS RESPONSIBLE FOR CREATING CUSTOM WEAPONS. */
class AEWeaponCreator extends Actor
	dependson(AEJSONParser);

//-----------------------------------------------------------------------------
// Structs

/** Our WeaponStruct that will contain all the variables for our weapon. 
 *  Default variables is now set by server. */
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


//-----------------------------------------------------------------------------
// Variables

/** Variable to easily use player controller. */
var AEPlayerController PC;


//-----------------------------------------------------------------------------
// Creation functions

/** Creates a custom-made weapon from server (main function) */
function UTWeapon CreateWeaponFromStruct(WeaponStruct weap)
{
	return CreateWeapon(weap.type, weap.spread, weap.magsize, weap.reloadTime, weap.damage, weap.speed);
}

/** Creates a custom-made weapon from server (sub-function) */
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


//-----------------------------------------------------------------------------
// Parsing

/** Parses the valueArray to a Weaponstruct */
function WeaponStruct parseToStruct(array<ValueStruct> values)
{
	local WeaponStruct returnWeapon;
	local ValueStruct  value;

	foreach values( value )
	{
		if      (value.type == "type")          returnWeapon.type       = value.value;   
		else if (value.type == "damage")        returnWeapon.damage     = float ( value.value );
		else if (value.type == "speed")         returnWeapon.speed      = float ( value.value );
		else if (value.type == "id")            returnWeapon.id         = int   ( value.value );         
		else if (value.type == "ammo_pool")     returnWeapon.magSize    = int   ( value.value );
		else if (value.type == "fire_rate")     returnWeapon.reloadTime = float ( value.value );
		else if (value.type == "spread")        returnWeapon.spread     = float ( value.value );
		else `log("[WeaponCreatorParse] No known type: " $ value.type);
	}

	return returnWeapon;
}


//-----------------------------------------------------------------------------
// Weapon functions


/** Sets a weapon to be a specific type. */
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

/** Changes a weapon's firing speed. */
function UTWeapon ChangeFiringSpeed(UTWeapon weap, float firingSpeed)
{
	weap.FireInterval[0] = firingSpeed;

	return weap;
}

/** Changes a weapon's magazine size. */
function UTWeapon ChangeMagazineSize(UTWeapon weap, int size)
{
	weap.AddAmmo(size);

	return weap;
}

/** Changes a weapon's projectile spread. */
function UTWeapon ChangeSpread(UTWeapon weap, float spread)
{
	// The higher spread value, the wider spread.
	weap.Spread[weap.CurrentFireMode] = spread;

	return weap;
}

DefaultProperties
{
	// Currently left empty.
}
