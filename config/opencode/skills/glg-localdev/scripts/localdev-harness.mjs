#!/usr/bin/env node

import { spawn, spawnSync } from "node:child_process"
import { createHash, randomUUID } from "node:crypto"
import fs from "node:fs"
import net from "node:net"
import os from "node:os"
import path from "node:path"
import { fileURLToPath } from "node:url"

const SCRIPT_PATH = fileURLToPath(import.meta.url)
const SKILL_ROOT = path.resolve(path.dirname(SCRIPT_PATH), "..")
const DEFAULT_REGISTRY_PATH = path.join(SKILL_ROOT, "references", "projects.json")
const DEFAULT_CACHE_ROOT = path.join(os.homedir(), ".cache", "glg-localdev")
const DEFAULT_CONFIG_ROOT = path.join(
  os.homedir(),
  "github",
  "glg",
  "gds.clusterconfig.dev",
)
const EPIQUERY_SERVICES = [
  "epi-general-internal-service",
  "epi-general-service",
]

class HarnessError extends Error {
  constructor(code, message, details = null, exitCode = 1) {
    super(message)
    this.name = "HarnessError"
    this.code = code
    this.details = details
    this.exitCode = exitCode
  }
}

export function normalizeRepositorySlug(remote) {
  if (typeof remote !== "string") return null
  const value = remote.trim()
  const patterns = [
    /^git@github\.com:([^/]+\/[^/]+?)(?:\.git)?$/i,
    /^https?:\/\/github\.com\/([^/]+\/[^/]+?)(?:\.git)?\/?$/i,
    /^ssh:\/\/git@github\.com\/([^/]+\/[^/]+?)(?:\.git)?\/?$/i,
  ]

  for (const pattern of patterns) {
    const match = value.match(pattern)
    if (match) return match[1].replace(/\.git$/i, "")
  }
  return null
}

export function mergeProjectConfig(
  registryConfig = {},
  explicitConfig = {},
  { requireCommand = true } = {},
) {
  const merged = {
    ...registryConfig,
    ...Object.fromEntries(
      Object.entries(explicitConfig).filter(([, value]) => value != null),
    ),
  }
  const required = ["service", "port", "securityMode", ...(requireCommand ? ["command"] : [])]
  const missing = required.filter((key) => {
    if (key === "command") {
      return !Array.isArray(merged.command) || merged.command.length === 0
    }
    return merged[key] == null || merged[key] === ""
  })

  if (missing.length > 0) {
    throw new HarnessError(
      "MISSING_PROJECT_METADATA",
      `missing project metadata: ${missing.join(", ")}`,
      { missing },
      2,
    )
  }
  if (
    !Number.isInteger(Number(merged.port)) ||
    Number(merged.port) < 1 ||
    Number(merged.port) > 65535
  ) {
    throw new HarnessError("INVALID_PORT", `invalid project port: ${merged.port}`, null, 2)
  }
  if (!["public", "verifiedSession"].includes(merged.securityMode)) {
    throw new HarnessError(
      "INVALID_SECURITY_MODE",
      `invalid security mode: ${merged.securityMode}`,
      null,
      2,
    )
  }

  const result = {
    ...merged,
    port: Number(merged.port),
    service: String(merged.service).toLowerCase(),
  }
  if (merged.command) result.command = [...merged.command]
  return result
}

export function renderEpiqueryOverride(templatesDir) {
  const source = JSON.stringify(path.resolve(templatesDir))
  const service = (name) => [
    `  ${name}:`,
    "    volumes:",
    "      - type: bind",
    `        source: ${source}`,
    "        target: /epiquery-templates",
    "        read_only: true",
  ].join("\n")

  return [
    "services:",
    ...EPIQUERY_SERVICES.map(service),
    "",
  ].join("\n")
}

function executableSql(sql) {
  const source = String(sql)
  let executable = ""
  let state = "normal"
  for (let index = 0; index < source.length; index += 1) {
    const current = source[index]
    const next = source[index + 1]
    if (state === "line-comment") {
      if (current === "\n") {
        executable += "\n"
        state = "normal"
      }
      continue
    }
    if (state === "block-comment") {
      if (current === "*" && next === "/") {
        state = "normal"
        index += 1
      }
      continue
    }
    if (state === "single-quote") {
      if (current === "'" && next === "'") {
        index += 1
      } else if (current === "'") {
        state = "normal"
      }
      continue
    }
    if (state === "double-quote") {
      if (current === '"' && next === '"') {
        index += 1
      } else if (current === '"') {
        state = "normal"
      }
      continue
    }
    if (state === "bracket") {
      if (current === "]" && next === "]") {
        index += 1
      } else if (current === "]") {
        state = "normal"
      }
      continue
    }

    if (current === "-" && next === "-") {
      state = "line-comment"
      index += 1
    } else if (current === "/" && next === "*") {
      state = "block-comment"
      index += 1
    } else if (current === "'") {
      state = "single-quote"
      executable += " "
    } else if (current === '"') {
      state = "double-quote"
      executable += " "
    } else if (current === "[") {
      state = "bracket"
      executable += " "
    } else {
      executable += current
    }
  }
  return executable
}

export function containsSqlMutation(sql) {
  const executable = executableSql(sql)
  const mutation = /\b(?:INSERT|UPDATE|DELETE|MERGE|UPSERT|REPLACE|TRUNCATE|DROP|ALTER|CREATE|EXEC(?:UTE)?|CALL|GRANT|REVOKE|DENY|DBCC|BACKUP|RESTORE|RECONFIGURE|KILL|SHUTDOWN|BULK|LOAD|COPY|VACUUM|LOCK|REFRESH)\b/i
  const selectInto = /\bSELECT\b[\s\S]*?\bINTO\b/i
  return mutation.test(executable) || selectInto.test(executable)
}

export function requiresWriteAuthorization(templatePath, sql) {
  if (path.extname(templatePath).toLowerCase() === ".mustache") return true
  if (containsSqlMutation(sql)) return true
  const statements = executableSql(sql)
    .split(";")
    .map((statement) => statement.trim())
    .filter(Boolean)
  const readOnly = /^(?:SELECT|WITH|VALUES|SHOW|EXPLAIN|DESCRIBE)\b/i
  return statements.some((statement) => !readOnly.test(statement))
}

