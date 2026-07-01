//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
//  Bionic exposes these headers, but the Swift `Android` overlay module
//  (as of Swift 6.3.3) does not yet re-export their symbols. This shim
//  imports them directly from the NDK sysroot until the overlay catches up.
//
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/xattr.h>
#include <sys/utsname.h>
