//
//  VCCacheManager.m
//  VedioVIPHelper
//
//  Created by ZHANG Zhipeng on 2018/11/15.
//  Copyright © 2018 zzp. All rights reserved.
//

#import "VCDiskCache.h"
#import "VCImageDecoder.h"
#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif

@implementation VCDiskCache {
	NSString *_path;
	CFMutableDictionaryRef _stmtDict;
	dispatch_queue_t _dbQueue;
	sqlite3 *_db;
}

+(id)sharedManager {
	static VCDiskCache *_sharedManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[VCDiskCache alloc] initWithPath: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
	});
	return _sharedManager;
}

- (id)initWithPath:(NSString *)path {
	if (self = [super init]) {
		_path = path;
		CFDictionaryValueCallBacks valueCallbacks = {0};
		_stmtDict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &valueCallbacks);
		_dbQueue = dispatch_queue_create("vc.db.queue", DISPATCH_QUEUE_SERIAL);
		[self db_open];
	}
	return self;
}

- (BOOL)db_initilize {
	// reference: https://www.sqlite.org/wal.html, Writers sync the WAL on every transaction commit if PRAGMA synchronous is set to FULL but omit this sync if PRAGMA synchronous is set to NORMAL
	NSString *sql = @"PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL; CREATE TABLE IF NOT EXISTS diskCache(KEY TEXT, DATA BLOB, MODIFIDE_TIME INTEGER, LAST_ACCESS_TIME INTEGER, PRIMARY KEY(KEY))";
	char *err;
	if (SQLITE_OK != sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err)) {
		NSLog(@"error is %s", err);
		return false;
	}
	return true;
}

- (BOOL)db_open {
	// fix sqlite3-dylib-illegal-multi-threaded-access: https://stackoverflow.com/questions/49198831/sqlite3-dylib-illegal-multi-threaded-access-to-database-connection
//	sqlite3_shutdown();
//	sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
//	sqlite3_initialize();
	NSString *fileName = [_path stringByAppendingString:@"/vccache.sqlite"];
	if (SQLITE_OK != sqlite3_open_v2([fileName UTF8String], &_db, SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, NULL)){
		NSLog(@"open db failed");
		return false;
	}
	return [self db_initilize];
}

- (sqlite3_stmt *)db_prepare_stmt:(NSString *)sql {
	if (!_db && ![self db_check]) {
		return nil;
	}
	sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(self->_stmtDict, (__bridge const void *)(sql));
	if (!stmt) {
		int result = sqlite3_prepare(self->_db, [sql UTF8String], (int)[sql length], &stmt, NULL);
		if (result != SQLITE_OK) {
			return nil;
		}
		CFDictionarySetValue(_stmtDict, (__bridge const void *)sql, stmt);
	} else {
		sqlite3_reset(stmt);
	}
	return stmt;
}

- (NSData *)searchObjectForKey:(NSString *)Key {
	NSString *sql = @"SELECT KEY, DATA, MODIFIDE_TIME, LAST_ACCESS_TIME FROM diskCache WHERE KEY = ?1";
	sqlite3_stmt *stmt = [self db_prepare_stmt:sql];
	sqlite3_bind_text(stmt, 1, Key.UTF8String, -1, NULL);
	NSData *item;
	if (sqlite3_step(stmt) == SQLITE_ROW) {
		item = [self db_objectForStmt:stmt];
	}
	
	return item;
}

- (NSData *)db_objectForStmt:(sqlite3_stmt *)stmt {
	NSData* data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 1) length:sqlite3_column_bytes(stmt, 1)];
	return data;
}

- (NSMutableArray<NSData *> *)searchObjects {
	NSMutableArray<NSData *> *items = [[NSMutableArray alloc] init];
	NSString *sql = @"SELECT * FROM diskCache";
	sqlite3_stmt *stmt = [self db_prepare_stmt:sql];
	int result;
	do {
		result = sqlite3_step(stmt);
		if (result == SQLITE_ROW) {
			NSData *item = [self db_objectForStmt:stmt];
			[items addObject:item];
		} else if (result == SQLITE_DONE) {
			break;
		} else {
			break;
		}
	} while (1);
	sqlite3_finalize(stmt);
	return items;
}

- (BOOL)deleteObjectForKey:(NSString *)key {
	NSString *sql = @"DELETE FROM diskCache where KEY = ?1";
	sqlite3_stmt *stmt = [self db_prepare_stmt:sql];
	sqlite3_bind_text(stmt, 1, (__bridge void *)key, -1, NULL);
	int result = sqlite3_step(stmt);
	if (result == SQLITE_OK) {
		sqlite3_finalize(stmt);
		CFDictionaryRemoveValue(_stmtDict, (__bridge void *)key);
		return true;
	}
	return false;
}

- (BOOL)db_check {
	if (!_db) {
		return [self db_open] && [self db_initilize];
	}
	return YES;
}

- (void)db_close {
	CFDictionaryRemoveAllValues(_stmtDict);
	sqlite3_close(_db);
}

- (void)dealloc {
	[self db_close];
}

#pragma mark - ASYNC APIs
- (void)searchObjectForKey:(NSString *)Key completionBlock:(VCSerchBlock) block {
	__weak typeof(self) weakSelf = self;
	dispatch_async(_dbQueue, ^{
		__strong typeof(self) strongSelf = weakSelf;
		NSData *data = [strongSelf searchObjectForKey:Key];
		block(data);
	});
}

- (void)deleteObjectForKey:(NSString *)Key completionBlock:(VCDeleteBlock)block {
	__weak typeof(self) weakSelf = self;
	dispatch_async(_dbQueue, ^{
		__strong typeof(self) strongSelf = weakSelf;
		BOOL finished = [strongSelf deleteObjectForKey:Key];
		block(finished);
	});
}

- (void)insertData:(NSData *)data forKey:(NSString *)key completionBlock:(VCDeleteBlock)block {
	dispatch_async(_dbQueue, ^{
		NSString *sql = @"INSERT OR REPLACE INTO diskCache(KEY, DATA, MODIFIDE_TIME, LAST_ACCESS_TIME) VALUES (?1, ?2, ?3, ?4) ";
		sqlite3_stmt *stmt = [self db_prepare_stmt:sql];
		BOOL result = false;
		if (stmt) {
			sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
			sqlite3_bind_blob(stmt, 2, (__bridge const void *)(data), -1, NULL);
			
			CFTimeInterval timestamp = CFAbsoluteTimeGetCurrent();
			sqlite3_bind_int(stmt, 3, timestamp);
			sqlite3_bind_int(stmt, 4, timestamp);
			result = sqlite3_step(stmt) == SQLITE_OK;
		}
		block(result);
	});
	
}

- (void)setObject:(id)object forKey:(NSString *)key {
	NSData* data = [[[VCImageDecoder alloc] init] encodeImage:object];
	NSString *sql = @"INSERT OR REPLACE INTO diskCache(KEY, DATA, MODIFIDE_TIME, LAST_ACCESS_TIME) VALUES (?1, ?2, ?3, ?4) ";
	sqlite3_stmt *stmt = [self db_prepare_stmt:sql];
	if (stmt) {
		sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
		sqlite3_bind_blob(stmt, 2, [data bytes], (int)data.length, NULL);
		
		CFTimeInterval timestamp = CFAbsoluteTimeGetCurrent();
		sqlite3_bind_int(stmt, 3, timestamp);
		sqlite3_bind_int(stmt, 4, timestamp);
		sqlite3_step(stmt);
	}
}
@end
