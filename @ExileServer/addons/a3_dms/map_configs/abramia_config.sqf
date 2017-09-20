/*
	Custom configs for Abramia (Isla Abramia).
	Sample by eraser1, edited for Abramia by Riker2335

	All of these configs exist in the main config. The configs below will simply override any config from the main config.
	Explanations to all of these configs also exist in the main config.
*/

// Let missions spawn close to water, since there's a lot of rivers and inlets. Also allows for missions on the islands more readily.
DMS_WaterNearBlacklist				= 100;

// Abramia is quite hilly, have found however that having it on a fairly flat terrain helps move it away from the edges of the mountains.... sometimes.
DMS_MinSurfaceNormal = 0.92;


// Trying out missions close-ish to zones
DMS_SpawnZoneNearBlacklist			= 1000;
DMS_TraderZoneNearBlacklist			= 1000;


// Comment out the below configs if you want missions to be able to spawn on the islands surrounding the mainland.

DMS_MinDistFromWestBorder			= 600;
DMS_MinDistFromEastBorder			= 300;
DMS_MinDistFromSouthBorder			= 300;
DMS_MinDistFromNorthBorder			= 300;
