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
	
	/**
	 * Структура облегчающая доступ к клеткам
	 */
	public class StructureCells extends Object {
		
		private var structCells:Object;			// Оригинальная структура заполненная клетками
		
		/**
		 * Конструктор
		 * 
		 * @param structCells Структура заполненная клетками
		 */
		public function StructureCells(structCells:Object) {
			this.structCells = structCells;
		}
		
		/**
		 * Получить клетку с индексом ij
		 * 
		 * @param i Строка клетки
		 * @param j Столбец клетки
		 * @return Клетка
		 */
		public function getIJ(i:int, j:int):Cell {
			if (this.structCells.hasOwnProperty(String(i) + String(j)))		// Если существует такая клетка в структуре тогда вернуть ее
				return this.structCells[String(i) + String(j)];
			return null;
		}
		
		
		/**
		 * Получить вторую верхнюю левую клетку [Top Left], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getTL2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 2) + String(cell.j - 2)))		// Если существует такая клетка в структуре тогда вернуть ее
				return this.structCells[String(cell.i + 2) + String(cell.j - 2)];
			return null;
		}	
		
		
		/**
		 * Получить вторую верхнюю правую клетку [Top Right], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getTR2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 2) + String(cell.j + 2)))		
				return this.structCells[String(cell.i + 2) + String(cell.j + 2)];
			return null;
		}		
		
		
		/**
		 * Получить вторую нижнюю левую клетку [Bottom Left], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getBL2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 2) + String(cell.j - 2)))		
				return this.structCells[String(cell.i - 2) + String(cell.j - 2)];
			return null;
		}	
		
		
		/**
		 * Получить вторую нижнюю правую клетку [Bottom Right], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getBR2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 2) + String(cell.j + 2)))		
				return this.structCells[String(cell.i - 2) + String(cell.j + 2)];
			return null;
		}		
		
		
		/**
		 * Получить первую верхнюю левую клетку [Top Left], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getTL1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 1) + String(cell.j - 1)))		// Если существует такая клетка в структуре тогда вернуть ее
				return this.structCells[String(cell.i + 1) + String(cell.j - 1)];
			return null;
		}	
		
		
		/**
		 * Получить первую верхнюю правую клетку [Top Right], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getTR1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 1) + String(cell.j + 1)))		
				return this.structCells[String(cell.i + 1) + String(cell.j + 1)];
			return null;
		}		
		
		
		/**
		 * Получить первую нижнюю левую клетку [Bottom Left], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getBL1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 1) + String(cell.j - 1)))		
				return this.structCells[String(cell.i - 1) + String(cell.j - 1)];
			return null;
		}	
		
		
		/**
		 * Получить первую нижнюю правую клетку [Bottom Right], относительно входной клетки
		 * 
		 * @param cell Входная клетка
		 * @return Клетка
		 */
		public function getBR1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 1) + String(cell.j + 1)))		
				return this.structCells[String(cell.i - 1) + String(cell.j + 1)];
			return null;
		}
		
	}

}