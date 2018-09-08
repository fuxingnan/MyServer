#! /bin/bash
ROOT=`cd $(dirname $0); pwd`
CONFDIR=$ROOT/etc
LOGDIR=$ROOT/log

# 定义erlang vm选项
ERL=erl
POLL=true
ASYNC=8
SMP=enable
ERL_PROCESSES=500000
CONNECT_ALL=true
DATETIME=`date "+%Y%m%d-%H%M%S"`
export ERL_CRASH_DUMP=$ROOT/erl_crash_$DATETIME.dump
export ERL_MAX_PORTS=102400
export ERL_MAX_ETS_TABLES=10000
export HOME=$ROOT
SYSTEM_CONFIG=$CONFDIR/system.config

# 其它变量
ERLANG_NODE=game@localhost
COOKIE="node-cookie"
WORLD_NODE=
# 地图节点启动的地图
AREA_MAP="[]"

# 运行的程序及控制文件
APP_MOD=game
APP_CTL=game_ctl
ERROR_LOG=$LOGDIR/game.log
SASL_LOG=$LOGDIR/game.sasl

# define additional environment variables
EBINS="$ROOT/ebin $ROOT/deps/ebin $ROOT/deps/protobuffs/ebin"
#echo "ebins is " $EBINS

# makesure the logs dir exists
if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR || echo "make $LOGDIR error!"; exit 1
fi

STATUS_SUCCESS=0    # 成功
STATUS_AGAIN=1      # 进行中,请重试
STATUS_USAGE=2      # 使用错误
STATUS_BADRPC=3     # rpc调用错误
STATUS_ERROR=4      # 其它错误

# 重新加载的系统数据
RELOAD_TYPE=all_data

# 打印错误
error() {
    echo -e "[1;41m[错误][0m $1"
    exit 1
}

# 打印信息
echo2() {
    echo -e "[1;42m[操作][0m $1"
}

# 打印警告
warn() {
    echo -e "[1;43m[警告][0m $1"
}

# 获取内网ip
getip() {
    echo `LANG=en_US; ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | grep '192.*' | cut -d: -f 2 | awk '{print $1}'`
}

# 使用说明
usage ()
{
    echo ""
    echo "用法:"
    echo "$0 ACTION [OPTION]"
    echo "ACTION:"
    echo "  live        交互方式启动"
    echo "  start       后台方式启动"
    echo "  status      获取后台运行状态"
    echo "  attach      通过Erlang shell连接后台运行节点"
    echo "  stop        停止节点"
    echo "  restart     重启节点"
    echo "  reload      重新加载数据或代码"
    echo ""
    echo "OPTION:"
    echo "  -h, --help              显示本信息"
    echo "  -n, --node=Nodename     节点名称:$ERLANG_NODE(default)"
    echo "  -c, --cookie=Cookie     节点cookie(默认\"\")"
    echo "  -f, --conf=Conf         指明使用的配置文件(默认gh.conf)"
    echo "  -r, --reload=Type       指明要reload的系统数据:code,config,all_data,指定的数据如goods(默认all_data)"
    echo "  -w, --world=World       指明world节点,为gate,area节点时需要指明此参数"
    echo ""
}

# 修改ulimit
change_ulimit() {
    if ! ulimit -HSn 102400 2> /dev/null ; then
        error "请确保具有root权限"
    fi
}

# 查询运行中节点的信息
rpc() 
{
    $ERL \
      $NAME_FLAG game_ctl@$HOST \
      -noinput \
      -pa $EBINS \
      -config $SYSTEM_CONFIG \
      -setcookie ${COOKIE} \
      -s ${APP_CTL} -extra $ERLANG_NODE $@
}

# 打印rpc返回信息
print_rpc_return ()
{
    case $1 in
    $STATUS_SUCCESS) 
        echo ""
        ;;
    $STATUS_AGAIN) 
        warn "进行中,请重试!"
        ;;
    $STATUS_USAGE) 
        error "命令不支持! $0 -h查看帮助"
        ;;
    $STATUS_BADRPC) 
        error "节点$ERLANG_NODE未运行"
        ;;
    *)
        error "未知命令! $0 -h查看帮助"
    esac
}

# 判断节点是否运行
is_started () 
{
    if [ "$APP_MOD" = "game" ]; then
        rpc status
    else
        rpc status $APP_MOD
    fi
    result=$?
    if [  "$result" = "$STATUS_SUCCESS" ]; then
        return 0
    fi
    return 1
}

