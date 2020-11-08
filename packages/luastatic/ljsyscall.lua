
package.path = package.path..";./ljsys/?.lua;./ljsys/syscall/?.lua"
local strict = require "strict"
local S = require "syscall"
local nl = require "syscall.nl"
local util = require "syscall.util"
local bit = require "bit"
local ffi = require "ffi"

dofile("ljsys/test.lua")



