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
package sogamo.connection {
	
	//import com.adobe.serialization.json.JSON; // NOTE : below Flash Player 11.0 or AIR 3.0
	
	import sogamo.core.sogamoSystem;
	
	import sogamo.events.sogamoEvent;
	
	import flash.net.URLVariables;
	
	import flash.net.URLLoader;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import flash.utils.Timer;
    
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	
	/**
	 * Class used to get the session id from sogamo.
	 * NOTE : In case u use a compiler for versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib
	 */
	
	public class ConnectionSession extends Connection {
		/** @private */
		private var _requestServer:URLRequest = new URLRequest();
		/** @private */
		private var _loaderServer:URLLoader = new URLLoader();
		/** @private */
		private var _timer:Timer = new Timer(10000, 1);
		/** @private */
		private var _onConnect:Function
		//protected var _system:sogamoSystem;
		
		/**
         * ConnectionData
         * Connects to sogamo server to get Session details
         * @param    $system                   reference to the main sogamo class
		 * @return none
         */
		public function ConnectionSession($system:sogamoSystem, $onConnect:Function ):void {
			_system = $system;
			_onConnect = $onConnect;
		}
		/**
         * connect
         * Connects to sogamo server sending API and player ids to retrieve the session ID
         * @param    $apiKey                   Application's API
         * @param    $player_id                Player ID
		 * @return none
         */
		public override function connect($apiKey:String, $player_id:String):void {
			_timer.stop();
			
			_requestServer.requestHeaders.push( new URLRequestHeader( 'Content-type', 'application/x-www-form-urlencoded' ) );
			
			_loaderServer.addEventListener( Event.COMPLETE, onDataCompleted, false, 0, true );
			_loaderServer.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onDataSecurityError, false, 0, true );
			_loaderServer.addEventListener( IOErrorEvent.IO_ERROR, onDataIOError, false, 0, true );
			
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeTimer);
			
			_requestServer.url = _url + "/?playerId=" + $player_id + "&apiKey=" + $apiKey;
				
			_loaderServer.load(_requestServer);
		}
		/** @private */
		private function onDataCompleted(e:Event):void {
			var serverData:Object = JSON.parse(e.currentTarget.data);
			if (serverData.hasOwnProperty("error")) {
				_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_SESSION, serverData.error));
			}else {
				_onConnect.call(null, serverData);
				//_system.onConnected(serverData);
			}
		}
		/** @private */
		private function onDataSecurityError(event:SecurityErrorEvent):void {
			_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_SESSION, "Security error"));
			_timer.reset();
			_timer.start();	
		}
		/** @private */
		private function onDataIOError(event:IOErrorEvent):void {
			_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_SESSION, "Data error"));
			_timer.reset();
			_timer.start();
		}
		/**
         * completeTimer
         * Reconnect to server in case of error to retrieve session ID
		 * @return none
         */
        private function completeTimer(e:TimerEvent):void {
			_loaderServer.load(_requestServer);
        }
	}
}