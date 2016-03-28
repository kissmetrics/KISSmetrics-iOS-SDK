//
// KISSmetricsSDK
//
// KMAMacros.c
//
// Copyright 2014 KISSmetrics
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


#ifndef KMALogVerbose
#  define KMALogVerbose 1
#endif

/* Our own internal logging */
#ifndef KMALog
#
#  //When debug, log warnings, else not.
#  ifdef DEBUG
#    if KMALogVerbose
#      define KMALog(...) NSLog(__VA_ARGS__)
#    else
#      define KMALog(...)
#    endif
#  else
#    define KMALog(...)
#  endif
#
#endif



/* Assert only under DEBUG */
// We never want to call assert for an error in or for the implementation of our SDK in release.
// Our SDK should always fail gracefully.
// We can use our own Assert under DEBUG to warn our customer devs of potential issues.
#ifndef KMAAssert
#
#   //When debug, apply asserts, else not.
#   ifdef DEBUG
#       define KMAAssert(A, B) NSAssert(A, B)
#   else
#       define KMAAssert(A, B)
#   endif
#
#endif

