class DHCasualAimM1GarandWeapon extends DH_M1GarandWeapon;

var float IronSightDisplayCloseFOV;

simulated event RenderOverlays( Canvas Canvas )
{
	local int m;
    local rotator RollMod;
    local ROPlayer Playa;
	//For lean - Justin
	local ROPawn rpawn;
	local int leanangle;
	// Drawpos actor
	local rotator RotOffset;

    if (Instigator == none)
    	return;

    // Lets avoid having to do multiple casts every tick - Ramm
    Playa = ROPlayer(Instigator.Controller);

    // Don't draw the weapon if we're not viewing our own pawn
    if (Playa != none && Playa.ViewTarget != Instigator)
    	return;

    // draw muzzleflashes/smoke for all fire modes so idle state won't
    // cause emitters to just disappear
	Canvas.DrawActor(None, false, true); // amb: Clear the z-buffer here

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
    	if (FireMode[m] != None)
        {
        	FireMode[m].DrawMuzzleFlash(Canvas);
        }
    }

	// these seem to set the current position and rotation of the weapon
	// in relation to the player

	//Adjust weapon position for lean
	rpawn = ROPawn(Instigator);
	if (rpawn != none && rpawn.LeanAmount != 0)
	{
		leanangle += rpawn.LeanAmount;
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );

	if( bUsesFreeAim && !(bUsingSights && Instigator.bIsWalking) )
	{
    	// Remove the roll component so the weapon doesn't tilt with the terrain
    	RollMod = Instigator.GetViewRotation();

    	if( Playa != none )
		{
			RollMod.Pitch += Playa.WeaponBufferRotation.Pitch;
			RollMod.Yaw += Playa.WeaponBufferRotation.Yaw;

			RotOffset.Pitch -= Playa.WeaponBufferRotation.Pitch;
			RotOffset.Yaw -= Playa.WeaponBufferRotation.Yaw;
    	}

		RollMod.Roll += leanangle;

		if( IsCrawling() )
		{
			RollMod.Pitch = CrawlWeaponPitch;
			RotOffset.Pitch = CrawlWeaponPitch;
		}
    }
    else
    {
    	RollMod = Instigator.GetViewRotation();
		RollMod.Roll += leanangle;

		if( IsCrawling() )
		{
			RollMod.Pitch = CrawlWeaponPitch;
			RotOffset.Pitch = CrawlWeaponPitch;
		}
   	}

	// use the special actor drawing when in ironsights to avoid the ironsight "jitter"
	// TODO: This messes up the lighting, and texture environment map shader when using
	// ironsights. Maybe use a texrotator to simulate the texture environment map, or
	// just find a way to fix the problems.
	if( bUsingSights && Playa != none)
	{
		bDrawingFirstPerson = true;
      	Canvas.DrawBoundActor(self, false, false,DisplayFOV,Playa.Rotation,Playa.WeaponBufferRotation,Instigator.CalcZoomedDrawOffset(self));
      	bDrawingFirstPerson = false;
	}
	else
	{
	    SetRotation( RollMod );
		bDrawingFirstPerson = true;
	    Canvas.DrawActor(self, false, false, DisplayFOV);
	    bDrawingFirstPerson = false;
	}
}

function SetServerOrientation(rotator NewRotation)
{
	local rotator WeaponRotation;

	if( bUsesFreeAim && !(bUsingSights && Instigator.bIsWalking) )
	{
    	// Remove the roll component so the weapon doesn't tilt with the terrain
    	WeaponRotation = Instigator.GetViewRotation();// + FARotation;

		WeaponRotation.Pitch += NewRotation.Pitch;
		WeaponRotation.Yaw += NewRotation.Yaw;
        WeaponRotation.Roll += ROPawn(Instigator).LeanAmount;

    	SetRotation( WeaponRotation );
		SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    }
}

simulated function bool ShouldUseFreeAim()
{
	if( FireMode[1].bMeleeMode && FireMode[1].IsFiring())
	{
		return false;
	}

	if(bUsesFreeAim && !(bUsingSights && Instigator.bIsWalking))
	{
		return true;
	}

	return false;
}

exec function setpso(float set)
{
	local vector setto;
	setto.X = set;
	ROProjectileFire(FireMode[0]).Default.ProjSpawnOffset = setto;
	ROProjectileFire(FireMode[0]).ProjSpawnOffset = setto;
	Log("PSO set to "$set);
}

simulated function setfapso(float set)
{
	local vector setto;
	setto.X = set;
	ROProjectileFire(FireMode[0]).Default.FAProjSpawnOffset = setto;
	ROProjectileFire(FireMode[0]).FAProjSpawnOffset = setto;
	Log("FAPSO set to "$set);
}

simulated function setpvo(float set)
{
	local vector setto;
	setto.X = set;
	Default.PlayerViewOffset = setto;
	PlayerViewOffset = setto;
	Log("PVO set to "$set);
}

defaultproperties
{
	IronSightDisplayFOV=50.000000
	IronSightDisplayCloseFOV=20.000000
	FireModeClass(0)=Class'DH_CasualAim.DHCasualAimM1GarandFire'
}