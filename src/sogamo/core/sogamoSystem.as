/*
* Sogamo
* Visit http://sogamo.com/ for documentation, updates and examples.
* Author Oscar Arotaype Herrera 
* email : developers@sogamo.com 
*
* 
* Copyright (c) 2013 ZelRealm Interactive Pte Ltd.
*
*/

package sogamo.core {
	
	import sogamo.connection.Connection;
	import sogamo.connection.ConnectionData;
	import sogamo.connection.ConnectionSession;
	import sogamo.connection.ConnectionSuggestion;
	
	import sogamo.events.sogamoEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Core of sogamo's system
	 */
	
	public class sogamoSystem extends EventDispatcher {
		
		private var _connectionSession:Connection;
		private var _connectionData:Connection;
		private var _connectionSuggestion:Connection;
		
		private var _api_key:String = "";
		private var _player_id:String = "";
		private var _game_url:String = "";
		private var _app_id:String = "";
		private var _sess_id:String = "";
		private var _s_app_id:String = "";//game_id
		
		private var _base_url:String = "";
		private var _base_protocol:String = "http://";
		
		private var _trackPlayerParams:Object = new Object();
		
		private var _sessionStorage:Object = new Object();
		
		/**
         * Sets url to the system which will return the session id
		 * @return none
         */
		public function sogamoSystem():void {
			_connectionSession = new ConnectionSession(this, onConnected);
			_connectionSession.url = "http://auth.sogamo.com";
			
			_connectionData = new ConnectionData(this);
			
			_connectionSuggestion = new ConnectionSuggestion(this);
			_connectionSuggestion.url = "http://sogamo-x10.herokuapp.com/";
		}
		/**
         * Connects to system to get session ID, this class is for internal use
         * @param    $apiKey                   The API key for your game. This can be found in Sogamo dashboard.
         * @param    $player_id                The player’s player ID. For Facebook games, we recommend that you use the player’s Facebook ID. Otherwise, this can be the player ID that you assign to the player.
         * @param    $username                 The player’s username. For Facebook games, we recommend that you use the player’s Facebook username. Otherwise, this can be the username that the player chooses, or left null if not applicable.
         * @param    $firstname                The player’s first name
         * @param    $lastname                 The player’s last name
         * @param    $dob                      The player’s date of birth in the format of MM-DD-YYYY. Example: 02-20-1980
         * @param    $gender                   The player’s gender, which is either male or female. Example: male
         * @param    $signup_datetime          The date that the player signed up to play your game.
         * @param    $updated_datetime         The date that the player last updated his details. The format is as in the example. For Facebook games, this is the “updated_time” field in the User object.
         * @param    $email                    The player’s e-mail address
         * @param    $relationship_status      The player’s relationship status: Single, In a relationship, Engaged, Married, It's complicated, In an open relationship, Widowed, Separated, Divorced, In a civil union, In a domestic partnership
         * @param    $number_of_friends        The player’s number of friends
         * @param    $status                   Player’s status: New Old This is so that Sogamo does not mistake an old player as new, because player can be new to our system but have been playing your game for some time.
         * @param    $credit                   Player’s Facebook credit balance
         * @param    $currency                 A comma-separated string containing all of player’s virtual currencies and balances Example: G=1,S=20,B=90
		 * @return   none
         */	
		protected function connect($apiKey:String, $player_id:String, $username:String, $firstname:String, $lastname:String, $dob:String, $gender:String, $signup_date:Date, $updated_date:Date, $email:String, $relationship_status:String, $no_of_frds:int, $status:String, $credit:int, $currency:String):void {
			_api_key = $apiKey;
			_player_id = $player_id;
			if (hasSession() != false) {
				cont(getSessionInfo("api_key"), getSessionInfo("player_id"), getSessionInfo("game_id"), getSessionInfo("session_id"), getSessionInfo("lc_url"));
			}else {
				_connectionSession.connect(_api_key, _player_id);
				//_connectionSession.addEventListener(sogamoEvent.CONNECTED, onConnected);
			}
			
			_trackPlayerParams["gameId"] = "";//Filled automatically      _s_app_id;
			_trackPlayerParams["player_id"] = _player_id;//Filled automatically if it would be playerID  _player_id;
			_trackPlayerParams["username"] = $username;
			_trackPlayerParams["firstname"] = $firstname;
			_trackPlayerParams["lastname"] = $lastname;
			_trackPlayerParams["dob"] = $dob;
			_trackPlayerParams["email"] = $email;
			_trackPlayerParams["gender"] = $gender;
			_trackPlayerParams["relationship_status"] = $relationship_status;
			_trackPlayerParams["signupDatetime"] = $signup_date;
			_trackPlayerParams["updatedDatetime"] = $updated_date;
			_trackPlayerParams["number_of_friends"] = $no_of_frds;
			_trackPlayerParams["status"] = $status;
			_trackPlayerParams["credit"] = $credit;
			_trackPlayerParams["currency"] = $currency;
			
			_trackPlayerParams["login_datetime"] = sogamoSystem.convertToUnix(new Date());
			_trackPlayerParams["last_active_datetime"] = sogamoSystem.convertToUnix(new Date());
		}
		/**
         * Called by ConnectionSession once we get session Id
         */
		private function onConnected($data:Object):void {
			_sess_id = $data['session_id'];
			_s_app_id = $data['game_id'];
			_base_url = $data['lc_url'];
			
			setSessionInfo("session_id", $data['session_id']);
			setSessionInfo("api_key", _api_key);
			setSessionInfo("game_id", $data['game_id']);
			setSessionInfo("player_id", _player_id);
			setSessionInfo("lc_url", $data['lc_url']);
							
			cont(_api_key, _player_id, $data['game_id'], getSessionInfo("session_id"), $data['lc_url']);
			
			_connectionData.url = _base_protocol + _base_url + "action." + _s_app_id + ".";
			
			_trackPlayerParams["session_id"] = _sess_id;//can be placed on ConnectionData
			_connectionData.send("session.login_datetime", _trackPlayerParams, true);
			
			_connectionSuggestion.checkStorage();//in case a suggestion call was made before login
			
			dispatchEvent(new sogamoEvent(sogamoEvent.CONNECTED, null));
		}
		/**
         * Generic method to send the tracks
         * @param    $type                     The track to be used
         * @param    $data                     Track's data
		 * @return   none
         */	
		protected function send($type:String, $data:Object):void {
			_connectionData.send($type, $data);
		}
		
		/**
		 * getSuggestion returns an object from server based on type, a function needs to be provided as parameter sicne this one will get the response from the server
         * @param    $type                     Suggestion Type
         * @param    $suggestionCallback       Function to call once we get a response from server, this function must support the same number of parameters sent by the server on string format
		 * @return   none
         */
		public function getSuggestion($type:String, $suggestionCallback:Function):void {
			_connectionSuggestion.getSuggestion($type, $suggestionCallback);
		}
		
		private function cont(apiKey:String, fb_player_id:String, game_id:String, session_id:String, lc_url:String):void {   
           	_api_key = apiKey; 				
			_player_id = fb_player_id;		
         
			_s_app_id = game_id;
			_sess_id = session_id;
			_base_url = lc_url;
		}
		private function hasSession():Boolean {
			return getSessionInfo("session_id") != null;
		}
		private function setSessionInfo(key:String, value:String):void {
			if(_api_key.length == 0 || _player_id.length == 0) return;
			_sessionStorage["sogamo_" + _api_key + "_" + _player_id + "_" + key] = value;
		}
		private function getSessionInfo(key:String):String {
			if(_api_key.length == 0 || _player_id.length == 0) return null;
			return _sessionStorage["sogamo_" + _api_key + "_" + _player_id + "_" + key];
		}
		
		/**
         * Returns the API Key
		 * @return String
         */	
		public function get apiKey():String {
			return _api_key;
		}
		
		/**
         * Returns the Game ID
		 * @return String
         */	
		public function get gameID():String {
			return _s_app_id;
		}
		
		/**
         * Returns the Session ID
		 * @return String
         */	
		public function get sessionID():String {
			return _sess_id;
		}
		
		/**
         * Returns the Player ID
		 * @return String
         */
		public function get playerID():String {
			return _player_id;
		}
		
		/**
         * Method to convert to Unix Time
		 * @param    $date                     Date value to convert
		 * @return String
         */
		public static function convertToUnix($date:Date):String {
			return String(Math.round($date.getTime()/1000));
		}
		
		/**
         * Method to convert to UTC time on javascript format - NO USED, replaced by UNIX
		 * @param    $date                     Date value to convert
		 * @return String
         */
		public static function convertToUTC($date:Date):String {
			//2012-09-11T13:52:31+0000
			return $date.getUTCFullYear() + "-" + $date.getUTCMonth() + "-" + $date.getUTCDate() + "T" + $date.getUTCHours() + ":" + $date.getUTCMinutes() + ":" + $date.getUTCSeconds() + "+0000";
		}
	}
}