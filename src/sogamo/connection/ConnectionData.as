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
	
	import sogamo.core.dataStorage;
	import sogamo.core.sogamoSystem;
	
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
	 * Class used to send the tracks to Sogamo
	 */
	
	public class ConnectionData extends Connection {
		/** @protected */
		protected var _requestServer:URLRequest = new URLRequest();
		/** @protected */
		protected var _loaderServer:URLLoader = new URLLoader();
		/** @protected */
		protected var _dataStorage:dataStorage;
		/** @private */
		private var _timer:Timer = new Timer(10000, 1);
		
		protected var _available:Boolean = true;
		//protected var _system:sogamoSystem;
		
		/**
         * ConnectionData
         * Connects to sogamo server to send the data
         * @param    $system                   reference to the main sogamo class
		 * @return none
         */
		public function ConnectionData($system:sogamoSystem):void {
			_system = $system;
			
			_requestServer.method = URLRequestMethod.POST;
			_requestServer.requestHeaders.push( new URLRequestHeader( 'Content-type', 'application/x-www-form-urlencoded' ) );
			
			_dataStorage = new dataStorage();
			
			_loaderServer.addEventListener( Event.COMPLETE, onDataCompleted, false, 0, true );
			_loaderServer.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onDataSecurityError, false, 0, true );
			_loaderServer.addEventListener( IOErrorEvent.IO_ERROR, onDataIOError, false, 0, true );
			
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeTimer);

		}
		/**
         * completeTimer
         * Reconnect to server in case of error to send track
		 * @return none
         */
        private function completeTimer(e:TimerEvent):void {
			_available = true;
			checkStorage();
        }
		/**
         * send
         * Send track to Sogamo
         * @param    $type                   the track used
         * @param    $data                   content of the track
         * @param    $data                   mainly used internally to put tracks at top of the etrics queue
		 * @return none
         */
		public override function send($type:String, $data:Object, $priority:Boolean = false):void {
			$priority ? _dataStorage.priority( { type:$type, data:$data } ) : _dataStorage.enqueue( { type:$type, data:$data } );
			checkStorage();
		}
		/**
         * checkStorage
         * Review the tracks queue and send the next track on the list
		 * @return none
         */
		public override function checkStorage():void {
			if(!_dataStorage.isEmpty() && _available && _system.sessionID != ""){
				_available = false;
				
				_timer.stop();
				
				var data:Object = _dataStorage.peek();
				
				var variables:URLVariables = new URLVariables();
				for (var key:String in data.data) {
					switch(key) {
						case "callback_function":
							break;
						case "sessionId":
							variables[key] = encodeURIComponent(_system.sessionID);
							break;
						case "playerId":
							variables[key] = encodeURIComponent(_system.playerID);
							break;
						case "gameId":
							variables[key] = encodeURIComponent(_system.gameID);
							break;
						default:
							variables[key] = encodeURIComponent(data.data[key]);
							break;
					}
				}
				_requestServer.data = variables;
				
				_requestServer.url = _url + data.type;
				_loaderServer.load(_requestServer);
			}
		}
		/**
         * onDataCompleted
         * Data send to server
		 * @return none
         */
		protected function onDataCompleted(e:Event):void {
			_dataStorage.dequeue();//remove the value sent
			_available = true;
			checkStorage();
		}
		/** @private */
		private function onDataSecurityError(event:SecurityErrorEvent):void {
			_timer.reset();
			_timer.start();	
		}
		/** @private */
		private function onDataIOError(event:IOErrorEvent):void {
			_timer.reset();
			_timer.start();
		}
	}
}