return require('lib/tap')(function (test)
  test("basic 64bit conversions", function (print, p, expect, uv)
    if _VERSION=='Lua 5.3' then
      assert(string.format("%x", 29913653248) == "6f6fe2000")
      assert(string.format("%x", 32207650816) == "77fb9c000")
    else
      print('skipped')
    end
  end)
end)
