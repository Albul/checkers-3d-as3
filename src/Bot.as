/*
 * 
 * Copyright (c) 2012, Albul Alexandr
 
 This file is part of Checkers3D.

    Checkers3D is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see < http://www.gnu.org/licenses/>.
*/
package  {
	import com.RandomArrayOutput;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	/**
	 * Class implements the computer player
	 */
	public class Bot extends Object {
		
		private var arrCheckers:Array;			// The array contents alive checkers of bot
		private var teamComputer:Boolean;
		private var logic:Logic;
		private var level:int;					// Difficulty level of bot

		public function Bot(teamBot:Boolean, arrCheckers:Array, logic:Logic, level:int = 1) {
			this.level = level;
			this.teamComputer = teamBot;
			this.arrCheckers = arrCheckers;
			this.logic = logic;
			
			logic.addEventListener(Logic.WHO_MOVE_CHANGED, onWhoMoveChanged);
			if (teamBot == Logic.WHITE_TEAM) toMove();
		}

		/**
		 * Make a finished move
		 */
		private function toMove():void {
			do {
				if (!makeMove(this.level)) {
					makeMove(this.level - 1);
				}
			} while (this.logic.checkFightingTeam(this.teamComputer));
			
			logic.whoMove = !this.teamComputer;
		}

		/**
		 * Make a single move
		 * @param level
		 * @return true - if the move was made, false - otherwise
		 */
		private function makeMove(level:int):Boolean {
			switch (level) {
				case 1:
					// If there is checker that made the last move, then continue to make it move
					if (this.logic.lastMovingChecker != null) {
						this.logic.lastMovingChecker.raise();
						this.logic.checkFightingTeam(this.teamComputer, true);
						this.logic.lastMovingChecker.lower();
					}
					else {
						// Randomly select checker which make the move
						var randArrOut:RandomArrayOutput = new RandomArrayOutput();		
						randArrOut.createRandom(this.arrCheckers);
						while (!randArrOut.isPrinted) {
							var checker:Checker = randArrOut.getRandomItem();
							for each (var cell:Cell in logic.structCells) {
								if (this.logic.checkMove(checker, cell, false)) {
									checker.raise();
									this.logic.checkMove(checker, cell, true);
									checker.lower();
									return true;
								}
							}
						}
						return false;
					}
				break;
				case 2:
					if (this.logic.lastMovingChecker != null) {
						this.logic.lastMovingChecker.raise();
						this.logic.checkFightingTeam(this.teamComputer, true);
						this.logic.lastMovingChecker.lower();
					}
					else {
						var randArrOut:RandomArrayOutput = new RandomArrayOutput();
						randArrOut.createRandom(this.arrCheckers);
						while (!randArrOut.isPrinted) {
							var checker:Checker = randArrOut.getRandomItem();
							for each (var cell:Cell in logic.structCells) {
								if (this.logic.checkMove(checker, cell, false)) {
									// Check whether the enemy beat checker by the selected cell
									if (!this.logic.checkKilling(checker.currentCell, cell)) {
										checker.raise();
										this.logic.checkMove(checker, cell, true);
										checker.lower();
										return true;
									}
								}
							}
						}
						return false;
					}
				break;
			default:
				return true;
				
			}
			return false;
		}

		public function removeBot():void {
			logic.removeEventListener(Logic.WHO_MOVE_CHANGED, onWhoMoveChanged);
		}

		private function onWhoMoveChanged(e:Event):void {
			if (logic.whoMove == this.teamComputer) {
				setTimeout(toMove, 750);
			}
		}

	}
}