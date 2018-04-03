#define CMP(file) compile preprocessFileLineNumbers ("custom\compile\"+file);
#define CALLCMP(file) call compile preprocessFileLineNumbers ("custom\compile\"+file);

if (!isDedicated) then {
	fnc_usec_selfactions = CMP("fn_selfActions.sqf")
	fnc_usec_unconscious = CMP("fn_unconscious.sqf") // Fixes for 1.0.6.3
	player_updateGui = CMP("player_updateGui.sqf")
	player_onPause = CMP("player_onPause.sqf")
	player_death = CMP("player_death.sqf")
	
	dz_fn_switchWeapon = CMP("switchWeapon\dz_fn_switchWeapon.sqf")
	dz_fn_switchWeapon_find = CMP("switchWeapon\dz_fn_switchWeapon_find.sqf")
	
	player_selectSlot = CMP("ui_selectSlot.sqf")
	
	vaultAddFriend = compile preprocessFileLineNumbers "scripts\vm\vaultAddFriend.sqf";
	vaultGetFriends = compile preprocessFileLineNumbers "scripts\vm\vaultGetFriends.sqf";
	vaultNearbyHumans = compile preprocessFileLineNumbers "scripts\vm\vaultNearbyHumans.sqf";
	vaultRemoveFriend = compile preprocessFileLineNumbers "scripts\vm\vaultRemoveFriend.sqf";
	
	if (GTS_RestrictBuilding) then {
		dze_buildChecks = CMP("dze_buildChecks.sqf")
	};
	
	if (GTS_RemoteVehicle) then {
		remoteVehicle = compile preprocessFileLineNumbers "scripts\remoteVehicle\remoteVehicle.sqf";
	};
	
	if (GTS_Hotkey && GTS_HotkeyHUD) then {
		CALLCMP("hotkeys.sqf")
	};
};
DZ_KeyDown_EH = CMP("keyboard.sqf")
fnc_usec_damageHandler = CMP("fn_damageHandler.sqf")
player_humanityChange = CMP("player_humanityChange.sqf")

echoMsg = {
	/**
		Описание:
		Выводит локализированное сообщение в один из чатов.
		
		Использование:
		"STR_MY_MESSAGE" call echoMsg;  // cut text
		["STR_MY_MESSAGE", "sys"] call echoMsg; // system chat with prepend
    */
	private ["_prepend","_msg","_type","_prependEnabled"];
	_prepend  = if (GTS_Prepend != "") then { GTS_Prepend } else { "" };
	
	if (typeName _this == "ARRAY") then {
		_msg = _this select 0;
		_type = _this select 1;
		_prependEnabled = _this select 2;
		
		if (!_prependEnabled) then { _prepend = "" };
	} else {
		_msg = _this; _type = 1;
	};
	
	if (["STR_", _msg] call fnc_inString) then {
		_msg = localize _msg;
	};
	
	if (_type == 1) exitWith {
		[_msg] spawn {
			10 cutText [format ["\n%1", _this select 0],"PLAIN DOWN"];
			uiSleep 3.5;
			10 cutFadeOut 1;
		};
	};
	if (_type == 2) exitWith { systemChat (_prepend+_msg) };
};

getPistol = {
	/**
		Описание:
		Ищет пистолета в инвентаре игрока.
		
		Возвращает:
		String (наименование пистолета, если он есть в инвентаре, или пустую строку, если нет).
		
		Использование:
		_pistol = call getPistol;
    */

	private "_pistol";
	_pistol = "";
	{ if ((getNumber (configFile >> "CfgWeapons" >> _x >> "Type")) == 2) exitWith { _pistol = _x }; } forEach weapons player;
	_pistol
};
	
DZE_SafeZonePosCheck = {
	private ["_position","_skipPos"];
	_position = _this select 0;
	_skipPos = false;

	if (!DZE_SafeZoneZombieLoot || count _this > 1) then {
		{
			if ((_position distance (_x select 0)) < (if (count _this > 1) then {_this select 1} else {_x select 1})) exitWith {_skipPos = true;};
		} forEach DZE_SafeZonePosArray;
	};
	_skipPos;
};

