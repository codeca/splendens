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

+ (NSArray*) findPathwithStart: (Cell*)start andGoal: (Cell*)goal andMap:(Map *)map{
	int* possibleDistance;
	possibleDistance = (int*)malloc(map.size*sizeof(int));
	int startRealDistance[map.size];
	int cameFrom[map.size];
	NSMutableArray* evaluated;
	NSMutableArray* toEvaluate;
	
	for (int i = 0; i < map.size; i++){
		cameFrom[i] = -1;
	}

	evaluated = [[NSMutableArray alloc]init];
	toEvaluate = [[NSMutableArray alloc]init];
	[toEvaluate addObject:start];
	
	startRealDistance[[PathFinder cellToInt:start andMap:map]] = 0;
	possibleDistance[[PathFinder cellToInt:start andMap:map]] = start.x+start.y;
	
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
	
	while([toEvaluate count] > 0){
		Cell* current;
		current = toEvaluate[[toEvaluate count]-1];
		if (current == goal){
			return [PathFinder reconsPath: cameFrom andMap: map andCurrent:goal];
		}
		else{
			[evaluated addObject:current];
			[toEvaluate removeObject:current];
			for (int i=-1;i<=1;i++){
				if (i==0) continue;
				for (int j=-1;j<=1;j++){
					if (j==0) continue;
					Cell* neighbor = [map cellAtX:current.x+i y:current.y+j];
					if (neighbor != nil){
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
	return nil;
}

+ (Cell*) intToCell: (int) cell andMap: (Map*)map{
	if (cell%map.size < 0 || cell%map.size >= map.size || cell/map.size < 0 || cell/map.size >= map.size) return nil;
	return [map cellAtX: cell%map.size y:cell/map.size];
}

+ (int) cellToInt: (Cell*)cell andMap: (Map*)map{
	return cell.y*map.size+cell.x;
}


+ (NSMutableArray*) reconsPath: (int*)cameFrom andMap:(Map*) map andCurrent: (Cell*) current{
	Cell* parent = [PathFinder intToCell: cameFrom[[PathFinder cellToInt: current andMap: map]] andMap:map];
	if (parent == nil){
		return [[NSMutableArray alloc] initWithObjects:current, nil];
	}
	NSMutableArray* temp = [PathFinder reconsPath: cameFrom andMap: map andCurrent:parent];
	[temp addObject: parent];
	return temp;
}

@end