export function findEpiqueryErrors(value) {
  const errors = []

  const visit = (item) => {
    if (Array.isArray(item)) {
      item.forEach(visit)
      return
    }
    if (!item || typeof item !== "object") return

    const isErrorEvent = item.message === "error"
    const isTopLevelError = typeof item.error === "string" && !item.message
    if (isErrorEvent || isTopLevelError) {
      errors.push({
        message:
          (typeof item.error === "string" && item.error) ||
          item.errorDetail?.message ||
          "Epiquery returned an error",
        code: item.errorDetail?.code || null,
      })
      return
    }
    Object.values(item).forEach(visit)
  }

  visit(value)
  return errors
}

export function parseCurlResponse(output) {
  const match = String(output).match(/\n(\d{3})\s*$/)
  if (!match) {
    throw new HarnessError(
      "INVALID_HTTP_RESPONSE",
      "curl output did not include an HTTP status",
    )
  }
  return {
    status: Number(match[1]),
    body: String(output).slice(0, match.index),
  }
}

function bootstrapOperation({ cacheFile, composeFile, configRoot }) {
  return {
    command: "glgroup",
    args: [
      "localdev",
      "bootstrap",
      "-x",
      "--environment",
      "development",
      "-p",
      configRoot,
      "-d",
      composeFile,
      "--cachefile",
      cacheFile,
    ],
  }
}

function composeFiles({
  committedOverride,
  committedOverrideExists,
  composeFile,
  epiqueryOverride,
}) {
  return [
    composeFile,
    ...(committedOverrideExists ? [committedOverride] : []),
    ...(epiqueryOverride ? [epiqueryOverride] : []),
  ]
}

function upOperation(options) {
  const files = composeFiles(options)
  return {
    command: "glgroup",
    args: [
      "localdev",
      "up",
      "-d",
      "-p",
      options.configRoot,
      "-f",
      files.join(" "),
      "--environment",
      "development",
      "--cachefile",
      options.cacheFile,
    ],
  }
}

export function buildProjectEnsurePlan(options) {
  return [
    ...(!options.composeExists || !options.cacheIsDevelopment
      ? [bootstrapOperation(options)]
      : []),
    {
      command: "glgroup",
      args: [
        "localdev",
        "host-app",
        "-d",
        options.composeFile,
        "-s",
        options.project.service,
        "-p",
        String(options.project.port),
        "--securityMode",
        options.project.securityMode,
        "--cachefile",
        options.cacheFile,
      ],
    },
    upOperation(options),
  ]
}

export function buildEpiqueryEnsurePlan(options) {
  return [
    ...(!options.composeExists || !options.cacheIsDevelopment
      ? [bootstrapOperation(options)]
      : []),
    upOperation(options),
  ]
}

export function buildEpiqueryUrl(baseUrl, connection, template) {
  const base = String(baseUrl).replace(/\/+$/, "")
  const encodedConnection = encodeURIComponent(connection)
  const encodedTemplate = String(template)
    .split("/")
    .map((part) => encodeURIComponent(part))
    .join("/")
  return `${base}/epiquery1/${encodedConnection}/${encodedTemplate}`
}

const HELP = `
Usage:
  localdev-harness.mjs project ensure [options]
  localdev-harness.mjs project stop [options]
  localdev-harness.mjs epiquery ensure --templates-dir <path> [options]
  localdev-harness.mjs epiquery query --connection <name> --template <path> [options]
  localdev-harness.mjs epiquery stop [options]
  localdev-harness.mjs status [options]

Project options:
  --root <path>                 Project root (default: current directory)
  --service <name>             Override the localdev service name
  --port <number>              Override the host process port
  --security-mode <mode>       public or verifiedSession
  --command-json <json>        Process command as a JSON string array
  --no-start                   Register the route but do not start a process

Epiquery options:
  --templates-dir <path>       epiquery-templates checkout or worktree
  --connection <name>          Epiquery connection name
  --template <path>            Template path relative to the checkout
  --params-json <json>         POST parameters (default: {})
  --allow-write                Permit a template containing write or DDL SQL
  --replace                    Replace another active harness template mount
  --summary-only               Omit the response body from successful output

Shared options:
  --config-root <path>         gds.clusterconfig.dev checkout
  --cache-root <path>          Harness state directory
  --registry <path>            Project metadata registry
  --timeout <seconds>          Readiness timeout (default: 90)
  --dry-run                    Return planned operations without mutations
  --pretty                     Pretty-print JSON output
  --help                       Show this help
`.trim()

const BOOLEAN_OPTIONS = new Set([
  "allow-write",
  "dry-run",
  "help",
  "no-start",
  "pretty",
  "replace",
  "summary-only",
])

function optionKey(value) {
  return value.replace(/^--/, "").replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
}

export function parseArguments(argv) {
  if (argv.length === 0 || argv.includes("--help")) {
    return { help: true }
  }

  let domain
  let action
  let index
  if (argv[0] === "status") {
    domain = "status"
    action = "show"
    index = 1
  } else {
    ;[domain, action] = argv
    index = 2
  }

  const valid =
    (domain === "project" && ["ensure", "stop"].includes(action)) ||
    (domain === "epiquery" && ["ensure", "query", "stop"].includes(action)) ||
    (domain === "status" && action === "show")
  if (!valid) {
    throw new HarnessError("INVALID_COMMAND", "unknown harness command", null, 2)
  }

  const options = {}
  while (index < argv.length) {
    const token = argv[index]
    if (!token.startsWith("--")) {
      throw new HarnessError("INVALID_ARGUMENT", `unexpected argument: ${token}`, null, 2)
    }
    const name = token.slice(2)
    const key = optionKey(token)
    if (BOOLEAN_OPTIONS.has(name)) {
      options[key] = true
      index += 1
      continue
    }
    const value = argv[index + 1]
    if (value == null || value.startsWith("--")) {
      throw new HarnessError("MISSING_ARGUMENT_VALUE", `${token} requires a value`, null, 2)
    }
    options[key] = value
    index += 2
  }

  return { domain, action, options }
}

function expandHome(value) {
  if (!value) return value
  if (value === "~") return os.homedir()
  if (value.startsWith("~/")) return path.join(os.homedir(), value.slice(2))
  return value
}

