/**
Copyright Shafique Arnab 2008
==============================
Class: Model
Purpose: Connect Other Classes & Call Required Functions
**/

import caurina.transitions.Tweener;

class lib.model {
	
	var myInterval;
	var actionDelay:Number = 1500;
	var xml:Object;
	var userText:Array = new Array(); // Array That Stored UserID's Based Upon Usernames
	var sitX:Array = [649,726,716,641,468,268,106,21,16,93]; // X-Coordinate of Chairs
	var sitY:Array = [35,130,238,340,411,411,340,238,130,35]; //Y-Coordinate of Chairs
	var flopX:Array = [257,312,367,422,477]; //X Coordinate of Flop Cards
	var flopY:Array = [116,116,116,116,116]; //Y Coordinate of Flop Cards
	var chipNames:Array = ['500','100','50','25','10','5']; //The Playable Chips
	var chipX:Array = [152,123,95,66,38,10]; //X Position Of Chips On The Pot (In Incremental Order)
	var tblX:Array = [];
	var tblY:Array = [];
	var actID:Number = -1; //Action ID//
	var inAction:Boolean = false; //If We Are Doing Something //
	var userCount:Number = 0; //User Count //
	var rowX:Array = [[458,482,506,530,554,578],[516,540,564,588,612,636],[535,559,583,607,631,655],[480,504,528,552,576,600],[407,431,455,479,503,527],[416,392,368,344,320,296],[345,321,297,273,249,225],[],[],[]];
	var rowY:Array = [[73,73,73,73,73,73],[130,130,130,130,130,130],[239,239,239,239,239,239],[293,293,293,293,293,293],[320,320,320,320,320,320],[320,320,320,320,320,320],[293,293,293,293,293,293],[],[],[]];
	var potX:Array = [500,476,452,428,404,380];
	var potY:Array = [203,203,203,203,203,203];
	var potRows:Number = 0;
	var inPause:Boolean = false;
	var inRestart:Boolean = false;
	
	public function model() {
		xml = new XML();
		xml.ignoreWhite = true;
		/*
			Loading Function Will Be Deprecated In The Future Upon Completion Of FlashVars
		**/
		// Load The XML Document //
		xml.load("assets/poker.xml");
		// Set Function Upload Load //
		xml.onLoad = function() {
			// Set Up The Users //
			_root.model.setUsers();
			// Set Up The Interval //
			_root.model.startInterval();
		}
	}
	
	// Sets The Users //
	private function setUsers():Void{
		// Create Empty Movie Users & Empty Cards Clip Movie Clip & Chips Movie Clip & Pot Movie Clip //
		_root.createEmptyMovieClip("cards",1);
		_root.createEmptyMovieClip("users",2);
		_root.createEmptyMovieClip("chips",3);
		_root.createEmptyMovieClip("pot",4);
		_root.createEmptyMovieClip("chipText",5);
		// First; What Are Our Players? //
		var players:Array = xml.firstChild.childNodes[0].childNodes;
		// Go Forth And Loop Through The Users //
		for(var count = 0; count <= 9; count++) {
			// If No User, Then Add An Open Seat //
			if(players[count] == undefined) {
				// Add A Decoy //
				_root.users.attachMovie('mc_player',count,count+1);
				_root.users[count].username.text = 'Open Seat';
				_root.users[count].chipText.text = '';
				_root.users[count].openseat = true;
				_root.users[count]._x = sitX[count];
				_root.users[count]._y = sitY[count];
			} else {
				// Add The User //
				addUser(count,xml.firstChild.childNodes[0].childNodes[count].childNodes[0].firstChild.nodeValue,xml.firstChild.childNodes[0].childNodes[count].childNodes[1].firstChild.nodeValue);
			}
		}
	}
	
