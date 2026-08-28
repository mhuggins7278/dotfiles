import assert from "node:assert/strict"
import { spawnSync } from "node:child_process"
import { createHash } from "node:crypto"
import fs from "node:fs"
import os from "node:os"
import path from "node:path"
import test from "node:test"
import { fileURLToPath } from "node:url"

import {
  buildEpiqueryUrl,
  buildEpiqueryEnsurePlan,
  buildProjectEnsurePlan,
  containsSqlMutation,
  findEpiqueryErrors,
  isAcceptableRouteStatus,
  mergeProjectConfig,
  normalizeRepositorySlug,
  parseCurlResponse,
  renderEpiqueryOverride,
  requiresWriteAuthorization,
} from "./localdev-harness.mjs"

test("normalizes supported GitHub repository URLs", () => {
  assert.equal(
    normalizeRepositorySlug("git@github.com:glg/consultations-api.git"),
    "glg/consultations-api",
  )
  assert.equal(
    normalizeRepositorySlug("https://github.com/glg/prism.git"),
    "glg/prism",
  )
  assert.equal(
    normalizeRepositorySlug("ssh://git@github.com/glg/settings-api.git"),
    "glg/settings-api",
  )
})

test("rejects repository URLs outside GitHub", () => {
  assert.equal(normalizeRepositorySlug("git@gitlab.com:glg/prism.git"), null)
})

test("explicit project metadata overrides the registry", () => {
  const resolved = mergeProjectConfig(
    {
      service: "prism",
      port: 8700,
      securityMode: "verifiedSession",
      command: ["npm", "run", "dev"],
    },
    {
      port: 8800,
      command: ["npm", "run", "dev:server"],
    },
  )

  assert.deepEqual(resolved, {
    service: "prism",
    port: 8800,
    securityMode: "verifiedSession",
    command: ["npm", "run", "dev:server"],
  })
})

test("reports missing required project metadata", () => {
  assert.throws(
    () => mergeProjectConfig({ service: "unknown" }, {}),
    /missing project metadata: port, securityMode, command/,
  )
})

test("rejects ports outside the TCP range", () => {
  assert.throws(
    () => mergeProjectConfig(
      {
        service: "example",
        port: 65536,
        securityMode: "public",
        command: ["npm", "start"],
      },
      {},
    ),
    /invalid project port/,
  )
})

test("normalizes host-app service names", () => {
  assert.equal(
    mergeProjectConfig(
      {
        service: "My-API",
        port: 3000,
        securityMode: "public",
        command: ["npm", "start"],
      },
      {},
    ).service,
    "my-api",
  )
})

test("allows register-only metadata without a process command", () => {
  assert.deepEqual(
    mergeProjectConfig(
      { service: "example", port: 3000, securityMode: "public" },
      {},
      { requireCommand: false },
    ),
    { service: "example", port: 3000, securityMode: "public" },
  )
})

test("renders read-only mounts for both configured Epiquery services", () => {
  const output = renderEpiqueryOverride("/tmp/epiquery templates")

  assert.match(output, /epi-general-internal-service:/)
  assert.match(output, /epi-general-service:/)
  assert.equal(output.match(/target: \/epiquery-templates/g)?.length, 2)
  assert.equal(output.match(/read_only: true/g)?.length, 2)
  assert.equal(output.match(/source: "\/tmp\/epiquery templates"/g)?.length, 2)
})

test("detects executable SQL mutations but ignores comments", () => {
  assert.equal(containsSqlMutation("SELECT TOP 10 * FROM dbo.Person"), false)
  assert.equal(
    containsSqlMutation("-- UPDATE is discussed here\nSELECT 1 AS value"),
    false,
  )
  assert.equal(
    containsSqlMutation("/* DELETE example */\nUPDATE dbo.Person SET Name = @name"),
    true,
  )
  assert.equal(containsSqlMutation("SELECT * INTO #ids FROM dbo.Person"), true)
  assert.equal(
    containsSqlMutation("SELECT '--' AS marker; DELETE FROM dbo.Person"),
    true,
  )
  assert.equal(containsSqlMutation("SELECT 'DELETE' AS operation"), false)
})

test("legacy Mustache templates fail closed without write authorization", () => {
  assert.equal(requiresWriteAuthorization("getValue.mustache", "SELECT 1"), true)
  assert.equal(requiresWriteAuthorization("getValue.sql", "SELECT 1"), false)
  assert.equal(requiresWriteAuthorization("updateValue.sql", "UPDATE dbo.Value SET X = 1"), true)
  assert.equal(
    requiresWriteAuthorization("denyValue.sql", "DENY SELECT ON dbo.Value TO public"),
    true,
  )
  assert.equal(
    requiresWriteAuthorization("checkValue.sql", "DBCC CHECKIDENT ('dbo.Value')"),
    true,
  )
  assert.equal(
    requiresWriteAuthorization("declareValue.sql", "DECLARE @id int; SELECT @id"),
    true,
  )
})

