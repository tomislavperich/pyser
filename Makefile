REGGAE_PATH = /usr/local/share/reggae
SERVICES = backend https://github.com/pyserorg/backend \
	   frontend https://github.com/pyserorg/frontend


collect: up
	@bin/collect.sh

publish: collect
	@ssh pyser.org 'cd /usr/cbsd/jails-data/pyserback-data/usr/home/pyser/pyser && git fetch && git reset --hard origin/master'
	@rsync -rv --delete-after --progress build/ pyser.org:/usr/cbsd/jails-data/nginx-data/usr/local/www/pyser.org/
	@ssh -t pyser.org 'sudo cbsd jexec jname=pyserback supervisorctl restart pyser'

shell: up
	@sudo cbsd jexec user=devel jname=pyserback /usr/src/bin/shell.sh

.include <${REGGAE_PATH}/mk/project.mk>