function resolvedPath(value) {
  return path.resolve(expandHome(value))
}

function runtimePaths(options = {}) {
  const configRoot = resolvedPath(
    options.configRoot || process.env.GLG_LOCALDEV_CONFIG_ROOT || DEFAULT_CONFIG_ROOT,
  )
  const cacheRoot = resolvedPath(
    options.cacheRoot || process.env.GLG_LOCALDEV_CACHE_ROOT || DEFAULT_CACHE_ROOT,
  )
  return {
    cacheRoot,
    cacheFile: path.join(cacheRoot, "glgroup.json"),
    committedOverride: path.join(configRoot, "docker-compose.override.yaml"),
    composeFile: path.join(configRoot, "docker-compose.yaml"),
    configRoot,
    epiqueryOverride: path.join(cacheRoot, "epiquery.override.yaml"),
    epiqueryState: path.join(cacheRoot, "epiquery.json"),
    lockFile: path.join(cacheRoot, ".lock"),
    projectStateDir: path.join(cacheRoot, "projects"),
    registryPath: resolvedPath(options.registry || DEFAULT_REGISTRY_PATH),
  }
}

function redact(value) {
  return String(value)
    .replace(/(password|token|secret)(["'=:\s]+)[^\s,"']+/gi, "$1$2[REDACTED]")
    .slice(-4000)
}

function commandDisplay(operation) {
  return [operation.command, ...operation.args].map((part) => JSON.stringify(part)).join(" ")
}

function runOperation(operation, context = {}) {
  context.operations?.push(operation)
  if (context.dryRun) return { stdout: "", stderr: "", status: 0 }

  const result = spawnSync(operation.command, operation.args, {
    cwd: operation.cwd || context.cwd,
    encoding: "utf8",
    env: operation.env || process.env,
    maxBuffer: 20 * 1024 * 1024,
    timeout: operation.timeout || context.timeout || 10 * 60 * 1000,
  })
  if (result.error) {
    throw new HarnessError(
      "COMMAND_FAILED",
      `failed to run ${operation.command}: ${result.error.message}`,
      { command: commandDisplay(operation) },
    )
  }
  if (result.status !== 0) {
    throw new HarnessError(
      "COMMAND_FAILED",
      `${operation.command} exited with status ${result.status}`,
      {
        command: commandDisplay(operation),
        stderr: redact(result.stderr || result.stdout),
      },
    )
  }
  return result
}

function commandOutput(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd,
    encoding: "utf8",
    env: options.env || process.env,
    maxBuffer: options.maxBuffer || 10 * 1024 * 1024,
    timeout: options.timeout || 30_000,
  })
  if (result.error) throw result.error
  if (result.status !== 0) return null
  return result.stdout.trim()
}

function readJson(file, fallback = null) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"))
  } catch (error) {
    if (error.code === "ENOENT") return fallback
    throw new HarnessError("INVALID_STATE", `could not read JSON: ${file}`)
  }
}

function writeJson(file, value) {
  fs.mkdirSync(path.dirname(file), { recursive: true })
  const temporary = `${file}.${process.pid}.tmp`
  fs.writeFileSync(temporary, `${JSON.stringify(value, null, 2)}\n`, { mode: 0o600 })
  fs.renameSync(temporary, file)
}

function isProcessAlive(pid) {
  if (!Number.isInteger(Number(pid))) return false
  try {
    process.kill(Number(pid), 0)
    return true
  } catch {
    return false
  }
}

function readLockOwner(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"))
  } catch {
    return null
  }
}

async function withLock(paths, callback) {
  fs.mkdirSync(paths.cacheRoot, { recursive: true })
  const token = randomUUID()
  let acquired = false
  for (let attempt = 0; attempt < 5 && !acquired; attempt += 1) {
    let descriptor
    try {
      descriptor = fs.openSync(paths.lockFile, "wx", 0o600)
      fs.writeFileSync(descriptor, `${JSON.stringify({
        pid: process.pid,
        startedAt: new Date().toISOString(),
        token,
      })}\n`)
      fs.closeSync(descriptor)
      acquired = true
    } catch (error) {
      if (descriptor != null) fs.closeSync(descriptor)
      if (error.code !== "EEXIST") throw error
      const age = Date.now() - fs.statSync(paths.lockFile).mtimeMs
      if (age < 5000) {
        throw new HarnessError(
          "HARNESS_BUSY",
          "another localdev harness process is acquiring the lock",
          null,
          3,
        )
      }
      const owner = readLockOwner(paths.lockFile)
      if (isProcessAlive(owner?.pid)) {
        throw new HarnessError(
          "HARNESS_BUSY",
          `another localdev harness process is active (${owner.pid})`,
          owner,
          3,
        )
      }
      try {
        fs.rmSync(paths.lockFile)
      } catch (removeError) {
        if (removeError.code !== "ENOENT") throw removeError
      }
    }
  }
  if (!acquired) {
    throw new HarnessError("HARNESS_BUSY", "could not acquire the localdev harness lock", null, 3)
  }

  try {
    return await callback()
  } finally {
    const owner = readLockOwner(paths.lockFile)
    if (owner?.token === token) {
      try {
        fs.rmSync(paths.lockFile)
      } catch (error) {
        if (error.code !== "ENOENT") throw error
      }
    }
  }
}

function discoverRepositorySlug(projectRoot) {
  const remote = commandOutput("git", ["-C", projectRoot, "remote", "get-url", "origin"])
  const remoteSlug = normalizeRepositorySlug(remote)
  if (remoteSlug) return remoteSlug

  const packageJson = readJson(path.join(projectRoot, "package.json"), {})
  const repository =
    typeof packageJson.repository === "string"
      ? packageJson.repository
      : packageJson.repository?.url
  return normalizeRepositorySlug(repository)
}

function parseCommandJson(value) {
  if (value == null) return null
  let command
  try {
    command = JSON.parse(value)
  } catch {
    throw new HarnessError("INVALID_COMMAND_JSON", "--command-json must be valid JSON", null, 2)
  }
  if (!Array.isArray(command) || command.some((part) => typeof part !== "string" || !part)) {
    throw new HarnessError(
      "INVALID_COMMAND_JSON",
      "--command-json must be a non-empty JSON string array",
      null,
      2,
    )
  }
  return command
}

