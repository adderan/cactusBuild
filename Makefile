export sonLibRootPath = ${PWD}/sonLib

libtokyocabinet = ${PWD}/tokyocabinet/libtokyocabinet.a
libkyototycoon = ${PWD}/kyototycoon/libkyototycoon.a
libkyotocabinet = ${PWD}/kyotocabinet/libkyotocabinet.a


export tcPrefix = $(PWD)/tokyocabinet
export tokyoCabinetIncl = -I ${tcPrefix}/include -DHAVE_TOKYO_CABINET=1
export tokyoCabinetLib = -L${tcPrefix}/lib -Wl,-Bstatic -ltokyocabinet -Wl,-Bdynamic -lz -lpthread -lm

export kcPrefix =$(PWD)/kyotocabinet
export ttPrefix =$(PWD)/kyototycoon
export kyotoTycoonIncl = -I${kcPrefix}/include -I${ttPrefix}/include -DHAVE_KYOTO_TYCOON=1 -I$(PWD)/zlib/include 
export kyotoTycoonLib = -L${ttPrefix}/lib -L${kcPrefix}/lib -Wl,-Bstatic -lkyototycoon -lkyotocabinet -Wl,-Bdynamic -lz -lpthread -lm -lstdc++

libSonLib = ${PWD}/sonLib/sonLib.a
libPinchesAndCacti = ${PWD}/sonLib/lib/stPinchesAndCacti.a
libCPecan = ${PWD}/sonLib/lib/cPecanLib.a
libMatchingAndOrdering = ${PWD}/sonLib/lib/matchingAndOrdering.a

halAppendCactusSubtree = ${PWD}/cactus2hal/bin/halAppendCactusSubtree

all: cactus ${halAppendCactusSubtree}
	rm -rf ${PWD}/env
	virtualenv ${PWD}/env
	. ${PWD}/env/bin/activate && pip install --pre toil
	. ${PWD}/env/bin/activate && cd ${PWD}/cactus && pip install -e .

cactus: ${libSonLib} ${libPinchesAndCacti} ${libCPecan} ${libMatchingAndOrdering}
	cd ${PWD}/cactus && make


${libSonLib}: ${libkyotocabinet} ${libtokyocabinet} ${libkyototycoon}
	cd ${PWD}/sonLib && make

sonLibRule: ${libSonLib}

tokyocabinetRule: ${libtokyocabinet}

kyototycoonRule: ${libkyototycoon}

kyotocabinetRule: ${libkyotocabinet}

${libtokyocabinet}:
	cd ${PWD}/tokyocabinet && ./configure --prefix=${PWD}/tokyocabinet --enable-static --disable-shared --disable-bzip && make && make install

${libkyototycoon}:
	cd ${PWD}/kyototycoon && ./configure --prefix=${PWD}/kyototycoon --enable-static --disable-shared --with-kc=${PWD}/kyotocabinet && make && make install

${libkyotocabinet}:
	cd kyotocabinet && ./configure --prefix=${PWD}/kyotocabinet --enable-static --disable-shared && make && make install


${libPinchesAndCacti}:
	cd ${PWD}/pinchesAndCacti && make

${libMatchingAndOrdering}:
	cd ${PWD}/matchingAndOrdering && make

${libCPecan}:
	cd ${PWD}/cPecan && make

${halAppendCactusSubtree}: hdf5Rule halRule
	cd ${PWD}/cactus2hal && PATH=${PWD}/hdf5/bin:$(PATH) make

hdf5Rule :
	cd hdf5 &&./configure --prefix=$(PWD)/hdf5 --enable-cxx && CFLAGS=-std=c99 make -e && make install

halRule:
	cd ${PWD}/hal && PATH=${PWD}/hdf5/bin:$(PATH) make

ucscClean:
	cd ${PWD}/cactus && make clean
	cd ${PWD}/sonLib && make clean
	cd ${PWD}/pinchesAndCacti && make clean
	cd ${PWD}/matchingAndOrdering && make clean

clean: ucscClean
	cd ${PWD}/kyotocabinet && make clean
	cd ${PWD}/kyototycoon && make clean
	cd ${PWD}/tokyocabinet && make clean
	cd ${PWD}/hdf5 && make clean
	cd ${PWD}/hal && make clean
	cd ${PWD}/cactus2hal && make clean
