//
//  Plug.m
//
//  Created by Guilherme Souza on 10/17/13.
//

#import "MultiPlug.h"

@interface MultiPlug()

@property NSMutableData* readBuffer;
@property NSMutableData* writeBuffer;
@property NSInputStream* inputStream;
@property NSOutputStream* outputStream;
@property BOOL hasSpace;
@property BOOL halfOpen;
@property NSArray* wishes;

@end

#define MSG_IN_PLAYER_DISCONNECTED -1
#define MSG_IN_SIMPLE_MATCH_PROGRESS 1
#define MSG_IN_FRIEND_MATCH_NOT_FOUND 2
#define MSG_IN_FRIEND_MATCH_PROGRESS 3
#define MSG_IN_FRIEND_MATCH_CANCELED 4
#define MSG_IN_MATCH_DONE 5
#define MSG_OUT_SIMPLE_MATCH 0
#define MSG_OUT_FRIEND_MATCH_START 1
#define MSG_OUT_FRIEND_MATCH_JOIN 2

@implementation MultiPlug

+ (MultiPlug*)multiPlug {
	return [[MultiPlug alloc] init];
}

- (id)init {
	if (self = [super init]) {
		NSString* url = [MULTIPLUG_EXTERNAL_HOST stringByAppendingFormat:@"/get.php?key=%@&noCache=%d", [[NSBundle mainBundle] bundleIdentifier], arc4random()];
		if (MULTIPLUG_DEBUG) NSLog(@"Getting server ip in %@", url);
		NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		NSOperationQueue* queue = [NSOperationQueue currentQueue];
		[NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse* _, NSData* data, NSError* error) {
			if (error) {
				[self closeWithError];
				if (MULTIPLUG_DEBUG) NSLog(@"Error with the request, check your Internet connection");
				return;
			}
			
			NSString* ip = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if (MULTIPLUG_DEBUG) NSLog(@"Got %@, connecting at port %d", ip, MULTIPLUG_PORT);
			
			CFReadStreamRef readStream;
			CFWriteStreamRef writeStream;
			CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, MULTIPLUG_PORT, &readStream, &writeStream);
			self.inputStream = (__bridge_transfer NSInputStream*)readStream;
			self.outputStream = (__bridge_transfer NSOutputStream*)writeStream;
			
			[self.inputStream setDelegate:self];
			[self.outputStream setDelegate:self];
			[self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[self.inputStream open];
			[self.outputStream open];
			
			self.writeBuffer = [[NSMutableData alloc] initWithCapacity:1024];
			self.readBuffer = [[NSMutableData alloc] initWithCapacity:1024];
		}];
		self.myId = [[NSUUID UUID] UUIDString];
	}
	return self;
}

- (void)startSimpleMatch:(NSString*)userName wishes:(NSArray*)wishes {
	if (self.state != MULTIPLUGSTATE_OPEN)
		@throw @"Invalid plug state";
	[self sendRawMessage:MSG_OUT_SIMPLE_MATCH data:@{@"name": userName,
													 @"id": self.myId,
													 @"wishes": wishes}];
	self.wishes = wishes;
	self.state = MULTIPLUGSTATE_MATCHING;
}

- (NSString*)startFriendMatch:(NSString*)userName numPlayers:(int)num {
	if (self.state != MULTIPLUGSTATE_OPEN)
		@throw @"Invalid plug state";
	NSString* alphabet = @"ABCDEFGHJKMNPQRSTUVWXYZ23456789";
	NSMutableString* code = [NSMutableString string];
	for (int i=0; i<5; i++)
		[code appendString:[alphabet substringWithRange:NSMakeRange(arc4random_uniform(alphabet.length), 1)]];
	[self sendRawMessage:MSG_OUT_FRIEND_MATCH_START data:@{@"name": userName,
														   @"id": self.myId,
														   @"key": code,
														   @"players": [NSNumber numberWithInt:num]}];
	self.state = MULTIPLUGSTATE_MATCHING;
	return code;
}

- (void)joinFriendMatch:(NSString*)userName withKey:(NSString*)key {
	if (self.state != MULTIPLUGSTATE_OPEN)
		@throw @"Invalid plug state";
	[self sendRawMessage:MSG_OUT_FRIEND_MATCH_JOIN data:@{@"name": userName,
														  @"id": self.myId,
														  @"key": key}];
}

- (void)sendMessage:(int)type data:(id)data {
	if (self.state != MULTIPLUGSTATE_INGAME)
		@throw @"Invalid plug state";
	if (type < 0)
		@throw @"Invalid type value";
	[self sendRawMessage:type data:@{@"player": self.myId, @"data": data}];
}

- (void)close {
	if (self.state != MULTIPLUGSTATE_CLOSED) {
		[self.inputStream close];
		[self.outputStream close];
		self.state = MULTIPLUGSTATE_CLOSED;
	}
}

#pragma mark - internal methods

// Listen to stream events
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	if (eventCode & NSStreamEventOpenCompleted) {
		// Stream opened
		if (self.halfOpen) {
			// Connected
			self.halfOpen = NO;
			self.state = MULTIPLUGSTATE_OPEN;
			[self.delegate multiPlugConnected:self];
		} else
			// Wait for both streams to open
			self.halfOpen = YES;
	} else if (eventCode & NSStreamEventEndEncountered || eventCode & NSStreamEventErrorOccurred) {
		// Stream closed
		if (self.state != MULTIPLUGSTATE_CLOSED) {
			[self.delegate multiPlugClosedWithError:self];
			self.state = MULTIPLUGSTATE_CLOSED;
		}
	} else if (aStream == self.outputStream && eventCode & NSStreamEventHasSpaceAvailable) {
		// The client can send more data
		if (self.writeBuffer.length)
			[self write];
		else
			self.hasSpace = YES;
	} else if (aStream == self.inputStream && eventCode & NSStreamEventHasBytesAvailable) {
		// Data has arrived
		[self read];
	}
}

