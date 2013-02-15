package {
	import sogamo.sogamoConnector;//Unique class needed to use Sogamo//****************************SOGAMO****************************
	
	import sogamo.events.sogamoEvent;//In case you want to detect connection and errors//****************************SOGAMO****************************
	
	import com.bit101.components.PushButton;//http://code.google.com/p/minimalcomps/
	import com.bit101.components.InputText;//http://code.google.com/p/minimalcomps/
	import com.bit101.components.Label;//http://code.google.com/p/minimalcomps/
	
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class main extends MovieClip {//set this class as the main for your flash doc

		/* This example uses Minimal Comps (//http://code.google.com/p/minimalcomps/) Please download the package in order to try this sample
		 * The specific sogamo's code is fallowed by //****************************SOGAMO****************************
		 */
		
		private var _sogamo:sogamoConnector;//****************************SOGAMO****************************
		
		private var _api_id:String = "api_key"; //API ID from Sogamo 70be281adf2a4051a4e9d1c7fe9978ec
		private var _user_id:String = "flash_test_id";
		
		private var _inputApiId_label:Label;
		private var _inputApiId:InputText;
		
		private var _inputUserId_label:Label;
		private var _inputUserId:InputText;
		
		private var _connectButton:PushButton;
		
		public function main():void {
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(event:Event = null):void {
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_sogamo = new sogamoConnector();
			_sogamo.addEventListener(sogamoEvent.CONNECTED, onSogamoConnected);// We could fire some action once we get a connection, but we start to track events righ way sicne the API has a buffer//****************************SOGAMO****************************
			_sogamo.addEventListener(sogamoEvent.ERROR_SESSION, onSogamoErrorSession);//****************************SOGAMO****************************
			
			_connectButton = new PushButton(this, 0, 0, "Connect", connect);
			_connectButton.x = (stage.stageWidth - _connectButton.width) / 2;
			_connectButton.y = (stage.stageHeight - _connectButton.height) / 2;
			
			_inputApiId_label = new Label(this, 0, 0, "API ID : ");
			_inputApiId_label.x = 35;
			_inputApiId_label.y = 40;
			
			_inputApiId = new InputText(this, 0, 0, _api_id, null);
			_inputApiId.width = 180;
			_inputApiId.x = 70;
			_inputApiId.y = 40;
			
			_inputUserId_label = new Label(this, 0, 0, "USER ID : ");
			_inputUserId_label.x = 25;
			_inputUserId_label.y = 65;
			
			_inputUserId = new InputText(this, 0, 0, _user_id, null);
			_inputUserId.width = 180;
			_inputUserId.x = 70;
			_inputUserId.y = 65;
			
		}
		private function onSogamoConnected(e:sogamoEvent):void {//****************************SOGAMO****************************
			_sogamo.removeEventListener(sogamoEvent.CONNECTED, onSogamoConnected);//****************************SOGAMO****************************
			
			var _inviteSentButton:PushButton = new PushButton(this, 0, 0, "Sent Invitation", inviteSent);
			_inviteSentButton.x = (stage.stageWidth / 2) - (_inviteSentButton.width + 10);
			_inviteSentButton.y = (stage.stageHeight / 2) - (_connectButton.height + 5);
			
			var _playerActionButton:PushButton = new PushButton(this, 0, 0, "Player Action", playerAction);
			_playerActionButton.x = (stage.stageWidth / 2) + 10;
			_playerActionButton.y = (stage.stageHeight / 2) - (_playerActionButton.height + 5);
			
			var _suggestionButton:PushButton = new PushButton(this, 0, 0, "Get Suggestion", suggestionAction);
			_suggestionButton.x = (stage.stageWidth - _playerActionButton.width) / 2;
			_suggestionButton.y = (stage.stageHeight / 2) + 5;
		}
		private function onSogamoErrorSession(e:sogamoEvent):void {//****************************SOGAMO****************************
			addChild(_inputApiId_label);
			addChild(_inputApiId);
			addChild(_inputUserId_label);
			addChild(_inputUserId);
			addChild(_connectButton);
		}
		private function connect(e:MouseEvent):void {
			//You can start to place events right away or even before connect to the api
			_sogamo.trackInviteSent(100, "user_final");//Sent track to Sogamo//****************************SOGAMO****************************
			_sogamo.API(_inputApiId.text, _inputUserId.text);//API connection//****************************SOGAMO****************************
			
			removeChild(_inputApiId_label);
			removeChild(_inputApiId);
			removeChild(_inputUserId_label);
			removeChild(_inputUserId);
			removeChild(_connectButton);
		}
		private function inviteSent(e:MouseEvent):void {
			_sogamo.trackInviteSent(1, "user_1, user_2, user_3");//Sent track to Sogamo//****************************SOGAMO****************************
		}
		private function playerAction(e:MouseEvent):void {
			_sogamo.trackPlayerAction("click", true, "User clicked on button");//Sent track to Sogamo//****************************SOGAMO****************************
		}
		private function suggestionAction(e:MouseEvent):void {
			_sogamo.getSuggestion("buy", suggestionReceiver);//Get Suggestion from Sogamo//****************************SOGAMO****************************
		}
		public function suggestionReceiver($val:String):void {
			trace("suggestionReceiver " + $val);
		}
	}
}