function resolveProject(projectRoot, options, paths) {
  if (!fs.existsSync(projectRoot) || !fs.statSync(projectRoot).isDirectory()) {
    throw new HarnessError("PROJECT_NOT_FOUND", `project root not found: ${projectRoot}`, null, 2)
  }
  const slug = discoverRepositorySlug(projectRoot)
  const registry = readJson(paths.registryPath, { projects: {} })
  const registryConfig = slug ? registry.projects?.[slug] || {} : {}
  const manifest = readJson(path.join(projectRoot, ".glg-localdev.json"), {})
  const explicit = {
    command: parseCommandJson(options.commandJson),
    port: options.port == null ? null : Number(options.port),
    securityMode: options.securityMode,
    service: options.service,
  }
  const project = mergeProjectConfig(
    { ...registryConfig, ...manifest },
    explicit,
    { requireCommand: !options.noStart },
  )
  project.portEnv = project.portEnv === undefined ? "PORT" : project.portEnv
  return { project, slug }
}

function projectStatePath(paths, projectRoot) {
  const key = createHash("sha256").update(projectRoot).digest("hex").slice(0, 16)
  return path.join(paths.projectStateDir, `${key}.json`)
}

function listenerPids(port) {
  const output = commandOutput("lsof", [
    "-nP",
    `-iTCP:${port}`,
    "-sTCP:LISTEN",
    "-t",
  ])
  if (!output) return []
  return [...new Set(output.split(/\s+/).map(Number).filter(Number.isInteger))]
}

function processWorkingDirectory(pid) {
  if (process.platform === "linux") {
    try {
      return fs.realpathSync(`/proc/${pid}/cwd`)
    } catch {
      return null
    }
  }
  const output = commandOutput("lsof", ["-a", "-p", String(pid), "-d", "cwd", "-Fn"])
  const pathLine = output?.split("\n").find((line) => line.startsWith("n"))
  return pathLine ? pathLine.slice(1) : null
}

function processGroupId(pid) {
  const output = commandOutput("ps", ["-o", "pgid=", "-p", String(pid)])
  const value = Number(output?.trim())
  return Number.isInteger(value) ? value : null
}

function processIdentity(pid) {
  if (!isProcessAlive(pid)) return null
  const startedAt = commandOutput("ps", ["-o", "lstart=", "-p", String(pid)])
  const command = commandOutput("ps", ["-o", "command=", "-p", String(pid)])
  const cwd = processWorkingDirectory(pid)
  if (!startedAt || !command || !cwd) return null
  return { command, cwd: canonicalPath(cwd), startedAt: startedAt.trim() }
}

function sameProcessIdentity(expected, actual) {
  return Boolean(
    expected &&
    actual &&
    expected.command === actual.command &&
    expected.cwd === actual.cwd &&
    expected.startedAt === actual.startedAt,
  )
}

function canonicalPath(value) {
  try {
    return fs.realpathSync(value)
  } catch {
    return path.resolve(value)
  }
}

function belongsToProject(pid, projectRoot) {
  const cwd = processWorkingDirectory(pid)
  if (!cwd) return false
  const project = canonicalPath(projectRoot)
  const processCwd = canonicalPath(cwd)
  return processCwd === project || processCwd.startsWith(`${project}${path.sep}`)
}

function wait(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds))
}

async function waitForListener(port, projectRoot, timeoutMs) {
  const deadline = Date.now() + timeoutMs
  while (Date.now() < deadline) {
    const pids = listenerPids(port)
    const matching = pids.find((pid) => belongsToProject(pid, projectRoot))
    if (matching) return matching
    await wait(500)
  }
  return null
}

function terminateProcessGroup(groupId) {
  try {
    process.kill(-groupId, "SIGTERM")
  } catch {
    // The process group may already have exited.
  }
}

function processGroupAlive(groupId) {
  const output = commandOutput("ps", ["-axo", "pgid="])
  if (output == null) return null
  return output
    .split("\n")
    .map((value) => Number(value.trim()))
    .includes(Number(groupId))
}

async function waitForProcessGroupExit(groupId, timeoutMs = 5000) {
  const deadline = Date.now() + timeoutMs
  while (Date.now() < deadline) {
    const alive = processGroupAlive(groupId)
    if (alive === false) return true
    if (alive == null) return false
    await wait(100)
  }
  return processGroupAlive(groupId) === false
}

async function ensureProjectProcess({
  context,
  noStart,
  onSpawn,
  project,
  projectRoot,
  stateFile,
  timeoutMs,
}) {
  const existingState = readJson(stateFile, null)
  const listeners = listenerPids(project.port)
  const matching = listeners.find((pid) => belongsToProject(pid, projectRoot))
  const conflicting = listeners.filter((pid) => !belongsToProject(pid, projectRoot))

  if (matching) {
    const matchingGroupId = processGroupId(matching)
    const currentIdentity = existingState?.pid
      ? processIdentity(existingState.pid)
      : null
    const owned = Boolean(
      existingState?.owned === true &&
      existingState.processGroupId === matchingGroupId &&
      sameProcessIdentity(existingState.processIdentity, currentIdentity),
    )
    return {
      listeningPid: matching,
      owned,
      pid: owned ? existingState.pid : matching,
      processGroupId: matchingGroupId,
      processIdentity: owned ? currentIdentity : null,
      reused: true,
    }
  }
  if (conflicting.length > 0) {
    throw new HarnessError(
      "PORT_CONFLICT",
      `port ${project.port} is owned by an unrelated process`,
      { pids: conflicting, port: project.port },
      3,
    )
  }
  if (noStart) {
    throw new HarnessError(
      "PROJECT_NOT_RUNNING",
      `no matching project process is listening on port ${project.port}`,
      { port: project.port },
      3,
    )
  }

  const processOperation = {
    command: project.command[0],
    args: project.command.slice(1),
    cwd: projectRoot,
    kind: "project-process",
  }
  context.operations.push(processOperation)
  if (context.dryRun) {
    return {
      owned: true,
      pid: null,
      processGroupId: null,
      processIdentity: null,
      reused: false,
    }
  }

  fs.mkdirSync(path.dirname(stateFile), { recursive: true })
  const logFile = path.join(path.dirname(stateFile), `${path.basename(stateFile, ".json")}.log`)
  const descriptor = fs.openSync(logFile, "a", 0o600)
  const env = { ...process.env }
  if (project.portEnv) env[project.portEnv] = String(project.port)
  const child = spawn(project.command[0], project.command.slice(1), {
    cwd: projectRoot,
    detached: true,
    env,
    stdio: ["ignore", descriptor, descriptor],
  })
  fs.closeSync(descriptor)
  child.unref()
  if (!child.pid) {
    throw new HarnessError("PROJECT_START_FAILED", "project process did not start")
  }
  const spawned = {
    logFile,
    owned: true,
    pid: child.pid,
    processGroupId: processGroupId(child.pid) || child.pid,
    processIdentity: processIdentity(child.pid),
    reused: false,
  }
  onSpawn?.(spawned)

  const listeningPid = await waitForListener(project.port, projectRoot, timeoutMs)
  if (!listeningPid) {
    terminateProcessGroup(spawned.processGroupId)
    throw new HarnessError(
      "PROJECT_START_TIMEOUT",
      `project did not listen on port ${project.port} within ${timeoutMs / 1000}s`,
      { logFile, pid: child.pid },
    )
  }
  return {
    ...spawned,
    listeningPid,
  }
}

