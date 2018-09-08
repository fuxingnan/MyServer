{application, gate_app,
    [{description, "some description for gateway"},
     {vsn, "0.1"},
     {modules, [game_partner, game_partner_dev, gate_acc, gate_app, gate_client, gate_client_mgr, gate_crypt, gate_node]},
     {registered, []},
     {applications, [kernel, stdlib, sasl]},
     {mod, {gate_app, []}},
     {env, []}
    ]
}.
