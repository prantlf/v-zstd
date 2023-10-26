ifeq (1,${RELEASE})
	VFLAGS=-prod
endif

all: check build test

check:
	v fmt -w .
	v vet .

build:
	v $(VFLAGS) -o gzstd cmd/gzstd/gzstd.v
	v $(VFLAGS) -o gunzstd cmd/gunzstd/gunzstd.v

test:
	v -use-os-system-to-run test .
	./test.sh

clean:
	rm -rf src/*_test src/*.dSYM gzstd gunzstd
