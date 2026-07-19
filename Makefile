ifeq (1,${RELEASE})
	VFLAGS=-prod
endif

all: check test

check:
	v fmt -w .
	v vet .

# build:
# 	v $(VFLAGS) -o gzstd cmd/gzstd/gzstd.v
# 	v $(VFLAGS) -o gunzstd cmd/gunzstd/gunzstd.v

test:
	v test .
# 	./test.sh

clean:
	rm -rf *_test *.dSYM gzstd gunzstd
