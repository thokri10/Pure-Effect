class AEPlayerShield extends Actor
	placeable;

var bool bOwnedByPlayer;

var AEPawn PawnController;

var int health;

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	local Projectile proj;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if(bBlockActors)
	{
		proj = Projectile(Other);

		`log("DAmage: " $ proj.Damage);
		if(proj != none){
			Other.Destroy();
		}
	}

	`log("[PlayerShield] Shiuld bloeck");

}

event Tick(float DeltaTime)
{
	local Projectile target;

	foreach CollidingActors(class'Projectile', target, 80)
	{
		if( !bOwnedByPlayer || target.InstigatorController != GetALocalPlayerController() )
			target.Destroy();
	}
}

simulated function bool StopsProjectile(Projectile P)
{
	if(P.InstigatorController.Pawn == PawnController)
		return false;

	health = health - p.Damage;

	`log("Health: " $ health);
	
	if(health <= 0)
		Destroy();

	return super.StopsProjectile(P);
}

event PostTouch(Actor Other)
{
	super.PostTouch(Other);

	`log("POST TOUCHT");
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	super.Bump(Other, OtherComp, HitNormal);

	`log("jkasdlkasjkdhakjshd");
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=CollisionSphere
		StaticMesh=StaticMesh'Level1pack.FalloffSphere.Mesh.CollisionSphere'
		Scale=1.3
		HiddenGame=true
		CollideActors=true
		BlockActors=true
	End Object

	Begin Object class=StaticMeshComponent Name=Sphere
		StaticMesh=StaticMesh'Level1pack.Mesh.ShieldSphere'
		HiddenGame=false
		Scale=5
		BlockActors=false
		CollideActors=false
	End Object

	Components.Add(CollisionSphere)
	Components.Add(Sphere)

	health = 100;

	bCanBeDamaged=true
	bCollideActors=true
	bBlockActors=true

	CollisionType=COLLIDE_BlockAll
}