	// Adds A User In //
	private function addUser(id:Number,username:String,chips:Number):Void{
		// Attach The Clip //
		_root.users.attachMovie('mc_player',id,id+1);
		// Set The Username //
		_root.users[id].username.text = username;
		// Set The Chips //
		_root.users[id].chipCount = chips;
		_root.users[id].chipText.text = chips;
		// Place It In The According Spot (Set By The Array of Possible X & Y Locations) //
		_root.users[id]._x = sitX[id];
		_root.users[id]._y = sitY[id];
		// Add To An Array That Corresponds Usernames To A User ID //
		/**
			Because we're doing this in AS2, we can't use the username as a key
			and thus an array_search function was created in order to get the ID
		**/
		userText[id] = username;
	}
	
	// Starts The Interval //
	private function startInterval():Void{
		trace('startInterval');
		// First Deal Cards //
		_root.game.dealCards();
		// Initiate Interval //
		myInterval = setInterval(this,"nextAction",actionDelay);
	}
	
	// Handles The Next Action In The XML File //
	public function nextAction():Void{
		// Are We Currently In An Action? //
		if(inAction or inPause) {
			return;
		} else {
			actID++;
		}
		// Are We Restarting? //
		if(inRestart) {
			trace('Calling Restart');
			// Run Restart Function //
			restart();
			// Remove Interval //
			clearInterval(myInterval);
			// Return
			return;
		}
		// Whats The ID Of The Current Action? //
		var actionID = xml.firstChild.childNodes[1].childNodes[actID].attributes.id;
		/**
			What Happens Here Is That Depending On The Action ID, A Subsequent Function Is Called.
			That function will then declare the inAction variable to true and run it's code.
			After that function completes it's job, it will set inAction to false and increment the actID so that we can move on.
		**/
		// Call That Function //
		switch(actionID) {
			case '1':
				inAction = true;
				_root.game.smallPost();
				break;
			case '2':
				inAction = true;
				_root.game.bigPost();
				break;
			case '3':
				inAction = true;
				_root.game.fold();
				break;
			case '4':
				inAction = true;
				_root.game.raise();
				break;
			case '5':
				inAction = true;
				_root.game.call();
				break;
			case '6':
				inAction = true;
				_root.game.moveChips();
				break;
			case '7':
				inAction = true;
				_root.game.func_bet();
				break;
			case '8':
				inAction = true;
				_root.game.win();
				break;
			case '9':
				inAction = true;
				trace('Mucks Hands');
				inAction = false;
				break;
		}	
	}
	
	/**
		Temporary Function That Outputs To An Action Window
	**/
	public function output(string:String):Void{
		_root.actionBox.htmlText = _root.actionBox.htmlText+string+"<br />";
	}
	
	// Searches An Array & Returns The Key //
	public function array_search(array:Array,value:String):Number{
		// Length //
		var length:Number = array.length;
		// Now Loop Through Array //
		for(var count = 0; count <= length; count++) {
			// Now Check If We Have A Match //
			if(array[count] == value) {
				return count;
			} else {
				continue;
			}
		}
		return null;
	}
	
	// Used To Calculate Chip Graphics //
	public function detChips(amount:Number):Array {
		var chips:Array = new Array();
		// Let's Work From Highest To Lowest //
		if(amount >= 500) {
			// How Many 500 Chips //
			chips[0] = Math.floor(amount / 500);
			// Now Subtract That Amount Worth of 500 From The Buffer //
			amount -= chips[0] * 500;
		}
		// Greater Then 100? //
		if(amount >= 100) { 
			// How Many 100 Chips? //
			chips[1] = Math.floor(amount / 100);
			// Now Subtract That Amount Worth of 100 From The Buffer //
			amount -= chips[1] * 100;
		}
		// Greater Then 50? //
		if(amount >= 50) {
			// How Many 50 Chips? //
			chips[2] = Math.floor(amount / 50);
			// Now Subtract That Amount Worth of 50 From The Buffer //
			amount -= chips[2] * 50;
		}
		// Greater Then 25? //
		if(amount >= 25) {
			// How Many 25 Chips? //
			chips[3] = Math.floor(amount / 25);
			// Now Subtract That Amount of 25 From The Buffer //
			amount -= chips[3] * 25;
		}
		// Greater Then 10? //
		if(amount >= 10) {
			// How Many 10 Chips? //
			chips[4] = Math.floor(amount / 10);
			// Now Subtract That Amount of 10 From The Buffer //
			amount -= chips[4] * 10;
		}
		// Greater Then 5? //
		if(amount >= 5) {
			// How Many 5 Chips? //
			chips[5] = Math.floor(amount / 5);
			// Now Subtract That Amount of 5 From The Buffer //
			amount -= chips[5] * 5;
		}
		// Return The Chips //
		return chips;
	}
	
