siglog siglog-private: source/*
	swipl -g "siglog(compile), halt" source/siglog.pl

siglog.deb: siglog siglog.desktop deb/DEBIAN/control deb/copyright makefile
	test -d deb/usr/bin || mkdir -p deb/usr/bin
	test -d deb/usr/bin/share/applications || mkdir -p deb/usr/share/applications
	cp siglog siglog-private deb/usr/bin/
	cp signal-cli deb/usr/bin/
	test -d deb/usr/share/siglog || mkdir -p deb/usr/share/siglog
	cp -r source deb/usr/share/siglog/ # copy the source
	cp siglog.desktop siglog-private.desktop deb/usr/share/applications/
	dpkg-deb --build deb siglog.deb

check:
	lintian -c siglog.deb

clean:
	rm -rf siglog deb/usr siglog.dev

signal-cli:
	swipl -g "signal(install,_)" source/signal.pl
