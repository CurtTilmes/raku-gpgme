CWD := $(shell pwd)
NAME := $(shell jq -r .name META6.json)
VERSION := $(shell jq -r .version META6.json)
ARCHIVENAME := $(subst ::,-,$(NAME))

PODABLE = GPGME                                   \
          GPGME/Data                              \
          GPGME/DecryptResult                     \
          GPGME/EncryptResult                     \
          GPGME/EngineInfo                        \
	  GPGME/GenKeyResult                      \
          GPGME/ImportResult                      \
          GPGME/ImportStatus                      \
          GPGME/InvalidKey                        \
          GPGME/Key                               \
          GPGME/KeySig                            \
          GPGME/NewSignature                      \
          GPGME/Recipient                         \
          GPGME/Signature                         \
          GPGME/SigNotation                       \
          GPGME/SignResult                        \
	  GPGME/SubKey                            \
          GPGME/TOFU                              \
          GPGME/UserID                            \
          GPGME/VerifyResult

PODMD = $(patsubst %,doc/%.md,$(PODABLE))

check:
	git diff-index --check HEAD
	prove6

doc/%.md: lib/%.rakumod
	raku --doc=Markdown $< > $@

doc: $(PODMD)

tag:
	git tag $(VERSION)
	git push origin --tags

dist:
	git archive --prefix=$(ARCHIVENAME)-$(VERSION)/ \
		-o ../$(ARCHIVENAME)-$(VERSION).tar.gz $(VERSION)

test-alpine:
	docker run --rm -t  \
	  -e RELEASE_TESTING=1 \
	  -v $(CWD):/test \
          --entrypoint="/bin/sh" \
	  jjmerelo/raku-test \
	  -c "apk add --update --no-cache gpgme && zef install --/test --deps-only --test-depends . && zef -v test ."

alpine-env:
	docker run --rm -it \
	  -e RELEASE_TESTING=1 \
	  -e PERL6LIB=/test/lib \
	  -v $(CWD):/test \
          --entrypoint="/bin/sh" \
	  jjmerelo/raku-test \
	  -c "apk add --update --no-cache gpgme && zef install --/test --deps-only --test-depends . && /bin/sh"

test-debian:
	docker run --rm -t \
	  -e RELEASE_TESTING=1 \
	  -v $(CWD):/test -w /test \
          --entrypoint="/bin/sh" \
	  jjmerelo/rakudo-nostar \
	  -c "apt update && apt install libgpgme11 && zef install --/test --deps-only --test-depends . && zef -v test ."

debian-env:
	docker run --rm -it \
	  -e RELEASE_TESTING=1 \
	  -e PERL6LIB=/test/lib \
	  -v $(CWD):/test -w /test \
          --entrypoint="/bin/sh" \
	  jjmerelo/rakudo-nostar \
	  -c "apt update && apt install libgpgme11 && zef install --/test --deps-only --test-depends . && /bin/bash"

# Yeah, I know I should put all this in a docker image
centos-env:
	docker run --rm -it \
	  -e RELEASE_TESTING=1 \
	  -e PERL6LIB=/test/lib \
	  -v $(CWD):/test -w /test \
          --entrypoint="/bin/bash" \
	  centos:latest \
	  -c "yum install -y glibc-locale-source glibc-langpack-en gpgme wget curl git && wget https://dl.bintray.com/nxadm/rakudo-pkg-rpms/CentOS/8/x86_64/rakudo-pkg-CentOS8-2020.02.1-04.x86_64.rpm && yum install -y rakudo-pkg-CentOS8-2020.02.1-04.x86_64.rpm && source ~/.bashrc && localedef -i en_US -f UTF-8 en_US.UTF-8 && zef install --/test --deps-only --test-depends . && /bin/bash"

test-centos:
	docker run --rm -t \
	  -e RELEASE_TESTING=1 \
	  -v $(CWD):/test -w /test \
          --entrypoint="/bin/bash" \
	  centos:latest \
	  -c "yum install -y glibc-locale-source glibc-langpack-en gpgme wget curl git && wget https://dl.bintray.com/nxadm/rakudo-pkg-rpms/CentOS/8/x86_64/rakudo-pkg-CentOS8-2020.02.1-04.x86_64.rpm && yum install -y rakudo-pkg-CentOS8-2020.02.1-04.x86_64.rpm && source ~/.bashrc && localedef -i en_US -f UTF-8 en_US.UTF-8  && zef install --/test --deps-only --test-depends . && zef -v test ."

test: test-alpine test-debian test-centos
