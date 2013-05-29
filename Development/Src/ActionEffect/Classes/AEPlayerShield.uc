class AEPlayerShield extends Actor
	placeable;

var bool bOwnedByPlayer;

var AEPawn ControllerPawn;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	`log("HEEYYYY!");
}

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

	if( ControllerPawn != none ){
		SetLocation( ControllerPawn.Location );
	}else
		Destroy();

	foreach CollidingActors(class'Projectile', target, 80)
	{
		if( !bOwnedByPlayer || target.InstigatorController != GetALocalPlayerController() )
			target.Destroy();
	}

	super.Tick(DeltaTime);
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
		StaticMesh=StaticMesh'Level1pack.Mesh.CollisionSphere'
		Scale=1.5
		HiddenGame=true
		CollideActors=true
		BlockActors=true
		BlockRigidBody=false
	End Object

	Begin Object class=StaticMeshComponent Name=Sphere
		StaticMesh=StaticMesh'Level1pack.Mesh.ShieldSphere'
		bOnlyOwnerSee=false
		HiddenGame=false
		Scale=6
		BlockActors=true
		CollideActors=true
		BlockRigidBody=false
	End Object

	Components.Add(CollisionSphere)
	Components.Add(Sphere)
	
	RemoteRole=ROLE_MAX;

	bOnlyOwnerSee=false

	bCollideActors=true
	bBlockActors=true

	BlockRigidBody=false

	bForceNetUpdate=true
	bAlwaysRelevant=true

	bNoDelete=false
	bStatic=false

	CollisionType=COLLIDE_BlockAll
}
