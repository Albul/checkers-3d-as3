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
	 * Класс отвечает за поведение бота
	 */
	public class Bot extends Object {
		
		private var arrCheckers:Array;			// Массив доступных шашек боту
		private var teamComputer:Boolean;		// Команда за которую играет компьютер
		private var logic:Logic;				// Указатель на класс логики игры
		private var level:int;					// Уровень сложности бота
		
		/**
		 * Конструктор
		 * @param	teamComputer Команда бота
		 * @param	arrCheckers Массив шашек бота
		 * @param	logic Указатель на класс логики игры
		 * @param	level Уровень сложности бота
		 */
		public function Bot(teamBot:Boolean, arrCheckers:Array, logic:Logic, level:int = 1) {
			this.level = level;
			this.teamComputer = teamBot;
			this.arrCheckers = arrCheckers;
			this.logic = logic;
			
			logic.addEventListener(Logic.WHO_MOVE_CHANGED, onWhoMoveChanged);	// Вешаем слушателя на смену хода команд
			if (teamBot == Logic.WHITE_TEAM) toMove();							// Если компьютер играет за белых тогда сразу делаем ход
		}
	
				
		/**
		 * Изменилась команда которая должна ходить
		 */
		private function onWhoMoveChanged(e:Event):void {
			if (logic.whoMove == this.teamComputer) {
				setTimeout(toMove, 750);					// Сделать ход из задержкой (для красоты)
			}
		}
		
		
		/**
		 * Сделать завершенный ход
		 */
		private function toMove():void {
			do {
				if (!makeMove(this.level)) {			// Если не получится сделать ход 2 - го левела, тогда сделать ход на левел ниже
					makeMove(this.level - 1);
				}
			} while (this.logic.checkFightingTeam(this.teamComputer));
			
			logic.whoMove = !this.teamComputer;			// Отдаем ход противоположенной команде
		}
		
		
		/**
		 * Сделать единичный ход
		 * @param	level Уровень сложности хода
		 * @return true - если ход был сделан, false - иначе
		 */
		private function makeMove(level:int):Boolean {
			switch (level) {
				case 1:											// Первый уровень сложности хода
					if (this.logic.lastMovingChecker != null) {	// Если существует последняя шашка которая сделала ход, то только ею и возможно ходить, а точнее бить, тогда делаем ею бой
						this.logic.lastMovingChecker.raise();
						this.logic.checkFightingTeam(this.teamComputer, true);
						this.logic.lastMovingChecker.lower();
					}
					else {
						// Создаем случайную выборку массива шашек
						var randArrOut:RandomArrayOutput = new RandomArrayOutput();		
						randArrOut.createRandom(this.arrCheckers);
							
						// Проходим один раз выборку
						while (!randArrOut.isPrinted) {
							var checker:Checker = randArrOut.getRandomItem();		// Получаем случайную шашку
							for each (var cell:Cell in logic.structCells) {			// Пробегаем все клетки доски
								if (this.logic.checkMove(checker, cell, false)) {	// Проверяем возможность хода выбранyой шашки на выбраyную клетку, и если возможно то ходим ею
									checker.raise();
									this.logic.checkMove(checker, cell, true);		// Делаем ход
									checker.lower();
									return true;
								}
							}
						}
						return false;
					}
				break;
				case 2: 											// Второй уровень сложности хода
					if (this.logic.lastMovingChecker != null) {		// Если существует последняя шашка которая сделала ход, то только ею и возможно ходить, а точнее бить, тогда делаем ею бой
						this.logic.lastMovingChecker.raise();
						this.logic.checkFightingTeam(this.teamComputer, true);
						this.logic.lastMovingChecker.lower();
					}
					else {
						// Создаем случайную выборку массива шашек
						var randArrOut:RandomArrayOutput = new RandomArrayOutput();		
						randArrOut.createRandom(this.arrCheckers);
							
						// Проходим один раз выборку
						while (!randArrOut.isPrinted) {
							var checker:Checker = randArrOut.getRandomItem();		// Получаем случайную шашку
							for each (var cell:Cell in logic.structCells) {			// Пробегаем все клетки доски
								if (this.logic.checkMove(checker, cell, false)) {	// Проверяем возможность хода выбранной шашки на выбранную клетку
									if (!this.logic.checkKilling(checker.currentCell, cell)) {	// Если ход возможен, тогда проверяем может ли противник побить шашку на выбраной клетке
										checker.raise();
										this.logic.checkMove(checker, cell, true);				// Если соперник не может побить, тогда делаем ход
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
		
		
		/**
		 * Удалить бота. Он перестанет реагировать на смену хода
		 */
		public function removeBot():void {
			logic.removeEventListener(Logic.WHO_MOVE_CHANGED, onWhoMoveChanged);
		}

	}

}