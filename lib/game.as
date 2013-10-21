/**
Copyright Shafique Arnab 2008
==============================
Class: Game
Purpose: Main Game Functions & Actions
**/

// Import Caurina Tweener //
import caurina.transitions.Tweener;

class lib.game {
	
	var pot = 0;
	var bet = 0;
	var flopCards:Array = new Array();
	
	// Gets The Username //
	private function getUsername():String {
		return(_root.model.xml.firstChild.childNodes[1].childNodes[_root.model.actID].childNodes[0].firstChild.nodeValue);
	}
	
	// Small Post //
	public function smallPost():Void {
		// Get The Username //
		var username:String = getUsername();
		// Now Get The User ID //
		var userID:Number = _root.model.array_search(_root.model.userText,username);
		// How Much We Posting? //
		var postAmount = _root.model.xml.firstChild.childNodes[1].childNodes[_root.model.actID].childNodes[1].firstChild.nodeValue;
		// Set It //
		pot = postAmount;
		bet = parseInt(postAmount);
		// Draw Table Chips //
		_root.model.drawChips(userID,bet);
		// Subtract From Current Chip Count //
		_root.users[userID].chipText.text = _root.users[userID].chipCount - postAmount;
		// Now Output The Action //
		_root.model.output("Small Blind by "+username+" of "+postAmount);
		// Allow It To Move On //
		_root.model.inAction = false;
	}
	
	// Big Post //
	public function bigPost():Void{
		// Get The Username //
		var username:String = getUsername();
		// Now Get The User ID //
		var userID:Number = _root.model.array_search(_root.model.userText,username);
		// How Much We Posting? //
		var postAmount = _root.model.xml.firstChild.childNodes[1].childNodes[_root.model.actID].childNodes[1].firstChild.nodeValue;
		// Set To Pot //
		pot = parseInt(pot) + parseInt(postAmount);
		// Set Bet //
		bet = parseInt(postAmount);
		// Draw Table Chips //
		_root.model.drawChips(userID,bet);
		// Subtract From Current Chip Count //
		_root.users[userID].chipText.text = _root.users[userID].chipCount - postAmount;
		// Now Output The Action //
		_root.model.output("Big Bling by "+username+" of "+postAmount);
		// Allow It To Move On //
		_root.model.inAction = false;
	}
	
	// User Folds //
	public function fold():Void{
		// Get The Username //
		var username:String = getUsername();
		// Now Get The ID of the The User //
		var userID:Number = _root.model.array_search(_root.model.userText,username);
		// Now Post The Output //
		_root.model.output("Fold by "+username);
		// Set Folded Text //
		_root.users[userID].chipText.text = "Folded";
		// Make The Cards Disappear //
		Tweener.addTween(_root.cards['carddown_'+userID+'1'],{_alpha:0,time:.5,_y:_root.cards['carddown_'+userID+'1']._y + 10});
		Tweener.addTween(_root.cards['carddown_'+userID+'2'],{_alpha:0,time:.5,_y:_root.cards['carddown_'+userID+'2']._y + 10,onComplete:function() {_root.model.inAction = false;}});
		/*// Make The Chips Disappear //
		if(_root.chips[userID] !== undefined) {
			Tweener.addTween(_root.chips[userID],{_alpha:0,_y:_root.chips[userID]._y + 10,time:.5});
			// Take Your Bet Out Of The Pot //
			//pot = pot - parseInt(_root.chipText['chipText_'+userID].text);
		}
		*/
		// Delete Chip Text //
		//_root.chipText['chipText_'+userID].text = "";
	}
	
	// User Rasises //
	public function raise():Void {
		// Get The Username //
		var username:String = getUsername();
		// Now Get The User ID //
		var userID:Number = _root.model.array_search(_root.model.userText,username);
		// Get The Raise Amount //
		var raiseAmount = _root.model.xml.firstChild.childNodes[1].childNodes[_root.model.actID].childNodes[1].firstChild.nodeValue;
		raiseAmount = parseInt(raiseAmount);
		// Set New Raise //
		bet = raiseAmount + parseInt(bet);
		pot = parseInt(pot) + parseInt(raiseAmount);
		// Draw Table Chips //
		_root.model.drawChips(userID,bet);
		// Subtract From Chip Count //
		_root.users[userID].chipText.text = _root.users[userID].chipCount - raiseAmount;
		// Output Text //
		_root.model.output("Raise by "+username+" of "+raiseAmount);
		// Move On //
		_root.model.inAction = false;
	}
	
