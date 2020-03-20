init:
	git clone --single-branch https://github.com/Kong/kong-pongo ../kong-pongo
	../kong-pongo/pongo.sh up
	../kong-pongo/pongo.sh build

test:
	../kong-pongo/pongo.sh lint
	../kong-pongo/pongo.sh run
down:
	../kong-pongo/pongo.sh down
