/*
	Littlebird Mission with new difficulty selection system
	Easy difficulty vehicle is not persistent
	based on work by Defent and eraser1
	easy/mod/difficult/hardcore - reworked by [CiC]red_ned http://cic-gaming.co.uk
*/

private ["_num", "_side", "_pos", "_OK", "_difficulty", "_extraParams", "_AICount", "_group", "_type", "_launcher", "_staticGuns", "_wreck", "_crate", "_crate1", "_vehicle", "_pinCode", "_class", "_veh", "_crate_loot_values", "_crate_loot_values1", "_missionAIUnits", "_missionObjs", "_msgStart", "_msgWIN", "_msgLOSE", "_missionName", "_markers", "_time", "_added", "_cleanup", "_baseObjs", "_crate_weapons", "_crate_weapon_list", "_crate_items", "_crate_item_list", "_crate_backpacks", "_rndlevel", "_PossibleVehicleClass", "_PossibleDifficulty"];

// For logging purposes
_num = DMS_MissionCount;


// Set mission side (only "bandit" is supported for now)
_side = "bandit";


// This part is unnecessary, but exists just as an example to format the parameters for "DMS_fnc_MissionParams" if you want to explicitly define the calling parameters for DMS_fnc_FindSafePos.
// It also allows anybody to modify the default calling parameters easily.
if ((isNil "_this") || {_this isEqualTo [] || {!(_this isEqualType [])}}) then
{
	_this =
	[
		[10,DMS_WaterNearBlacklist,DMS_MinSurfaceNormal,DMS_SpawnZoneNearBlacklist,DMS_TraderZoneNearBlacklist,DMS_MissionNearBlacklist,DMS_PlayerNearBlacklist,DMS_TerritoryNearBlacklist,DMS_ThrottleBlacklists],
		[
			[]
		],
		_this
	];
};

// Check calling parameters for manually defined mission position.
// You can define "_extraParams" to specify the vehicle classname to spawn, either as _vehClass or [_vehClass]
_OK = (_this call DMS_fnc_MissionParams) params
[
	["_pos",[],[[]],[3],[],[],[]],
	["_extraParams",[]]
];

if !(_OK) exitWith
{
	diag_log format ["DMS ERROR :: Called MISSION paul_castle.sqf with invalid parameters: %1",_this];
};


//create possible difficulty add more of one difficulty to weight it towards that
_PossibleDifficulty		= 	[
								"difficult",
								"difficult",
								"hardcore",
								"hardcore",
								"hardcore"
							];
//choose difficulty and set value
_difficulty = selectRandom _PossibleDifficulty;

switch (_difficulty) do
{
	case "easy":
	{
		_AICount = (4 + (round (random 2)));
		_crate_weapons 		= (1 + (round (random 1)));
		_crate_items 		= (2 + (round (random 5)));
		_crate_backpacks 	= (2 + (round (random 1)));
	};

	case "moderate":
	{
		_AICount = (5 + (round (random 1)));
		_crate_weapons 		= (2 + (round (random 1)));
		_crate_items 		= (4 + (round (random 5)));
		_crate_backpacks 	= (2 + (round (random 1)));
	};

	case "difficult":
	{
		_AICount = (5 + (round (random 1)));
		_crate_weapons 		= (15 + (round (random 1)));
		_crate_items 		= (15 + (round (random 6)));
		_crate_backpacks 	= (3 + (round (random 1)));
	};

	//case "hardcore":
	default
	{
		_AICount = (5 + (round (random 1)));
		_crate_weapons 		= (20 + (round (random 1)));
		_crate_items 		= (20 + (round (random 7)));
		_crate_backpacks 	= (4 + (round (random 1)));
	};
};

_msgStart = ['#FFFF00',"Soldiers are trying to setup their base. Kill them and steal their APC!"];


_group =
[
	_pos,					// Position of AI
	_AICount,				// Number of AI
	_difficulty,			// "random","hardcore","difficult","moderate", or "easy"
	"random", 				// "random","assault","MG","sniper" or "unarmed" OR [_type,_launcher]
	_side 					// "bandit","hero", etc.
] call DMS_fnc_SpawnAIGroup;

//add vehicle patrol
_veh =
[
	[
		[(_pos select 0) -75,(_pos select 1)+75,0]
	],
	_group,
	"bambi",
	_difficulty,
	_side
] call DMS_fnc_SpawnAIVehicle;


// add static guns
// _staticGuns =
// [
// 	[
// 		// make statically positioned relative to centre point and randomise a little
// 		[(_pos select 0) -(5-(random 2)),(_pos select 1)+(5-(random 2)),0]
// 	],
// 	_group,
// 	"assault",
// 	"static",
// 	"bandit"
// ] call DMS_fnc_SpawnAIStaticMG;

