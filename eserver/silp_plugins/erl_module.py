# -*- coding: utf8 -*-

import silp

def default_impl(*skips):
    lines = []
    if not 'start' in skips:
        lines.append('%% @doc 启动模块')
        lines.append('start()->')
        lines.append('    gen_mod:start_module(?MODULE, []).')
        lines.append('')

    if not 'init' in skips:
        lines.append('%% 初始化')
        lines.append('init([]) ->')
        lines.append('    ok.')
        lines.append('')

    if not 'terminate' in skips:
        lines.append('%% 结束')
        lines.append('terminate() ->')
        lines.append('    ok.')
        lines.append('')

    if not 'init_player' in skips:
        lines.append('%% @doc 玩家进程初始化')
        lines.append('init_player(Player, _) ->')
        lines.append('    Player.')
        lines.append('')

    if not 'gather_player' in skips:
        lines.append('%% @doc 玩家数据收集(迁移使用)')
        lines.append('gather_player(_Player) ->')
        lines.append('    ?NONE.')
        lines.append('')

    if not 'terminate_player' in skips:
        lines.append('%% @doc 结束某个玩家数据')
        lines.append('terminate_player(_Player) ->')
        lines.append('    ok.')
        lines.append('')

    if not 'handle_timeout' in skips:
        lines.append('%% @doc 处理timeout')
        lines.append('handle_timeout(_Event, Player) ->')
        lines.append('    ?DEBUG(?_U("收到未知time消息:~p"), [_Event]),')
        lines.append('    {ok, Player}.')
        lines.append('')

    if not 'handle_s2s_call' in skips:
        lines.append('%% @doc 处理s2s_call请求')
        lines.append('handle_s2s_call(_Req, Player) ->')
        lines.append('    ?ERROR(?_U("未知的s2s_call请求: ~p"), [_Req]),')
        lines.append('    {unknown, Player}.')
        lines.append('')

    if not 'handle_s2s_cast' in skips:
        lines.append('%% @doc 处理s2s_cast请求')
        lines.append('handle_s2s_cast(_Req, Player) ->')
        lines.append('    ?ERROR(?_U("未知的s2s_cast请求: ~p"), [_Req]),')
        lines.append('    {unknown, Player}.')
        lines.append('')

    if not 'i' in skips:
        lines.append('%% @doc 运行信息')
        lines.append('i(_Player) ->')
        lines.append('    [].')

    if not 'p' in skips:
        lines.append('%% @doc 运行信息字符')
        lines.append('p(_Info) ->')
        lines.append('    "".')

    return lines
