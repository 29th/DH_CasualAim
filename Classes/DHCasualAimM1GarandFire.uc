class DHCasualAimM1GarandFire extends DH_M1GarandFire;

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int projectileID;
    local int SpawnCount;
    local float theta;
    local coords MuzzlePosition;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    //log("Projectile Firing, location of muzzle is "$Weapon.GetBoneCoords('Muzzle').Origin);
    //if( ROProjectileWeapon(Instigator.weapon) != none )
    //	log("MuzzleCoords location = "$ROProjectileWeapon(Instigator.weapon).GetMuzzleCoords().Origin);
	// if weapon in iron sights, spawn at eye position, otherwise spawn at muzzle tip
	// Temp commented out until we add the free-aim system in
	if( (Instigator.Weapon.bUsingSights && Instigator.bIsWalking) || Instigator.bBipodDeployed )
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		StartProj = StartTrace + X * ProjSpawnOffset.X;

		// check if projectile would spawn through a wall and adjust start location accordingly
		Other = Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
		if (Other != none )
		{
	   		StartProj = HitLocation;
		}
	}
	else
	{
        MuzzlePosition = Weapon.GetMuzzleCoords();

		// Get the muzzle position and scale it down 5 times (since the model is scaled up 5 times in the editor)
        StartTrace = MuzzlePosition.Origin - Weapon.Location;
		StartTrace = StartTrace * 0.2;
		StartTrace = Weapon.Location + StartTrace;

        Spawn(class 'ROEngine.RODebugTracer',Instigator,,StartTrace,rotator(MuzzlePosition.XAxis));

		StartProj = StartTrace + MuzzlePosition.XAxis * FAProjSpawnOffset.X;

        Spawn(class 'ROEngine.RODebugTracer',Instigator,,StartProj,rotator(MuzzlePosition.XAxis));

		Other = Trace(HitLocation, HitNormal, StartTrace, StartProj, true);// was false to only trace worldgeometry

		// Instead of just checking walls, lets check all actors. That way we won't have rounds
		// spawning on the other side of players and missing them altogether - Ramm 10/14/04
		if( Other != none )
		{
			StartProj = HitLocation;
		}
	}
    Aim = AdjustAim(StartProj, AimError);

	// for free-aim, just use where the muzzlebone is pointing
	if( !(Instigator.Weapon.bUsingSights && Instigator.bIsWalking) && !Instigator.bBipodDeployed && Instigator.Weapon.bUsesFreeAim
		&& Instigator.IsHumanControlled())
	{
		Log("Free Aim");
		Aim = rotator(MuzzlePosition.XAxis);
	}
	else
		Log("Not Free Aim");

	log("Weapon fire Aim = "$Aim$" Startproj = "$Startproj$" Muzzle X = "$MuzzlePosition.XAxis); // muzzlepos is the same at both fovs
	//PlayerController(Instigator.Controller).ClientMessage("Weapon fire Aim = "$Aim$" Startproj = "$Startproj);

//    Instigator.ClearStayingDebugLines();
//    Instigator.DrawStayingDebugLine(StartProj, StartProj+65535* MuzzlePosition.XAxis, 0,0,255);
//    Instigator.DrawStayingDebugLine(StartProj, StartProj+65535* vector(Aim), 0,255,0);

    SpawnCount = Max(1, ProjPerFire * int(Load));

	CalcSpreadModifiers();

	if( (DH_MGBase(Owner) != none) && DH_MGBase(Owner).bBarrelDamaged )
	{
		AppliedSpread = 4 * Spread;
	}
	else
	{
		AppliedSpread = Spread;
	}

    switch (SpreadStyle)
    {
        case SS_Random:
           	X = Vector(Aim);
           	for (projectileID = 0; projectileID < SpawnCount; projectileID++)
           	{
              	R.Yaw = AppliedSpread * ((FRand()-0.5)/1.5);
              	R.Pitch = AppliedSpread * (FRand()-0.5);
              	R.Roll = AppliedSpread * (FRand()-0.5);
              	SpawnProjectile(StartProj, Rotator(X >> R));
           	}
           	break;

        case SS_Line:
           	for (projectileID = 0; projectileID < SpawnCount; projectileID++)
           	{
              	theta = AppliedSpread*PI/32768*(projectileID - float(SpawnCount-1)/2.0);
              	X.X = Cos(theta);
              	X.Y = Sin(theta);
              	X.Z = 0.0;
              	SpawnProjectile(StartProj, Rotator(X >> Aim));
           	}
           	break;

        default:
           	SpawnProjectile(StartProj, Aim);
    }
}