test("finds Epiquery errors embedded in successful HTTP responses", () => {
  assert.deepEqual(findEpiqueryErrors([{ id: 1 }]), [])
  assert.deepEqual(
    findEpiqueryErrors([
      {
        message: "error",
        error: "Invalid object name",
        errorDetail: { code: "EREQUEST" },
      },
    ]),
    [
      {
        message: "Invalid object name",
        code: "EREQUEST",
      },
    ],
  )
  assert.deepEqual(
    findEpiqueryErrors({ error: "unable to find connection by name 'bad'" }),
    [{ message: "unable to find connection by name 'bad'", code: null }],
  )
})

test("separates curl response bodies from HTTP status", () => {
  assert.deepEqual(parseCurlResponse('[{"id":1}]\n200'), {
    status: 200,
    body: '[{"id":1}]',
  })
  assert.throws(() => parseCurlResponse("missing status"), /HTTP status/)
})

test("plans generic host-app registration against explicit Compose state", () => {
  const plan = buildProjectEnsurePlan({
    cacheFile: "/cache/glgroup.json",
    committedOverride: "/gds/docker-compose.override.yaml",
    committedOverrideExists: true,
    cacheIsDevelopment: false,
    composeExists: false,
    composeFile: "/gds/docker-compose.yaml",
    configRoot: "/gds",
    epiqueryOverride: "/cache/epiquery.override.yaml",
    project: {
      service: "consultations-api",
      port: 3020,
      securityMode: "verifiedSession",
      command: ["npm", "run", "dev"],
    },
  })

  assert.deepEqual(plan[0], {
    command: "glgroup",
    args: [
      "localdev",
      "bootstrap",
      "-x",
      "--environment",
      "development",
      "-p",
      "/gds",
      "-d",
      "/gds/docker-compose.yaml",
      "--cachefile",
      "/cache/glgroup.json",
    ],
  })
  assert.deepEqual(plan[1], {
    command: "glgroup",
    args: [
      "localdev",
      "host-app",
      "-d",
      "/gds/docker-compose.yaml",
      "-s",
      "consultations-api",
      "-p",
      "3020",
      "--securityMode",
      "verifiedSession",
      "--cachefile",
      "/cache/glgroup.json",
    ],
  })
  assert.deepEqual(plan[2].args.filter((value) => value === "-f").length, 1)
  assert.equal(
    plan[2].args[plan[2].args.indexOf("-f") + 1],
    "/gds/docker-compose.yaml /gds/docker-compose.override.yaml /cache/epiquery.override.yaml",
  )
  assert.deepEqual(plan[2].args.slice(-4), [
    "--environment",
    "development",
    "--cachefile",
    "/cache/glgroup.json",
  ])
  assert.equal(plan.flatMap(({ args }) => args).includes("streamliner"), false)
})

test("plans Epiquery startup with the generated mount override", () => {
  const plan = buildEpiqueryEnsurePlan({
    cacheFile: "/cache/glgroup.json",
    committedOverride: "/gds/docker-compose.override.yaml",
    committedOverrideExists: true,
    cacheIsDevelopment: true,
    composeExists: true,
    composeFile: "/gds/docker-compose.yaml",
    configRoot: "/gds",
    epiqueryOverride: "/cache/epiquery.override.yaml",
  })

  assert.equal(plan.length, 1)
  assert.deepEqual(plan[0].args, [
    "localdev",
    "up",
    "-d",
    "-p",
    "/gds",
    "-f",
    "/gds/docker-compose.yaml /gds/docker-compose.override.yaml /cache/epiquery.override.yaml",
    "--environment",
    "development",
    "--cachefile",
    "/cache/glgroup.json",
  ])
})

test("existing Compose state is re-bootstrapped when the cache is not development", () => {
  const plan = buildEpiqueryEnsurePlan({
    cacheFile: "/cache/glgroup.json",
    cacheIsDevelopment: false,
    committedOverride: "/gds/docker-compose.override.yaml",
    committedOverrideExists: true,
    composeExists: true,
    composeFile: "/gds/docker-compose.yaml",
    configRoot: "/gds",
    epiqueryOverride: "/cache/epiquery.override.yaml",
  })

  assert.equal(plan[0].args[1], "bootstrap")
})

