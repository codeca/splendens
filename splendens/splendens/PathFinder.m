//
//  PathFinder.m
//  splendens
//
//  Created by Rodolfo Bitu on 24/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "PathFinder.h"
#import "Map.h"

@interface PathFinder()


+ (int) cellToInt: (Cell*)cell andMap: (Map*)map;
+ (Cell*) intToCell: (int) cell andMap: (Map*)map;
+ (NSMutableArray*) reconsPath: (int*)cameFrom andMap:(Map*) map andCurrent: (Cell*) current;
@end

@implementation PathFinder

//A* algorithm to find a shortest path from cell start to cell goal, returns a NSArray with the path.
//More info about A* at wiki
+ (NSArray*) findPathwithStart: (Cell*)start andGoal: (Cell*)goal andMap:(Map *)map{
	if (start == goal) return nil;
	//init
	int* possibleDistance;
	possibleDistance = (int*)malloc(map.size*map.size*sizeof(int));
	int startRealDistance[map.size*map.size];
	int cameFrom[map.size*map.size];
	NSMutableArray* evaluated;
	NSMutableArray* toEvaluate;
	for (int i = 0; i < map.size*map.size; i++){
		cameFrom[i] = -1;
	}
	evaluated = [[NSMutableArray alloc]init];
	toEvaluate = [[NSMutableArray alloc]init];
	[toEvaluate addObject:start];
	startRealDistance[[PathFinder cellToInt:start andMap:map]] = 0;
	possibleDistance[[PathFinder cellToInt:start andMap:map]] = start.x+start.y;
	
	//set comparator to sort toEvaluate Array
	NSComparator comp = ^(Cell* a, Cell* b){
		if (possibleDistance[ [PathFinder cellToInt:a andMap:map]] > possibleDistance[ [PathFinder cellToInt:b andMap:map]] ) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		
		if (possibleDistance[ [PathFinder cellToInt:a andMap:map]] < possibleDistance[ [PathFinder cellToInt:b andMap:map]] ) {
			return (NSComparisonResult)NSOrderedDescending;
		}
		return (NSComparisonResult)NSOrderedSame;
		
	};
	
	[toEvaluate sortUsingComparator:comp];
	
	//A* algorithm
	while([toEvaluate count] > 0){
		Cell* current;
		current = toEvaluate[[toEvaluate count]-1]; //get the cell with smaller possibleDistance
		if (current == goal){
			free(possibleDistance);
			return [PathFinder reconsPath: cameFrom andMap: map andCurrent:goal]; //found the path!
		}
		else{
			[evaluated addObject:current];
			[toEvaluate removeObject:current];
			//get all neighbors
			for (int i=-1;i<=1;i++){
				for (int j=-1;j<=1;j++){
					if (i==j || i==-j) continue;
					Cell* neighbor = [map cellAtX:current.x+i y:current.y+j];
					if (neighbor != nil && (neighbor.type == CellTypeEmpty || neighbor == goal)){
						int neighborInt = [PathFinder cellToInt:neighbor andMap:map];
						int currentInt = [PathFinder cellToInt:current andMap:map];
						int tentativeStartRealDistance = startRealDistance[currentInt]+1;
						int tentativePossibleDistance = tentativeStartRealDistance + neighbor.x + neighbor.y;
						if ([evaluated indexOfObject:neighbor]!=NSNotFound && tentativePossibleDistance >= possibleDistance[neighborInt]) continue;
						if ([toEvaluate indexOfObject:neighbor]==NSNotFound || tentativePossibleDistance<possibleDistance[neighborInt]){
							
							cameFrom[neighborInt] = currentInt;
							
							possibleDistance[neighborInt] = tentativePossibleDistance;
							startRealDistance[neighborInt] = tentativeStartRealDistance;
							if ([toEvaluate indexOfObject:neighbor]==NSNotFound){
								[toEvaluate addObject:neighbor];
							}
						}
					}
					
				}
				[toEvaluate sortUsingComparator:comp];
			}
		}
	}
	free(possibleDistance);
	return nil;	//found no path :(
}

+ (Cell*) intToCell: (int) cell andMap: (Map*)map{
	if (cell%map.size < 0 || cell%map.size >= map.size || cell/map.size < 0 || cell/map.size >= map.size) return nil;
	return [map cellAtX: cell%map.size y:cell/map.size];
}

+ (int) cellToInt: (Cell*)cell andMap: (Map*)map{
	return cell.y*map.size+cell.x;
}

//Reconstruct path from cameFrom vector
+ (NSMutableArray*) reconsPath: (int*)cameFrom andMap:(Map*) map andCurrent: (Cell*) current{
	
	if (cameFrom[[PathFinder cellToInt: current andMap: map]] == -1){
		return [[NSMutableArray alloc] initWithObjects:current, nil];
	}
	
	Cell* parent = [PathFinder intToCell: cameFrom[[PathFinder cellToInt: current andMap: map]] andMap:map];
	NSMutableArray* temp = [PathFinder reconsPath: cameFrom andMap: map andCurrent:parent];
	[temp addObject: current];
	return temp;
}

@end
