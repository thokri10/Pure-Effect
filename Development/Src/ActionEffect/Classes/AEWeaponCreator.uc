class AEWeaponCreator extends Actor;

var array<class> weaponTypes;

simulated function UTWeapon CreateWeaponFromStruct(WeaponStruct weap)
{
	return CreateWeapon(weap.type, weap.spread, weap.magsize, weap.reloadTime);
}

simulated function UTWeapon CreateWeapon(string type, float spread, int magazineSize, float reloadSpeed)
{
	local UTWeapon returnWeapon;

	returnWeapon = SpawnWeaponType(type);

	returnWeapon = ChangeSpread(returnWeapon, spread);
	returnWeapon = ChangeMagazineSize(returnWeapon, magazineSize);
	returnWeapon = ChangeFireSpeed(returnWeapon, reloadSpeed);

	return returnWeapon;
}

function UTWeapon ChangeFireSpeed(UTWeapon weap, float fireSpeed)
{
	weap.FireInterval[0]=firespeed;

	return weap;
}

function UTWeapon ChangeMagazineSize(UTWeapon weap, int size)
{
	weap.AddAmmo(size);

	return weap;
}

function UTWeapon ChangeSpread(UTWeapon weap, float spread)
{
	weap.Spread[weap.CurrentFireMode] = spread;

	return weap;
}

function UTWeapon SpawnWeaponType(string Type)
{
	switch(Type)
	{
	case "linkgun": return Spawn(class'UTWeap_LinkGun'); break;
	case "rocket" : return Spawn(class'UTWeap_RocketLauncher_Content'); break;
	case "shockRifle": return Spawn(class'UTWeap_ShockRifle'); break;
	default: `log("[WeaponSpawnError] No weapon of this type: " $Type); break;
	};
}

DefaultProperties
{
	weaponTypes(0)=class'UTWeap_LinkGun'
	weaponTypes(1)=class'UTWeap_RocketLauncher_Content'
	WeaponTypes(2)=class'UTWeap_ShockRifle'
}