# start interactive server
live ()
{
    #change_ulimit
    $ERL \
      $NAME_FLAG $ERLANG_NODE \
      -pa $EBINS \
      -config $SYSTEM_CONFIG \
      -setcookie ${COOKIE} \
      -${APP_MOD} area_map ${AREA_MAP} \
      -${APP_MOD} world \'${WORLD_NODE}\' \
      -s ${APP_MOD} start \
      $ERLANG_OPTS --extra $ARGS "$@"
}

# 启动server
start ()
{
    change_ulimit
    if is_started; then
        warn "节点$ERLANG_NODE已经启动"
        exit 0
    fi

    $ERL \
      $NAME_FLAG $ERLANG_NODE \
      -noinput -detached \
      -pa $EBINS \
      -setcookie ${COOKIE} \
      -kernel error_logger \{file,\"$ERROR_LOG\"\} \
      -sasl sasl_error_logger \{file,\"$SASL_LOG\"\} \
      -${APP_MOD} area_map ${AREA_MAP} \
      -${APP_MOD} world ${WORLD_NODE} \
      -s ${APP_MOD} start\
      $ERLANG_OPTS $ARGS "$@"
    
    RETRY=0
    while [ $RETRY -lt 60 ];do
        if [ $? -ne 0 ]; then
            error "节点$ERLANG_NODE启动失败:$?"
        else
            if is_started; then
                break
            else
                let RETRY++
                sleep 1
            fi
            if [ $RETRY -ge 30 ]; then
                warn "*****************服务器$APP_NAME启动失败,请手动检查**************"
                exit 1
            fi
        fi
    done
    echo2 "节点$ERLANG_NODE启动成功!"
}

# 获取状态
status ()
{
    if is_started; then
        echo2 "节点$ERLANG_NODE状态: 运行中"
    else
        print_rpc_return $?
    fi  
}

# 连接到节点内
attach ()
{
    if ! is_started; then
        error "节点$ERLANG_NODE未启动"
    fi
    $ERL \
      $NAME_FLAG ${NAME}debug@$HOST \
      -setcookie ${COOKIE} \
      -remsh $ERLANG_NODE \
      $ERLANG_OPTS $ARGS "$@"
}

# 停止节点
stop ()
{
    if rpc stop; then
        echo2 "节点$ERLANG_NODE停止: 成功"
    else
        print_rpc_return $?
    fi  
}

# 重启节点
restart ()
{
    if rpc restart; then
        echo2 "节点$ERLANG_NODE重启: 成功"
    else
        print_rpc_return $?
    fi  
}

# 重新加载
reload ()
{
    if rpc reload ${RELOAD_TYPE} > /dev/null; then
        echo2 "节点$ERLANG_NODE重新加载${RELOAD_TYPE}成功"
    else
        error "节点$ERLANG_NODE重新加载${RELOAD_TYPE}失败"
    fi  
}

# parse command line parameters
while [ $# -ne 0 ] ; do
    PARAM=$1
    shift
    case $PARAM in
        --) break ;;
        --node|-n) ERLANG_NODE=$1; shift ;;
        --cookie|-c) COOKIE=$1 ; shift ;;
        --conf|-f) export GAME_CONF_FILE=$1 ; shift ;;
        --help|-h) usage; exit 0;;
        --reload|-r) RELOAD_TYPE=$1; shift;;
        --world|-w) WORLD_NODE=$1; shift;;
        *) ARGS="$ARGS $PARAM" ;;
    esac
done

NAME=${ERLANG_NODE%%@*}
HOST=${ERLANG_NODE##*@}
NAME_FLAG=-name
[ "$ERLANG_NODE" = "${ERLANG_NODE%.*}" ] && NAME_FLAG=-sname

# 检测world参数
if [ "$APP_MOD" = "area_app" -o "$APP_MOD" = "gate_app" ]; then
    [ -z "$WORLD_NODE" ] && error "请设置-w(--world)参数"
fi

ERLANG_OPTS="-connect_all $CONNECT_ALL +K $POLL -smp $SMP +P $ERL_PROCESSES \
    +t 10485760 +fnu +hms 8192 +hmbs 8192 +zdbbl 81920"

case $ARGS in
    '') usage;;
    ' live') live;;
    ' start') start;;
    ' status') status;;
    ' attach') attach;;
    ' stop') stop;;
    ' restart') restart;;
    ' reload') reload;;
    *) usage; exit 1;;
esac
