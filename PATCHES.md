# uteg patches on top of upstream Dokploy

Branch `uteg` = upstream release tag + the patches below. Keep this list current; it is the checklist when resolving upstream sync conflicts.

| Patch | Files |
|---|---|
| Self-update disabled (UI + API). Upgrades only via the `uteg images` pipeline. | `apps/dokploy/server/api/routers/settings.ts`, `apps/dokploy/components/layouts/side.tsx`, `apps/dokploy/components/dashboard/settings/web-server.tsx` |
| Version shown as `<upstream>-uteg.N` (`UTEG_VERSION`) | `apps/dokploy/server/api/routers/settings.ts`, `Dockerfile` (tail) |
| Monitoring agent image override (`MONITORING_IMAGE`) | `packages/server/src/setup/monitoring-setup.ts`, `Dockerfile` (tail) |
| Image build to GHCR | `.github/workflows/uteg-images.yml` |

Images: `ghcr.io/utegsk/dokploy:<version>-uteg.<run>` and `ghcr.io/utegsk/dokploy-monitoring:<same tag>` (amd64).