// Try to send the cached write buffer
- (void)write {
	int len = self.writeBuffer.length;
	
	if (self.state == MULTIPLUGSTATE_CLOSED)
		return;
	
	int writtenLen = [self.outputStream write:self.writeBuffer.bytes maxLength:len];
	
	if (writtenLen == -1) {
		[self closeWithError];
		return;
	}
	
	if (writtenLen)
		[self.writeBuffer setData:[self.writeBuffer subdataWithRange:NSMakeRange(writtenLen, len-writtenLen)]];
	
	if (writtenLen != len)
		self.hasSpace = NO;
}

// Try to read all data from the stream
- (void)read {
	static uint8_t buffer[512];
	int readLen;
	
	if (self.state == MULTIPLUGSTATE_CLOSED)
		return;
	
	do {
		readLen = [self.inputStream read:buffer maxLength:512];
		if (readLen > 0)
			[self.readBuffer appendBytes:buffer length:readLen];
	} while (readLen == 512);
	
	if (readLen < 0) {
		[self closeWithError];
		return;
	}
	
	[self processMessages];
}

// Extract messages from the read data
- (void)processMessages {
	int len;
	uint8_t bytes[3];
	NSError* error = NULL;
	
	while (true) {
		if (self.state == MULTIPLUGSTATE_CLOSED)
			return;
		
		// Read the message byte length
		if (self.readBuffer.length < 3)
			return;
		[self.readBuffer getBytes:bytes length:3];
		len = bytes[2]+(bytes[1]<<8)+(bytes[0]<<16);
		
		// Extract the data
		if (self.readBuffer.length < 3+len)
			return;
		NSData* data = [self.readBuffer subdataWithRange:NSMakeRange(3, len)];
		[self.readBuffer setData:[self.readBuffer subdataWithRange:NSMakeRange(len+3, self.readBuffer.length-len-3)]];
		
		// Inflate the JSON for [type data]
		NSArray* msg = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error) {
			[self closeWithError];
			return;
		}
		NSNumber* type = msg[0];
		[self processRawMessage:[type intValue] data:msg[1]];
	}
}

// Close the current connection sending the error flag
- (void)closeWithError {
	self.state = MULTIPLUGSTATE_CLOSED;
	[self.delegate multiPlugClosedWithError:self];
}

// Directly send a message
- (void)sendRawMessage:(int)type data:(id)data {
	NSError* error = NULL;
	NSArray* message = @[[NSNumber numberWithInt:type], data];
	NSData* bufferData = [NSJSONSerialization dataWithJSONObject:message options:0 error:&error];
	int len = bufferData.length;
	uint8_t bytes[3];
	bytes[0] = len>>16;
	bytes[1] = (len>>8)%256;
	bytes[2] = len%256;
	NSData* lenBuffer = [[NSData alloc] initWithBytes:bytes length:3];
	[self.writeBuffer appendData:lenBuffer];
	[self.writeBuffer appendData:bufferData];
	if (self.hasSpace)
		[self write];
}

// Initial message process
- (void)processRawMessage:(int)type data:(id)data {
	if (self.state == MULTIPLUGSTATE_INGAME) {
		if (type == MSG_IN_PLAYER_DISCONNECTED) {
			[self.delegate multiPlug:self playerDisconnected:data];
		} else {
			NSString* player = data[@"player"];
			id userData = data[@"data"];
			[self.delegate multiPlug:self receivedMessage:type data:userData player:player];
		}
	} else if (type == MSG_IN_SIMPLE_MATCH_PROGRESS) {
		// Pick the best waiting/wanted ratio
		float bestWanted = 1;
		float bestWaiting = 0;
		for (NSDictionary* each in data) {
			// Only consider rooms that this player is in
			NSNumber* wanted = each[@"wanted"];
			NSNumber* waiting = each[@"waiting"];
			if ([self.wishes indexOfObject:wanted] != NSNotFound) {
				float fWaiting = [waiting floatValue];
				float fWanted = [wanted floatValue];
				if (fWaiting/fWanted >= bestWaiting/bestWanted) {
					bestWanted = fWanted;
					bestWaiting = fWaiting;
				}
			}
		}
		
		[self.delegate multiPlug:self matchStatus:bestWaiting max:bestWanted];
	} else if (type == MSG_IN_FRIEND_MATCH_NOT_FOUND) {
		[self close];
		[self.delegate multiPlugFriendMatchNotFound:self];
	} else if (type == MSG_IN_FRIEND_MATCH_PROGRESS) {
		float wanted = [data[@"wanted"] floatValue];
		float waiting = [data[@"waiting"] floatValue];
		[self.delegate multiPlug:self matchStatus:waiting max:wanted];
	} else if (type == MSG_IN_FRIEND_MATCH_CANCELED) {
		[self close];
		[self.delegate multiPlugFriendMatchCanceled:self];
	} else if (type == MSG_IN_MATCH_DONE) {
		[self.delegate multiPlug:self matched:data];
	}
}

@end
