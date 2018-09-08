SHELL := /bin/bash
.PHONY: all apps2 get-deps compile  ct  eunit test  clean check_plt build_plt dialyzer _gen proto rel data
REBAR=`which rebar || printf ./rebar`
REPO=yulong
ERL := erl
EBIN_DIRS := ebin deps/ebin $(wildcard deps/*/ebin)

ifndef DATATYPE
	DATATYPE=all
endif

ifndef DATALOG
	DATALOG=3
endif

all: compile

get-deps:
	@$(REBAR) get-deps

compile: apps2
	@$(REBAR) compile

ct:
	./scripts/generate_emakefile.escript
	@$(REBAR) skip_deps=true ct

_gen:
	(cd src/gen; erl -make)

# 根据协议定义文件重新生成协议
proto: _gen
	echo "生成协议 ..."
	./script/make_messageid.py
	@$(ERL) -pa . -pa ./ebin -noshell -eval "genall:gen(proto)"

data:
	@echo "生成数据文件 ${DATATYPE} log等级 ${DATALOG} ..."
	@$(ERL) -pa $(EBIN_DIRS) -noshell -eval "genall:gen(data, ${DATATYPE}, ${DATALOG})"

rel:
	echo "生成rel执行目录 ..."
	@$(REBAR) generate

apps2:
	(echo "生成子项目配置app文件 ...")
	(cd src/gateway; $(MAKE))
	(cd src/player; $(MAKE))
	(cd src/world; $(MAKE))
	(cd src/log; $(MAKE))
	(cd src/db; $(MAKE))
	(cp src/ctl/gamectl.tpl gamectl && chmod +x gamectl)

eunit:
	@$(REBAR) skip_deps=true eunit

test: eunit ct

clean:
	@$(REBAR) clean

APPS = kernel stdlib sasl erts ssl tools os_mon runtime_tools crypto inets \
	xmerl webtool snmp public_key mnesia eunit syntax_tools compiler
COMBO_PLT = $(HOME)/.$(REPO)_combo_dialyzer_plt

check_plt: compile
	dialyzer --check_plt --plt $(COMBO_PLT) --apps $(APPS) \
		ebin

build_plt: compile
	dialyzer --build_plt --output_plt $(COMBO_PLT) --apps $(APPS) \
		ebin

dialyzer: compile
	dialyzer -Wno_return --plt $(COMBO_PLT) ebin