	// Calls A Bet //
	public function call():Void {
		// Get The Username //
		var username:String = getUsername();
		// Now Get The User ID //
		var userID:Number = _root.model.array_search(_root.model.userText,username);
		// Update Chip Count //
		_root.users[userID].chipText.text = _root.users[userID].chipCount - bet;
		// Update Pot Count //
		pot = parseInt(pot) + parseInt(bet);
		// Draw Table Chips //
		_root.model.drawChips(userID,bet);
		// Output Text //
		_root.model.output("Call by "+username+" to match "+bet);
		// Move On //
		_root.model.inAction = false;
	}
	
	// Flop (Community Cards) //
	public function flop():Void {
		//trace('Flop: '+_root.model.actID);
		//trace('inAction: '+_root.model.inAction);
		// Is The Cards Movie Clip Created? //
		if(_root.cards == null or _root.cards == undefined) {
			_root.createEmptyMovieClip('flop',1);
		}
		// First Set The Bet To 0 Because This Indicates Its The End of The Round //
		bet = 0;
		// Now Get The Cards Needed (Maximum of 3 Anyhow) //
		for(var count:Number = 0; count <= 4; count++) {
			var cardID:String = _root.model.xml.firstChild.childNodes[1].childNodes[_root.model.actID].childNodes[count].firstChild.nodeValue;
			// Break The Loop If No Card ID //
			if(cardID == undefined or cardID == null) {
				break;
			}
			// Add The Card To The Array //
			var x = flopCards.length;
			flopCards[x] = cardID;
			
			// Attach The Card Required //
			_root.cards.attachMovie(cardID+'.png',cardID,_root.cards.getNextHighestDepth());
			// Now Set The Precise Location Of The Card //
			// Now If It's The First Card; Then Place It In It's Original Location Otherwise That of the previous card //
			_root.cards[cardID]._x = (flopCards[x-1] == undefined) ? _root.model.flopX[x] - _root.cards[cardID]._width : _root.model.flopX[x-1];
			_root.cards[cardID]._y = _root.model.flopY[x];
			_root.cards[cardID]._alpha = 0;
			// Last One? //
			if(_root.model.xml.firstChild.childNodes[1].childNodes[_root.model.actID].childNodes[(count+1)].firstChild.nodeValue == undefined) {
				var reset:Function = function() {
					_root.model.inAction = false;
				}
			} else {
				var reset:Function = function() {
					return;
				}
			}
			// Now Fade It In //
			Tweener.addTween(_root.cards[cardID], {_alpha:100,time:1,_x:_root.model.flopX[x],delay:(count*.5),onComplete:reset});
		}
		// Output //
		_root.model.output("Cards have been added to flop.");
	}
	
	// Moves Chips To Center //
	public function moveChips():Void{
		//trace('MoveChips: '+_root.model.actID);
		//trace('inAction: '+_root.model.inAction);
		// Amount To Go Up To //
		var amount:Number = _root.model.userCount - 1;
		var setFinal:Boolean = false;
		// Unset The Chip Text //
		unloadMovie(_root.chipText);
		// Now Move All The Chips To The Center //
		for(var track:Number = 0; track <= amount; track++) {
			// Okay If The User's Null; Skip //
			if(_root.chips[track] == undefined) {
				continue;
			}
			// Loop Through The Chips Available //
			for(var chipTrack:Number = 0; chipTrack <= 5; chipTrack++) {
				// Does This Row Exist? //
				if(_root.chips[track]['row_'+chipTrack] == undefined) {
					continue;
				}
				// Last One? //
				if(track == amount && setFinal == false) {
					var drawPot = function() {
						_root.model.drawPot();
					}
					setFinal = true;
				} else {
					var drawPot = function() {
						return;
					}
					setFinal = false;
				}
				// Tween This Row //
				Tweener.addTween(_root.chips[track]['row_'+chipTrack],{_x:420,_y:200,time:1,onComplete:drawPot});
			}
		}
	}
	
