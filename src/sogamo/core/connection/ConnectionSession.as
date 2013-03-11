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

package sogamo.core.connection {
	
	//import com.adobe.serialization.json.JSON; // NOTE : below Flash Player 11.0 or AIR 3.0
	
	import sogamo.core.sogamoSystem;
	
	import sogamo.core.connection.Connection;
	
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
	 * Class used to get the session ID from <strong>SOGAMO's system</strong>.
	 * 
	 * NOTE : In case u use a compiler for versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib.
	 * <p><strong>Copyright (c) 2013 ZelRealm Interactive Pte Ltd.</strong> Visit <a href="http://sogamo.com">http://sogamo.com</a> for documentation, updates and examples. </p>
	 */
	public class ConnectionSession extends Connection {
		private var _requestServer:URLRequest = new URLRequest();
		private var _loaderServer:URLLoader = new URLLoader();
		private var _errorTimer:Timer = new Timer(10000, 1);
		private var _onConnect:Function;
		
		 /**
		 * Constructor
		 * 
         * @param    $system                   reference to the main <strong>SOGAMO</strong> class
		 * @return   none
		 * 
         * Connects to <strong>SOGAMO's system</strong> to get Session details.
		 * 
         * <strong>NOTE</strong> : For versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib
         */
		public function ConnectionSession($system:sogamoSystem, $onConnect:Function ):void {
			_system = $system;
			_onConnect = $onConnect;
		}
		
		/**
         * Connects to <strong>SOGAMO's system</strong> sending API and player ID to retrieve the session ID.
		 * 
         * @param    $apiKey                   Application's API
         * @param    $player_id                Player ID
		 * @return   none
         */
		public override function connect($apiKey:String, $player_id:String):void {
			_errorTimer.stop();
			
			_requestServer.requestHeaders.push( new URLRequestHeader( 'Content-type', 'application/x-www-form-urlencoded' ) );
			
			_loaderServer.addEventListener( Event.COMPLETE, onDataCompleted, false, 0, true );
			_loaderServer.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onDataSecurityError, false, 0, true );
			_loaderServer.addEventListener( IOErrorEvent.IO_ERROR, onDataIOError, false, 0, true );
			
            _errorTimer.addEventListener(TimerEvent.TIMER_COMPLETE, completeErrorTimer);
			
			_requestServer.url = _url + "/?playerId=" + $player_id + "&apiKey=" + $apiKey;
				
			_loaderServer.load(_requestServer);
		}
		private function onDataCompleted(e:Event):void {
			var serverData:Object = JSON.parse(e.currentTarget.data);
			if (serverData.hasOwnProperty("error")) {
				_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_SESSION, serverData.error));
			}else {
				_onConnect.call(null, serverData);
				//_system.onConnected(serverData);
			}
		}
		private function onDataSecurityError(event:SecurityErrorEvent):void {
			_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_SESSION, "Security error"));
			_errorTimer.reset();
			_errorTimer.start();	
		}
		private function onDataIOError(event:IOErrorEvent):void {
			_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_SESSION, "Data error"));
			_errorTimer.reset();
			_errorTimer.start();
		}
        private function completeErrorTimer(e:TimerEvent):void {
			_loaderServer.load(_requestServer);
        }
	}
}