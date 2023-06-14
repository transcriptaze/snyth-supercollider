EXTENSIONS = ~/Library/Application\ Support/SuperCollider/Extensions
SOURCE = ~/Development/tools/supercollider
SRC=sn.cpp

.PHONY: build

clean:
	rm -rf build
	mkdir build
	cd build && cmake -DSC_PATH=$(SOURCE) -DCMAKE_BUILD_TYPE=RELEASE .. 

format: $(SRC)
	clang-format -i *.cpp

build: format
	cd build && make

install: build
	mkdir -p $(EXTENSIONS)/snyth/classes
	mkdir -p $(EXTENSIONS)/snyth/plugins
	cp SN.sc         $(EXTENSIONS)/snyth/classes
	cp DDS.sc        $(EXTENSIONS)/snyth/classes
	cp build/SN.scx  $(EXTENSIONS)/snyth/plugins
	cp build/DDS.scx $(EXTENSIONS)/snyth/plugins
