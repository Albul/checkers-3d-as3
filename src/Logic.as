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
	import alternativa.engine3d.objects.Mesh;
	import com.WarningText;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	
	/**
	 * Класс отвечает за логику игры. За проверку хода, за бой шашек, и т.д.
	 */
	public class Logic extends EventDispatcher {
		
		static public const WHITE_TEAM:Boolean = false;
		static public const BLACK_TEAM:Boolean = true;
		static public const MAX_SIZE_BOARD:int = 8;
		
		static public const WHO_MOVE_CHANGED:String = "whoMoveChanged";
		static public const CHECKER_KILLED:String = "checkerKilled";
		
		// Места куда складываются убитые шашки разных команд
		private var cemetryWhite:Vector3D = new Vector3D(-40, -55, -4.3);		
		private var cemetryBlack:Vector3D = new Vector3D(-40, 55, -4.3);
			

		private var _whoMove:Boolean;				// Флаг указывает чей сейчас ход (false - ход белых, true - ход черных)
		
		public var structCells:Object;
		private var strucCells:StructureCells;
		
		private var arrWhiteCheckers:Array;			// Массив белых живых шашек
		private var arrBlackCheckers:Array;			// Массив черных живых шашек
		
		private var selectedChecker:Checker;		// Выделенная шашка
		private var lastFightingChecker:Checker; 	// Последняя шашка которая сделала бой
		private var _lastMovingChecker:Checker; 	// Последняя шашка которая сделала ход
		private var _teamPlayer:Boolean;			// Команда за которую играет игрок (false - за белых, true - за черных)
		private var bot:Bot;							// Компьютерный игрок (бот)
		
		/**
		 * Конструктор класса который отвечает за логику игры
		 *
		 * @param structCells Структура заполненная клетками
		 * @param arrWhiteCheckers Массив белых шашек
		 * @param arrBlackCheckers Массив черных шашек
		 * @param teamPlayer Команда за которую играет игрок (false - за белых, true - за черных)
		 * @param levelGame Уровень сложности игры
		 */
		public function Logic(structCells:Object, arrWhiteCheckers:Array, arrBlackCheckers:Array, teamPlayer:Boolean = false, levelGame:int = 0) {
			this._teamPlayer = teamPlayer;
			this.arrBlackCheckers = arrBlackCheckers;
			this.arrWhiteCheckers = arrWhiteCheckers;
			this.structCells = structCells;
			this.strucCells = new StructureCells(structCells);		// Создаем дополнительную структуру клеток для упрощения доступа к ним
			
			addListeners();								// Добавляем слушателей шашки игрока и на все клетки доски
			
			bot = new Bot(!teamPlayer, (!teamPlayer? this.arrBlackCheckers : this.arrWhiteCheckers), this, levelGame);	// Создаем бота
		}
		
		
		/**
		 * Проверить и сделать ход
		 * @param	checker Шашка которой пытаемся сделать ход
		 * @param	cell Клетка на которую ходим
		 * @param	makeMove Флаг указывает на то нужно ли делать ход, или просто проверить возможность
		 * @return true - если ход возможен (был сделан), false - иначе
		 */
		public function checkMove(checker:Checker, cell:Cell, makeMove:Boolean = true):Boolean {
				
				if (cell.isOccupied)									// Если клетка занята тогда невозможно сделать ход
					return false;
				
				if (checker.isQueen) {									// Если выбраная шашка есть дамкой, тогда проверяем возможность хода другой функцией
					return checkMoveQueen(checker, cell, makeMove);
				}
				
				// Если клетка на которую ходим, находится рядом возле клетки на которой стоит шашка которой ходим - тогда делаем ход (при чем ход назад невозможен, поэтому для белых проверяем на рядок выше i+1, а для черных на рядок ниже i-1)
				if ((cell.j == checker.currentCell.j  + 1 || cell.j == checker.currentCell.j  - 1) 
					&& ((cell.i == checker.currentCell.i + 1 && checker.team == Logic.WHITE_TEAM) 
					|| (cell.i == checker.currentCell.i - 1 && checker.team == Logic.BLACK_TEAM))
					&& !checkFightingTeam(checker.team)) {
					if (makeMove) {							// Делаем ход если нужно
						checker.moveTo(cell);
						this._lastMovingChecker = checker;	// Запоминаем шашку которая ходила последний раз
						checkQueen(checker);				// Делаем проверку на то стала ли шашка дамкой
					}
					return true;
				}
					
				// Если клетка на которую ходим находится через одну от клетки на которой стоит шашка которой ходим
				if ((checker.currentCell.i + 2 == cell.i) && (checker.currentCell.j + 2 == cell.j)
					|| (checker.currentCell.i + 2 == cell.i) && (checker.currentCell.j - 2 == cell.j)
					|| (checker.currentCell.i - 2 == cell.i) && (checker.currentCell.j + 2 == cell.j)
					|| (checker.currentCell.i - 2 == cell.i) && (checker.currentCell.j - 2 == cell.j)) {
						// Находим прирост индексов, от клетки из шашкой к клетки на которую ходим
						var ii:int = (cell.i - checker.currentCell.i) / 2;
						var jj:int = (cell.j - checker.currentCell.j) / 2;
						var enemyCell:Cell = this.strucCells.getIJ(cell.i - ii, cell.j - jj);			// Получаем клетку на которой возможно стоит вражеская шашка
						if (enemyCell.isOccupied && enemyCell.currentChecker.team != checker.team) {	// Если вражеская клетка занята, и на ней стоит шашка из противоположной команды, тогда возможно сделать бой
							if (makeMove) {																// Делаем ход если нужно
								killChecker(enemyCell.currentChecker);									// Убиваем вражескую шашку
								checker.moveTo(cell);
								this._lastMovingChecker = this.lastFightingChecker = checker;			// Запоминаем шашку которая ходила и била последний раз
								checkQueen(checker);													// Делаем проверку на то стала ли шашка дамкой
							}
							return true;
						}
				}
			
			return false;
		}
		
		
		
		/**
		 * Проверить возможность указанной команды побить шашки соперника (сделать бой). 
		 *
		 * @param team Цвет комманды которой нужно проверить возможность боя (false - команда белых, true - команда черных)
		 * @return True - если бой возможен, false - иначе
		 */
		public function checkFightingTeam(team:Boolean, makeFighting:Boolean = false):Boolean {
			// Взависимости от тога какая команда запрашивает ответ, такой массив шашек выбираем для проверки
			var teamCheckers:Array = (team == Logic.WHITE_TEAM? this.arrWhiteCheckers : this.arrBlackCheckers);
			// Если нету последней походившей шашки, то это тот случай когда нужно перебрать все шашки команды и проверить возможность каждой сделать бой
			if (this._lastMovingChecker == null) {
				// Перебираем все живые шашки команды
				for each (var checker:Checker in teamCheckers) {	
					// Если взяли дамку, тогда проверяем возможность сделать бой дамкой - отдельной функцией				
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
			else {	// Если команда уже ходила шашкой, тогда проверяем сделан ли бой этой командой. Если существует последняя шашка которая била, тогда проверяем только ее на возможность сделать ещо один бой. (Бить несколько шашек противника возможно только одной шашкой и сразу).
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
		 * Проверить сможет ли побить противоположная команда шашку, которая стоит на клетке currentCell, и пытается походить на клетку toCell
		 * @param	currentCell Клетка на которой стоит шашка которая проверяется
		 * @param	toCell Клетка куда хочет походить шашка
		 * @return true - если шашку побьют, false - иначе
		 */
		public function checkKilling(currentCell:Cell, toCell:Cell):Boolean {
			var k:int = 0;
			
			var iStep:int;
			var jStep:int;
			var i:int;
			var j:int;
				
			// Делаем всего 4 прохода, которые соответствуют 4 - м диагональным направлениям по которым может походить дамка
			while (k <= 4) {
				k++;
				
				// Определяем направление, за каждый проход проверяем одну из четырех диагональных направлений
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
				
				// Получаем клетку которая стоит за шашкой, относительно выбраного направления. 
				// Если эта клетка занята (неважно кем), тогда невозможно побить шашку из этого направления
				var backCell:Cell = this.strucCells.getIJ(toCell.i - iStep, toCell.j - jStep);
				if (backCell != null && backCell.isOccupied && backCell != currentCell)
					continue;
					
				// Проходим всю диагональ
				while (i <= Logic.MAX_SIZE_BOARD && i >= 1 && j <= Logic.MAX_SIZE_BOARD && j >= 1) {
					var curCell:Cell = this.strucCells.getIJ(i, j);
					if (curCell.isOccupied) {													// Если клетка занята
						if (curCell.currentChecker.team == currentCell.currentChecker.team) {	// Если на клетке стоит своя шашка, тогда перейти к следующей итерации (взять для проверки другое направление)
							break;
						}
							
						// Если на клетке стоит вражеская шашка, тогда проверяем следущую клетку, если она не занйнята - тогда возможно зделать бой, 
						// иначе на этом направлении не возможно сделать бой, так как перелететь через две вражеские шашки нельзя
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
		 * Проверить и сделать ход дамкой
		 * @param	checker Дамка которой ходим
		 * @param	cell Клетка на которую ходим
		 * @param	makeMove Флаг указывает на то нужно ли делать ход, или просто проверить возможность
		 * @return true - если ход возможен (был сделан), false - иначе
		 */
		private function checkMoveQueen(checker:Checker, cell:Cell, makeMove:Boolean = true):Boolean {
			// Если дамка стоит на одной диагонале из клеткой на которую ходим (это будет когда прирост столбцов и рядков одинаковый по модулю)
			if (Math.abs(cell.i - checker.currentCell.i) == Math.abs(cell.j - checker.currentCell.j)) {
					
				// Вычисляем прирост для рядков и столбцов, с этим приростом мы будем шагать с проверкой от дамки к клетке на которую ходим
				var iStep:int = cell.i > checker.currentCell.i ? 1 : -1;
				var jStep:int = cell.j > checker.currentCell.j ? 1 : -1;
				var i:int = checker.currentCell.i + iStep;
				var j:int = checker.currentCell.j + jStep;
				var lastIsOccupied:Boolean;		// Будет указывать зайнята ли предыдущая клетка га диагонали
				var isEnemy:Boolean;			// Будет указывать обнаружен ли враг на диагонали
					
				// Проходим всю диагональ от выделенной дамки к клетки
				while (i != cell.i) {
					var curCell:Cell = this.strucCells.getIJ(i, j);
					if (curCell.isOccupied) {								// Если клетка занята
						if (curCell.currentChecker.team == checker.team) {	// Если на этой диагонали стоит хоть одна своя шашка, тогда ход невозможен
							return false;
						}
							
						// Если на клетке стоит вражеская шашка, тогда запомнить это у флаг, если предыдущая клетка тоже была занята, тогда ход невозможен (через две шашки перелететь нельзя)
						if (curCell.currentChecker.team != checker.team) {	
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
			
				// Если был обнаружен враг на диагонали, тогда убить все шашки на этой диагонали
				if (isEnemy) {
					if (makeMove) {
						// Убиваем
						i = checker.currentCell.i + iStep;
						j = checker.currentCell.j + jStep;
						
						while (i != cell.i) {
							var curCell:Cell = this.strucCells.getIJ(i, j);
							if (curCell.isOccupied) {			// Если клетка занята
								killChecker(curCell.currentChecker);
							}
								
							j += jStep;
							i += iStep;
						}
						
						checker.moveTo(cell);
						this._lastMovingChecker = this.lastFightingChecker = checker;	// Запоминаем шашку которая ходила и била последний раз
					}
					return true;
				}
				// Если не обнаружено вражеских шашек на диагонали, тогда проверяем возможность боя для этой команды,
				// и только когда для этой команды бой невозможен тогда делаем обычный ход дамкой
				else {								
					if (!checkFightingTeam(checker.team)) {
						if (makeMove) {
							checker.moveTo(cell);
							this._lastMovingChecker = checker;
						}
						return true;
					}
				}
					
			}
			
			return false;
		}
		
				
		/**
		 * Убить шашку
		 *
		 * @param checker Шашка которую нужно убить
		 */
		private function killChecker(checker:Checker):void {
			
			// Если нужно убить белую шашку
			if (checker.team == Logic.WHITE_TEAM) {											
				checker.kill(cemetryWhite.x, cemetryWhite.y, cemetryWhite.z);				// Убиваем шашку
				cemetryWhite.x += Graphic.WIDTH_CHECKER + 0.1;								// Расчитывем новое место на кладвище 
				this.arrWhiteCheckers.splice(this.arrWhiteCheckers.indexOf(checker), 1);	// Удаляем шашку из массива белых шашек
				
			}
			
			// Если нужно убить черную шашку
			if (checker.team == Logic.BLACK_TEAM) {											
				checker.kill(cemetryBlack.x, cemetryBlack.y, cemetryBlack.z);				// Убиваем шашку
				cemetryBlack.x += Graphic.WIDTH_CHECKER + 0.1;
				this.arrBlackCheckers.splice(this.arrBlackCheckers.indexOf(checker), 1);	// Удаляем шашку из массива черных шашек
			}
			
			// Если это шашка игрока тогда отписываемся от клика
			if (checker.team == this.teamPlayer) {
				checker.removeEventListener(MouseEvent3D.CLICK, onCheckerClicked);
			}
			
			// Удаляем бота если какаято команда проиграла
			if (this.NumberWhite == 0 || this.NumberBlack == 0) {
				bot.removeBot();
			}

			this.dispatchEvent(new Event(CHECKER_KILLED));			// Событие - шашка убита
		}
		
				
		/**
		 * Проверить, стала ли шашка королевой
		 * 
		 * @param	checker Шашка которую нужно проверить
		 * @return true - если шашка стала королевой, false - иначе
		 */
		private function checkQueen(checker:Checker):Boolean {
			if (checker.isQueen)									// Если шашка уже дамка, тогда выйти
				return false;
			
			if (checker.team == Logic.WHITE_TEAM) {					// Если выбрана белая шашка
				if (checker.currentCell.i == MAX_SIZE_BOARD) {		// Если шашка дошла до противоположеного конца доски (для белых это 8-й ряд), тогда сделать ее дамкой
					checker.setQueen();
					return true;
				}
			}			
			
			if (checker.team == Logic.BLACK_TEAM) {			// Если выбрана черная шашка
				if (checker.currentCell.i == 1) {			// Если шашка дошла до противоположеного конца доски (для черных это 1-й ряд), тогда сделать ее дамкой
					checker.setQueen();
					return true;
				}
			}
			
			return false;
		}
		
		
		/**
		 * Проверить возможность дамки побить шашки соперника
		 * @param	checker Входящая дамка
		 * @param	makeFighting Если true тогда дамка сделает один первый возможный бой
		 * @return true - если дамка может побить шашки соперника. false - иначе
		 */
		private function checkFightingQueen(checker:Checker, makeFighting:Boolean = false):Boolean {
			var k:int = 0;
			
			var iStep:int;
			var jStep:int;
			var i:int;
			var j:int;
				
			// Делаем всего 4 прохода, которые соответствуют 4 - м диагональным направлениям по которым может походить дамка
			while (k <= 4) {
				k++;
				
				// Определяем направление, за каждый проход проверяем одну из четырех диагональных направлений
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
				
				i = checker.currentCell.i + iStep;
				j = checker.currentCell.j + jStep;
				// Проходим всю диагональ
				while (i <= Logic.MAX_SIZE_BOARD && i >= 1 && j <= Logic.MAX_SIZE_BOARD && j >= 1) {
					var curCell:Cell = this.strucCells.getIJ(i, j);
					if (curCell.isOccupied) {			// Если клетка занята
						if (curCell.currentChecker.team == checker.team) {	// Если на клетке стоит своя шашка, тогда перейти к следующей итерации (взять для проверки другое направление)
							break;
						}
							
						// Если на клетке стоит вражеская шашка, тогда проверяем следущую за ней клетку, если она не занйнята - тогда возможно зделать бой, 
						// иначе на этом направлении не возможно сделать бой, так как перелететь через две вражеские шашки невозможно
						if (curCell.currentChecker.team != checker.team) {	
							if (this.strucCells.getIJ(i + iStep, j + jStep) != null && !this.strucCells.getIJ(i + iStep, j + jStep).isOccupied) {
								if (makeFighting) {
									killChecker(curCell.currentChecker);									// Убиваем вражескую шашку
									checker.moveTo(this.strucCells.getIJ(i + iStep, j + jStep));
									this._lastMovingChecker = this.lastFightingChecker = checker;			// Запоминаем шашку которая ходила и била последний раз
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
		 * Проверить возможность входящей шашки побить шашки соперника
		 * @param	checker Входящая шашка
		 * @param	makeFighting Если true тогда шашка сделает один первый возможный бой
		 * @return true - если шашка может побить шашки соперника. false - иначе
		 */
		private function checkFightingChecker(checker:Checker, makeFighting:Boolean = false):Boolean {
			
			// Получаем нужные клетки вокруг шашки
			var cellTL2:Cell = this.strucCells.getTL2(checker.currentCell);
			var cellTL1:Cell = this.strucCells.getTL1(checker.currentCell);
			var cellTR2:Cell = this.strucCells.getTR2(checker.currentCell);
			var cellTR1:Cell = this.strucCells.getTR1(checker.currentCell);
			var cellBL2:Cell = this.strucCells.getBL2(checker.currentCell);
			var cellBL1:Cell = this.strucCells.getBL1(checker.currentCell);
			var cellBR2:Cell = this.strucCells.getBR2(checker.currentCell);
			var cellBR1:Cell = this.strucCells.getBR1(checker.currentCell);
			
			// Если не нужно сделать бой шашкой, тогда проверить только возможность сделать бой
			if (!makeFighting) {
				if ((cellTL2 != null && !cellTL2.isOccupied && cellTL1.isOccupied && cellTL1.currentChecker.team != checker.team)
					|| (cellTR2 != null && !cellTR2.isOccupied && cellTR1.isOccupied && cellTR1.currentChecker.team != checker.team)
					|| (cellBL2 != null && !cellBL2.isOccupied && cellBL1.isOccupied && cellBL1.currentChecker.team != checker.team)
					|| (cellBR2 != null && !cellBR2.isOccupied && cellBR1.isOccupied && cellBR1.currentChecker.team != checker.team))
					return true;
			}
			
			// Если вторая клетка по диагонале свободна, а первая клетка по диагонале занята вражеской шашкой - тогда бой возможен
			if ((cellTL2 != null && !cellTL2.isOccupied && cellTL1.isOccupied && cellTL1.currentChecker.team != checker.team)) {
				killChecker(cellTL1.currentChecker);									// Убиваем вражескую шашку
				checker.moveTo(cellTL2);
				this._lastMovingChecker = this.lastFightingChecker = checker;			// Запоминаем шашку которая ходила и била последний раз
				checkQueen(checker);													// Делаем проверку на то стала ли шашка дамкой
				return true;
			}	
			
			if ((cellTR2 != null && !cellTR2.isOccupied && cellTR1.isOccupied && cellTR1.currentChecker.team != checker.team)) {
				killChecker(cellTR1.currentChecker);									// Убиваем вражескую шашку
				checker.moveTo(cellTR2);
				this._lastMovingChecker = this.lastFightingChecker = checker;			// Запоминаем шашку которая ходила и била последний раз
				checkQueen(checker);													// Делаем проверку на то стала ли шашка дамкой
				return true;
			}	
			
			if ((cellBL2 != null && !cellBL2.isOccupied && cellBL1.isOccupied && cellBL1.currentChecker.team != checker.team)) {
				killChecker(cellBL1.currentChecker);									// Убиваем вражескую шашку
				checker.moveTo(cellBL2);
				this._lastMovingChecker = this.lastFightingChecker = checker;			// Запоминаем шашку которая ходила и била последний раз
				checkQueen(checker);													// Делаем проверку на то стала ли шашка дамкой
				return true;
			}	
			
			if ((cellBR2 != null && !cellBR2.isOccupied && cellBR1.isOccupied && cellBR1.currentChecker.team != checker.team)) {
				killChecker(cellBR1.currentChecker);									// Убиваем вражескую шашку
				checker.moveTo(cellBR2);
				this._lastMovingChecker = this.lastFightingChecker = checker;			// Запоминаем шашку которая ходила и била последний раз
				checkQueen(checker);													// Делаем проверку на то стала ли шашка дамкой
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