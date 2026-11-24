#!/usr/bin/env bash
set -Eeuo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
exec 9>/run/lock/zvitplus-cicd.lock
flock -n 9 || { echo 'Another deployment is active'; exit 1; }
base=/opt/zvit-plus/App
state=/var/lib/zvitplus-cicd
stage=/home/developer2/zvitplus-cicd/payload
templates=/usr/local/share/zvitplus-cicd
mkdir -p "$state"
compose=(docker compose --project-directory "$base" --env-file "$base/.env" -f "$base/docker-compose.yml")
override="$state/images.yml"
write_override() {
  printf 'services:\n  api:\n    image: "%s"\n  web:\n    image: "%s"\n' "$1" "$2" > "$override"
}
apply_images() {
  "${compose[@]}" -f "$override" up -d --no-build --no-deps api web
}
if [[ ${1:-} == --rollback ]]; then
  test -s "$state/previous-api" && test -s "$state/previous-web"
  write_override "$(cat "$state/previous-api")" "$(cat "$state/previous-web")"
  apply_images
  echo 'Previous application images restored; database volumes preserved'
  exit 0
fi
[[ $# == 0 ]] || exit 2
test -s "$stage/api/ZvitPlus.API.dll"
test -s "$stage/web/index.html"
revision=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8-sig"))["commit"])' "$stage/build-info.json")
[[ $revision =~ ^[0-9a-f]{40}$ ]] || { echo 'Invalid commit'; exit 2; }
tag=${revision:0:12}
available=$(df -Pk "$state" | awk 'NR==2 {print $4}')
[[ $available -ge 1048576 ]] || { echo 'Less than 1 GiB free; deployment stopped'; exit 1; }
"${compose[@]}" config --quiet
api_container=$("${compose[@]}" ps -q api)
web_container=$("${compose[@]}" ps -q web)
test -n "$api_container" && test -n "$web_container"
old_api=$(docker inspect --format '{{.Image}}' "$api_container")
old_web=$(docker inspect --format '{{.Image}}' "$web_container")
docker build --network=none --label ci.zvitplus.owner=local-jenkins -f "$templates/api.Dockerfile" -t "zvitplus-cicd-api:$tag" "$stage"
docker build --network=none --label ci.zvitplus.owner=local-jenkins -f "$templates/web.Dockerfile" -t "zvitplus-cicd-web:$tag" "$stage"
printf '%s\n' "$old_api" > "$state/previous-api"
printf '%s\n' "$old_web" > "$state/previous-web"
cp -f "$override" "$state/last-images.yml" 2>/dev/null || true
rollback_on_error() {
  trap - ERR
  write_override "$old_api" "$old_web"
  apply_images || true
  echo 'Deployment failed; attempted rollback to previous images' >&2
  exit 1
}
trap rollback_on_error ERR
write_override "zvitplus-cicd-api:$tag" "zvitplus-cicd-web:$tag"
apply_images
healthy=false
for attempt in $(seq 1 30); do
  web_status=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://127.0.0.1/ || true)
  api_status=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://127.0.0.1/api/stats || true)
  if [[ $web_status == 200 && ( $api_status == 200 || $api_status == 401 || $api_status == 403 ) ]]; then healthy=true; break; fi
  sleep 2
done
[[ $healthy == true ]]
trap - ERR
printf '%s\n' "$revision" > "$state/current-commit"
new_api=$(docker image inspect --format '{{.Id}}' "zvitplus-cicd-api:$tag")
new_web=$(docker image inspect --format '{{.Id}}' "zvitplus-cicd-web:$tag")
while read -r image_id; do
  [[ -n $image_id ]] || continue
  if [[ $image_id != "$new_api" && $image_id != "$new_web" && $image_id != "$old_api" && $image_id != "$old_web" ]]; then
    docker image rm "$image_id" || true
  fi
done < <(docker image ls --no-trunc --quiet --filter label=ci.zvitplus.owner=local-jenkins | sort -u)
echo "DEPLOY_OK $revision"
df -h /