test("builds an encoded Epiquery POST URL", () => {
  assert.equal(
    buildEpiqueryUrl(
      "https://local.dev.glgresearch.com/epi-general-internal/",
      "GLGLIVE",
      "consultations-api/get consultation.sql",
    ),
    "https://local.dev.glgresearch.com/epi-general-internal/epiquery1/GLGLIVE/consultations-api/get%20consultation.sql",
  )
})

test("route verification rejects missing routes", () => {
  assert.equal(isAcceptableRouteStatus(302), true)
  assert.equal(isAcceptableRouteStatus(401), true)
  assert.equal(isAcceptableRouteStatus(403), true)
  assert.equal(isAcceptableRouteStatus(404), false)
  assert.equal(isAcceptableRouteStatus(500), false)
})

test("CLI dry-run returns a generic project plan without writing state", () => {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "glg-localdev-test-"))
  const configRoot = path.join(temporary, "gds.clusterconfig.dev")
  const projectRoot = path.join(temporary, "example-api")
  const cacheRoot = path.join(temporary, "cache")
  fs.mkdirSync(configRoot)
  fs.mkdirSync(projectRoot)

  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(new URL("./localdev-harness.mjs", import.meta.url)),
      "project",
      "ensure",
      "--root",
      projectRoot,
      "--service",
      "example-api",
      "--port",
      "65431",
      "--security-mode",
      "public",
      "--command-json",
      '["npm","run","dev"]',
      "--config-root",
      configRoot,
      "--cache-root",
      cacheRoot,
      "--dry-run",
    ],
    { encoding: "utf8" },
  )

  assert.equal(result.status, 0, result.stderr)
  const output = JSON.parse(result.stdout)
  assert.equal(output.ok, true)
  assert.equal(output.project.service, "example-api")
  assert.equal(output.operations.at(-1).kind, "project-process")
  assert.equal(fs.existsSync(cacheRoot), false)
  fs.rmSync(temporary, { recursive: true, force: true })
})

test("Epiquery query dry-run plans an unpersisted worktree", () => {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "glg-epiquery-test-"))
  const configRoot = path.join(temporary, "gds.clusterconfig.dev")
  const templatesDir = path.join(temporary, "epiquery-templates.issue-1")
  const cacheRoot = path.join(temporary, "cache")
  fs.mkdirSync(configRoot)
  fs.mkdirSync(templatesDir)
  fs.writeFileSync(path.join(templatesDir, "getValue.sql"), "SELECT 1 AS value\n")
  spawnSync("git", ["init", "-q", templatesDir])
  spawnSync("git", ["-C", templatesDir, "remote", "add", "origin", "git@github.com:glg/epiquery-templates.git"])

  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(new URL("./localdev-harness.mjs", import.meta.url)),
      "epiquery",
      "query",
      "--templates-dir",
      templatesDir,
      "--connection",
      "GLGLIVE",
      "--template",
      "getValue.sql",
      "--config-root",
      configRoot,
      "--cache-root",
      cacheRoot,
      "--dry-run",
    ],
    { encoding: "utf8" },
  )

  assert.equal(result.status, 0, result.stderr)
  const output = JSON.parse(result.stdout)
  assert.equal(output.ok, true)
  assert.equal(output.template, "getValue.sql")
  assert.equal(fs.existsSync(cacheRoot), false)
  fs.rmSync(temporary, { recursive: true, force: true })
})

test("failed project setup leaves a pending cleanup journal", () => {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "glg-localdev-failure-"))
  const configRoot = path.join(temporary, "gds.clusterconfig.dev")
  const projectRoot = path.join(temporary, "example-api")
  const cacheRoot = path.join(temporary, "cache")
  const binDir = path.join(temporary, "bin")
  fs.mkdirSync(configRoot)
  fs.mkdirSync(projectRoot)
  fs.mkdirSync(binDir)
  fs.writeFileSync(path.join(configRoot, "docker-compose.yaml"), "services: {}\n")
  fs.mkdirSync(cacheRoot)
  fs.writeFileSync(
    path.join(cacheRoot, "glgroup.json"),
    '{"environment":"development"}\n',
  )
  const fakeGlgroup = path.join(binDir, "glgroup")
  fs.writeFileSync(fakeGlgroup, "#!/bin/sh\nexit 1\n", { mode: 0o755 })

  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(new URL("./localdev-harness.mjs", import.meta.url)),
      "project",
      "ensure",
      "--root",
      projectRoot,
      "--service",
      "example-api",
      "--port",
      "65431",
      "--security-mode",
      "public",
      "--command-json",
      '["npm","run","dev"]',
      "--config-root",
      configRoot,
      "--cache-root",
      cacheRoot,
    ],
    {
      encoding: "utf8",
      env: { ...process.env, PATH: `${binDir}:${process.env.PATH}` },
    },
  )

  assert.equal(result.status, 1)
  const stateFiles = fs.readdirSync(path.join(cacheRoot, "projects"))
  assert.equal(stateFiles.length, 1)
  const state = JSON.parse(
    fs.readFileSync(path.join(cacheRoot, "projects", stateFiles[0]), "utf8"),
  )
  assert.equal(state.status, "pending")
  assert.equal(state.service, "example-api")
  fs.rmSync(temporary, { recursive: true, force: true })
})

