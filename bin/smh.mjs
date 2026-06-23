#!/usr/bin/env node
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const [,, command, projectName] = process.argv

if (command !== 'init' || !projectName) {
  console.error('Usage: smh init <project-name>')
  process.exit(1)
}

const harnessRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)))
const templatesDir = path.join(harnessRoot, 'templates')

const targetDir = path.join(process.cwd(), projectName)
const orchDir  = path.join(targetDir, `${projectName}-orch`)
const codeDir  = path.join(targetDir, `${projectName}-code`)

if (fs.existsSync(targetDir)) {
  console.error(`Error: '${projectName}/' already exists in ${process.cwd()}`)
  process.exit(1)
}

fs.mkdirSync(orchDir, { recursive: true })
fs.mkdirSync(path.join(codeDir, 'specs', 'done'), { recursive: true })

fs.copyFileSync(path.join(templatesDir, 'orch', 'CLAUDE.md'),   path.join(orchDir, 'CLAUDE.md'))
fs.copyFileSync(path.join(templatesDir, 'orch', '.gitignore'),  path.join(orchDir, '.gitignore'))
fs.copyFileSync(path.join(templatesDir, 'code', 'CLAUDE.md'),   path.join(codeDir, 'CLAUDE.md'))
fs.copyFileSync(path.join(templatesDir, 'code', '.gitignore'),  path.join(codeDir, '.gitignore'))

const configTemplate = fs.readFileSync(path.join(harnessRoot, 'config.template.yaml'), 'utf8')
fs.writeFileSync(path.join(orchDir, 'config.yaml'), configTemplate.replaceAll('my-project', projectName))

console.log('')
console.log(`✓ ${projectName}/`)
console.log(`  ├── ${projectName}-orch/`)
console.log(`  │   ├── CLAUDE.md`)
console.log(`  │   └── config.yaml  ← fill in: Trello board ID and code repo path`)
console.log(`  └── ${projectName}-code/`)
console.log(`      ├── CLAUDE.md`)
console.log(`      └── specs/`)
console.log('')
console.log(`Next: open ${projectName}/${projectName}-orch/ in Claude Code and run: setup-trello https://trello.com/b/xxxxx/board-name`)
