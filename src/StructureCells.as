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
	 * The structure simplifies access to the cells
	 */
	public class StructureCells extends Object {


		private var structCells:Object; // The original structure filled cells


		public function StructureCells(structCells:Object) {
			this.structCells = structCells;
		}


		public function getIJ(i:int, j:int):Cell {
			if (this.structCells.hasOwnProperty(String(i) + String(j)))
				return this.structCells[String(i) + String(j)];
			return null;
		}
		
		
		/**
		 * Get a second top left cell, relative to the input cell
		 */
		public function getTL2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 2) + String(cell.j - 2)))
				return this.structCells[String(cell.i + 2) + String(cell.j - 2)];
			return null;
		}	
		
		
		/**
		 * Get a second top right cell, relative to the input cell
		 */
		public function getTR2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 2) + String(cell.j + 2)))		
				return this.structCells[String(cell.i + 2) + String(cell.j + 2)];
			return null;
		}		
		
		
		/**
		 * Get a second bottom left cell, relative to the input cell
		 */
		public function getBL2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 2) + String(cell.j - 2)))		
				return this.structCells[String(cell.i - 2) + String(cell.j - 2)];
			return null;
		}	
		
		
		/**
		 * Get a second bottom right cell, relative to the input cell
		 */
		public function getBR2(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 2) + String(cell.j + 2)))		
				return this.structCells[String(cell.i - 2) + String(cell.j + 2)];
			return null;
		}		
		
		
		/**
		 * Get a first top left cell, relative to the input cell
		 */
		public function getTL1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 1) + String(cell.j - 1)))
				return this.structCells[String(cell.i + 1) + String(cell.j - 1)];
			return null;
		}	
		
		
		/**
		 * Get a first top right cell, relative to the input cell
		 */
		public function getTR1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i + 1) + String(cell.j + 1)))		
				return this.structCells[String(cell.i + 1) + String(cell.j + 1)];
			return null;
		}		
		
		
		/**
		 * Get a first bottom left cell, relative to the input cell
		 */
		public function getBL1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 1) + String(cell.j - 1)))		
				return this.structCells[String(cell.i - 1) + String(cell.j - 1)];
			return null;
		}	
		
		
		/**
		 * Get a first bottom right cell, relative to the input cell
		 */
		public function getBR1(cell:Cell):Cell {
			if (this.structCells.hasOwnProperty(String(cell.i - 1) + String(cell.j + 1)))		
				return this.structCells[String(cell.i - 1) + String(cell.j + 1)];
			return null;
		}
		
	}
}