function activeEpiqueryOverride(paths) {
  const state = readJson(paths.epiqueryState, null)
  if (!state || !fs.existsSync(state.overrideFile)) return null
  return state.overrideFile
}

function planOptions(paths, project = null) {
  const glgroupCache = readJson(paths.cacheFile, null)
  return {
    cacheFile: paths.cacheFile,
    cacheIsDevelopment: glgroupCache?.environment === "development",
    committedOverride: paths.committedOverride,
    committedOverrideExists: fs.existsSync(paths.committedOverride),
    composeExists: fs.existsSync(paths.composeFile),
    composeFile: paths.composeFile,
    configRoot: paths.configRoot,
    epiqueryOverride: activeEpiqueryOverride(paths),
    project,
  }
}

function validateConfigRoot(paths) {
  if (!fs.existsSync(paths.configRoot) || !fs.statSync(paths.configRoot).isDirectory()) {
    throw new HarnessError(
      "CONFIG_ROOT_NOT_FOUND",
      `gds.clusterconfig.dev checkout not found: ${paths.configRoot}`,
      null,
      2,
    )
  }
}

function executePlan(plan, context) {
  plan.forEach((operation) => runOperation(operation, context))
}

function composeFileArguments(paths, epiqueryOverride = activeEpiqueryOverride(paths)) {
  return composeFiles({
    committedOverride: paths.committedOverride,
    committedOverrideExists: fs.existsSync(paths.committedOverride),
    composeFile: paths.composeFile,
    epiqueryOverride,
  }).flatMap((file) => ["-f", file])
}

function renderedComposeServices(paths, epiqueryOverride = activeEpiqueryOverride(paths)) {
  const output = commandOutput("docker", [
    "compose",
    ...composeFileArguments(paths, epiqueryOverride),
    "config",
    "--services",
  ], { timeout: 60_000 })
  return output ? output.split("\n").filter(Boolean) : null
}

function verifyHostApp(paths, project) {
  const services = renderedComposeServices(paths)
  if (!services || services.length === 0) {
    throw new HarnessError("COMPOSE_VERIFY_FAILED", "could not render Docker Compose state")
  }
  const name = `${project.service.toLowerCase()}-hostapp`
  if (!services.includes(name)) {
    throw new HarnessError("HOST_APP_MISSING", `generated Compose is missing ${name}`)
  }
  return name
}

async function waitForRoute(service, timeoutMs) {
  const url = `https://local.dev.glgresearch.com/${service}/`
  const deadline = Date.now() + timeoutMs
  while (Date.now() < deadline) {
    const status = commandOutput("curl", [
      "--silent",
      "--show-error",
      "--output",
      "/dev/null",
      "--write-out",
      "%{http_code}",
      "--max-time",
      "5",
      url,
    ], { timeout: 10_000 })
    const code = Number(status)
    if (isAcceptableRouteStatus(code)) return { status: code, url }
    await wait(1000)
  }
  throw new HarnessError(
    "HOST_APP_ROUTE_TIMEOUT",
    `host-app route was not reachable within ${timeoutMs / 1000}s`,
    { url },
  )
}

export function isAcceptableRouteStatus(status) {
  return (status >= 200 && status < 400) || status === 401 || status === 403
}

function validateTemplatesDirectory(templatesDir) {
  if (!fs.existsSync(templatesDir) || !fs.statSync(templatesDir).isDirectory()) {
    throw new HarnessError(
      "TEMPLATES_NOT_FOUND",
      `Epiquery templates directory not found: ${templatesDir}`,
      null,
      2,
    )
  }
  const slug = discoverRepositorySlug(templatesDir)
  if (slug !== "glg/epiquery-templates") {
    throw new HarnessError(
      "INVALID_TEMPLATES_REPOSITORY",
      `expected a glg/epiquery-templates checkout, found ${slug || "no GitHub remote"}`,
      null,
      2,
    )
  }
}

function inspectContainer(name) {
  const inspect = (format) => {
    const result = spawnSync("docker", ["inspect", "--format", format, name], {
      encoding: "utf8",
      maxBuffer: 10 * 1024 * 1024,
      timeout: 30_000,
    })
    if (result.error) {
      throw new HarnessError(
        "DOCKER_INSPECT_FAILED",
        `could not inspect Docker container ${name}: ${result.error.message}`,
      )
    }
    if (result.status !== 0) {
      if (/no such (?:object|container)/i.test(result.stderr || result.stdout)) {
        return null
      }
      throw new HarnessError(
        "DOCKER_INSPECT_FAILED",
        `could not inspect Docker container ${name}`,
        { stderr: redact(result.stderr || result.stdout) },
      )
    }
    return result.stdout.trim()
  }

  const mountsOutput = inspect("{{json .Mounts}}")
  if (mountsOutput == null) return null
  const runningOutput = inspect("{{.State.Running}}")
  if (runningOutput == null) return null
  try {
    return {
      Mounts: JSON.parse(mountsOutput),
      State: { Running: runningOutput === "true" },
    }
  } catch {
    return null
  }
}