test("queries reject pending Epiquery state", () => {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "glg-epiquery-pending-"))
  const templatesDir = path.join(temporary, "epiquery-templates")
  const cacheRoot = path.join(temporary, "cache")
  fs.mkdirSync(templatesDir)
  fs.mkdirSync(cacheRoot)
  fs.writeFileSync(path.join(templatesDir, "getValue.sql"), "SELECT 1 AS value\n")
  fs.writeFileSync(
    path.join(cacheRoot, "epiquery.json"),
    `${JSON.stringify({
      baseUrl: "https://local.dev.glgresearch.com/epi-general-internal",
      status: "pending",
      templatesDir,
    })}\n`,
  )

  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(new URL("./localdev-harness.mjs", import.meta.url)),
      "epiquery",
      "query",
      "--connection",
      "GLGLIVE",
      "--template",
      "getValue.sql",
      "--cache-root",
      cacheRoot,
      "--dry-run",
    ],
    { encoding: "utf8" },
  )

  assert.equal(result.status, 3)
  assert.equal(JSON.parse(result.stderr).error.code, "EPIQUERY_NOT_READY")
  fs.rmSync(temporary, { recursive: true, force: true })
})

test("cleanup preserves project state when Compose cannot be inspected", () => {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "glg-localdev-cleanup-"))
  const configRoot = path.join(temporary, "gds.clusterconfig.dev")
  const projectRoot = path.join(temporary, "example-api")
  const cacheRoot = path.join(temporary, "cache")
  const stateDir = path.join(cacheRoot, "projects")
  const binDir = path.join(temporary, "bin")
  fs.mkdirSync(configRoot)
  fs.mkdirSync(projectRoot)
  fs.mkdirSync(stateDir, { recursive: true })
  fs.mkdirSync(binDir)
  fs.writeFileSync(path.join(configRoot, "docker-compose.yaml"), "invalid: [\n")
  const key = createHash("sha256")
    .update(fs.realpathSync(projectRoot))
    .digest("hex")
    .slice(0, 16)
  const stateFile = path.join(stateDir, `${key}.json`)
  fs.writeFileSync(stateFile, `${JSON.stringify({
    hostAppService: "example-api-hostapp",
    owned: false,
    pid: null,
    port: 65431,
    root: projectRoot,
    service: "example-api",
    status: "pending",
  })}\n`)
  const fakeDocker = path.join(binDir, "docker")
  fs.writeFileSync(fakeDocker, "#!/bin/sh\nexit 1\n", { mode: 0o755 })

  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(new URL("./localdev-harness.mjs", import.meta.url)),
      "project",
      "stop",
      "--root",
      projectRoot,
      "--config-root",
      configRoot,
      "--cache-root",
      cacheRoot,
    ],
    {
      encoding: "utf8",
      env: { ...process.env, PATH: `${binDir}:${process.env.PATH}` },
    },
  )

  assert.equal(result.status, 1)
  assert.equal(JSON.parse(result.stderr).error.code, "CLEANUP_VERIFY_FAILED")
  assert.equal(fs.existsSync(stateFile), true)
  fs.rmSync(temporary, { recursive: true, force: true })
})

test("a stale malformed lock is reclaimed", () => {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "glg-localdev-lock-"))
  const projectRoot = path.join(temporary, "example-api")
  const cacheRoot = path.join(temporary, "cache")
  fs.mkdirSync(projectRoot)
  fs.mkdirSync(cacheRoot)
  const lockFile = path.join(cacheRoot, ".lock")
  fs.writeFileSync(lockFile, "{")
  const stale = new Date(Date.now() - 10_000)
  fs.utimesSync(lockFile, stale, stale)

  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(new URL("./localdev-harness.mjs", import.meta.url)),
      "project",
      "stop",
      "--root",
      projectRoot,
      "--cache-root",
      cacheRoot,
    ],
    { encoding: "utf8" },
  )

  assert.equal(result.status, 0, result.stderr)
  assert.equal(fs.existsSync(lockFile), false)
  fs.rmSync(temporary, { recursive: true, force: true })
})
