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
	
	import sogamo.sogamoConfigurator;
	
	import sogamo.core.sogamoSystem;
	import sogamo.core.Base64;
	
	import sogamo.core.connection.Connection;
	
	import sogamo.events.sogamoEvent;
	
	import flash.net.URLVariables;
	
	import flash.net.URLLoader;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	import flash.net.SharedObject;
    import flash.net.SharedObjectFlushStatus;
	
	import flash.utils.Timer;
	import flash.utils.ByteArray;
    
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	
	/**
	 * Class used to send the tracks to <strong>SOGAMO's system</strong>.
	 * 
	 * NOTE : In case u use a compiler for versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib.
	 * <p><strong>Copyright (c) 2013 ZelRealm Interactive Pte Ltd.</strong> Visit <a href="http://sogamo.com">http://sogamo.com</a> for documentation, updates and examples. </p>
	 */
	public class ConnectionData extends Connection {
		
		private var _requestServer:URLRequest = new URLRequest();
		private var _loaderServer:URLLoader = new URLLoader();
		private var _errorTimer:Timer = new Timer(10000, 1);
		
		private var _checkStorageTimer:Timer = new Timer(10000);//Used for update timer method
		
		private static var DATA_SENDING:uint = 1;//this track was sent and we're waiting response for erasing it
		private static var DATA_WAITING:uint = 0;//this track is waiting to be sent
		
		private var _dataStorage:Array;
		private var _localStorage:SharedObject;
		
		private var _availableLocalDataStorage:Boolean;
		
		private var _available:Boolean = true;
		
		 /**
		 * Constructor
		 * 
         * @param    $system                   reference to the main SOGAMO's class
		 * @return   none
		 * 
         * Connects to <strong>SOGAMO's system</strong> to send the tracks.
		 * 
		 * <strong>NOTE</strong> : For versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib
         */
		public function ConnectionData($system:sogamoSystem):void {
			_system = $system;
			
			_requestServer.method = URLRequestMethod.POST;
			_requestServer.requestHeaders.push( new URLRequestHeader( 'Content-type', 'application/x-www-form-urlencoded' ) );
			
			_loaderServer.addEventListener( Event.COMPLETE, onDataCompleted, false, 0, true );
			_loaderServer.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onDataSecurityError, false, 0, true );
			_loaderServer.addEventListener( IOErrorEvent.IO_ERROR, onDataIOError, false, 0, true );
			
            _errorTimer.addEventListener(TimerEvent.TIMER_COMPLETE, completeErrorTimer);
			
			_checkStorageTimer.addEventListener(TimerEvent.TIMER, completeCheckStorageTimer);
			
			_dataStorage = new Array();
				
			if (_system.configurator.LocalStorageEnable) {
				try {
					_localStorage = SharedObject.getLocal("Sogamo_Local_Storage_Data");
					if (_localStorage.data.record == undefined) {
						_localStorage.data.record = new String();
					}else {
						_dataStorage = uncompress(_localStorage.data.record);
						if(_dataStorage == null) _dataStorage = new Array();
					}
					_availableLocalDataStorage = true;
				} catch (error:Error) {
					_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_DATA_STORAGE, "Cannot initialize local Storage Data"));
				}
			}
		}
		public function compress($var:Array):String {
			var b:ByteArray = new ByteArray();
			b.writeObject($var);
			b.compress();
			return Base64.Encode( b );
		}
		public function uncompress(str:String):Array {
			var result:Array = new Array();
			var b:ByteArray = Base64.Decode( str );
			b.uncompress();
			b.position=0;
			while(b.bytesAvailable>0){
				result.push(b.readObject());
			}
			return result[0]
		}
		
        private function flushdata():void {//Saves the data on the local storage system
			_localStorage.data.record = compress(_dataStorage);
			var flushStatus:String = null;
			try {
                flushStatus = _localStorage.flush(_system.configurator.LocalStorageSize * 1024);
            } catch (error:Error) {
				_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_DATA_STORAGE, "Cannot write local data"));
			}
            if (flushStatus != null) {
                switch (flushStatus) {
                    case SharedObjectFlushStatus.PENDING:
                        !_localStorage.hasEventListener(NetStatusEvent.NET_STATUS) ? _localStorage.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus) : null;
                        break;
                    case SharedObjectFlushStatus.FLUSHED:
                        break;
                }
            }
		}
		
		private function onFlushStatus(event:NetStatusEvent):void {
            switch (event.info.code) {
                case "SharedObject.Flush.Success":
                    break;
                case "SharedObject.Flush.Failed":
					_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_DATA_STORAGE, "User denied permission to increase local storage size"));
                    break;
            }
            _localStorage.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
        }
        private function completeErrorTimer(e:TimerEvent):void {//Reconnect to server in case of error to send tracks again
			_available = true;
			if (_system.configurator.UpdateType != sogamoConfigurator.TIMER) {//if no timer try to send the data again, in case of timer the next call to teh timer will send the data again
				checkStorage();
			}
        }
		
        private function completeCheckStorageTimer(e:TimerEvent):void {//Sents data to <strong>SOGAMO's system</strong> on time intervals.
			_available = true;
			checkStorage();
        }
		
		/**
         * Sends track to <strong>SOGAMO's system.</strong>
		 * 
         * @param    $type                   the track used
         * @param    $data                   content of the track
         * @param    $priority               mainly used internally to put tracks at top of the tracks queue
		 * @return   none
		 * 
         */
		public override function send($type:String, $data:Object, $priority:Boolean = false):void {//it is called automatically once we have sessionid value
			var i:uint = 0;
			if ($priority) {
				for (i = 0; i < _dataStorage.length; i++) {
					if (_dataStorage[i][0] != "old_data") {//we leave the old data always to the start on the queue
						_dataStorage.splice(i, 0, new Array($type, $data, ConnectionData.DATA_WAITING) );
						break;
					}
				}
				if(_dataStorage.length == 0) {
					_dataStorage.push(new Array($type, $data, ConnectionData.DATA_WAITING) );
				}
			}else {
				_dataStorage.push(new Array($type, $data, ConnectionData.DATA_WAITING) );
			}
			if(_system.sessionID != ""){//if we already have sessionID save on local storage system and continue(also means that we have game_id, player id is set by user)
				for (i = 0; i < _dataStorage.length; i++) {
					if (!(_dataStorage[i][1] is String)) {//if no Sring we need to convert it to JSON String
						for (var key:String in _dataStorage[i][1]) {
							switch(key) {
								case "playerId":
									_dataStorage[i][1][key] = _system.playerID;
									break;
								case "gameId":
									_dataStorage[i][1][key] = _system.gameID;
									break;
							}
						}
						_dataStorage[i][1]["sessionId"] = encodeURIComponent(_system.sessionID);
						_dataStorage[i][1]["action"] = _system.gameID + "." + _dataStorage[i][0];//game id + type
				
						//_dataStorage[i][1] = JSON.encode(_dataStorage[i][1]);// NOTE : below Flash Player 11.0 or AIR 3.0
						_dataStorage[i][1] = JSON.stringify(_dataStorage[i][1]);
					}
				}
				if (_availableLocalDataStorage) {
					flushdata();
					if (_system.configurator.UpdateType != sogamoConfigurator.AUTOMATIC && _localStorage.size > ((_system.configurator.LocalStorageSize * 1024) - 128)) {//if no automatic update method and the size of data is getting closer to the limit,send data utomatically
						checkStorage();
					}
				}
				
				if (_system.configurator.UpdateType == sogamoConfigurator.TIMER && !_checkStorageTimer.running) {//we have id, update timer method is used and  timer is not running
					_checkStorageTimer.delay = _system.configurator.TimerTime * 1000;
					_checkStorageTimer.start();
				}
				
				if (_system.configurator.UpdateType == sogamoConfigurator.AUTOMATIC) {
					checkStorage();
				}
			}
		}
		
		/**
		 * Reviews the tracks queue, builds the JSON data to be send to <strong>SOGAMO's system.</strong>
		 * 
		 * @return none
		 * 
         */
		public override function checkStorage():void {
			if (_available) {
				
				_available = false;
				_errorTimer.stop();
				if (_dataStorage.length > 0) {//if we have data
					
					var variables:URLVariables = new URLVariables();
					var i:uint = 0;
					for (i = 0; i < _dataStorage.length; i++) {
						variables[i] = _dataStorage[i][1];
						_dataStorage[i][2] = ConnectionData.DATA_SENDING;
					}
					_requestServer.data = variables;
					_requestServer.url = _url;
					
					_loaderServer.load(_requestServer);
				}
			}
		}
		protected function onDataCompleted(e:Event):void {
			var i:uint = 0;
			while(i < _dataStorage.length) {
				if (_dataStorage[i][2] == ConnectionData.DATA_SENDING) {
					_dataStorage.splice(i, 1);
				}else {
					i++;
				}
			}
			if (_availableLocalDataStorage) {//we update the local storage
				flushdata();
			}
			
			_system.dispatchEvent(new sogamoEvent(sogamoEvent.DATA_SENT, ""));
			
			if (_system.configurator.UpdateType != sogamoConfigurator.TIMER) {
				_available = true;
				_system.configurator.UpdateType == sogamoConfigurator.AUTOMATIC ? checkStorage() : null;
			}
		}
		private function onDataSecurityError(event:SecurityErrorEvent):void {
			_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_DATA, "SecurityError"));
			_errorTimer.reset();
			_errorTimer.start();
		}
		private function onDataIOError(event:IOErrorEvent):void {
			_system.dispatchEvent(new sogamoEvent(sogamoEvent.ERROR_DATA, "IOError"));
			_errorTimer.reset();
			_errorTimer.start();
		}
	}
}