	// Draws The Pot //
	public function drawPot():Void{
		//trace('DrawPot: '+_root.model.actID);
		//trace('inAction: '+_root.model.inAction);
		// Variables //
		potRows = 0;
		var finalCount:Boolean = false;
		var drawRow:Boolean = true;
		// Unload The Chips Movie Clip //
		unloadMovie(_root.chips);
		_root.createEmptyMovieClip("pot",4);
		// Get Chips //
		var chips:Array = detChips(parseInt(_root.game.pot));
		var nullRows:Number = 0;
		// Now Draw That Amount of Chips To The Pot //
		for(var count:Number = 5; count >= 0; count--) {
			// Last One? //
			if(count == 0) {
				finalCount = true;
			}
			// How Many? //
			var chipCount:Number = chips[count];
			if(chipCount == undefined) {
				nullRows++;
				// Only Skip If Its Not The Final Count //
				if(finalCount == false) {
					drawRow = true;
					continue;
				} else {
					drawRow = false;
				}
			}
			// Create Another Container For This Chip Type //
			if(_root.pot['row_'+count] == undefined && drawRow == true) {
				_root.pot.createEmptyMovieClip('row_'+count,_root.pot.getNextHighestDepth());
				// Place Row Accordingly //
				_root.pot['row_'+count]._x = potX[count+nullRows];
				_root.pot['row_'+count]._y = potY[count+nullRows];
				// Increment The Number of Rows //
				potRows++;
			}
			// If We're Drawing This Row //
			if(drawRow) {
				// Now Add The Required Amount of Chips //
				for(var x:Number = 1; x <= chipCount; x++) {
					// Add Chip Graphic //
					_root.pot['row_'+count].attachMovie('mc_tbl'+chipNames[count],'id_'+x,_root.pot['row_'+count].getNextHighestDepth());
					// Now Place The Chip Accordingly //
					_root.pot['row_'+count]['id_'+x]._y -= 5 * (x - 1);
				}
			}
			// If We Are The Last One //
			if(finalCount == true) {
				// Now If ChipCount Is Undefined //
				if(chipCount == undefined or x == chipCount) {
					// Call The Flop //
					_root.game.flop();
				}
			}
		}
		// Update Pot Text //
		_root.potText.text = _root.game.pot;
		// Recreate Clip //
		_root.createEmptyMovieClip('chips',3);
	}
	
