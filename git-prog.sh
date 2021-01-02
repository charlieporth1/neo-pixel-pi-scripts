#!/bin/bash
export ROOT_GIT_DIR=""
git config --global user.name 'Charlie Porth'
git config --global user.email 'charlieporth1@gmail.com'
IF_NGIT_INIT() {
	cd $ROOT_GIT_DIR
	if ! [[ -d ./.git ]]; then
		git init
		git remote add origin $REPO
		git pull origin master
		git push --set-upstream origin master
	fi

}
IF_ADD_SUB() {
	cd $ROOT_GIT_DIR
	SUB_MODLUES_GIT_DIR=`find . -type d -name .git | grep -v '\./\.'`
	for GIT_DIR in "${SUB_MODLUES_GIT_DIR}"
	do
		echo "done"
	done
}
COMMIT_AND_PUSH() {
	cd $ROOT_GIT_DIR
	git pull
	git add .
	git commit -m "Automatic commit from server at `date`"
	timeout 600 git push
	timeout 600 git push -ff
}
cp -rf /home/$ADMIN_USR/.git-credentials  ~/.git-credentials

export ROOT_GIT_DIR=$PROG
IF_NGIT_INIT 'https://github.com/charlieporth1/neo-pixel-pi-scripts'
COMMIT_AND_PUSH

export ROOT_GIT_DIR=/home/pi/neo-pixel-python 
IF_NGIT_INIT 'https://github.com/charlieporth1/neo-pixel-raspi-py'
COMMIT_AND_PUSH




[[ "$USER" != "$ADMIN_USR" ]] && rm -rf ~/.git-credentials
