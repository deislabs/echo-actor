# Copyright 2015-2019 Capital One Services, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

COLOR ?= always # Valid COLOR options: {always, auto, never}
CARGO = cargo --color $(COLOR)
TARGET = target/wasm32-unknown-unknown/debug
KEYDIR = .keys

.PHONY: all bench build check clean doc test update

all: build

bench:
	@$(CARGO) bench

build:
	@$(CARGO) build
	wascap sign $(TARGET)/echo_actor.wasm $(TARGET)/echo_actor_signed.wasm -a ./.keys/account.nk -m ./.keys/module.nk -s

check:
	@$(CARGO) check

clean:
	@$(CARGO) clean

doc:
	@$(CARGO) doc

test: build
	@$(CARGO) test

update:
	@$(CARGO) update

release: release-build
release: release-sign

.PHONY: release-build
release-build:
	@$(CARGO) build --release

.PHONY: release-sign
release-sign:
	wascap sign target/wasm32-unknown-unknown/release/echo_actor.wasm target/wasm32-unknown-unknown/release/echo_actor_s.wasm -c wok:echoProvider  -a $(KEYDIR)/account.nk -m $(KEYDIR)/module.nk -s

.PHONY: keys keys-account keys-module

keys: keys-account
keys: keys-module

keys-account:
	mkdir -p $(KEYDIR)
	nk gen account > $(KEYDIR)/account.txt
	awk '/Seed/{ print $$2 }' $(KEYDIR)/account.txt > $(KEYDIR)/account.nk

keys-module:
	mkdir -p $(KEYDIR)
	nk gen module > $(KEYDIR)/module.txt
	awk '/Seed/{ print $$2 }' $(KEYDIR)/module.txt > $(KEYDIR)/module.nk
	