	// Makes A Bet //
	public function func_bet():Void {
		// Get Username //
		var username:String = getUsername();
		// Get User ID //
		var userID:Number = _root.model.array_search(_root.model.userText,username);
		// Get Bet Amount //
		var betAmount = _root.model.xml.firstChild.childNodes[1].childNodes[_root.model.actID].childNodes[1].firstChild.nodeValue;
		betAmount = parseInt(betAmount);
		// Now Change The Current Bet //
		if(betAmount <= bet) {
			return;
		}
		bet = betAmount;
		// Add It To The Pot //
		pot = parseInt(pot) + bet;
		// Draw Table Chips //
		_root.model.drawChips(userID,bet);
		// Update Chip Count //
		_root.users[userID].chipText.text = _root.users[userID].chipCount - betAmount;
		// Output //
		_root.model.output(username+" bet "+betAmount);
		// Move On //
		_root.model.inAction = false;
	}
	
	// Handles A Win //
	public function win():Void {
		// Get Username //
		var username:String = getUsername();
		// Get User ID //
		var userID:Number = _root.model.array_search(_root.model.userText,username);
		// Update Chip Count //
		_root.users[userID].chipCount  =  parseInt(_root.users[userID].chipCount) + parseInt(pot) + parseInt(bet);
		_root.users[userID].chipText.text = _root.users[userID].chipCount;
		// Make Bet Chips Disappear //
		Tweener.addTween(_root.chips[userID],{_alpha:0,time:.3});
		_root.chipText['chipText_'+userID].text = "";
		var nullRows:Number = 0;
		// We Need To Loop Through & Set It For Each Row //
		for(var count:Number = 5; count >= 0; count--) {
			// Skip If Undefined Object //
			if(_root.pot['row_'+count] == undefined) {
				nullRows++;
				continue;
			}
			// Get Values //
			var xValue:Number = _root.model.rowX[userID][(count+nullRows)];
			var yValue:Number = _root.model.rowY[userID][(count+nullRows)];
			// Add Tween //
			Tweener.addTween(_root.pot['row_'+count],{_x:xValue,_y:yValue,time:1,delay:.3});	
		}
		
		// Output //
		_root.potText.text = username+" just won the pot of "+pot+".";
		// Move On //
		_root.model.inAction = false;
	}
	
	// Deals The Cards //
	public function dealCards():Void{
		// Prevent Action Movement Until Complete //
		_root.model.inAction = true;
		var delay:Number = 0;
		var userCount:Number = 0;
		// Function To Check If Action Completed //
		var isDone:Function = function(i,count) {
			if(i == 2 && count == (userCount-1)) {
				_root.model.inAction = false;
				// Store The UserCount //
				_root.model.userCount = userCount;
			}
		}
		// Do It Twice Cuz We Need Two Cards Handed Out //
		for(var i:Number = 1; i <= 2; i++) {
			// Now Lets Loop Through The Users //
			for(var count:Number = 0; count <= 9; count++) {
				// Are You Just An Open Seat? //
				if(_root.users[count].openseat == true) {
					continue;
				}
				// Increment The Actual User Count //
				userCount = (i == 1) ? userCount + 1 : userCount;
				// Now Let's Add Another Card For Dealing //
				_root.cards.attachMovie('mc_carddown','carddown_'+count+i,_root.cards.getNextHighestDepth());
				// Set The X To Be Half The Table //
				_root.cards['carddown_'+count+i]._x = 395;
				_root.cards['carddown_'+count+i]._y = 200;
				_root.cards['carddown_'+count+i]._alpha = 0;
				// Set The Delay //
				if(i == 2) {
					delay = (count * .25) + (userCount / 4);
				} else {
					delay = count * .25;
				}
				// Now Send It To The Correct Location //
				Tweener.addTween(_root.cards['carddown_'+count+i],{_alpha:100, time:1, _x:_root.model.sitX[count] + (i*20), _y:_root.model.sitY[count] - (54 / 2),delay:delay, onComplete:isDone, onCompleteParams:[i,count]});
			}
		}
	}
}