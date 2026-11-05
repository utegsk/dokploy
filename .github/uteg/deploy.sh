#!/usr/bin/env bash
# Runs on the Dokploy host: ssh host 'bash -s' -- <image> < deploy.sh
# Backs up the Dokploy database, switches the dokploy service to <image> and
# waits for the new container to report healthy. Rolls the image back if not.
set -euo pipefail

IMAGE="$1"
SERVICE=dokploy
BACKUP_DIR="$HOME/dokploy-backups"
KEEP_BACKUPS=14
HEALTH_TIMEOUT=420

current=$(docker service inspect "$SERVICE" --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}')
echo "Current image: $current"
echo "New image:     $IMAGE"

mkdir -p "$BACKUP_DIR"
backup="$BACKUP_DIR/dokploy-$(date +%Y%m%d-%H%M%S).dump"
pg=$(docker ps -q -f name=dokploy-postgres | head -1)
docker exec "$pg" pg_dump -U dokploy -Fc dokploy > "$backup"
echo "Backup: $backup ($(du -h "$backup" | cut -f1))"
ls -1t "$BACKUP_DIR"/dokploy-*.dump | tail -n +$((KEEP_BACKUPS + 1)) | xargs -r rm --

docker pull --quiet "$IMAGE"
docker service update --quiet --detach --image "$IMAGE" "$SERVICE" >/dev/null

rollback() {
	echo "::error::$1 — rolling back to $current"
	docker service update --quiet --detach=false --image "$current" "$SERVICE" >/dev/null
	echo "Rolled back. Database backup from before the update: $backup"
	echo "Migrations are not reverted; restore the backup if the old version misbehaves."
	exit 1
}

deadline=$((SECONDS + HEALTH_TIMEOUT))
while ((SECONDS < deadline)); do
	sleep 10
	container=$(docker ps -q -f "name=${SERVICE}\." -f "ancestor=$IMAGE" | head -1)
	[ -n "$container" ] || continue
	status=$(docker inspect "$container" --format '{{.State.Health.Status}}')
	echo "$(date +%T) $status"
	if [ "$status" = healthy ]; then
		echo "Deployed $IMAGE"
		exit 0
	fi
	[ "$status" = unhealthy ] && rollback "new container is unhealthy"
done
rollback "no healthy container after ${HEALTH_TIMEOUT}s"
