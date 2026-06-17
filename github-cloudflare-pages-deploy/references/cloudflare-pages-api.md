# Cloudflare Pages API Notes

> Last verified: 2026-06. Field names and endpoints may change — always cross-check against https://developers.cloudflare.com/api/ before using.

Use these notes with the Cloudflare API/MCP connector. Prefer current Cloudflare docs or OpenAPI search when field names appear stale.

## List Projects

`GET /accounts/{account_id}/pages/projects`

Use this before creating anything. Check for a matching project name or an existing domain.

## Create Project

`POST /accounts/{account_id}/pages/projects`

Minimal body for a GitHub-backed frontend:

```json
{
  "name": "project-name",
  "production_branch": "main",
  "build_config": {
    "build_command": "npm run build",
    "destination_dir": "dist",
    "root_dir": "",
    "build_caching": true
  },
  "source": {
    "type": "github",
    "config": {
      "owner": "github-owner",
      "owner_id": "123456",
      "repo_name": "repo-name",
      "repo_id": "123456789",
      "production_branch": "main",
      "deployments_enabled": true,
      "production_deployments_enabled": true,
      "pr_comments_enabled": true,
      "preview_deployment_setting": "all",
      "preview_branch_includes": ["*"],
      "preview_branch_excludes": [],
      "path_includes": ["*"],
      "path_excludes": []
    }
  }
}
```

If the exact GitHub repo ID is unknown, create/check the repo with GitHub first. Some Cloudflare API calls can infer repo ID from an installed GitHub app, but do not rely on that as a portable behavior.

## Domains

Add a domain:

`POST /accounts/{account_id}/pages/projects/{project_name}/domains`

```json
{ "name": "home.example.com" }
```

Read a domain:

`GET /accounts/{account_id}/pages/projects/{project_name}/domains/{domain_name}`

Look for:

- `status: "active"`
- `verification_data.status: "active"`
- `validation_data.status: "active"`

If verification says `CNAME record not set`, add a proxied DNS CNAME in the zone:

```json
{
  "type": "CNAME",
  "name": "home.example.com",
  "content": "project-name.pages.dev",
  "proxied": true,
  "ttl": 1
}
```

## Deployments

List deployments:

`GET /accounts/{account_id}/pages/projects/{project_name}/deployments`

Trigger a GitHub production deployment when none starts automatically:

`POST /accounts/{account_id}/pages/projects/{project_name}/deployments`

Use multipart form-data with at least:

- `branch`: production branch, for example `main`
- `pages_build_output_dir`: output directory, for example `dist`

Poll:

`GET /accounts/{account_id}/pages/projects/{project_name}/deployments/{deployment_id}`

Success means the last stage named `deploy` has `status: "success"`. If a stage fails, fetch deployment logs before trying random fixes.