function epiqueryContainerState() {
  return Object.fromEntries(
    EPIQUERY_SERVICES.map((service) => {
      const container = inspectContainer(service)
      const mount = container?.Mounts?.find(
        (candidate) => candidate.Destination === "/epiquery-templates",
      )
      return [service, {
        exists: Boolean(container),
        mountSource: mount?.Source ? canonicalPath(mount.Source) : null,
        running: container?.State?.Running === true,
      }]
    }),
  )
}

function verifyEpiqueryMounts(templatesDir) {
  const expected = canonicalPath(templatesDir)
  const containers = epiqueryContainerState()
  const invalid = Object.entries(containers).filter(
    ([, state]) => !state.running || state.mountSource !== expected,
  )
  if (invalid.length > 0) {
    throw new HarnessError(
      "EPIQUERY_MOUNT_VERIFY_FAILED",
      "Epiquery containers are not using the requested template worktree",
      { expected, containers },
    )
  }
  return containers
}

async function waitForDiagnostic(baseUrl, timeoutMs) {
  const url = `${baseUrl.replace(/\/+$/, "")}/diagnostic`
  const deadline = Date.now() + timeoutMs
  while (Date.now() < deadline) {
    const output = commandOutput("curl", [
      "--silent",
      "--show-error",
      "--max-time",
      "5",
      url,
    ], { timeout: 10_000 })
    if (output) {
      try {
        const diagnostic = JSON.parse(output)
        if (diagnostic.message === "ok") return { diagnostic, url }
      } catch {
        // The route may return a proxy response while containers are starting.
      }
    }
    await wait(1000)
  }
  throw new HarnessError(
    "EPIQUERY_DIAGNOSTIC_TIMEOUT",
    `Epiquery diagnostic was not ready within ${timeoutMs / 1000}s`,
    { url },
  )
}

function parseParams(value) {
  try {
    const parsed = JSON.parse(value || "{}")
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) throw new Error()
    return parsed
  } catch {
    throw new HarnessError(
      "INVALID_PARAMS_JSON",
      "--params-json must be a JSON object",
      null,
      2,
    )
  }
}

function resolveTemplateFile(templatesDir, template) {
  if (!template) {
    throw new HarnessError("MISSING_TEMPLATE", "--template is required", null, 2)
  }
  const root = canonicalPath(templatesDir)
  const file = canonicalPath(path.resolve(root, template))
  if (!file.startsWith(`${root}${path.sep}`) || !fs.existsSync(file) || !fs.statSync(file).isFile()) {
    throw new HarnessError(
      "TEMPLATE_NOT_FOUND",
      `template is not a file inside the selected worktree: ${template}`,
      null,
      2,
    )
  }
  return { file, relative: path.relative(root, file) }
}

async function ensureProject(options) {
  const paths = runtimePaths(options)
  validateConfigRoot(paths)
  const projectRoot = canonicalPath(resolvedPath(options.root || process.cwd()))
  const { project, slug } = resolveProject(projectRoot, options, paths)
  const timeoutMs = Number(options.timeout || 90) * 1000
  const context = { dryRun: Boolean(options.dryRun), operations: [] }
  const stateFile = projectStatePath(paths, projectRoot)
  const existingState = readJson(stateFile, null)
  if (
    existingState &&
    (
      existingState.service !== project.service ||
      existingState.port !== project.port ||
      existingState.securityMode !== project.securityMode
    )
  ) {
    throw new HarnessError(
      "PROJECT_CONFIG_CONFLICT",
      "this worktree already has different harness state; stop it before reconfiguring",
      {
        existing: {
          port: existingState.port,
          securityMode: existingState.securityMode,
          service: existingState.service,
        },
        requested: {
          port: project.port,
          securityMode: project.securityMode,
          service: project.service,
        },
      },
      3,
    )
  }
  const plan = buildProjectEnsurePlan(planOptions(paths, project))

  const pendingState = {
    command: project.command || null,
    createdAt: existingState?.createdAt || new Date().toISOString(),
    hostAppService: `${project.service}-hostapp`,
    owned: false,
    pid: null,
    port: project.port,
    root: projectRoot,
    securityMode: project.securityMode,
    service: project.service,
    slug,
    status: "pending",
  }
  if (!context.dryRun) writeJson(stateFile, pendingState)
  executePlan(plan, context)
  const processState = await ensureProjectProcess({
    context,
    noStart: Boolean(options.noStart),
    onSpawn: (spawned) => writeJson(stateFile, {
      ...pendingState,
      ...spawned,
    }),
    project,
    projectRoot,
    stateFile,
    timeoutMs,
  })

  if (context.dryRun) {
    return {
      ok: true,
      action: "project.ensure",
      dryRun: true,
      operations: context.operations,
      project: { ...project, root: projectRoot, slug },
    }
  }

  writeJson(stateFile, {
    ...pendingState,
    logFile: processState.logFile || existingState?.logFile || null,
    listeningPid: processState.listeningPid || null,
    owned: processState.owned,
    pid: processState.pid,
    processGroupId: processState.processGroupId,
    processIdentity: processState.processIdentity,
  })
  const hostAppService = verifyHostApp(paths, project)
  const route = await waitForRoute(project.service, timeoutMs)
  const state = {
    ...pendingState,
    hostAppService,
    logFile: processState.logFile || existingState?.logFile || null,
    listeningPid: processState.listeningPid || null,
    owned: processState.owned,
    pid: processState.pid,
    processGroupId: processState.processGroupId,
    processIdentity: processState.processIdentity,
    route,
    status: "ready",
    updatedAt: new Date().toISOString(),
  }
  writeJson(stateFile, state)
  return {
    ok: true,
    action: "project.ensure",
    process: {
      listeningPid: processState.listeningPid || null,
      owned: processState.owned,
      pid: processState.pid,
      processGroupId: processState.processGroupId,
      reused: processState.reused,
    },
    project: state,
  }
}

