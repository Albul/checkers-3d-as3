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
	import alternativa.engine3d.core.events.MouseEvent3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	
	
	/**
	 * Class implements the logic of the game.
	 */
	public class Logic extends EventDispatcher {
		
		static public const WHITE_TEAM:Boolean = false;
		static public const BLACK_TEAM:Boolean = true;
		static public const MAX_SIZE_BOARD:int = 8;
		
		static public const WHO_MOVE_CHANGED:String = "whoMoveChanged";
		static public const CHECKER_KILLED:String = "checkerKilled";
		
		// Places where the checkers fly after death
		private var cemetryWhite:Vector3D = new Vector3D(-40, -55, -4.3);		
		private var cemetryBlack:Vector3D = new Vector3D(-40, 55, -4.3);

		private var _whoMove:Boolean;				// false - move the white team, true - move the black team
		
		public var structCells:Object;
		private var strucCells:StructureCells;
		
		private var arrWhiteCheckers:Array;			// The array of the white alive checkers
		private var arrBlackCheckers:Array;
		
		private var selectedChecker:Checker;
		private var lastFightingChecker:Checker;
		private var _lastMovingChecker:Checker;
		private var _teamPlayer:Boolean;
		private var bot:Bot;
		
		public function Logic(structCells:Object, arrWhiteCheckers:Array, arrBlackCheckers:Array,
		                      teamPlayer:Boolean = false, levelGame:int = 0) {
			this._teamPlayer = teamPlayer;
			this.arrBlackCheckers = arrBlackCheckers;
			this.arrWhiteCheckers = arrWhiteCheckers;
			this.structCells = structCells;
			this.strucCells = new StructureCells(structCells);
			
			addListeners();
			
			bot = new Bot(!teamPlayer, (!teamPlayer? this.arrBlackCheckers : this.arrWhiteCheckers), this, levelGame);
		}

		/**
		 * Check and make a move
		 * @param	checker Checker which try to make a move
		 * @param	cell Cell on which make the move
		 * @param	makeMove true - make a move, false - check a move
		 * @return true - if move is possible, false - otherwise
		 */
		public function checkMove(checker:Checker, cell:Cell, makeMove:Boolean = true):Boolean {
				if (cell.isOccupied)
					return false;
				
				if (checker.isQueen) {
					return checkMoveQueen(checker, cell, makeMove);
				}
				
				//  If the checker and the cell is a close (it is impossible to make a move backward)
				if ((cell.j == checker.currentCell.j  + 1 || cell.j == checker.currentCell.j  - 1) 
					&& ((cell.i == checker.currentCell.i + 1 && checker.team == Logic.WHITE_TEAM) 
					|| (cell.i == checker.currentCell.i - 1 && checker.team == Logic.BLACK_TEAM))
					&& !checkFightingTeam(checker.team)) {
					if (makeMove) {
						checker.moveTo(cell);
						this._lastMovingChecker = checker;
						checkQueen(checker);
					}
					return true;
				}
					
				// If a checker and cell are after one cell
				if ((checker.currentCell.i + 2 == cell.i) && (checker.currentCell.j + 2 == cell.j)
					|| (checker.currentCell.i + 2 == cell.i) && (checker.currentCell.j - 2 == cell.j)
					|| (checker.currentCell.i - 2 == cell.i) && (checker.currentCell.j + 2 == cell.j)
					|| (checker.currentCell.i - 2 == cell.i) && (checker.currentCell.j - 2 == cell.j)) {
						var ii:int = (cell.i - checker.currentCell.i) / 2;
						var jj:int = (cell.j - checker.currentCell.j) / 2;
						// Cell which is probably enemy checker
						var enemyCell:Cell = this.strucCells.getIJ(cell.i - ii, cell.j - jj);
						if (enemyCell.isOccupied && enemyCell.currentChecker.team != checker.team) {
							if (makeMove) {
								killChecker(enemyCell.currentChecker);
								checker.moveTo(cell);
								this._lastMovingChecker = this.lastFightingChecker = checker;
								checkQueen(checker);
							}
							return true;
						}
				}
			
			return false;
		}
		
		/**
		 * Check the specified team the opportunity to beat the enemy checkers
		 */
		public function checkFightingTeam(team:Boolean, makeFighting:Boolean = false):Boolean {
			var teamCheckers:Array = (team == Logic.WHITE_TEAM? this.arrWhiteCheckers : this.arrBlackCheckers);
			if (this._lastMovingChecker == null) {
				for each (var checker:Checker in teamCheckers) {
					if (checker.isQueen) {
						if (checkFightingQueen(checker, makeFighting))
							return true;
						continue;
					}
					else {
						if (checkFightingChecker(checker, makeFighting))
							return true;
						continue;
					}
				}
			}
			else {
				if (this.lastFightingChecker != null) {
					if (this.lastFightingChecker.isQueen) {
						return checkFightingQueen(this.lastFightingChecker, makeFighting);
					}
					else {
						return checkFightingChecker(this.lastFightingChecker, makeFighting);
					}
				}
				else
					return false;
			}
			return false;
		}
				
		/**
		 * Check whether to beat the enemy team, the checker which stands on the currentCell, and tries to make a move on the toCell
		 * @param	currentCell
		 * @param	toCell
		 * @return true - if checker was beaten, false - otherwise
		 */
		public function checkKilling(currentCell:Cell, toCell:Cell):Boolean {
			var k:int = 0;
			var iStep:int;
			var jStep:int;
			var i:int;
			var j:int;
				
			while (k <= 4) {
				k++;
				// Determine the direction
				switch (k) {
					case 1:
						iStep = -1;
						jStep = -1;
						break;
					case 2:
						iStep = -1;
						jStep = 1;
						break;
					case 3:
						iStep = 1;
						jStep = -1;
						break;	
					case 4:
						iStep = 1;
						jStep = 1;
						break;
				}
				
				i = toCell.i + iStep;
				j = toCell.j + jStep;

				var backCell:Cell = this.strucCells.getIJ(toCell.i - iStep, toCell.j - jStep);
				if (backCell != null && backCell.isOccupied && backCell != currentCell)
					continue;
					
				while (i <= Logic.MAX_SIZE_BOARD && i >= 1 && j <= Logic.MAX_SIZE_BOARD && j >= 1) {
					var curCell:Cell = this.strucCells.getIJ(i, j);
					if (curCell.isOccupied) {
						if (curCell.currentChecker.team == currentCell.currentChecker.team) {
							break;
						}

						if (curCell.currentChecker.team != currentCell.currentChecker.team) {
							if (curCell.currentChecker.isQueen) {
								return true;
							}
							if (i - iStep == toCell.i && j - jStep == toCell.j) {
								return true;
							}
						}
					}
					j += jStep;
					i += iStep;
				}	
			}
									
			return false;	
		}

		public function set whoMove(value:Boolean):void {
			_whoMove = value;
			this.lastFightingChecker = null;
			this._lastMovingChecker = null;
			this.dispatchEvent(new Event(WHO_MOVE_CHANGED));
		}

		public function get whoMove():Boolean {
			return _whoMove;
		}

		public function get lastMovingChecker():Checker {
			return _lastMovingChecker;
		}

		public function get teamPlayer():Boolean {
			return _teamPlayer;
		}

		public function get NumberWhite():int {
			return this.arrWhiteCheckers.length;
		}	

		public function get NumberBlack():int {
			return this.arrBlackCheckers.length;
		}

		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Check and make a move queen
		 * @param	queen
		 * @param	cell Cell on which make the move
		 * @param	makeMove true - make a move, false - check a move
		 * @return true - if move is possible, false - otherwise
		 */
		private function checkMoveQueen(queen:Checker, cell:Cell, makeMove:Boolean = true):Boolean {
			// If the queen and the cell are in the same diagonal
			if (Math.abs(cell.i - queen.currentCell.i) == Math.abs(cell.j - queen.currentCell.j)) {
					
				// Calculate increase row and column
				var iStep:int = cell.i > queen.currentCell.i ? 1 : -1;
				var jStep:int = cell.j > queen.currentCell.j ? 1 : -1;
				var i:int = queen.currentCell.i + iStep;
				var j:int = queen.currentCell.j + jStep;
				var lastIsOccupied:Boolean;
				var isEnemy:Boolean;

				while (i != cell.i) {
					var curCell:Cell = this.strucCells.getIJ(i, j);
					if (curCell.isOccupied) {
						if (curCell.currentChecker.team == queen.team) {
							return false;
						}
							
						if (curCell.currentChecker.team != queen.team) {
							if (lastIsOccupied)
								return false;
								
							lastIsOccupied = true;
							isEnemy = true;
						}
					}
					else {
						lastIsOccupied = false;
					}
						
					j += jStep;
					i += iStep;
				}

				if (isEnemy) {
					if (makeMove) {
						i = queen.currentCell.i + iStep;
						j = queen.currentCell.j + jStep;
						
						while (i != cell.i) {
							var curCell:Cell = this.strucCells.getIJ(i, j);
							if (curCell.isOccupied) {
								killChecker(curCell.currentChecker);
							}
								
							j += jStep;
							i += iStep;
						}
						
						queen.moveTo(cell);
						this._lastMovingChecker = this.lastFightingChecker = queen;
					}
					return true;
				}
				else {								
					if (!checkFightingTeam(queen.team)) {
						if (makeMove) {
							queen.moveTo(cell);
							this._lastMovingChecker = queen;
						}
						return true;
					}
				}
			}
			
			return false;
		}

		private function killChecker(checker:Checker):void {
			if (checker.team == Logic.WHITE_TEAM) {											
				checker.kill(cemetryWhite.x, cemetryWhite.y, cemetryWhite.z);
				cemetryWhite.x += Graphic.WIDTH_CHECKER + 0.1;
				this.arrWhiteCheckers.splice(this.arrWhiteCheckers.indexOf(checker), 1);
			}
			
			if (checker.team == Logic.BLACK_TEAM) {
				checker.kill(cemetryBlack.x, cemetryBlack.y, cemetryBlack.z);
				cemetryBlack.x += Graphic.WIDTH_CHECKER + 0.1;
				this.arrBlackCheckers.splice(this.arrBlackCheckers.indexOf(checker), 1);
			}
			
			if (checker.team == this.teamPlayer) {
				checker.removeEventListener(MouseEvent3D.CLICK, onCheckerClicked);
			}
			
			if (this.NumberWhite == 0 || this.NumberBlack == 0) {
				bot.removeBot();
			}

			this.dispatchEvent(new Event(CHECKER_KILLED));
		}

		/**
		 * Check whether the checker became queen
		 * @param	checker
		 * @return true - If the checker became queen, false - otherwise
		 */
		private function checkQueen(checker:Checker):Boolean {
			if (checker.isQueen)
				return false;
			
			if (checker.team == Logic.WHITE_TEAM) {
				if (checker.currentCell.i == MAX_SIZE_BOARD) {
					checker.setQueen();
					return true;
				}
			}			
			
			if (checker.team == Logic.BLACK_TEAM) {
				if (checker.currentCell.i == 1) {
					checker.setQueen();
					return true;
				}
			}
			
			return false;
		}

		/**
		 * Check the queen's possibility to beat the enemy checkers
		 * @param	queen
		 * @param	makeFighting true - make a move, false - check a move
		 * @return true - if the queen can beat the enemy checkers. false - otherwise
		 */
		private function checkFightingQueen(queen:Checker, makeFighting:Boolean = false):Boolean {
			var k:int = 0;
			
			var iStep:int;
			var jStep:int;
			var i:int;
			var j:int;
				
			// Check the four diagonals
			while (k <= 4) {
				k++;
				
				// Determine the direction
				switch (k) {
					case 1:
						iStep = -1;
						jStep = -1;
						break;
					case 2:
						iStep = -1;
						jStep = 1;
						break;
					case 3:
						iStep = 1;
						jStep = -1;
						break;	
					case 4:
						iStep = 1;
						jStep = 1;
						break;
				}
				
				i = queen.currentCell.i + iStep;
				j = queen.currentCell.j + jStep;
				// We pass all the diagonal
				while (i <= Logic.MAX_SIZE_BOARD && i >= 1 && j <= Logic.MAX_SIZE_BOARD && j >= 1) {
					var curCell:Cell = this.strucCells.getIJ(i, j);
					if (curCell.isOccupied) {
						if (curCell.currentChecker.team == queen.team) {	// Take to check the other direction
							break;
						}

						if (curCell.currentChecker.team != queen.team) {
							if (this.strucCells.getIJ(i + iStep, j + jStep) != null
									&& !this.strucCells.getIJ(i + iStep, j + jStep).isOccupied) {
								if (makeFighting) {
									killChecker(curCell.currentChecker);
									queen.moveTo(this.strucCells.getIJ(i + iStep, j + jStep));
									this._lastMovingChecker = this.lastFightingChecker = queen;
								}
								return true;
							}
							else
								break;
						}
					}
						
					j += jStep;
					i += iStep;
				}	
			}
			return false;	
		}
		
		/**
		 * Check the input checker's possibility to beat the enemy checkers
		 * @param	checker Input checker
		 * @param	makeFighting  true - make a move, false - check a move
		 * @return true - if the queen can beat the enemy checkers. false - otherwise
		 */
		private function checkFightingChecker(checker:Checker, makeFighting:Boolean = false):Boolean {
			
			// Choose appropriate cells around checker
			var cellTL2:Cell = this.strucCells.getTL2(checker.currentCell);
			var cellTL1:Cell = this.strucCells.getTL1(checker.currentCell);
			var cellTR2:Cell = this.strucCells.getTR2(checker.currentCell);
			var cellTR1:Cell = this.strucCells.getTR1(checker.currentCell);
			var cellBL2:Cell = this.strucCells.getBL2(checker.currentCell);
			var cellBL1:Cell = this.strucCells.getBL1(checker.currentCell);
			var cellBR2:Cell = this.strucCells.getBR2(checker.currentCell);
			var cellBR1:Cell = this.strucCells.getBR1(checker.currentCell);

			if (!makeFighting) {
				if ((cellTL2 != null && !cellTL2.isOccupied && cellTL1.isOccupied
						&& cellTL1.currentChecker.team != checker.team)
					|| (cellTR2 != null && !cellTR2.isOccupied && cellTR1.isOccupied
						&& cellTR1.currentChecker.team != checker.team)
					|| (cellBL2 != null && !cellBL2.isOccupied && cellBL1.isOccupied
						&& cellBL1.currentChecker.team != checker.team)
					|| (cellBR2 != null && !cellBR2.isOccupied && cellBR1.isOccupied
						&& cellBR1.currentChecker.team != checker.team))
					return true;
			}

			if ((cellTL2 != null && !cellTL2.isOccupied && cellTL1.isOccupied
					&& cellTL1.currentChecker.team != checker.team)) {
				killChecker(cellTL1.currentChecker);
				checker.moveTo(cellTL2);
				this._lastMovingChecker = this.lastFightingChecker = checker;
				checkQueen(checker);
				return true;
			}	
			
			if ((cellTR2 != null && !cellTR2.isOccupied && cellTR1.isOccupied
					&& cellTR1.currentChecker.team != checker.team)) {
				killChecker(cellTR1.currentChecker);
				checker.moveTo(cellTR2);
				this._lastMovingChecker = this.lastFightingChecker = checker;
				checkQueen(checker);
				return true;
			}	
			
			if ((cellBL2 != null && !cellBL2.isOccupied && cellBL1.isOccupied
					&& cellBL1.currentChecker.team != checker.team)) {
				killChecker(cellBL1.currentChecker);
				checker.moveTo(cellBL2);
				this._lastMovingChecker = this.lastFightingChecker = checker;
				checkQueen(checker);
				return true;
			}	
			
			if ((cellBR2 != null && !cellBR2.isOccupied && cellBR1.isOccupied
					&& cellBR1.currentChecker.team != checker.team)) {
				killChecker(cellBR1.currentChecker);
				checker.moveTo(cellBR2);
				this._lastMovingChecker = this.lastFightingChecker = checker;
				checkQueen(checker);
				return true;
			}
			
			return false;
		}

		private function addListeners():void {
			if (this.teamPlayer) {
				for each (var checker:Checker in this.arrBlackCheckers) {
					checker.addEventListener(MouseEvent3D.CLICK, onCheckerClicked);
				}	
			}
			else {
				for each (var checker:Checker in this.arrWhiteCheckers) {
					checker.addEventListener(MouseEvent3D.CLICK, onCheckerClicked);
				}	
			}
			
			for each (var cell:Cell in this.structCells) {
				cell.addEventListener(MouseEvent3D.CLICK, onCellClicked);
			}
		}

		private function selectChecker(checker:Checker):void {
			if (this.selectedChecker != null)
				this.selectedChecker.lower();
			
			this.selectedChecker = checker;
			checker.raise();
		}

		private function deselectChecker():void {
			if (this.selectedChecker != null)
				this.selectedChecker.lower();
			
			this.selectedChecker = null;
		}

		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------


		private function onCellClicked(e:MouseEvent3D):void {
			if (this.selectedChecker == null)
				return;
			
			if (checkMove(this.selectedChecker, Cell(e.currentTarget), true)) {
				if (!checkFightingTeam(whoMove)) {
					deselectChecker();
					whoMove = !whoMove;
				}
			}
		}

		private function onCheckerClicked(e:MouseEvent3D):void {
			if (this.teamPlayer != this.whoMove)
				return;
				
			var checker:Checker = Checker(e.currentTarget);
			selectChecker(checker);
		}

	}
}