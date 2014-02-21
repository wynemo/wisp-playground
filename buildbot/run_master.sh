cd ~/wisp-play-master
~/sandbox/bin/python -c "from twisted.scripts import twistd; twistd.run()" --no_save --logfile=twistd.log --python=buildbot.tac
