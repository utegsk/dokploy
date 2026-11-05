# uteg patches on top of upstream Dokploy

Branch `uteg` = upstream release tag + the patches below. Keep this list current; it is the checklist when resolving upstream sync conflicts.

| Patch | Files |
|---|---|
| Self-update disabled (UI + API). Upgrades only via the `uteg images` pipeline. | `apps/dokploy/server/api/routers/settings.ts`, `apps/dokploy/components/layouts/side.tsx`, `apps/dokploy/components/dashboard/settings/web-server.tsx` |
| Version shown as `<upstream>-uteg.N` (`UTEG_VERSION`) | `apps/dokploy/server/api/routers/settings.ts`, `Dockerfile` (tail) |
| Monitoring agent image override (`MONITORING_IMAGE`) | `packages/server/src/setup/monitoring-setup.ts`, `Dockerfile` (tail) |
| Remote-server monitoring for self-hosted (`ENABLE_REMOTE_MONITORING`, default on): agent deployed on server setup, Monitoring tab, charts button, Server Threshold notification toggle | `packages/server/src/constants/index.ts`, `packages/server/src/setup/server-setup.ts`, `apps/dokploy/server/api/routers/settings.ts` (`isRemoteMonitoringEnabled`), `apps/dokploy/components/dashboard/settings/servers/setup-server.tsx`, `.../servers/show-servers.tsx`, `.../notifications/handle-notifications.tsx` |
| Cherry-pick of upstream `a9aeeef7` (unmerged branch): self-hosted threshold alerts resolve the organization instead of sending to `""` | `apps/dokploy/server/api/routers/notification.ts`, `apps/dokploy/__test__/notifications/receive-notification.test.ts` — drop when upstream merges it |
| Image build to GHCR on every push to `uteg` | `.github/workflows/uteg-images.yml` |
| Daily upstream sync PR (latest Dokploy release → `sync/<tag>` → PR into `uteg`; draft + `sync-conflict` label on conflicts) | `.github/workflows/uteg-upstream-sync.yml` |
| CI on PRs into `uteg` (build, test, typecheck, Go agent) | `.github/workflows/uteg-ci.yml` |
| Deploy after image build, approval via environment `uteg-infra`; DB backup, health wait, image rollback | `.github/workflows/uteg-deploy.yml`, `.github/uteg/deploy.sh` |

Images: `ghcr.io/utegsk/dokploy:<version>-uteg.<run>` and `ghcr.io/utegsk/dokploy-monitoring:<same tag>` (amd64).
