
.PHONY: all html htmlbatch

all:

html:
	vim -u tools/buildhtml.vim

htmlbatch:
	git show-branch devel || git branch -t devel origin/devel
	git show-branch gh-pages || git branch -t gh-pages origin/gh-pages
	vim -u tools/buildhtml.vim -e -s -- --batch
	cd html && git push ..

deploy:
	sh ./tools/update-master.sh