_baseObjs =
[
	"paul_castle",
	_pos
] call DMS_fnc_ImportFromM3E;

//create possible vehicle list
_PossibleVehicleClass 		= [
								"CUP_O_BTR90_HQ_RU",
								"CUP_B_BMP2_CZ",
								"O_APC_Tracked_02_cannon_F",
								"I_APC_Wheeled_03_cannon_F",
								"CUP_B_BMP2_CZ_Des"
							];
//choose the vehicle
_VehicleClass = selectRandom _PossibleVehicleClass;


// Dont give pin coded vehicles on easy
if (_difficulty isEqualTo "easy") then
{
	_vehicle = [_VehicleClass,[(_pos select 0) -15, (_pos select 1) -15, 0]] call DMS_fnc_SpawnNonPersistentVehicle;
	_msgWIN = ['#0080ff',"The soldiers are killed."];
}
else
{
	_pinCode = (1000 +(round (random 8999)));
	_vehicle = [_VehicleClass,[(_pos select 0) -20, (_pos select 1) -20, 0],_pinCode] call DMS_fnc_SpawnPersistentVehicle;
	_msgWIN = ['#0080ff',format ["The Soldiers trying to setup their base are eliminated and APC is being stolen, entry code %1...",_pinCode]];
};


// Create Crate type
_crate1 = ["Box_NATO_Wps_F",_pos] call DMS_fnc_SpawnCrate;


// setup crate iteself with items
_crate_loot_values1 =
[
	_crate_weapons,			// Weapons
	_crate_items,			// Items + selection list
	_crate_backpacks 		// Backpacks
];


// Define mission-spawned AI Units
_missionAIUnits =
[
	_group 		// We only spawned the single group for this mission
];

// Define mission-spawned objects and loot values
_missionObjs =
[
	_baseObjs+[_veh],		// armed AI vehicle, base objects, and static guns
	[_vehicle],								//this is prize vehicle
	[[_crate1,_crate_loot_values1]]			//this is prize crate
];

// define start messages in difficulty choice

// Define Mission Win message defined in persistent choice

// Define Mission Lose message
_msgLOSE = ['#FF0000',"The Soldiers didn't think it was a suitable location to build their base and moved on with their APC!"];

// Define mission name (for map marker and logging)
_missionName = "APC at Soldier Camp";

// Create Markers
_markers =
[
	_pos,
	_missionName,
	_difficulty
] call DMS_fnc_CreateMarker;

// Record time here (for logging purposes, otherwise you could just put "diag_tickTime" into the "DMS_AddMissionToMonitor" parameters directly)
_time = diag_tickTime;

// Parse and add mission info to missions monitor
_added =
[
	_pos,
	[
		[
			"kill",
			_group
		],
		[
			"playerNear",
			[_pos,DMS_playerNearRadius]
		]
	],
	[
		_time,
		(DMS_MissionTimeOut select 0) + random((DMS_MissionTimeOut select 1) - (DMS_MissionTimeOut select 0))
	],
	_missionAIUnits,
	_missionObjs,
	[_missionName,_msgWIN,_msgLOSE],
	_markers,
	_side,
	_difficulty,
	[]
] call DMS_fnc_AddMissionToMonitor;

// Check to see if it was added correctly, otherwise delete the stuff
if !(_added) exitWith
{
	diag_log format ["DMS ERROR :: Attempt to set up mission %1 with invalid parameters for DMS_AddMissionToMonitor! Deleting mission objects and resetting DMS_MissionCount.",_missionName];

	// Delete AI units and the crate. I could do it in one line but I just made a little function that should work for every mission (provided you defined everything correctly)
	_cleanup = [];
	{
		_cleanup pushBack _x;
	} forEach _missionAIUnits;

	_cleanup pushBack ((_missionObjs select 0)+(_missionObjs select 1));

	{
		_cleanup pushBack (_x select 0);
	} foreach (_missionObjs select 2);

	_cleanup call DMS_fnc_CleanUp;


	// Delete the markers directly
	{deleteMarker _x;} forEach _markers;


	// Reset the mission count
	DMS_MissionCount = DMS_MissionCount - 1;
};


// Notify players
[_missionName,_msgStart] call DMS_fnc_BroadcastMissionStatus;



if (DMS_DEBUG) then
{
	(format ["MISSION: (%1) :: Mission #%2 started at %3 with %4 AI units and %5 difficulty at time %6",_missionName,_num,_pos,_AICount,_difficulty,_time]) call DMS_fnc_DebugLog;
};
