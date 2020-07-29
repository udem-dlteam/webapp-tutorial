.SUFFIXES:
.SUFFIXES: .md .html .scm .js

all: webapp-tutorial.js index.html

.md.html: webapp-tutorial.js webapp-tutorial.css
	echo "<link rel=\"stylesheet\" href=\"default.css\">" > webapp-tutorial.temp
	echo "<script src=\"webapp-tutorial.js\"></script>" >> webapp-tutorial.temp
	pandoc +RTS -M512M -K128M -RTS -H webapp-tutorial.temp -f markdown -t revealjs -V theme:simple --standalone -o $*.html $*.md
	rm -f webapp-tutorial.temp
	@echo "###### to publish the slides to https://udem-dlteam.github.io/webapp-tutorial/."
	@echo "git commit -a -m '<some_message>'"
	@echo "git push"

.scm.js:
	@if ../../../gsc/gsc -:=../../.. -target js -o $*.js -exe $*.scm; then \
	  echo "###### compilation of $*.scm to $*.js succeeded"; \
	else \
	  echo "###### compilation of $*.scm to $*.js failed"; \
	  rm -f $*.js; \
	  exit 1; \
	fi

clean:
	rm -f webapp-tutorial.js webapp-tutorial.temp index.html
