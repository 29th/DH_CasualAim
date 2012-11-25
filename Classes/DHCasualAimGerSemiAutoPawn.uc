class DHCasualAimGerSemiAutoPawn extends DH_HeerPawn;

function SetWalking(bool bNewIsWalking)
{
	local float NewFOV;

	//Log("SetWalking " $ bNewIsWalking);
	if(bIronSights)
	{
		if(bNewIsWalking && DHCasualAimM1GarandWeapon(Weapon) != None)
		{
			NewFOV = DHCasualAimM1GarandWeapon(Weapon).IronSightDisplayCloseFOV;
		}
		else
		{
			NewFOV = ROWeapon(Weapon).IronSightDisplayFOV;
		}
		Weapon.DisplayFOV = NewFOV;
		//Log("Set DisplayFOV to " $ NewFOV);
	}

	Super.SetWalking(bNewIsWalking);
}

simulated function vector CalcDrawOffset(inventory Inv)
{
	local vector DrawOffset;
	local float UseFOV;

	if ( Controller == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	if(bIronSights) {
		UseFOV = ROWeapon(Weapon).IronSightDisplayFOV;
		Log("CalcDrawOffset IS"); }
	else {
		UseFOV = Weapon.DisplayFOV;
		Log("CalcDrawOffset Not IS"); }

	DrawOffset = ((0.9/UseFOV * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() );
	if ( !IsLocallyControlled() )
		DrawOffset.Z += BaseEyeHeight;
	else
	{
		// Added these for proneing and leaning
		DrawOffset.Z += EyePosition().Z;
		DrawOffset.X += EyePosition().X;
		DrawOffset.Y += EyePosition().Y;

	    DrawOffset += WeaponBob(Inv.BobDamping);
        DrawOffset += CameraShake();
	}
	return DrawOffset;
}