async function ensureEpiquery(options) {
  const paths = runtimePaths(options)
  validateConfigRoot(paths)
  if (!options.templatesDir) {
    throw new HarnessError("MISSING_TEMPLATES_DIR", "--templates-dir is required", null, 2)
  }
  const templatesDir = canonicalPath(resolvedPath(options.templatesDir))
  validateTemplatesDirectory(templatesDir)
  const timeoutMs = Number(options.timeout || 90) * 1000
  const context = { dryRun: Boolean(options.dryRun), operations: [] }
  const existing = readJson(paths.epiqueryState, null)
  if (
    existing &&
    canonicalPath(existing.templatesDir) !== templatesDir &&
    !options.replace
  ) {
    throw new HarnessError(
      "EPIQUERY_IN_USE",
      "another template worktree is active; pass --replace only when replacing it is intended",
      { activeTemplatesDir: existing.templatesDir, requestedTemplatesDir: templatesDir },
      3,
    )
  }

  const previousContainers = context.dryRun ? {} : epiqueryContainerState()
  if (!context.dryRun) {
    fs.mkdirSync(paths.cacheRoot, { recursive: true })
    fs.writeFileSync(paths.epiqueryOverride, renderEpiqueryOverride(templatesDir), {
      mode: 0o600,
    })
    writeJson(paths.epiqueryState, {
      baseUrl: "https://local.dev.glgresearch.com/epi-general-internal",
      createdAt: existing?.createdAt || new Date().toISOString(),
      overrideFile: paths.epiqueryOverride,
      previousContainers,
      status: "pending",
      templatesDir,
    })
  }
  const plan = buildEpiqueryEnsurePlan({
    ...planOptions(paths),
    epiqueryOverride: paths.epiqueryOverride,
  })
  executePlan(plan, context)

  if (context.dryRun) {
    return {
      ok: true,
      action: "epiquery.ensure",
      dryRun: true,
      operations: context.operations,
      overrideFile: paths.epiqueryOverride,
      templatesDir,
    }
  }

  const containers = verifyEpiqueryMounts(templatesDir)
  const baseUrl = "https://local.dev.glgresearch.com/epi-general-internal"
  const diagnostic = await waitForDiagnostic(baseUrl, timeoutMs)
  const state = {
    baseUrl,
    containers,
    createdAt: new Date().toISOString(),
    diagnosticUrl: diagnostic.url,
    overrideFile: paths.epiqueryOverride,
    previousContainers,
    status: "ready",
    templatesDir,
    updatedAt: new Date().toISOString(),
  }
  writeJson(paths.epiqueryState, state)
  return { ok: true, action: "epiquery.ensure", epiquery: state }
}

async function queryEpiquery(options) {
  const paths = runtimePaths(options)
  let state = readJson(paths.epiqueryState, null)
  let ensurePlan = null
  if (options.templatesDir) {
    ensurePlan = await ensureEpiquery(options)
    state = options.dryRun
      ? {
          baseUrl: "https://local.dev.glgresearch.com/epi-general-internal",
          status: "ready",
          templatesDir: canonicalPath(resolvedPath(options.templatesDir)),
        }
      : readJson(paths.epiqueryState, null)
  }
  if (!state || state.status !== "ready") {
    throw new HarnessError(
      "EPIQUERY_NOT_READY",
      "no ready harness-managed Epiquery worktree is active; run epiquery ensure first",
      null,
      3,
    )
  }
  if (!options.connection) {
    throw new HarnessError("MISSING_CONNECTION", "--connection is required", null, 2)
  }
  const template = resolveTemplateFile(state.templatesDir, options.template)
  const sql = fs.readFileSync(template.file, "utf8")
  if (requiresWriteAuthorization(template.relative, sql) && !options.allowWrite) {
    throw new HarnessError(
      "WRITE_NOT_AUTHORIZED",
      "template is legacy Mustache or contains write/DDL SQL; pass --allow-write only with explicit authorization",
      { template: template.relative },
      3,
    )
  }
  const params = parseParams(options.paramsJson)
  const url = buildEpiqueryUrl(state.baseUrl, options.connection, template.relative)
  if (options.dryRun) {
    return {
      ok: true,
      action: "epiquery.query",
      dryRun: true,
      connection: options.connection,
      ensure: ensurePlan,
      template: template.relative,
      url,
    }
  }

  fs.mkdirSync(paths.cacheRoot, { recursive: true })
  const paramsFile = path.join(paths.cacheRoot, `query-${process.pid}.json`)
  fs.writeFileSync(paramsFile, JSON.stringify(params), { mode: 0o600 })
  let result
  try {
    result = spawnSync("curl", [
      "--silent",
      "--show-error",
      "--max-time",
      String(options.timeout || 90),
      "--request",
      "POST",
      "--header",
      "Content-Type: application/json",
      "--data-binary",
      `@${paramsFile}`,
      "--write-out",
      "\n%{http_code}",
      url,
    ], {
      encoding: "utf8",
      maxBuffer: 20 * 1024 * 1024,
      timeout: Number(options.timeout || 90) * 1000 + 5000,
    })
  } finally {
    fs.rmSync(paramsFile, { force: true })
  }
  if (result.error || result.status !== 0) {
    throw new HarnessError(
      "EPIQUERY_REQUEST_FAILED",
      "curl could not complete the Epiquery request",
      { stderr: redact(result.stderr || result.error?.message) },
    )
  }
  const response = parseCurlResponse(result.stdout)
  let parsed
  try {
    parsed = JSON.parse(response.body)
  } catch {
    throw new HarnessError(
      "INVALID_EPIQUERY_RESPONSE",
      "Epiquery did not return JSON",
      { httpStatus: response.status },
    )
  }
  const errors = findEpiqueryErrors(parsed)
  if (response.status >= 400 || errors.length > 0) {
    throw new HarnessError(
      "EPIQUERY_QUERY_ERROR",
      "Epiquery returned a query error",
      { errors, httpStatus: response.status, template: template.relative },
    )
  }

  return {
    ok: true,
    action: "epiquery.query",
    connection: options.connection,
    httpStatus: response.status,
    response: options.summaryOnly ? undefined : parsed,
    resultCount: Array.isArray(parsed) ? parsed.length : null,
    template: template.relative,
  }
}

