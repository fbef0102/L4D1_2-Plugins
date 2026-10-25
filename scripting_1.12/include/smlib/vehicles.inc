#if defined _smlib_vehicles_included
	#endinput
#endif
#define _smlib_vehicles_included

#include <sourcemod>
#include <sdktools_entinput>
#include <sdktools_functions>
#include <smlib/entities>

/**
 * Returns the vehicle's driver.
 * If there is no driver in the vehicle, -1 is returned.
 *
 * @param vehicle			Entity index.
 * @return					Client index, or -1 if there is no driver.
 */
stock int Vehicle_GetDriver(int vehicle)
{
	int m_hVehicle = GetEntPropEnt(vehicle, Prop_Send, "m_hPlayer");

	return m_hVehicle;
}

/**
 * Returns whether there is a driver in the vehicle or not.
 *
 * @param vehicle			Entity index.
 * @return					True if the vehicle has a driver, false otherwise
 */
stock bool Vehicle_HasDriver(int vehicle)
{
	return Vehicle_GetDriver(vehicle) != -1;
}

/**
 * Kicks the driver ouf of the vehicle
 *
 * @param vehicle			Entity index.
 * @return					True on success, false otherwise.
 */
stock bool Vehicle_ExitDriver(int vehicle)
{
	if (!Vehicle_HasDriver(vehicle)) {
		return false;
	}

	return AcceptEntityInput(vehicle, "ExitVehicle");
}

/**
 * Start's the vehicle's engine
 *
 * @param vehicle			Entity index.
 * @return					True on success, false otherwise.
 */
stock bool Vehicle_TurnOn(int vehicle)
{
	return AcceptEntityInput(vehicle, "TurnOn");
}

/**
 * Shuts down the vehicle's engine
 *
 * @param vehicle			Entity index.
 * @return					True on success, false otherwise.
 */
stock bool Vehicle_TurnOff(int vehicle)
{
	return AcceptEntityInput(vehicle, "TurnOff");
}

/**
 * Locks the vehicle.
 *
 * @param vehicle			Entity index.
 * @return					True on success, false otherwise.
 */
stock bool Vehicle_Lock(int vehicle)
{
	return AcceptEntityInput(vehicle, "Lock");
}

/**
 * Unlocks the vehicle.
 *
 * @param vehicle			Entity index.
 * @return					True on success, false otherwise.
 */
stock bool Vehicle_Unlock(int vehicle)
{
	return AcceptEntityInput(vehicle, "Unlock");
}

/**
 * Returns wether the entity is a valid vehicle or not.
 *
 * @param vehicle			Entity index.
 * @return					True if it is a valid vehicle, false otherwise.
 */
stock bool Vehicle_IsValid(int vehicle)
{
	if (!Entity_IsValid(vehicle)) {
		return false;
	}

	return Entity_ClassNameMatches(vehicle, "prop_vehicle", true);
}

/**
 * Reads the vehicle script from a vehicle.
 * This script contains all the vehicle settings like its speed
 * and that stuff.
 *
 * @param vehicle			Entity index.
 * @param buffer			String Buffer.
 * @param size				String Buffer size.
 * @noreturn
 */
stock void Vehicle_GetScript(int vehicle, char[] buffer, int size)
{
	GetEntPropString(vehicle, Prop_Data, "m_vehicleScript", buffer, size);
}

/**
 * Sets the script of a vehicle.
 * This script contains all the vehicle settings like its speed
 * and that stuff.
 *
 * @param vehicle			Entity index.
 * @param buffer			Vehicle Script path.
 * @noreturn
 */
stock void Vehicle_SetScript(int vehicle, char[] script)
{
	DispatchKeyValue(vehicle, "vehiclescript", script);
}
