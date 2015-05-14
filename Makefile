#OTPROOT=$(EI_DIR)
#OTPROOT=/usr/lib/erlang/lib/erl_interface-3.7.15
ifeq ($(ERL_ROOT),)
	export ERL_ROOT=$(shell erl -noshell -eval 'io:format("~s~n", [code:root_dir()]), init:stop().')
endif

ifeq (,$(ERL_ROOT))
$(error "Unable to locate erlang root directory! Is erlang installed?")
endif

#Search ERL_ROOT for erl_interface
ERL_INTERFACE_ROOT = $(addprefix $(ERL_ROOT)/lib/, $(shell ls $(ERL_ROOT)/lib | grep erl_interface))
ERL_INTERFACE_INCLUDE = $(ERL_INTERFACE_ROOT)/include
ERL_INTERFACE_LIB = $(ERL_INTERFACE_ROOT)/lib


all:	bin/cnodeserver bin/cnodeclient bin/complex3.beam

bin/%.beam:	src/%.erl
	erlc -o bin $<

bin/%:	src/%.c
	mkdir -p bin
	gcc -o $@ -I$(ERL_INTERFACE_INCLUDE) -L$(ERL_INTERFACE_LIB) src/complex.c $< -lerl_interface -lei -lpthread -lnsl

clean:
	rm -rf bin


start_server:
	epmd -daemon
	bin/cnodeserver 3456

start_client:
	echo "run 'complex3:foo(4).' via erlang shell"
	erl -sname e1 -setcookie secretcookie -pa bin
