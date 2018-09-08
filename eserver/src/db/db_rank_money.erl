
-module(db_rank_money).
-author("276300120@qq.comm").                                           
                                                                     
-vsn("0.1").                                                          
-include("wg.hrl").                                                   
-include("db.hrl").                                                   
-include("errno.hrl").                                                
-include("const.hrl").                                                 
-include("common.hrl").                                                
-include("player.hrl").                                               
-include("room.hrl").

-export[fields_to_record/1, record_to_fields/1].                                                  
                                                                                                 
-export[create/1, update/1].
-export[load/1].
                                                                                                  
                                                                                                
-define(TABLE_RAND_MONEY, "table_money").
-define(FULL_FIELDS_Money, [
    "id",              "name",       "image",      "money"
    ]).                                                                                          
                                                                                                  
fields_to_record([                                                                               
    Id,                Name,         Image,        Money
    ]) ->                                                                                         
    Data = #money_rank_data{
        id = Id,                               
        name =  Name,
        image = Image,
        money = Money
    },                                                                                           
    decode(Data).                                                                               
                                                                                                  
record_to_fields(Data=#money_rank_data{}) ->
    #money_rank_data{
        id = Id,
        name =  Name,
        image = Image,
        money = Money
    } = encode(Data),                                                                           
    [                                                                                            
    Id,                Name,         Image,    Money
    ].                                                                                            
                                                                                                  
%% @doc 创建数据 #win_rank_data                                                                      
create(Data) ->                                                                                 
    Vals = record_to_fields(Data),                                                              
    case ?DB_GAME:insert(?TABLE_RAND_MONEY, Vals) of
        {updated, 1} ->                                                                           
            ok;                                                                                   
        {error, _Reason} ->                                                                       
            ?ERROR("Create win_rank error: ~p ~p", [Data, _Reason]),
            ?C2SERR(?E_DB)                                                                        
    end.                                                                                          
                                                                                                 
                                                                   
load(Id) ->                                                                                       
    case ?DB_GAME:select(?TABLE_RAND_MONEY, ?FULL_FIELDS_Money, ["id=", db_util:encode(Id)]) of
        {error, _Reason} ->                                                                       
            ?ERROR("Load moneyrank error: ~p ~p", [Id, _Reason]),
            [];                                                                                   
        {selected, _Fields, [Row]} ->                                                             
            % ?DEBUG("selected fields: ~p~nrow: ~p", [_Fields, Row]),                             
            fields_to_record(Row);                                                                
        {selected, _Fields, []} ->                                                                
            %?DEBUG("Load moneyrank not found: ~p", [Id]),
            []                                                                                    
    end.                                                                                          
                                                                                                 
%% @doc 更新数据 #rand_win                                                                     
update(Data) ->
    %?INFO(?_U("保存金钱排行榜:~p"), [1]),
    ["id" | Fields] = ?FULL_FIELDS_Money,
    [Id | Vals] = record_to_fields(Data),                                                       
    case ?DB_GAME:update(?TABLE_RAND_MONEY, Fields, Vals, db_util:where_id(Id)) of
        {updated, 1} ->                                                                           
            ok;                                                                                   
        {updated, 0} ->                                                                          
            ok;                                                                                   
        {error, _Reason} ->                                                                       
            ?ERROR("Update moneyrank error: ~p ~p", [Id, _Reason]),
            ?C2SERR(?E_DB)                                                                        
    end.                                                                                          
                                                                                                                                                                                                                                                           
                                                                            
decode(Data=#money_rank_data{ name =  Name,image = Image}) ->
    Data#money_rank_data{
        name = game_misc:decode_term(Name),
        image = game_misc:decode_term(Image)
    }.

encode(Data=#money_rank_data{name =  Name,image = Image}) ->
    Data#money_rank_data{
        name = game_misc:encode_term(Name),
        image = game_misc:encode_term(Image)
    }.
