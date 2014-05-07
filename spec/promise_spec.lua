describe("promise tests", function()
  it("does one thing", function()

    local p = require 'init'()

    local id = p:start(function() return 'lol' end)

    assert.are.same({'lol'}, {p:fetch(id)})
    assert.are.equal(nil, p.threads[id])
  end)

  it("does many things", function()

    local p = require 'init'()

    local id1 = p:start(function() return 'lol' end)
    local id2 = p:start(function() return 'lol' end)

    assert.are.same({{[id1] = {'lol'}, [id2]={'lol'}}}, {p:all()})
    assert.are.same({}, p.threads)
  end)

  it("does many things out of order", function()

    local p = require 'init'()

    local id1 = p:start(function() return 'lol' end)
    local id2 = p:start(function() return 'lol' end)

    assert.are.same({id1, 'lol'}, {p:first()})
    assert.are.same({id2, 'lol'}, {p:first()})
    assert.are.same({}, p.threads)
  end)
end)
