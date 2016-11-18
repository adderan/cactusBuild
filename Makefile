export sonLibRootPath = ${PWD}/sonLib

export tokyoCabinetLib = ${PWD}/tokyocabinet/libtokyocabinet.a
export kyotoTycoonLib = ${PWD}/kyototycoon/libkyototycoon.a
export kyotoCabinetLib = ${PWD}/kyotocabinet/libkyotocabinet.a

kyotoTycoonIncl = -I${PWD}/kyototycoon -DHAVE_KYOTO_TYCOON=1 
kyotoTycoonLib = -L${PWD}/kyototycoon -Wl,-rpath,${ttPrefix}/lib -Wl,-Bstatic -lkyototycoon -lkyotocabinet -Wl,-Bdynamic -lz -lbz2 -lpthread -lm -lstdc++

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

${libtokyocabinet}: tokyocabinetRule

${libkyototycoon}: kyototycoonRule

${libkyotocabinet}: kyotocabinetRule

tokyocabinetRule:
	cd ${PWD}/tokyocabinet && ./configure --prefix=${PWD}/tokyocabinet --disable-bzip && make && make install

kyototycoonRule:
	cd ${PWD}/kyototycoon && ./configure --prefix=${PWD}/kyototycoon --with-kc=${PWD}/kyotocabinet && make && make install

kyotocabinetRule:
	cd kyotocabinet && ./configure --prefix=${PWD}/kyotocabinet && make && make install


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
