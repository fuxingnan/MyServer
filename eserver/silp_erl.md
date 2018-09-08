# DB_MODULE_HEADER(module, author, version) #
```
-module(${module}).
-author("${author}").

-vsn("${version}").
-include("wg.hrl").
-include("db.hrl").
-include("errno.hrl").
-include("const.hrl").
-include("common.hrl").
-include("player.hrl").
```

# MOD_MODULE_HEADER(module, author, version) #
```
-module(${module}).
-author("${author}").

-vsn("${version}").
-include("wg.hrl").
-include("errno.hrl").
-include("const.hrl").
-include("common.hrl").
-include("player.hrl").
-include("../src/proto/proto.hrl").

-behaviour(gen_mod).

-export([start/0]).

%% gen_mod回调函数
-export([i/1, p/1, init/1, terminate/0,
        init_player/2, gather_player/1, terminate_player/1,
        handle_c2s/3, handle_timeout/2, handle_s2s_call/2, handle_s2s_cast/2]).

```

# MGR_MODULE_HEADER(module, author, version) #
```
-module(${module}).
-author("${author}").

-vsn("${version}").
-include("wg.hrl").
-include("const.hrl").
-include("errno.hrl").
-include("common.hrl").
-include("player.hrl").
-include("../player/player_internal.hrl").

-behaviour(gen_server).

-export([start_link/0]).
-export([i/0, p/1]).

%% gen_server回调函数
-export([init/1, terminate/2, code_change/3,
        handle_cast/2, handle_call/3, handle_info/2]).
```

# SYS_MODULE_HEADER(module, author, version) #
```
-module(${module}).
-author("${author}").

-vsn("${version}").
-include("wg.hrl").
-include("game.hrl").
-include("../src/player/player_internal.hrl").
```

# GEN_MODULE_HEADER(module, author, version) #
```
-module(${module}).
-author("${author}").

-vsn("${version}").
-include("genbase.hrl").
```

# SYS_FELLOW_ATTR_SECTION(quality, color) #
```
?FELLOW_QUALITY_${quality} ->
    #sys_fellow_attr_section{
        attack_add = Attr#sys_fellow_attr.attack_add__${color},
        hit_add = Attr#sys_fellow_attr.hit_add__${color},
        critical_add = Attr#sys_fellow_attr.critical_add__${color},
        guard_add = Attr#sys_fellow_attr.guard_add__${color},
        bless_add = Attr#sys_fellow_attr.bless_add__${color},
        zz_attack = Attr#sys_fellow_attr.zz_attack__${color},
        zz_hit = Attr#sys_fellow_attr.zz_hit__${color},
        zz_critical = Attr#sys_fellow_attr.zz_critical__${color},
        zz_guard = Attr#sys_fellow_attr.zz_guard__${color},
        zz_bless = Attr#sys_fellow_attr.zz_bless__${color},
        max_star_level = Attr#sys_fellow_attr.max_star_level__${color},
        zz_point = Attr#sys_fellow_attr.zz_point__${color}
    };
```

# SYS_FELLOW_STAR_SECTION(quality, color) #
```
?FELLOW_QUALITY_${quality} ->
    #sys_fellow_star_section{
        attack_zz_max = Star#sys_fellow_star.attack_zz_max__${color},
        hit_zz_max = Star#sys_fellow_star.hit_zz_max__${color},
        critical_zz_max = Star#sys_fellow_star.critical_zz_max__${color},
        guard_zz_max = Star#sys_fellow_star.guard_zz_max__${color},
        bless_zz_max = Star#sys_fellow_star.bless_zz_max__${color}
    };
```


