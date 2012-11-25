class DHCasualAimPlayer extends DHPlayer;

function HandleWalking()
{
	local ROPawn P;

	P = ROPawn(Pawn);

	if (P == None)
		return;

	if (P.bIsCrawling)
		P.SetWalking(false);
	//else if (P.bIronSights)
		//P.SetWalking(true);
	else
		P.SetWalking(bRun != 0);

// MergeTODO: this could probably be handled better
	P.SetSprinting(bSprint != 0);
}

exec function setdeffov(float set)
{
	ROWeapon(Pawn.Weapon).IronSightDisplayFOV = set;
	ROWeapon(Pawn.Weapon).Default.IronSightDisplayFOV = set;
}

exec function setpso(float set)
{
	DHCasualAimM1GarandWeapon(Pawn.Weapon).setpso(set);
}

exec function setfapso(float set)
{
	DHCasualAimM1GarandWeapon(Pawn.Weapon).setfapso(set);
}

exec function setpvo(float set)
{
	DHCasualAimM1GarandWeapon(Pawn.Weapon).setpvo(set);
}

exec function setmyfov(float set)
{
	Pawn.Weapon.DisplayFOV = set;
	Log("DisplayFOV set to "$set);
}

defaultproperties
{
}