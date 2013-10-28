/*
 * 
 * Copyright (c) 2012, Albul Alexandr
 
	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package com {

	public class MathUtils {

		static public function roundTo(value:Number, to:Number):Number {
			//return (Math.floor(value / to) * to);
			return value - value % to;	
		}

		static public function toRadians(value:Number):Number {
			return (Math.PI / 180) * value;
		}

		static public function toDegrees(value:Number):Number {
			return (180 * value) * Math.PI;
		}

	}
}