fnc_remote_message = {
  private ["_type","_message"];
  _type = _this select 0;
  _message = _this select 1;
  call {
    if (_type == "radio") exitWith {
		if (player hasWeapon "ItemRadio") then {
			if (player getVariable["radiostate",true]) then {
				systemChat _message;
				playSound "Radio_Message_Sound";
			};
        };
    };
    if (_type == "IWAC") exitWith {
		if (getPlayerUID player == (_message select 0)) then {
			if (player hasWeapon "ItemRadio") then {
				if (player getVariable["radiostate",true]) then {
					(_message select 1) call dayz_rollingMessages;
					playSound "IWAC_Message_Sound";
				};
			};
        };
    };
    if (_type == "private") exitWith {if(getPlayerUID player == (_message select 0)) then {systemChat (_message select 1);};};
    if (_type == "global") exitWith {systemChat _message;};
    if (_type == "hint") exitWith {hint _message;};
    if (_type == "titleCut") exitWith {titleCut [_message,"PLAIN DOWN",3];};
    if (_type == "titleText") exitWith {titleText [_message, "PLAIN DOWN"]; titleFadeOut 10;};
    if (_type == "rollingMessages") exitWith {_message call dayz_rollingMessages;};
    if (_type == "dynamic_text") exitWith {
      [
        format ["<t size='0.40' color='#FFFFFF' align='center'>%1</t><br /><t size='0.70' color='#d5a040' align='center'>%2</t>",_message select 0,_message select 1],
        0,
        0,
        10,
        0.5
      ] spawn BIS_fnc_dynamicText;
    };
	if (_type == "msgWithPos") exitWith {
		_pos = _this select 2;
		_missionType = _this select 3;
		
		waitUntil {uiSleep 1; (diag_tickTime - lastMissionMsgTime) > 13};
		
		[
			format ["
					<t size='0.35' color='#FFFFFF' align='left'>%1</t>
					<br/>
					<t size='0.60' color='#d5a040' align='left'>%2</t>
					",
					_message select 0,
					_message select 1
			],
			safeZoneX + safeZoneW * 0.17570755,
			safeZoneY + safeZoneH * 0.02708334,
			10,
			0.5
		 ] spawn BIS_fnc_dynamicText;
		 
		if (!isNil "_missionType" && {_missionType == "patrol"}) then {
			lastMissionMsgTime = diag_tickTime;
		} else {
			if (!isNil "_pos") then {
				_pos spawn GTS_ShowMissionPos;
			};
		};
		
    };
  };
};
"RemoteMessage" addPublicVariableEventHandler {(_this select 1) spawn fnc_remote_message;};

/*
 (getPosATL player) spawn GTS_ShowMissionPos;
 -200 spawn GTS_ShowHumChangeMsg;
 */
if (GTS_MissionPosMsg) then {
	GTS_ShowMissionPos = {
		private ["_pos","_display","_mapCtrl"];
		disableSerialization;
		_pos = _this;
		
		lastMissionMsgTime = diag_tickTime;
		playSound "Radio_Message_Sound";
		
		13 cutRsc ["MissionMessage", "PLAIN", 0.5];
		_display = uiNamespace getVariable "MissionMessage";
		_mapCtrl = _display displayCtrl 12102;
		_mapCtrl ctrlMapAnimAdd [7,.35,_pos];
		ctrlMapAnimCommit _mapCtrl;
		uiSleep 10.5;
		
		waitUntil {uiSleep .1; ctrlMapAnimDone _mapCtrl}; 
		
		ctrlMapAnimClear _mapCtrl;
		13 cutFadeout 2; 
	};
};
if (GTS_HumChangeMsg) then {
	GTS_ShowHumChangeMsg = {
		private ["_humChange","_msg","_color"];
		_humChange = _this;
		_msg = "Падший";
		_color = "";
		
		[
			format ["<t size='0.50' color='#dde047' align='left'>%1</t><t size='0.70' color='#429bf4' align='left'>%2</t>",_humChange,_msg],
			0,
			0,
			5,
			0.5,
			0.25,
			14
		] spawn BIS_fnc_dynamicText;
	};
};