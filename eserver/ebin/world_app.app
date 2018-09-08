{application, world_app,
    [{description, "The world application"},
     {vsn, "0.1"},
     {modules, ['gm_ctrl', 'rank', 'room_master_mgr', 'room_newplayer_mgr', 'room_ordinary_mgr', 'world_app', 'world_data', 'world_horn', 'world_id', 'world_nodes', 'world_online']},
     {registered, []},
     {applications, [kernel, stdlib, sasl]},
     {mod, {world_app, []}},
     {env, []}
    ]
}.
