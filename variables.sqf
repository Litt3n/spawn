hotkeyHUD = if (GTS_HotkeyHUD) then { true } else { false };
if (GTS_MissionPosMsg) then { lastMissionMsgTime = diag_tickTime; };

switch GTS_CurrencyStorageType do {
	case "onlyBank": {
		GTS_BankInteractExitCond = { true };
		GTS_BankInteractAction = { false };
		GTS_BankObjectUpdateCond = { false };
	};
	case "storage": {
		GTS_BankInteractExitCond = { !(_typeOf in DZE_MoneyStorageClasses) };
		GTS_BankInteractAction = { (_typeOfCursorTarget in DZE_MoneyStorageClasses && {!locked _cursorTarget} && {!(_typeOfCursorTarget in DZE_LockedStorage)} && {player distance _cursorTarget < 5}) };
		GTS_BankObjectUpdateCond = { (_type in DZE_MoneyStorageClasses) };
	};
	case "vehicle": {
		GTS_BankInteractExitCond = { !(ZSC_CurrentStorage isKindOf "AllVehicles") };
		GTS_BankInteractAction = { (_isVehicle && {!_isMan} && {!locked _cursorTarget} && {_isAlive} && {player distance _cursorTarget < 5}) };
		GTS_BankObjectUpdateCond = { (_object isKindOf "AllVehicles") };
	};
	case "storageAndVehicle": {
		GTS_BankInteractExitCond = { (!(_typeOf in DZE_MoneyStorageClasses) && !(cursortarget isKindOf "AllVehicles")) };
		GTS_BankInteractAction = { ((_typeOfCursorTarget in DZE_MoneyStorageClasses || _isVehicle) && {!_isMan} && {!locked _cursorTarget} && {_isAlive} && !(_typeOfCursorTarget in DZE_LockedStorage) && {player distance _cursorTarget < 5}) };
		GTS_BankObjectUpdateCond = { ((_type in DZE_MoneyStorageClasses) || (_object isKindOf "AllVehicles")) };
	};
};
if (!GTS_SpecialCurrencyMultiplier) then { GTS_CurrMult = 1 };


if (GTS_ESS) then { 
	AllPlayers = AllPlayers + ["GUE_Soldier_1","RU_Soldier_TL","MVD_Soldier_Marksman"];
};

if (GTS_DontUpdateObjects) then {
	dontUpdate_objects = [
		"ClutterCutter_EP1","Desk","FoldChair","FoldTable","Park_bench1","Park_bench2","Park_bench2_noRoad","SmallTable","WoodChair","Axe_woodblock","Barrel1","Barrel4","Barrel5","Barrels","Fuel_can","Garbage_can","Garbage_container","Haystack","Haystack_small",
		"HeliH","HeliHCivil","HeliHRescue","Land_Barrel_empty","Land_Barrel_sand","Land_Barrel_water","Land_Ind_BoardsPack1","Land_Ind_BoardsPack2","Land_Pneu","Land_ladder","Land_ladder_half","Misc_TyreHeap","Misc_concrete_High","Misc_palletsfoiled","Misc_palletsfoiled_heap",
		"Notice_board","Paleta1","Paleta2","Pile_of_wood","Satelit","Sr_border","BMP2Wreck","BRDMWreck","HMMWVWreck","LADAWreck","Land_BoatSmall_1","Land_BoatSmall_2a","Land_BoatSmall_2b","Mi8Wreck","SKODAWreck","T72Wreck","T72WreckTurret","UAZWreck","UH1Wreck","UralWreck",
		"datsun01Wreck","datsun02Wreck","hiluxWreck","Baseball","Can_small","EvDogTags","EvKobalt","EvMap","EvMoney","EvMoscow","EvPhoto","Explosive","FloorMop","Loudspeaker","MetalBucket","Misc_Videoprojektor","Misc_Videoprojektor_platno","Misc_Wall_lamp","Notebook",
		"Radio","SatPhone","SkeetDisk","SkeetMachine","SmallTV","Suitcase","bomb","Body","Grave","Hanged","Hanged_MD","Mass_grave","Land_Bench_EP1","Land_Cabinet_EP1","Land_Carpet_2_EP1","Land_Carpet_EP1","Land_Chair_EP1","Land_Chest_EP1","Dirtmount_EP1","Land_Crates_EP1",
		"Land_Dirthump01_EP1","Land_Dirthump02_EP1","Land_Dirthump03_EP1","Land_Misc_Coil_EP1","Land_bags_EP1","C130J_wreck_EP1","UH60_wreck_EP1","Land_Bag_EP1","Land_Basket_EP1","Land_Blankets_EP1","Land_Boots_EP1","Land_Bowl_EP1","Land_Bucket_EP1","Land_Canister_EP1",
		"Land_Pillow_EP1","Land_Rack_EP1","Land_Reservoir_EP1","Land_Sack_EP1","Land_Shelf_EP1","Land_Table_EP1","Land_Table_small_EP1","Land_Teapot_EP1","Land_Urn_EP1","Land_Vase_EP1","Land_Vase_loam_2_EP1","Land_Vase_loam_3_EP1","Land_Vase_loam_EP1","Land_Water_pipe_EP1",
		"Land_Wheel_cart_EP1","Land_Wicker_basket_EP1","Land_stand_waterl_EP1","Land_sunshade_EP1","Land_tires_EP1","Microphone1_ep1","Microphone2_ep1","Microphone3_ep1","Misc_Backpackheap_EP1","Misc_TyreHeapEP1","Sign_sphere100cm_EP1","Sign_sphere10cm_EP1","Sign_sphere25cm_EP1"
	];
};

