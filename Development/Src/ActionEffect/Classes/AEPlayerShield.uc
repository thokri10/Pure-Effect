class AEPlayerShield extends Actor
	placeable;

var bool bOwnedByPlayer;

var AEPawn ControllerPawn;

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	local Projectile proj;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if(bBlockActors)
	{
		proj = Projectile(Other);

		if(proj != none){
			Other.Destroy();
		}
	}
}

event Tick(float DeltaTime)
{
	local Projectile target;

	SetLocation( ControllerPawn.Location );

	foreach CollidingActors(class'Projectile', target, 80)
	{
		if( !bOwnedByPlayer || target.InstigatorController != GetALocalPlayerController() )
			target.Destroy();
	}
}

simulated function bool StopsProjectile(Projectile P)
{
	if(P.InstigatorController.Pawn == ControllerPawn)
		return false;

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

	`log("BUMP");
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=CollisionSphere
		StaticMesh=StaticMesh'Level1pack.FalloffSphere.Mesh.CollisionSphere'
		Scale=2
		HiddenGame=true
		CollideActors=true
		BlockActors=true
		BlockRigidBody=false
	End Object

	Begin Object class=StaticMeshComponent Name=Sphere
		StaticMesh=StaticMesh'Level1pack.Mesh.ShieldSphere'
		HiddenGame=false
		Scale=6
		BlockActors=true
		CollideActors=true
		BlockRigidBody=false
	End Object

	Components.Add(CollisionSphere)
	Components.Add(Sphere)

	bCanBeDamaged=true
	bCollideActors=true
	bBlockActors=true
	BlockRigidBody=false

	CollisionType=COLLIDE_BlockAll
}
