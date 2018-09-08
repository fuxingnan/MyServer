{application, db_app,
    [{description, "The db_app ver:0.1 application"},
     {vsn, "0.1"},
     {modules, ['db', 'db_account', 'db_app', 'db_counter', 'db_gm_ctrl', 'db_log', 'db_player', 'db_rank_lose_money', 'db_rank_money', 'db_rank_win_money', 'db_util']},
     {registered, []},
     {applications, [kernel, stdlib]},
     {mod, {db_app, []}},
     {env, []}
    ]
}.