if (GTS_VirtualGarage) then { DZE_maintainClasses set [count DZE_maintainClasses, "HeliHCivil"]; };

if (GTS_JAEM) then { 
	DayZ_SafeObjects set [count DayZ_SafeObjects, "HeliHRescue"];
	playerHasEvacField = false;
	playersEvacField = objNull;
	evac_chopperInProgress = false;
};

if (!GTS_Safezones) then { 
	GTS_SafezoneRelocate = false; 
	DZE_SafeZoneZombieLoot = false;
	DZE_SafeZoneNoBuildItems = [];
	DZE_SafeZoneNoBuildDistance = 150;
	DZE_SafeZonePosArray = [[[6325,7807,0],100],[[4063,11664,0],100],[[11447,11364,0],100],[[1606,7803,0],100],[[12944,12766,0],100],[[12060,12638,0],100]];
} else {
	DZE_SafeZonePosArray = [];
	{
		DZE_SafeZonePosArray set [count DZE_SafeZonePosArray, [(_x select 0), (_x select 1)]];
	} forEach infiSZ;
};

GTS_Prepend = ""; // Приставка перед сообщениями в системном чате (функция echoMsg).
DZE_NoBuildNear = [];
DZE_NoBuildNearDistance = 150;

/*
	Fixes for 1.0.6.3
*/
dayz_trees = dayz_trees - ["b_corylus.p3d"];

//Player self-action handles
dayz_resetSelfActions = {
	s_player_equip_carry = -1;
	s_player_fire = -1;
	s_player_cook = -1;
	s_player_boil = -1;
	s_player_fireout = -1;
	s_player_packtent = -1;
	s_player_packtentinfected = -1;
	s_player_fillfuel = -1;
	s_player_grabflare = -1;
	s_player_removeflare = -1;
	s_player_studybody = -1;
	s_player_deleteBuild = -1;
	s_player_flipveh = -1;
	s_player_sleep = -1;
	s_player_fillfuel210 = -1;
	s_player_fillfuel20 = -1;
	s_player_fillfuel5 = -1;
	s_player_siphonfuel = -1;
	s_player_repair_crtl = -1;
	s_player_fishing = -1;
	s_player_fishing_veh = -1;
	s_player_gather = -1;
	s_player_destroytent = -1;
	s_player_attach_bomb = -1;
	s_player_upgradestorage = -1;
	s_player_Drinkfromhands = -1;
	
	// EPOCH ADDITIONS
	s_player_packvault = -1;
	s_player_lockvault = -1;
	s_player_unlockvault = -1;
	s_player_showname = -1;
	s_player_parts_crtl = -1;
	s_player_information = -1;
	s_player_fuelauto = -1;
	s_player_fuelauto2 = -1;
	s_player_fillgen = -1;
	s_player_upgrade_build = -1;
	s_player_maint_build = -1;
	s_player_downgrade_build = -1;
	s_player_towing = -1;
	s_halo_action = -1;
	s_player_SurrenderedGear = -1;
	s_player_maintain_area = -1;
	s_player_maintain_area_force = -1;
	s_player_maintain_area_preview = -1;
	s_player_heli_lift = -1;
	s_player_heli_detach = -1;
	s_player_lockUnlock_crtl = -1;
	s_player_lockUnlockInside_ctrl = -1;
	s_player_toggleSnap = -1;
	s_player_toggleSnapSelect = -1;
	s_player_toggleSnapSelectPoint = [];
	snapActions = -1;
	s_player_plot_boundary = -1;
	s_player_plotManagement = -1;
	s_player_toggleDegree = -1;
	s_player_toggleDegrees=[];
	degreeActions = -1;
	s_player_toggleVector = -1;
	s_player_toggleVectors=[];
	vectorActions = -1;
	s_player_manageDoor = -1;
	// VM
	s_player_vaultma = -1;
	
	// Custom below
	s_givemoney_dialog = -1;
	s_bank_dialog = -1;
	s_player_checkWallet = -1;
	s_bank_dialog1 = -1;
	s_bank_dialog2 = -1;
	s_player_copyToKey = -1;
	s_player_claimVehicle = -1;
	s_garage_dialog = -1;
	s_player_gdoor_opener = [];
	s_player_gdoor_opener_ctrl = -1;
	s_player_butcher_human = -1;
	s_player_bury_human = -1;
	s_player_zhide2 = -1;
	s_player_cleanguts = -1;
	s_player_hotwirevault = -1;
	s_player_clothes = -1;
	s_player_evacChopper = [];
	s_player_evacChopper_ctrl = -1;
	BTC_liftActionId = -1;
	BTC_liftHudId = -1;
	s_player_zhide4 = -1;
	s_player_zhide5 = -1;
	s_player_zedsr = -1;
	
};
call dayz_resetSelfActions;