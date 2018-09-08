%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 文字相关
%%%
%%%----------------------------------------------------------------------
-ifndef(LANG_HRL).
-define(LANG_HRL, true).

%% 用来文字转化的宏
%%-define(LANG(TAG), ?_LANG_??TAG).


-ifdef(LANG_FANTI).

-define(_LANG_SYSTEM, "系統").

-define(_LANG_SILVER, "銀幣").
-define(_LANG_GOLD, "金幣").

%%-------------
%% 勁敵關系郵件
%%-------------

%% 發給失敗者
-define(_LANG_ENEMY_LOSER_MAIL_TITLE, "受到勁敵挑戰").
-define(_LANG_ENEMY_LOSER_MAIL_CONTENT,
    "你被玩家[~s]打敗，此人能力只比你高那麽一點點，暫且將其當做勁敵，下回努力將其打敗，讓Ta嘗嘗拳頭的滋味。").

%% 發給成功者
-define(_LANG_ENEMY_WINNER_MAIL_TITLE, "成功打敗勁敵").
-define(_LANG_ENEMY_WINNER_MAIL_CONTENT,
    "你的勁敵[~s]最近沒啥長進，被你輕松打敗。Ta現在已經沒有資格做你的勁敵了。").
%% 郵件提示
-define(_LANG_MAIL_NOTICE_NOFRIEND, "不是好友不能發送郵件").

-else. % 本地化(简体)

-define(_LANG_SYSTEM, "系统").

-define(_LANG_SILVER, "银币").
-define(_LANG_GOLD, "金币").

%%-------------
%% 劲敌关系邮件
%%-------------

%% 发给失败者
-define(_LANG_ENEMY_LOSER_MAIL_TITLE, "受到劲敌挑战").
-define(_LANG_ENEMY_LOSER_MAIL_CONTENT,
    "你被玩家[~s]打败，此人能力只比你高那么一点点，暂且将其当做劲敌，下回努力将其打败，让Ta尝尝拳头的滋味。").

%% 发给成功者
-define(_LANG_ENEMY_WINNER_MAIL_TITLE, "成功打败劲敌").
-define(_LANG_ENEMY_WINNER_MAIL_CONTENT,
    "你的劲敌[~s]最近没啥长进，被你轻松打败。Ta现在已经没有资格做你的劲敌了。").

%% 邮件提示
-define(_LANG_MAIL_NOTICE_NOFRIEND, "不是好友不能发送邮件").
-define(_LANG_MAIL_NOTICE_NO_ONLINE, "对方不在线，不能发送邮件").


-endif. % 本地化

-endif. % LANG_HRL
