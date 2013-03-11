/*
* Sogamo
* Visit http://sogamo.com/ for documentation, updates and examples.
* 
* Author Oscar Arotaype Herrera 
* email : developers@sogamo.com 
* 
* 
* Copyright (c) 2013 ZelRealm Interactive Pte Ltd.
* 
*/

package sogamo.core {
	
	import sogamo.sogamoConfigurator;
	
	import sogamo.core.connection.Connection;
	import sogamo.core.connection.ConnectionData;
	import sogamo.core.connection.ConnectionSession;
	import sogamo.core.connection.ConnectionSuggestion;
	
	import sogamo.events.sogamoEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/** Dispatched when connected to <strong>SOGAMO's system</strong>(we have session ID). **/
	[Event(name="CONNECTED", 		type="sogamo.events.sogamoEvent")]
	/** Dispatched when the system experiences an ERROR_SESSION while connecting, check the event's <code>data</code> variable for more details about the error type. **/
	[Event(name="ERROR_SESSION", 	type="sogamo.events.sogamoEvent")]
	
	/** Dispatched when the data is sent to <strong>SOGAMO's system.</strong> **/
	[Event(name="DATA_SENT", 	    type="sogamo.events.sogamoEvent")]
	/** Dispatched when the data is not saved on <strong>SOGAMO's system</strong>, the system will try to send the data continuosly until save it, check the event's <code>data</code> variable for more details about the error type. **/
	[Event(name="ERROR_DATA", 	    type="sogamo.events.sogamoEvent")]
	
	/** Dispatched when the system experiences a problem storing the data locally, which could mean that the space is full or the user has disabled access to local storage, check the event's <code>data</code> variable for more details about the error type. **/
	[Event(name = "DATA_STORAGE_ERROR", 	type = "sogamo.events.sogamoEvent")]
	
	/** Dispatched when the no suggestion is received for <code>getSuggestion</code> call. **/
	[Event(name="SUGGESTION_EMPTY", 	type="sogamo.events.sogamoEvent")]
	
	/**
	 * SOGAMO's Core Class, no modify this class(use the sogamoConnector instead).
	 * 
	 * <p><strong>Copyright (c) 2013 ZelRealm Interactive Pte Ltd.</strong> Visit <a href="http://sogamo.com">http://sogamo.com</a> for documentation, updates and examples. </p>
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
		
		private var _configurator:sogamoConfigurator;
		
		 /**
		 * Constructor
		 * 
         * @param    $conf                     Configurator class to change the default properties of the system (like update method or times to use)
		 * @return   none
		 * 
		 * Starts the <strong>SOGAMO</strong> API
         */
		public function sogamoSystem($conf:sogamoConfigurator = null):void {
			if ($conf != null) {
				_configurator = $conf;
			}else {
				_configurator = new sogamoConfigurator();
			}
			
			_connectionSession = new ConnectionSession(this, onConnected);
			_connectionSession.url = "http://auth.sogamo.com";
			
			_connectionData = new ConnectionData(this);
			
			_connectionSuggestion = new ConnectionSuggestion(this);
			_connectionSuggestion.url = "http://sogamo-x10.herokuapp.com/";
		}
		/**
         * Connects to system to get session ID, this class is for internal use.
		 * 
         * @param    $apiKey                   The API key for your game. This can be found in <strong>SOGAMO'</strong> dashboard.
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
         * @param    $status                   Player’s status: New Old This is so that <strong>SOGAMO</strong> does not mistake an old player as new, because player can be new to our system but have been playing your game for some time.
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
         * Called by ConnectionSession once we get session ID.
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
			
			_connectionData.url = _base_protocol + _base_url + "batch";//Used by JSON
			
			_trackPlayerParams["session_id"] = _sess_id;//can be placed on ConnectionData
			_connectionData.send("session.login_datetime", _trackPlayerParams, true);
			
			_connectionSuggestion.checkStorage();//in case a suggestion call was made before login
			
			dispatchEvent(new sogamoEvent(sogamoEvent.CONNECTED, null));
		}
		/**
         * Generic method to send the tracks.
		 * 
         * @param    $type                     The track to be used
         * @param    $data                     Track's data
		 * @return   none
         */	
		protected function send($type:String, $data:Object):void {
			_connectionData.send($type, $data);
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
		 * getSuggestion returns an object from server based on type, a function needs to be provided as parameter since this one will get the response from the server.
		 * 
         * @param    $type                     Suggestion Type
         * @param    $suggestionCallback       Function to call once we get a response from server, this function must support the same number of parameters sent by the server on string format.
		 * @return   Boolean                   Indicates if the operation was able to be completed or no(no player id set)
         */
		public function getSuggestion($type:String, $suggestionCallback:Function):Boolean {
			if (_player_id != "") {
				_connectionSuggestion.getSuggestion($type, $suggestionCallback);
				return true;
			}else {
				return false;
			}
		}
		
		/**
		 * sendData used to send the data to the server when the update method is set to manual.
		 * 
         * @return   Boolean                    Indicates if the operation was able to be completed or no(update method not set to manual, session_id empty, performing update currently due to a previous manual call)
         */
		public function sendData():Boolean {
			if (_configurator.UpdateType == sogamoConfigurator.MANUAL && _sess_id != "") {//if update type is manual and session id is available we make the call
				_connectionData.checkStorage();
				return true;
			}else {
				return false;//no manual method enabled or sess_id null
			}
		}
		
		/**
         * Returns the API Key.
		 * 
		 * @return String
         */	
		public function get apiKey():String {
			return _api_key;
		}
		
		/**
         * Returns the Game ID.
		 * 
		 * @return String
         */	
		public function get gameID():String {
			return _s_app_id;
		}
		
		/**
         * Returns the Session ID.
		 * 
		 * @return String
         */	
		public function get sessionID():String {
			return _sess_id;
		}
		
		/**
         * Returns the Player ID.
		 * 
		 * @return String
         */
		public function get playerID():String {
			return _player_id;
		}
		
		/**
         * Returns the Configurator class.
		 * 
		 * @return String
         */
		public function get configurator():sogamoConfigurator {
			return _configurator;
		}
		
		/**
         * Method to convert to Unix Time. Used internally by the system to convert all the dates.
		 * 
		 * @param    $date                     Date value to convert
		 * @return String
         */
		public static function convertToUnix($date:Date):String {
			return String(Math.round($date.getTime() / 1000));
		}
		
		/**
         * Method to convert to UTC time on javascript format - NO USED, replaced by UNIX.
		 * 
		 * @param    $date                     Date value to convert
		 * @return String
         */
		public static function convertToUTC($date:Date):String {
			return $date.getUTCFullYear() + "-" + $date.getUTCMonth() + "-" + $date.getUTCDate() + "T" + $date.getUTCHours() + ":" + $date.getUTCMinutes() + ":" + $date.getUTCSeconds() + "+0000";
		}
	}
}