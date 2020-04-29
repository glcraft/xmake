add_rules("mode.release", "mode.debug")

target("dep1")
    set_kind("static")
    add_deps("dep3")
    add_files("src/interface.c")
    on_load(function (target)
        os.rm(target:targetfile())
        os.rm(target:dep("dep3"):targetfile())
    end)
    before_link(function (target)
        assert(os.isfile(target:dep("dep3"):targetfile()), "dep1: before_link failed!")
    end)
    after_link(function (target)
        assert(os.isfile(target:targetfile()), "dep1: after_link failed!")
    end)
    on_install(function (target) end)

target("dep2")
    set_kind("static")
    add_deps("dep3")
    add_files("src/interface.c")
    on_load(function (target)
        os.rm(target:targetfile())
        os.rm(target:dep("dep3"):targetfile())
    end)
    before_link(function (target)
        assert(os.isfile(target:dep("dep3"):targetfile()), "dep2: before_link failed!")
    end)
    after_link(function (target)
        assert(os.isfile(target:targetfile()), "dep2: after_link failed!")
    end)
    on_install(function (target) end)

target("dep3")
    set_kind("static")
    add_files("src/interface.c")
    add_deps("dep4", "dep5")
    on_load(function (target)
        os.rm(target:targetfile())
        os.rm(target:dep("dep4"):targetfile())
        os.rm(target:dep("dep5"):targetfile())
    end)
    after_link(function (target)
        assert(os.isfile(target:targetfile()), "dep3: after_link failed!")
        assert(os.isfile(target:dep("dep4"):targetfile()), "dep3: after_link failed!")
        assert(os.isfile(target:dep("dep5"):targetfile()), "dep3: after_link failed!")
    end)
    on_install(function (target) end)

target("dep4")
    set_kind("static")
    add_files("src/interface.c")
    on_load(function (target)
        os.rm(target:targetfile())
    end)
    after_link(function (target)
        assert(os.isfile(target:targetfile()), "dep4: after_link failed!")
    end)
    on_install(function (target) end)

target("dep5")
    set_kind("static")
    add_files("src/interface.c")
    on_load(function (target)
        os.rm(target:targetfile())
    end)
    after_link(function (target)
        assert(os.isfile(target:targetfile()), "dep5: after_link failed!")
    end)
    on_install(function (target) end)

target("test1")
    set_kind("binary")
    add_deps("dep1", "dep2")
    add_files("src/test.c")
    on_load(function (target)
        os.rm(target:targetfile())
        os.rm(target:dep("dep1"):targetfile())
        os.rm(target:dep("dep2"):targetfile())
        os.rm(target:dep("dep3"):targetfile())
    end)
    before_link(function (target)
        assert(os.isfile(target:dep("dep1"):targetfile()), "test1: before_link failed!")
        assert(os.isfile(target:dep("dep2"):targetfile()), "test1: before_link failed!")
        assert(os.isfile(target:dep("dep3"):targetfile()), "test1: before_link failed!")
    end)
    after_link(function (target)
        assert(os.isfile(target:targetfile()), "test1: after_link failed!")
    end)
    on_install(function (target) end)

target("test2")
    set_kind("binary")
    add_deps("dep1")
    add_files("src/test.c")
    on_load(function (target)
        os.rm(target:targetfile())
        os.rm(target:dep("dep1"):targetfile())
        os.rm(target:dep("dep3"):targetfile())
    end)
    before_link(function (target)
        assert(os.isfile(target:dep("dep1"):targetfile()), "test2: before_link failed!")
        assert(os.isfile(target:dep("dep3"):targetfile()), "test2: before_link failed!")
    end)
    after_link(function (target)
        assert(os.isfile(target:targetfile()), "test2: after_link failed!")
    end)
    on_install(function (target) end)
