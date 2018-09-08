{application, player_app,
    [{description, "The player application"},
     {vsn, "0.1"},
     {modules, ['gen_mod', 'player_admin', 'player_app', 'player_counter', 'player_counter_util', 'player_mgr', 'player_server', 'player_sup', 'robot_server', 'robot_sup']},
     {registered, []},
     {applications, [kernel, stdlib, sasl]},
     {mod, {player_app, []}},
     {env, []}
    ]
}.
