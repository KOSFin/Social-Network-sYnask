import { spawn } from 'node:child_process'

const steps = [
  { name: 'Install dependencies', cmd: 'npm', args: ['install', '--no-audit', '--no-fund'] },
  { name: 'Run eslint', cmd: 'npm', args: ['run', 'lint'] },
  { name: 'Run unit tests', cmd: 'npm', args: ['run', 'test:run'] },
  { name: 'Build frontend', cmd: 'npm', args: ['run', 'build'] },
]

function runStep(step) {
  return new Promise((resolve, reject) => {
    console.log(`\n[preflight] ${step.name}`)
    const child = spawn(step.cmd, step.args, { stdio: 'inherit', shell: process.platform === 'win32' })

    child.on('close', (code) => {
      if (code === 0) {
        resolve()
        return
      }
      reject(new Error(`${step.name} failed with exit code ${code}`))
    })
  })
}

for (const step of steps) {
  await runStep(step)
}

if (process.env.API_HEALTHCHECK_URL) {
  console.log('\n[preflight] Running API smoke checks')
  await import('./api-smoke.mjs')
}

console.log('\n[preflight] Frontend preflight completed successfully')
