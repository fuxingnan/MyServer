{application, log_app,
    [{description, "The log application"},
     {vsn, "0.1"},
     {modules, ['log_app', 'log_server']},
     {registered, []},
     {applications, [kernel, stdlib, sasl]},
     {mod, {log_app, []}},
     {env, []}
    ]
}.