async function stopProject(options) {
  const paths = runtimePaths(options)
  const projectRoot = canonicalPath(resolvedPath(options.root || process.cwd()))
  const stateFile = projectStatePath(paths, projectRoot)
  const state = readJson(stateFile, null)
  if (!state) {
    return { ok: true, action: "project.stop", changed: false, projectRoot }
  }

  const context = { dryRun: Boolean(options.dryRun), operations: [] }
  let processStopped = false
  let ownershipLost = false
  const identityMatches = sameProcessIdentity(
    state.processIdentity,
    processIdentity(state.pid),
  )
  if (state.owned && state.processGroupId && identityMatches) {
    context.operations.push({
      command: "kill",
      args: ["--", `-${state.processGroupId}`],
      kind: "project-process",
    })
    if (!context.dryRun) {
      terminateProcessGroup(state.processGroupId)
      if (!await waitForProcessGroupExit(state.processGroupId)) {
        throw new HarnessError(
          "PROCESS_STOP_FAILED",
          "the harness-owned process group did not stop; cleanup journal was preserved",
          { processGroupId: state.processGroupId },
        )
      }
      processStopped = true
    }
  } else if (state.owned) {
    ownershipLost = true
  }

  let hostAppInCompose = false
  if (fs.existsSync(paths.composeFile)) {
    const services = renderedComposeServices(paths)
    if (!services) {
      throw new HarnessError(
        "CLEANUP_VERIFY_FAILED",
        "could not inspect Compose state; cleanup journal was preserved",
      )
    }
    hostAppInCompose = services.includes(state.hostAppService)
  }
  if (hostAppInCompose) {
    runOperation({
      command: "docker",
      args: [
        "compose",
        ...composeFileArguments(paths),
        "stop",
        state.hostAppService,
      ],
    }, context)
  } else if (inspectContainer(state.hostAppService)?.State?.Running) {
    runOperation({
      command: "docker",
      args: ["stop", state.hostAppService],
    }, context)
  }
  if (!context.dryRun) fs.rmSync(stateFile, { force: true })
  return {
    ok: true,
    action: "project.stop",
    changed: true,
    dryRun: context.dryRun || undefined,
    operations: context.dryRun ? context.operations : undefined,
    ownershipLost,
    processStopped,
    projectRoot,
  }
}

function stopEpiquery(options) {
  const paths = runtimePaths(options)
  const state = readJson(paths.epiqueryState, null)
  if (!state) return { ok: true, action: "epiquery.stop", changed: false }

  const context = { dryRun: Boolean(options.dryRun), operations: [] }
  let existingServices = []
  if (fs.existsSync(paths.composeFile)) {
    existingServices = renderedComposeServices(paths, state.overrideFile)
    if (!existingServices) {
      throw new HarnessError(
        "CLEANUP_VERIFY_FAILED",
        "could not inspect Compose state; Epiquery cleanup journal was preserved",
      )
    }
  }
  const epiqueryServices = EPIQUERY_SERVICES.filter((service) =>
    existingServices.includes(service),
  )
  if (epiqueryServices.length > 0) {
    runOperation({
      command: "docker",
      args: [
        "compose",
        ...composeFileArguments(paths, state.overrideFile),
        "stop",
        ...epiqueryServices,
      ],
    }, context)
  } else {
    const runningContainers = EPIQUERY_SERVICES.filter(
      (service) => inspectContainer(service)?.State?.Running,
    )
    if (runningContainers.length > 0) {
      runOperation({
        command: "docker",
        args: ["stop", ...runningContainers],
      }, context)
    }
  }
  if (!context.dryRun) {
    fs.rmSync(state.overrideFile, { force: true })
    fs.rmSync(paths.epiqueryState, { force: true })
  }
  return {
    ok: true,
    action: "epiquery.stop",
    changed: true,
    dryRun: context.dryRun || undefined,
    operations: context.dryRun ? context.operations : undefined,
  }
}

function harnessStatus(options) {
  const paths = runtimePaths(options)
  const projects = []
  if (fs.existsSync(paths.projectStateDir)) {
    for (const entry of fs.readdirSync(paths.projectStateDir)) {
      if (!entry.endsWith(".json")) continue
      const state = readJson(path.join(paths.projectStateDir, entry), null)
      if (!state) continue
      projects.push({
        ...state,
        processAlive: Boolean(
          listenerPids(state.port).find(
            (pid) =>
              belongsToProject(pid, state.root) &&
              processGroupId(pid) === state.processGroupId,
          ),
        ),
      })
    }
  }
  const epiquery = readJson(paths.epiqueryState, null)
  return {
    ok: true,
    action: "status",
    composeFile: paths.composeFile,
    epiquery: epiquery
      ? { ...epiquery, currentContainers: epiqueryContainerState() }
      : null,
    projects,
  }
}

async function dispatch(parsed) {
  if (parsed.help) return { help: HELP }
  const { action, domain, options } = parsed
  const paths = runtimePaths(options)

  if (domain === "status") return harnessStatus(options)
  const execute = async () => {
    if (domain === "project" && action === "ensure") return ensureProject(options)
    if (domain === "project" && action === "stop") return stopProject(options)
    if (domain === "epiquery" && action === "ensure") return ensureEpiquery(options)
    if (domain === "epiquery" && action === "query") return queryEpiquery(options)
    if (domain === "epiquery" && action === "stop") return stopEpiquery(options)
    throw new HarnessError("INVALID_COMMAND", "unknown harness command", null, 2)
  }
  if (options.dryRun) return execute()
  return withLock(paths, execute)
}

async function main() {
  let pretty = false
  try {
    const parsed = parseArguments(process.argv.slice(2))
    pretty = Boolean(parsed.options?.pretty)
    const result = await dispatch(parsed)
    if (result.help) {
      process.stdout.write(`${result.help}\n`)
      return
    }
    process.stdout.write(`${JSON.stringify(result, null, pretty ? 2 : 0)}\n`)
  } catch (error) {
    const harnessError =
      error instanceof HarnessError
        ? error
        : new HarnessError("UNEXPECTED_ERROR", error.message || String(error))
    process.stderr.write(`${JSON.stringify({
      ok: false,
      error: {
        code: harnessError.code,
        details: harnessError.details,
        message: harnessError.message,
      },
    }, null, pretty ? 2 : 0)}\n`)
    process.exitCode = harnessError.exitCode
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === SCRIPT_PATH) {
  await main()
}
