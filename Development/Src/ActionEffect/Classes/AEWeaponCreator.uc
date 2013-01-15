// THIS CLASS IS RESPONSIBLE FOR CREATING CUSTOM WEAPONS.
class AEWeaponCreator extends Actor;

// Variable to easy use playercontroller
var AEPlayerController PC;

// Creates a custom-made weapon from server (main function)
simulated function UTWeapon CreateWeaponFromStruct(WeaponStruct weap)
{
	return CreateWeapon(weap.type, weap.spread, weap.magsize, weap.reloadTime);
}

// Creates a custom-made weapon from server (sub-function)
simulated function UTWeapon CreateWeapon(string type, float spread, int magazineSize, float reloadSpeed)
{
	// Initializes a weapon.
	local UTWeapon returnWeapon;
	returnWeapon = SpawnWeaponType(type);

	// Changes the weapon's stats.
	returnWeapon = ChangeSpread(returnWeapon, spread);
	returnWeapon = ChangeMagazineSize(returnWeapon, magazineSize);
	returnWeapon = ChangeFiringSpeed(returnWeapon, reloadSpeed);

	return returnWeapon;
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
		case "linkgun":     return Spawn(class'UTWeap_LinkGun');                        break;
		case "Rocket" :     return Spawn(class'AEWeapon_RocketLauncher');               break;
		case "shockRifle":  return Spawn(class'UTWeap_ShockRifle');                     break;
		default:            `log("[WeaponSpawnError] No weapon of this type: " $Type);  break;
	};
}

DefaultProperties
{
	// Currently left empty.
}
