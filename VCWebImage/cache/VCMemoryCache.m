//
//  VCMemoryCache.m
//  VCWebImageDemo
//
//  Created by ZHANG Zhipeng on 2018/11/15.
//  Copyright © 2018 zzp. All rights reserved.
//

/***
   * 双向链表以及字典实现
   * 字典中持有strong的node节点，而节点自身的前后关系是用unsafe_unretain修饰。
   * LRU淘汰算法
 ***/

#import "VCMemoryCache.h"
#import "VCMarco.h"

@interface LinkedNode: NSObject{
	@package
	__unsafe_unretained LinkedNode *_next;
	__unsafe_unretained LinkedNode *_prev;
	id key;
	id value;
	NSTimeInterval updateTime;
//	NSInteger count;
	NSInteger cost;
}
@end

@implementation LinkedNode
@end

@interface LinkedMap : NSObject {
	@package
	LinkedNode *_head;
	LinkedNode *_tail;
	CFMutableDictionaryRef _cacheDict;
	NSInteger _totalCount;
	NSInteger _totalCost;
	dispatch_semaphore_t _ioLock;
}

- (void)insertNode:(LinkedNode *)node;
- (void)removeNode:(LinkedNode *)node;
- (void)bringNodeToHead:(LinkedNode *)node;
@end

@implementation LinkedMap
- (id)init {
	if (self = [super init]) {
		_cacheDict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		_ioLock = dispatch_semaphore_create(1);
	}
	return self;
}

- (void)insertNode:(LinkedNode *)node {
	LOCK(_ioLock);
	LinkedNode *theNode = CFDictionaryGetValue(_cacheDict, (__bridge const void *)(node->key));
	if (!theNode) {
		theNode = node;
		_totalCount ++;
		_totalCost += node->cost;
		CFDictionarySetValue(_cacheDict, (__bridge const void *)node->key, (__bridge const void*)theNode);
	} else {
		theNode->updateTime = CACurrentMediaTime();
	}
	if (_head) {
		node->_prev = nil;
		node->_next = _head;
		_head->_prev = node;
		_head = node;
	} else {
		_head = _tail = theNode;
	}
	UNLOCK(_ioLock);
}

- (void)removeNode:(LinkedNode *)node {
	LOCK(_ioLock);
	CFDictionaryRemoveValue(_cacheDict, (__bridge const void *)(node->key));
	_totalCount --;
	_totalCost -= node->cost;
	if (_head == node) {
		_head->_next->_prev = nil;
		node = nil;
	} else if (_tail == node) {
		_tail->_prev->_next = nil;
		_tail= nil;
	} else {
		node->_prev->_next = node->_next;
		node->_next->_prev = node->_prev;
		node = nil;
	}
	UNLOCK(_ioLock);
}

- (void)bringNodeToHead:(LinkedNode *)node {
	if (node == _head) {
		return;
	}
	LOCK(_ioLock);
	if (node == _tail) {
		node->_prev->_next = nil;
		_tail = node->_prev;
		
	} else {
		node->_prev->_next = node->_next;
		node->_next->_prev = node->_prev;
	}
	
	node->_next = _head;
	node->_prev = nil;
	_head->_prev = node;
	_head = node;
	UNLOCK(_ioLock);
}
@end

@implementation VCMemoryCache {
	dispatch_semaphore_t _lock;
	LinkedMap *_linkMap;
}

+ (id)sharedCache {
	static VCMemoryCache *_sharedCache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedCache = [[VCMemoryCache alloc] init];
	});
	return _sharedCache;
}

- (id)init {
	self = [super init];
	if (self) {
		_linkMap = [[LinkedMap alloc] init];
	}
	return self;
}

- (void)setObject:(id)object forKey:(id)key {
	LinkedNode *node = CFDictionaryGetValue(_linkMap->_cacheDict, (__bridge const void *)(key));
	if (!node) {
		node = [LinkedNode new];
		node->key = key;
		node->value = object;
		[_linkMap insertNode:node];
	} else {
		[_linkMap bringNodeToHead:node];
	}
}

- (id)objectForKey:(id)key {
	LinkedNode *node = CFDictionaryGetValue(_linkMap->_cacheDict, (__bridge const void *)(key));
	return node ? node->value : nil;
}

- (void)removeObjectForKey:(id)key {
	LinkedNode *node = CFDictionaryGetValue(_linkMap->_cacheDict, (__bridge const void *)(key));
	if (node) {
		[_linkMap removeNode:node];
	}
}


@end
