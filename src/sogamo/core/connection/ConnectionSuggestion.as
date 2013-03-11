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
	
	import sogamo.core.storage.suggestionStorage;
	
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
	 * Class used to get suggestions from <strong>SOGAMO's system</strong>.
	 * 
	 * NOTE : In case u use a compiler for versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib.
	 * <p><strong>Copyright (c) 2013 ZelRealm Interactive Pte Ltd.</strong> Visit <a href="http://sogamo.com">http://sogamo.com</a> for documentation, updates and examples. </p>
	 */
	public class ConnectionSuggestion extends Connection {
		private var _requestServer:URLRequest = new URLRequest();
		private var _loaderServer:URLLoader = new URLLoader();
		private var _errorTimer:Timer = new Timer(10000, 1);
		private var _available:Boolean = true;
		private var _suggestionStorage:suggestionStorage;
		
		 /**
		 * Constructor
		 * 
         * @param    $system                   reference to the main <strong>SOGAMO</strong> class
		 * @return none
		 * 
         * Connects to <strong>SOGAMO's system</strong> to get suggestions.
		 * 
		 * <strong>NOTE</strong> : For versions below Flash Player 11.0 or AIR 3.0 please replace the native JSON class with the JSON class from as3corelib
         */
		public function ConnectionSuggestion($system:sogamoSystem):void {
			_system = $system;
			
			//_requestServer.method = URLRequestMethod.POST;
			_requestServer.method = URLRequestMethod.GET;
			_requestServer.requestHeaders.push( new URLRequestHeader( 'Content-type', 'application/x-www-form-urlencoded' ) );
			
			//_suggestionStorage = new dataStorage();
			_suggestionStorage = new suggestionStorage();
			
			_loaderServer.addEventListener( Event.COMPLETE, onDataCompleted, false, 0, true );
			_loaderServer.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onDataSecurityError, false, 0, true );
			_loaderServer.addEventListener( IOErrorEvent.IO_ERROR, onDataIOError, false, 0, true );
			
            _errorTimer.addEventListener(TimerEvent.TIMER_COMPLETE, completeErrorTimer);
			
			//super($system, false);//send system used and false as we don't requiere local Storage for Suggestions;
		}
        private function completeErrorTimer(e:TimerEvent):void {
			_available = true;
			checkStorage();
        }
		
		/**
		 * Receives a type and a function to call once we get response from <strong>SOGAMO's system</strong> based on type.
		 * 
         * @param    $type                     Suggestion Type
         * @param    $suggestionCallback       Function to call once we get a response from server
		 * @return   none
         */	
		public override function getSuggestion($type:String, $callback:Function):void {
			var params:Object = new Object();
			
			params["apiKey"] = encodeURIComponent(_system.apiKey);
			params["playerId"] = _system.playerID;//******** Already filled with the right one as you only can get here if you've received response from server
			params["suggestionType"] = encodeURIComponent($type);
			params["callback_function"] = $callback;
			
			_suggestionStorage.enqueue( { data:params } );
			checkStorage();
		}
		
		/**
         * Reviews the data queue requesting the next suggestion if there's one.
		 * 
		 * @return none
		 * 
         */
		public override function checkStorage():void {
			if (!_suggestionStorage.isEmpty() && _available) {
				
				_available = false;
				
				_errorTimer.stop();
				
				var data:Object = _suggestionStorage.peek();
				
				var variables:URLVariables = new URLVariables();
				for (var key:String in data.data) {
					variables[key] = encodeURIComponent(data.data[key]);
				}
				_requestServer.data = variables;
				
				_requestServer.url = _url;
				
				_loaderServer.load(_requestServer);
				
			}
		}
		
		private function onDataCompleted(e:Event):void {
			if (e.currentTarget.data != "") {//If empty data, no proceed to JSON parsing
				var serverData:Array = String(JSON.parse(e.currentTarget.data).suggestion).split(",");
				var localData:Object = _suggestionStorage.peek();
				if (serverData.length != 0 ) {
					localData.data["callback_function"].apply(null, serverData);
				}else {
					_system.dispatchEvent(new sogamoEvent(sogamoEvent.SUGGESTION_EMPTY, null));
				}
			}else {
				_system.dispatchEvent(new sogamoEvent(sogamoEvent.SUGGESTION_EMPTY, null));
			}
			_suggestionStorage.dequeue();//remove the value sent
			_available = true;
			checkStorage();
		}
		private function onDataSecurityError(event:SecurityErrorEvent):void {
			_errorTimer.reset();
			_errorTimer.start();	
		}
		private function onDataIOError(event:IOErrorEvent):void {
			_errorTimer.reset();
			_errorTimer.start();
		}
	}
}