	// Draws The Chips On The Table For A User //
	public function drawChips(userID:Number,amount:Number):Void{
		// First Get The Chip Array //
		var chips:Array = detChips(amount);
		var nullRows:Number = 0;
		var finalCount:Boolean = false;
		var drawRow:Boolean = true;
		// Create The Movie Clip //
		_root.chips.createEmptyMovieClip(userID,userID+1);
		// Set Alpha //
		_root.chips[userID]._alpha = 0;
		// Now Loop Through Each Chip Type (There's 6 of Them)
		// 0 = 500, 1 = 100, 2 = 50, 3 = 25, 4 = 10, 5 = 5
		for(var count:Number = 5; count >= 0; count--) {
			// Last One? //
			if(count == 0) {
				finalCount = true;
			}
			// Now How Many Of This Chip? //
			var chipCount:Number = chips[count];
			// If 0; Skip & Increment The Null Row Counter //
			if(chipCount == undefined) {
				nullRows++;
				// Only Continue If It Is Not The Last One // 
				if(finalCount == false) {
					// For Next Row //
					drawRow = true;
					continue;
				} else {
					// Don't Draw //
					drawRow = false;
				}
			}
			// Create Another Container For This Chip Type //
			if(drawRow) {
				if(_root.chips[userID]['row_'+count] == undefined) {
					_root.chips[userID].createEmptyMovieClip('row_'+count,_root.chips[userID].getNextHighestDepth()+2);
					// Place Row Accordingly //
					_root.chips[userID]['row_'+count]._x = rowX[userID][count+nullRows];
					_root.chips[userID]['row_'+count]._y = rowY[userID][count+nullRows];
				}
				// Now Add The Required Amount of Chips //
				for(var x:Number = 1; x <= chipCount; x++) {
					// Add Chip Graphic //
					_root.chips[userID]['row_'+count].attachMovie('mc_tbl'+chipNames[count],'id_'+x,_root.chips[userID]['row_'+count].getNextHighestDepth());
					// Now Place The Chip Accordingly //
					_root.chips[userID]['row_'+count]['id_'+x]._y -= 5 * (x - 1);
				}
			}
			// Last One? //
			// If We Are The Last One //
			if(finalCount == true) {
				// Now If ChipCount Is Undefined //
				if(chipCount == undefined or x == chipCount) {
					// Fade The Chips In //
					Tweener.addTween(_root.chips[userID],{_alpha:100, time:1,onStart:function(){_root.model.chipText(amount,userID,count,nullRows);},onCompleteParams:[amount,userID,count,nullRows]});
				}
			}
		}	
	}
	
	// Sets Chip Text //
	public function chipText(amount:Number,userID:Number,count:Number,nullRows:Number):Void{
		// Does It Exist? //
		if(_root.chipText == undefined) {
			_root.createEmptyMovieClip("chipText",5);
		}
		// Increase Count //
		count++;
		// Get Text Coordinate Values //
		var yCoor:Number = rowY[userID][count+nullRows] + (_root.chips[userID]._height - 3);
		var depth:Number = userID+1;
		// If It Is Greater Then 5 Then Reverse //
		if(userID > 4) {
			var xCoor:Number = rowX[userID][5] + ((5 - (count + nullRows)) * 19);
		} else {
			var xCoor:Number = rowX[userID][count+nullRows] + ((5 - nullRows) * 19);
		}
		// Create TextFIeld //
		_root.chipText.createTextField('chipText_'+userID,depth,xCoor,yCoor,70,16);
		// Set Formatting //
		var txtFormat:TextFormat = new TextFormat();
		txtFormat.font = "Arial";
		txtFormat.color = 0xFFCC00;
		txtFormat.size = 10;
		txtFormat.align = "left";
		// Apply Text //
		_root.chipText['chipText_'+userID].text = amount;
		// Apply Formatting //
		_root.chipText['chipText_'+userID].setTextFormat(txtFormat);
	}
	// Restart Function //
	private function restart():Void{
		trace('Restart Function');
		// First, Let's Set Pause To False //
		inPause = false;
		// Now Reset Pot & Bet //
		_root.game.pot = 0;
		_root.game.bet = 0;
		// Unset Flop Cards //
		_root.game.flopCards = new Array();
		// Reset Pot Rows //
		potRows = 0;
		// Reset Action ID //
		actID = -1;
		// Now Recreate The Movie Clips //
		_root.createEmptyMovieClip("cards",1);
		_root.createEmptyMovieClip("chips",3);
		_root.createEmptyMovieClip("pot",4);
		_root.createEmptyMovieClip("chipText",5);
		// Set Restart To False //
		inRestart = false;
		// Recreate Interval & Get Going //
		startInterval();
	}
}