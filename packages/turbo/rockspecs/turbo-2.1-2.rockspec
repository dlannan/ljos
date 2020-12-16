package = "turbo"
version = "2.1-2"
supported_platforms = {"linux", "macosx"}
source = {
    url = "git://github.com/kernelsauce/turbo",
    tag = "v2.1.2"
}
description = {
    summary = "A networking suite for LuaJIT2, optimized for performance.",
    detailed = [[Turbo.lua is just another framework to create network programs for Linux. It uses kernel
        event polling to manage network connections instead of the traditional concurency models that employ
        threads. As it does not use threads, no locks, mutexes or other bad things are required. It solves the
        same issues as Node.js, Tornado etc. except it solves it with Lua. A simple, yet powerful language that
        fits nicely with the event polling model with its builtin coroutines.]],
    homepage = "http://turbolua.org",
    maintainer = "John Abrahamsen <jhnabrhmsn@gmail.com>",
    license = "Apache 2.0"
}
build = {
    type = "make",
    makefile = "Makefile"
}
