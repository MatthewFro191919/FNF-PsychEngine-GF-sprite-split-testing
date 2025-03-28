package flixel.addons.tile;

import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;

#if (flixel < version("5.9.0"))
/**
 * @author greglieberman
 */
@:deprecated("FlxRayCastTilemap is deprecated, use FlxTilemap.ray or rayStep, instead")
class FlxRayCastTilemap extends FlxTilemap
{
	/**
	 * Casts a ray from the start point until it hits either a filled tile, or the edge of the tilemap
	 *
	 * If the starting point is outside the bounding box of the tilemap,
	 * it will not cast the ray, and place the end point at the start point.
	 *
	 * Warning: If your ray is completely horizontal or vertical, make sure your x or y values are exactly zero.
	 * Otherwise you may suffer the wrath of floating point rounding error!
	 *
	 * Algorithm based on
	 * http://www.metanetsoftware.com/technique/tutorialB.html
	 * http://www.cse.yorku.ca/~amana/research/grid.pdf
	 * http://www.flipcode.com/archives/Raytracing_Topics_Techniques-Part_4_Spatial_Subdivisions.shtml
	 *
	 * @param 	Start    			The starting point of the ray
	 * @param 	Direction   		The direction to shoot the ray. Does not need to be normalized
	 * @param 	Result   			Where the resulting point is stored, in (x,y) coordinates
	 * @param 	ResultInTiles  		A point containing the tile that was hit, in tile coordinates (optional)
	 * @param 	MaxTilesToCheck 	The maximum number of tiles you want the ray to pass. -1 means go across the entire tilemap. Only change this if you know what you're doing!
	 * @return   True if hit a filled tile, false if it hit the end of the tilemap
	 *
	 */
	public function rayCast(Start:FlxPoint, Direction:FlxPoint, ?Result:FlxPoint, ?ResultInTiles:FlxPoint, MaxTilesToCheck:Int = -1):Bool
	{
		// Current x, y, in tiles
		var cx:Float;
		var cy:Float;
		// Starting tile cell bounds, in pixels
		var cbx:Float;
		var cby:Float;
		// Maximum time the ray has traveled so far (not distance!)
		var tMaxX:Float;
		var tMaxY:Float;
		// The time that the ray needs to travel to cross a single tile (not distance!)
		var tDeltaX:Float = 0;
		var tDeltaY:Float = 0;
		// Step direction, either 1 or -1
		var stepX:Float;
		var stepY:Float;
		// Bounds of the tileMap where the ray would exit
		var outX:Float;
		var outY:Float;
		var hitTile:Bool = false;
		var tResult:Float = 0;

		if (Start == null)
		{
			return false;
		}

		if (Result == null)
		{
			Result = FlxPoint.get();
		}

		if (Direction == null || (Direction.x == 0 && Direction.y == 0))
		{
			// No direction, no ray
			Result.x = Start.x;
			Result.y = Start.y;

			return false;
		}

		// Find the tile at the start position of the ray
		cx = getColumnAt(Start.x);
		cy = getRowAt(Start.y);

		if (!inTileRange(cx, cy))
		{
			// Outside of the tilemap
			Result.x = Start.x;
			Result.y = Start.y;

			return false;
		}

		if (getTileIndex(Std.int(cx), Std.int(cy)) > 0)
		{
			// start point is inside a block
			Result.x = Start.x;
			Result.y = Start.y;

			return true;
		}

		if (MaxTilesToCheck == -1)
		{
			// This number is large enough to guarantee that the ray will pass through the entire tile map
			MaxTilesToCheck = widthInTiles * heightInTiles;
		}

		// Determine step direction, and initial starting block
		if (Direction.x > 0)
		{
			stepX = 1;
			outX = widthInTiles;
			cbx = x + (cx + 1) * scaledTileWidth;
		}
		else
		{
			stepX = -1;
			outX = -1;
			cbx = x + cx * scaledTileWidth;
		}

		if (Direction.y > 0)
		{
			stepY = 1;
			outY = heightInTiles;
			cby = y + (cy + 1) * scaledTileHeight;
		}
		else
		{
			stepY = -1;
			outY = -1;
			cby = y + cy * scaledTileHeight;
		}

		// Determine tMaxes and deltas
		if (Direction.x != 0)
		{
			tMaxX = (cbx - Start.x) / Direction.x;
			tDeltaX = scaledTileWidth * stepX / Direction.x;
		}
		else
		{
			tMaxX = 1000000;
		}

		if (Direction.y != 0)
		{
			tMaxY = (cby - Start.y) / Direction.y;
			tDeltaY = scaledTileHeight * stepY / Direction.y;
		}
		else
		{
			tMaxY = 1000000;
		}

		// Step through each block
		for (tileCount in 0...MaxTilesToCheck)
		{
			if (tMaxX < tMaxY)
			{
				cx = cx + stepX;
				if (getTileIndex(Std.int(cx), Std.int(cy)) > 0)
				{
					hitTile = true;
					break;
				}

				if (cx == outX)
				{
					hitTile = false;
					break;
				}

				tMaxX = tMaxX + tDeltaX;
			}
			else
			{
				cy = cy + stepY;

				if (getTileIndex(Std.int(cx), Std.int(cy)) > 0)
				{
					hitTile = true;
					break;
				}

				if (cy == outY)
				{
					hitTile = false;
					break;
				}

				tMaxY = tMaxY + tDeltaY;
			}
		}

		// Result time
		tResult = (tMaxX < tMaxY) ? tMaxX : tMaxY;

		// Store the result
		Result.x = Start.x + (Direction.x * tResult);
		Result.y = Start.y + (Direction.y * tResult);

		if (ResultInTiles != null)
		{
			ResultInTiles.x = cx;
			ResultInTiles.y = cy;
		}

		return hitTile;
	}

	public function inTileRange(TileX:Float, TileY:Float):Bool
	{
		return (TileX >= 0 && TileX < widthInTiles && TileY >= 0 && TileY < heightInTiles);
	}

	@:deprecated("tileAt is deprecated, use getTileIndexAt, instead")
	public function tileAt(worldX:Float, worldY:Float):Int
	{
		return getTileIndexAt(worldX, worldY);
	}

	@:deprecated("tileIndexAt is deprecated, use getMapIndexAt, instead")
	public function tileIndexAt(worldX:Float, worldY:Float):Int
	{
		return getMapIndexAt(worldX, worldY);
	}

	@:deprecated("coordsToTileX is deprecated, use getColumnAt, instead")
	public function coordsToTileX(worldX:Float):Float
	{
		return getColumnAt(worldX);
	}

	@:deprecated("coordsToTileY is deprecated, use getRowAt, instead")
	public function coordsToTileY(worldY:Float):Float
	{
		return getRowAt(worldY);
	}

	@:deprecated("indexToCoordX is deprecated, use getColumnPos(getColumn(mapIndex)), instead")
	public function indexToCoordX(mapIndex:Int):Float
	{
		return getColumnPos(getColumn(mapIndex));
	}

	@:deprecated("indexToCoordY is deprecated, use getRowPos(getRow(mapIndex)), instead")
	public function indexToCoordY(mapIndex:Int):Float
	{
		return getRowPos(getRow(mapIndex));
	}
}
#elseif FLX_NO_COVERAGE_TEST
#error "FlxRayCastTilemap has been removed in flixel-addons 4.0.0, use FlxTilemap.ray or rayStep, instead"
#end