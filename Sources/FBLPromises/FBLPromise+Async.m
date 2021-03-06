/**
 Copyright 2018 Google Inc. All rights reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "FBLPromise+Async.h"

#import "FBLPromisePrivate.h"

@implementation FBLPromise (AsyncAdditions)

+ (instancetype)async:(FBLPromiseAsyncWorkBlock)work {
  return [self onQueue:dispatch_get_main_queue() async:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue async:(FBLPromiseAsyncWorkBlock)work {
  NSParameterAssert(work);

  FBLPromise *promise = [[[self class] alloc] initPending];
  dispatch_group_async([self class].dispatchGroup, queue, ^{
    @try {
      work(
          ^(id __nullable value) {
            [promise fulfill:value];
          },
          ^(NSError *error) {
            [promise reject:error];
          });
    } @catch (id exception) {
      [promise reject:exception];
    }
  });
  return promise;
}

@end
