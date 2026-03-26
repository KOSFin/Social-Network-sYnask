const baseUrl = process.env.API_HEALTHCHECK_URL

if (!baseUrl) {
  process.exit(0)
}

const requiredServices = ['identity', 'content', 'social_graph', 'activity', 'moderation', 'ai']

async function assertOk(path) {
  const response = await fetch(`${baseUrl}${path}`)
  if (!response.ok) {
    throw new Error(`Request failed: ${path} -> ${response.status}`)
  }
  return response.json()
}

const health = await assertOk('/health')
if (health.status !== 'ok') {
  throw new Error('Gateway /health returned invalid payload')
}

const services = await assertOk('/internal/services')
for (const serviceName of requiredServices) {
  if (!services[serviceName]?.base_url) {
    throw new Error(`Service ${serviceName} missing in /internal/services response`)
  }
}

console.log('[preflight] API smoke checks passed')
