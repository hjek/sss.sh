shartphone shartphone-private: source/*
	swipl -g "shartphone(compile), halt" source/shartphone.pl

shartphone.deb: shartphone shartphone.desktop deb/DEBIAN/control deb/copyright makefile
	test -d deb/usr/bin || mkdir -p deb/usr/bin
	test -d deb/usr/bin/share/applications || mkdir -p deb/usr/share/applications
	cp shartphone shartphone-private deb/usr/bin/
	cp signal-cli deb/usr/bin/
	test -d deb/usr/share/shartphone || mkdir -p deb/usr/share/shartphone
	cp -r source deb/usr/share/shartphone/ # copy the source
	cp shartphone.desktop shartphone-private.desktop deb/usr/share/applications/
	dpkg-deb --build deb shartphone.deb

check:
	lintian -c shartphone.deb

clean:
	rm -rf shartphone deb/usr shartphone.dev

signal-cli:
	swipl -g "signal(install,_)" source/signal.pl
